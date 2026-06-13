# Produce a safetensors model file out of multiple inputs
# python convert.py model.safetensors --config config.json --models file1.bin file2.bin ...

# Based on convert.py from calm ( https://github.com/zeux/calm ), adapted to and extended for PasLLM LLM engine 

import argparse
import base64
import json
import os.path
import safetensors
import safetensors.torch
import torch
import struct
import numpy as np 
# optionally imports sentencepiece below when converting models without HF tokenizer.json

argp = argparse.ArgumentParser()
argp.add_argument("output", type=str)
argp.add_argument("input", type=str, nargs="?")
argp.add_argument("--config", type=str)
argp.add_argument("--tokenizer", type=str)
argp.add_argument("--tokenizerconfig", type=str)
argp.add_argument("--chattemplate", type=str)
argp.add_argument("--models", type=str, nargs="+")
argp.add_argument("--dtype", type=str, default="q80", choices=["bf16", "fp16", "fp8", "q80", "q40nl", "q41nl", "q42nl", "q43nl", "q40", "q7f8", "q6f16", "q3f8"])
argp.add_argument("--hf", type=str, help="huggingface model path")
argp.add_argument("--cpu", action="store_true", help="use CPU for conversion, useful for debugging")
# Q42NL/Q43NL shared optimization parameters
argp.add_argument("--q4xnl_method", type=str, default="gradient", 
                  choices=["gradient", "grid", "coarse_fine"],
                  help="Q42NL/Q43NL optimization: gradient (fast, 6x, 99.7%%), grid (slow, perfect), coarse_fine (balanced, 1.5x, 99.97%%)")
argp.add_argument("--q4xnl_gd_iterations", type=int, default=5,
                  help="Gradient descent iterations for Q42NL/Q43NL (default: 5, best quality: 20, fast: 5)")
argp.add_argument("--q4xnl_gd_lr", type=float, default=0.3,
                  help="Learning rate for Q42NL/Q43NL gradient descent (default: 0.3, best quality: 0.1, fast: 0.3)")
# Optional inference parameters
argp.add_argument("--temperature", type=float, help="temperature for inference (default: model specific)")
argp.add_argument("--top_p", type=float, help="top_p for inference (default: model specific)")
argp.add_argument("--penalty_last_n", type=int, help="penalty_last_n for inference (default: model specific)")
argp.add_argument("--penalty_repeat", type=float, help="penalty_repeat for inference (default: model specific)")
argp.add_argument("--penalty_frequency", type=float, help="penalty_frequency for inference (default: model specific)")
argp.add_argument("--penalty_presence", type=float, help="penalty_presence for inference (default: model specific)")
args = argp.parse_args()

if args.cpu:
    torch.set_default_device("cpu")
    torch.cuda.is_available = lambda: False
    # torch.set_default_tensor_type(torch.FloatTensor) # deprecated in torch 2.1, use torch.set_default_dtype instead
    torch.set_default_dtype(torch.float32)

# First check if input is a HuggingFace model path, if so, we will load the config, model and tokenizer from there, and then convert it
if args.hf is not None:
    from huggingface_hub import snapshot_download
    from transformers import AutoConfig, AutoTokenizer  #, AutoModelForCausalLM

    # download model folder from HuggingFace, excluding .bin files (assume the model contains safetensors)
    #ignore_patterns = ["*.bin", "*.pth", "*.pt", "*.gguf", "consolidated.safetensors"] if not args.all else []
    #huggingface_hub.snapshot_download(repo_id=args.repo, local_dir=args.output, ignore_patterns=ignore_patterns)
                                                                                                                         
    # download the model files
    snapshot_download(args.hf, allow_patterns=["*.json", "*.model", "*.safetensors", "*.bin"])

    # load config
    config = AutoConfig.from_pretrained(args.hf)
    args.config = config._name_or_path + "/config.json"

    # load tokenizer
    tokenizer = AutoTokenizer.from_pretrained(args.hf)
    args.tokenizer = tokenizer._name_or_path + "/tokenizer.json"

    # load tokenizer config, but only if it exists
    if os.path.exists(os.path.join(args.hf, "tokenizer_config.json")):
        args.tokenizerconfig = os.path.join(args.hf, "tokenizer_config.json")

    # load models
    args.models = [os.path.join(args.hf, fn) for fn in os.listdir(args.hf) if fn.endswith(".safetensors") or fn.endswith(".bin")]

if args.input is not None:
    # assume input is a directory with HuggingFace layout
    if args.config is None:
        args.config = os.path.join(args.input, "config.json")
        if not os.path.exists(args.config):
            argp.error("no config.json found in {}".format(args.input))
    if args.tokenizer is None:
        args.tokenizer = os.path.join(args.input, "tokenizer.json")
        if not os.path.exists(args.tokenizer):
            args.tokenizer = os.path.join(args.input, "tokenizer.model")
        if not os.path.exists(args.tokenizer):
            argp.error("no tokenizer.json or tokenizer.model found in {}".format(args.input))
    if args.tokenizerconfig is None:
        if os.path.exists(os.path.join(args.input, "tokenizer_config.json")):
            args.tokenizerconfig = os.path.join(args.input, "tokenizer_config.json")
    if args.models is None:
        files = os.listdir(args.input)
        args.models = [os.path.join(args.input, fn) for fn in files if os.path.splitext(fn)[1] == ".safetensors"]
        if len(args.models) == 0:
            args.models = [os.path.join(args.input, fn) for fn in files if os.path.splitext(fn)[1] == ".bin"]
        if len(args.models) == 0:
            argp.error("no .safetensors or .bin files found in {}".format(args.input))
elif args.config is None or args.models is None:
    argp.error("arguments --config, --tokenizer and --models are required unless argument input is specified")

# Try to infer tokenizer_config.json from tokenizer.json
if args.tokenizerconfig is None:
    if os.path.exists(args.tokenizer) and args.tokenizer.endswith("tokenizer.json"):
        args.tokenizerconfig = args.tokenizer.replace("tokenizer.json", "tokenizer_config.json")
        if not os.path.exists(args.tokenizerconfig):
            args.tokenizerconfig = None # If not found, set to None

# The same for chat_template.jinja, which is also optional
if args.chattemplate is None:
    if os.path.exists(args.tokenizer) and args.tokenizer.endswith("tokenizer.json"):        
        args.chattemplate = args.tokenizer.replace("tokenizer.json", "chat_template.jinja")
        if not os.path.exists(args.chattemplate):
            args.chattemplate = None # If not found, set to None

with open(args.config, "r") as f:
    config = json.load(f)

metadata = {}
tensors = {}
quantizedtensors = {} # a bool map for quantized tensors, if True, the tensor is quantized

allow_noninterleaved = False # for future

arch = config["architectures"][0]
arch_remap = {
    "LlamaForCausalLM": "llama", 
    "MistralForCausalLM": "mistral", 
    "MixtralForCausalLM": "mixtral", 
    "Qwen2ForCausalLM": "qwen2", 
    "Qwen3ForCausalLM": "qwen3",
    "Qwen3MoeForCausalLM": "qwen3moe",
    "OLMoForCausalLM": "olmo", 
    "GemmaForCausalLM": "gemma", 
    "Gemma2ForCausalLM": "gemma2", 
    "Gemma3ForCausalLM": "gemma3", 
    "MiniCPMForCausalLM": "minicpm", 
    "CohereForCausalLM": "cohere", 
    "InternLM2ForCausalLM": "internlm2", 
    "DbrxForCausalLM": "dbrx", 
    "XverseForCausalLM": "xverse", 
    "Phi3ForCausalLM": "phi3", 
    "KPhi3ForCausalLM": "kphi3", 
    "OlmoeForCausalLM": "olmoe",
    "SmolLM3ForCausalLM": "smollm3",
    "ApertusForCausalLM": "apertus"
}
assert arch in arch_remap, "Unsupported architecture: {}; must be one of: {}".format(arch, list(arch_remap.keys()))
arch = arch_remap[arch]

metadata["palm"] = "true" # this is a palm model, so we set the metadata accordingly, for indicating that this is compatible with the PALM LLM engine (old name)
metadata["pasllm"] = "true" # this is a pasllm model, so we set the metadata accordingly, for indicating that this is compatible with the PasLLM LLM engine
metadata["arch"] = arch
metadata["dtype"] = args.dtype.upper() # convert.py will always produce a safetensors file with dtype in uppercase in the metadata

if arch in ["llama", "mistral", "mixtral", "qwen2", "qwen3", "qwen3moe", "gemma", "gemma2", "gemma3", "minicpm", "cohere", "internlm2", "xverse", "phi3", "kphi3", "olmoe", "smollm3", "apertus" ]:
    metadata["dim"] = config["hidden_size"]
    metadata["hidden_dim"] = config["intermediate_size"]
    if arch in ["mixtral", "qwen3moe", "minicpm", "olmoe"]: 
        if "moe_intermediate_size" in config:
            # If the model has a separate moe_intermediate_size, use it as expert hidden dimension
            metadata["expert_hidden_dim"] = config["moe_intermediate_size"]
        else:
            # Otherwise, use the intermediate size as expert hidden dimension as well
            metadata["expert_hidden_dim"] = config["intermediate_size"] 
    metadata["head_dim"] = config.get("head_dim", config["hidden_size"] // config["num_attention_heads"])
    metadata["n_layers"] = config["num_hidden_layers"]
    metadata["n_heads"] = config["num_attention_heads"]
    metadata["n_kv_heads"] = config.get("num_key_value_heads", config["num_attention_heads"])
    metadata["vocab_size"] = config["vocab_size"]
    metadata["max_seq_len"] = config["max_position_embeddings"]
    #metadata["max_seq_len"] = 2048 if arch == "phi3" else config["max_position_embeddings"]
    metadata["bos_token_id"] = -1 if arch in ["qwen2", "qwen3", "qwen3moe", "olmoe"] else config["bos_token_id"]
    metadata["eos_token_id"] = [32000, 32007] if arch in ["phi3", "kphi3"] else config["eos_token_id"]
    metadata["rope_theta"] = config.get("rope_theta", 10000.0)
    metadata["rotary_dim"] = int(metadata["head_dim"] * config.get("partial_rotary_factor", 1))
    metadata["norm_eps"] = config["layer_norm_eps"] if arch == "cohere" else config["rms_norm_eps"]
    metadata["norm_type"] = "layernorm_par" if arch in ["cohere", "apertus"] else "rmsnorm"

    # attention_bias
    if "attention_bias" in config:
        if config["attention_bias"] is not None:
            metadata["attention_bias"] = config["attention_bias"]

    # attention_dropout
    if "attention_dropout" in config:
        if config["attention_dropout"] is not None:
            metadata["attention_dropout"] = float(config["attention_dropout"])

    # Query-Key normalization
    if "qk_norm" in config:
        if config["qk_norm"] is not None:
            metadata["qk_norm"] = config["qk_norm"]

    # optional attn_logit_softcapping and final_logit_softcapping with null check
    if "attn_logit_softcapping" in config:
        if config["attn_logit_softcapping"] is not None:
            metadata["attn_logit_softcapping"] = float(config["attn_logit_softcapping"])
    if "final_logit_softcapping" in config:
        if config["final_logit_softcapping"] is not None:
            metadata["final_logit_softcapping"] = float(config["final_logit_softcapping"])

    # Activation function
    _hidden = config.get("hidden_act", config.get("hidden_activation"))
    if _hidden in ("gelu_pytorch_tanh", "gelu_pytorch", "gelu_tanh"):
        _hidden = "gelu"
    assert _hidden in ("gelu", "silu", "xielu", "relu")
    metadata["act_type"] = _hidden

    if "query_pre_attn_scalar" in config:
        metadata["query_pre_attn_scalar"] = float(config["query_pre_attn_scalar"])

    # ----- PasLLM SWA METADATA (exactly what PasLLM.pas loads) -----
    n_layers = int(config["num_hidden_layers"])
    max_seq_len = int(metadata["max_seq_len"])

    # Map HF "layer_types" → PALM "attention_types"
    lt = config.get("layer_types")
    if isinstance(lt, list):
        att_types = []
        i = 0
        while i < n_layers:
            t = lt[i] if i < len(lt) else "full_attention"
            if t == "sliding_attention":
                att_types.append("sliding_attention")
            elif t == "full_attention":
                att_types.append("full_attention")
            elif t in ("none", "no_attention"):
                att_types.append("no_attention")
            else:
                att_types.append("full_attention")
            i += 1
        metadata["attention_types"] = att_types

        # Derive per-layer sliding_window_sizes:
        # Use global 'sliding_window' if present; otherwise default each to max_seq_len
        # Check for null 
        if "sliding_window" not in config:
            global_win = max_seq_len
        else:
            global_win = config.get("sliding_window", max_seq_len)
        try:
            global_win = int(global_win)
        except Exception:
            global_win = max_seq_len
        if global_win < 1 or global_win > max_seq_len:
            global_win = max_seq_len

        sizes = []
        i = 0
        while i < n_layers:
            if att_types[i] == "sliding_attention":
                sizes.append(global_win)
            else:
                sizes.append(max_seq_len)
            i += 1
        metadata["sliding_window_sizes"] = sizes        

    # Qwen3 and OLMoE uses QK normalization, so we need to set the metadata accordingly
    if arch in ["qwen3", "qwen3moe", "olmoe"]:
        metadata["qk_rmsnorm"] = "true" 

    if ("post_norm" in config) and (config["post_norm"] is not None):
       metadata["post_norm"] = config["post_norm"]

    if (arch in ["qwen3", "qwen3moe", "apertus"]) and allow_noninterleaved:
        # These use non-interleaved rotary embeddings, so we need to set the metadata accordingly       
        metadata["qk_rope_noninterleaved"] = "true" 
        metadata["rope_noninterleaved"] = "true" 
                     
    # moe
    if arch in ["mixtral"]:
        metadata["n_experts"] = config["num_local_experts"]
        metadata["n_experts_active"] = config["num_experts_per_tok"]
    elif arch in ["minicpm"] and "num_experts" in config:
        metadata["n_experts"] = config["num_experts"]
        metadata["n_experts_active"] = config["num_experts_per_tok"]
    elif arch in ["qwen3moe"]:
        metadata["n_experts"] = config["num_experts"]
        metadata["n_experts_active"] = config["num_experts_per_tok"]
    elif arch in ["olmoe"]:
        metadata["n_experts"] = config["num_experts"]
        metadata["n_experts_active"] = config["num_experts_per_tok"]

    # NoPE support
    if arch in ["smollm3"]:
    
        # no_rope_layers (list[int], optional) — List with at least the same length as the number of layers in the model. A 1 at an index position indicates that the corresponding layer will use RoPE, while a 0 indicates that it’s a NoPE layer.
        if "no_rope_layers" in config:
            metadata["no_rope_layers"] = config["no_rope_layers"]
        else:
            metadata["no_rope_layers"] = None

        # We can use no_rope_layer_interval to create a no_rope_layers list if it is not provided
        if ("no_rope_layer_interval" in config) and ((metadata["no_rope_layers"] is None) or (len(metadata["no_rope_layers"]) == 0)):
            # no_rope_layer_interval (int, optional, defaults to 4) — If no_rope_layers is None, it will be created using a NoPE layer every no_rope_layer_interval layers.
            no_rope_layer_interval = config.get("no_rope_layer_interval", 4)
            metadata["no_rope_layers"] = [0 if i % no_rope_layer_interval == 0 else 1 for i in range(config["num_hidden_layers"])]

elif arch == "olmo":
    metadata["dim"] = config["d_model"]
    metadata["hidden_dim"] = (config["mlp_hidden_size"] or config["d_model"] * config["mlp_ratio"]) // 2
    metadata["n_layers"] = config["n_layers"]
    metadata["n_heads"] = config["n_heads"]
    metadata["n_kv_heads"] = config["n_heads"]
    metadata["vocab_size"] = config["embedding_size"]
    metadata["max_seq_len"] = config["max_sequence_length"]
    metadata["bos_token_id"] = -1
    metadata["eos_token_id"] = config["eos_token_id"]
    metadata["rope_theta"] = 10000.0
    metadata["rotary_dim"] = config["d_model"] // config["n_heads"]
    metadata["norm_eps"] = 1e-5
    metadata["norm_type"] = "layernorm"

    assert config["activation_type"] == "swiglu"
    metadata["act_type"] = "silu"

    if config.get("clip_qkv", None):
        metadata["qkv_clip"] = config["clip_qkv"]
elif arch == "dbrx":
    metadata["dim"] = config["d_model"]
    metadata["hidden_dim"] = config["ffn_config"]["ffn_hidden_size"]
    metadata["head_dim"] = config["d_model"] // config["n_heads"]
    metadata["n_layers"] = config["n_layers"]
    metadata["n_heads"] = config["n_heads"]
    metadata["n_kv_heads"] = config["attn_config"]["kv_n_heads"]
    metadata["vocab_size"] = config["vocab_size"]
    metadata["max_seq_len"] = config["max_seq_len"]
    metadata["bos_token_id"] = -1
    metadata["eos_token_id"] = 100257
    metadata["rope_theta"] = config["attn_config"]["rope_theta"]
    metadata["rotary_dim"] = config["d_model"] // config["n_heads"]
    metadata["norm_eps"] = 1e-5
    metadata["norm_type"] = "layernorm"
    metadata["act_type"] = "silu"
    metadata["n_experts"] = config["ffn_config"]["moe_num_experts"]
    metadata["n_experts_active"] = config["ffn_config"]["moe_top_k"]
    metadata["qkv_clip"] = config["attn_config"]["clip_qkv"]

# this is a horrible gpt-2 unicode byte encoder hack from https://github.com/openai/gpt-2/blob/master/src/encoder.py#L9
# this has poisoned all HF tokenizer configs that use ByteLevel decoder/preprocessor
# as a result we get crazy UTF-8-as-bytes-as-UTF8 in the tokenizer data that we need to convert back
def gpt2_bytes_to_unicode():
    bs = list(range(ord("!"), ord("~")+1))+list(range(ord("¡"), ord("¬")+1))+list(range(ord("®"), ord("ÿ")+1))
    cs = bs[:]
    n = 0
    for b in range(2**8):
        if b not in bs:
            bs.append(b)
            cs.append(2**8+n)
            n += 1
    cs = [chr(n) for n in cs]
    return dict(zip(bs, cs))

# load chat_template from tokenizer config
chat_template = None
bos_token_value = None
eos_token_value = None
if args.tokenizerconfig is not None:
    with open(args.tokenizerconfig, "r") as f:
        tokenizer_config = json.load(f)
        chat_template = tokenizer_config.get("chat_template", None)
        bos_token_value = tokenizer_config.get("bos_token", None)
        eos_token_value = tokenizer_config.get("eos_token", None)

# load chat_template, when exists, and override the tokenizer config chat_template
if args.chattemplate is not None:
    with open(args.chattemplate, "r") as f:
        chat_template = f.read()

# load tokenizer model
original_vocab_size = metadata["vocab_size"]  # preserve for legacy compatibility
tokens = [""] * metadata["vocab_size"]
scores = [0] * metadata["vocab_size"]
tokens_gpt2 = False

ext = os.path.splitext(args.tokenizer)[1]
if ext == ".json":
    with open(args.tokenizer, "r") as f:
        tokenizer = json.load(f)

    vocab = tokenizer["model"]["vocab"]
    tokens_gpt2 = not tokenizer["model"].get("byte_fallback", False)

    if arch in ["gemma3ex"]:
        # Determine max token id across vocab & added tokens; expand vocab if needed
        max_id = -1
        for _, i in vocab.items():
            if isinstance(i, int):
                max_id = max(max_id, i)
        for added in tokenizer.get("added_tokens", []):
            tid = added.get("id")
            if isinstance(tid, int):
                max_id = max(max_id, tid)
        if max_id >= metadata["vocab_size"]:
            new_vs = max_id + 1
            print(f"[convert.py] Info: expanding vocab_size from {metadata['vocab_size']} to {new_vs} to fit tokenizer IDs")
            tokens.extend([""] * (new_vs - len(tokens)))
            scores.extend([0] * (new_vs - len(scores)))
            metadata["vocab_size"] = new_vs
            config["vocab_size"] = new_vs

        def _ensure_size(idx: int):
            if idx >= len(tokens):
                need = idx + 1 - len(tokens)
                tokens.extend([""] * need)
                scores.extend([0] * need)
                metadata["vocab_size"] = len(tokens)
                config["vocab_size"] = len(tokens)
        for t, i in vocab.items():
            if isinstance(i, int) and i >= 0:
                _ensure_size(i)
                tokens[i] = t
        for added in tokenizer.get("added_tokens", []):
            tid = added.get("id")
            if isinstance(tid, int) and tid >= 0:
                _ensure_size(tid)
                tokens[tid] = added.get("content", "")
    else:
        # legacy fixed behavior for all other architectures
        assert len(vocab) <= config["vocab_size"], "Base vocab larger than config vocab_size"
        for t, i in vocab.items():
            tokens[i] = t
        for added in tokenizer["added_tokens"]:
            vid = added["id"]
            if vid >= 0 and vid < len(tokens):
                tokens[vid] = added["content"]
            elif vid >= len(tokens):
                print(f"[convert.py] Warning: skipping added token {added['content']} with id {vid} outside vocab size {len(tokens)}")

    # compute score as negative merge index so that earlier merges get selected first
    for i, m in enumerate(tokenizer["model"]["merges"]):
        t1, t2 = (m[0], m[1]) if isinstance(m, list) else m.split(" ", 2)
        ti = vocab[t1 + t2]
        if scores[ti] == 0:
            scores[ti] = -(1 + i)
elif ext == ".model":
    import sentencepiece
    sp_model = sentencepiece.SentencePieceProcessor(model_file=args.tokenizer)
    assert sp_model.vocab_size() <= config["vocab_size"]
    assert sp_model.bos_id() == config["bos_token_id"]
    assert sp_model.eos_id() == config["eos_token_id"]

    for i in range(sp_model.vocab_size()):
        tokens[i] = sp_model.id_to_piece(i)
        scores[i] = sp_model.get_score(i)
elif ext == ".tiktoken":
    with open(args.tokenizer, "r") as f:
        vocab = f.readlines()
    assert len(vocab) <= config["vocab_size"]

    for i, l in enumerate(vocab):
        t, r = l.rstrip().split(" ")
        t = base64.b64decode(t)
        tokens[i] = t.decode("utf-8", errors="replace").replace("\0", "\7")
        scores[i] = -int(r)
else:
    raise Exception("Unknown tokenizer file extension: {}; expected .json or .model/.tiktoken".format(ext))

# postprocess tokens
gpt2_decode = {v: k for k, v in gpt2_bytes_to_unicode().items()}

for i, t in enumerate(tokens):
    if tokens_gpt2:
        b = bytes([gpt2_decode.get(c, 0) for c in t])
    else:
        t = t.replace('\u2581', ' ') # sentencepiece uses this character as whitespace
        b = t.encode('utf-8')

    b = b.replace(b"\0", b"\7") # replace null bytes with bell characters
    assert b.count(0) == 0 # no null bytes allowed

    tokens[i] = b

# load model files
weights = {}
for fn in args.models:
    ext = os.path.splitext(fn)[1]
    if ext == ".safetensors":
        with safetensors.safe_open(fn, framework="pt") as f:
            for k in f.keys():
                assert(k not in weights)
                weights[k] = f.get_tensor(k)
    elif ext == ".bin":
        pth = torch.load(fn, map_location="cpu", weights_only=True)
        # Handle different PyTorch model formats
        # Some models store weights directly in the dict, others wrap them in 'state_dict' or 'model'
        if isinstance(pth, dict):
            # Check if this is a wrapped state dict (common in pytorch_model.bin)
            if 'state_dict' in pth:
                pth = pth['state_dict']
            elif 'model' in pth and isinstance(pth['model'], dict):
                pth = pth['model']
        
        for k in pth.keys():
            assert(k not in weights)
            weights[k] = pth[k]
    else:
        raise Exception("Unknown model file extension: {}; expected .safetensors or .bin".format(ext))

# huggingface permutes WQ and WK, this function reverses it
# see https://github.com/huggingface/transformers/blob/b132c1703eb1c8bd9dfa4ad6a9be2bfd6ef819e9/src/transformers/models/llama/convert_llama_weights_to_hf.py#L122
def permute_reverse(w, heads, rotary_dim):
    head_dim = w.shape[0] // heads
    assert rotary_dim <= head_dim
    w = torch.unflatten(w, 0, (-1, head_dim))
    # wr is the rotary part, wk is the part kept unrotated
    wr = w[:, :rotary_dim]
    wk = w[:, rotary_dim:]
    # switch wr from outputting two rotary_dim/2 chunks to outputting values interleaved
    wr = torch.unflatten(wr, 1, (2, -1))
    wr = wr.transpose(1, 2)
    wr = wr.flatten(1, 2)
    # assemble the heads back
    w = torch.cat([wr, wk], dim=1)
    return torch.flatten(w, 0, 1)

def permute_reverse_single_head(w, rotary_dim):
    """
    Permute reverse for a single head, used for models with only one attention head.
    This is a simplified version of the permute_reverse function.
    """
    head_dim = w.shape[0]
    assert rotary_dim <= head_dim
    wr = w[:rotary_dim]
    wk = w[rotary_dim:]
    # switch wr from outputting two rotary_dim/2 chunks to outputting values interleaved
    wr = wr.view(2, -1).transpose(0, 1).flatten()
    # assemble the heads back
    return torch.cat([wr, wk], dim=0) 

# fp8 support requires torch 2.1, but we support other dtypes on earlier versions
dtype = {
    "bf16": torch.bfloat16,
    "fp16": torch.float16, 
    "fp8": getattr(torch, "float8_e5m2", None), 
    "q80": torch.uint8, 
    "q40nl": torch.uint8, 
    "q41nl": torch.uint8, 
    "q42nl": torch.uint8,
    "q43nl": torch.uint8,
    "q40": torch.uint8, 
    "q7f8": torch.uint8, 
    "q6f16": torch.uint8,
    "q3f8": torch.uint8
}[args.dtype]
assert dtype

# Q3F8 quantization: 8 values get quantized to 32 bits, 3-bit normalized int per value + shared fp8 scale factor
# int range is asymmetric; we use this fact to encode the max value as -4 to expand the range a little bit
def q3f8(t):
    if torch.cuda.is_available():
        t.max() # work around cuda load from mmap using small block size for reading...
        t = t.cuda()
    # groups of 8 values
    gt = t.unflatten(-1, (-1, 8))
    # max (abs) of each group
    _, gmaxi = gt.abs().max(-1)
    gmax = gt.gather(-1, gmaxi.unsqueeze(-1))
    # round gmax to fp8 to make sure we're quantizing to the right range
    gmax = gmax.to(torch.float8_e5m2).to(gmax.dtype)
    # normalize gt; note that gmax may be zero
    gt /= gmax
    torch.nan_to_num(gt, nan=0.0, posinf=0.0, neginf=0.0, out=gt)
    # normalize each group by -max ([-1, 1]) and quantize to [0, 8)
    # note that 8 needs to be clamped to 7 since positive half of the range is shorter
    gtq = (gt.to(torch.float16) * -4 + 4).clamp(0, 7).round().to(torch.int32)
    # assemble the results
    gtq <<= torch.tensor([8 + i * 3 for i in range(8)], dtype=torch.int32, device=gtq.device)
    gtr = gtq.sum(-1, dtype=torch.int32)
    gtr += gmax.squeeze(-1).to(torch.float8_e5m2).view(torch.uint8)
    return gtr.cpu()

# Q7F8 quantization: 8 values get quantized to 64 bits, 7-bit normalized int per value + shared fp8 scale factor
# int range is asymmetric; we use this fact to encode the max value as -64 to expand the range a little bit
# this is a vectorized version of the Q7F8 quantization
# 8×7-bit values + 1×fp8 scale = 64 bits.
def q7f8(t: torch.Tensor) -> torch.Tensor:
    if torch.cuda.is_available():
        t.max()  # mmap quirk workaround
        t = t.cuda()
    if t.shape[-1] % 8 != 0:
        raise ValueError("last dimension must be a multiple of 8")
    gt = t.unflatten(-1, (-1, 8)).to(torch.float32)  # (..., G, 8)
    # abs-max indices, then gather the *signed* value (matches q3f pattern)
    _, gmaxi = gt.abs().max(-1)
    gmax = gt.gather(-1, gmaxi.unsqueeze(-1))        # (..., G, 1) signed
    # fp8(e5m2) round-trip for scale (keeps semantics aligned with C implementation)
    gmax = gmax.to(torch.float8_e5m2).to(torch.float32)
    # normalize (avoid div-by-zero) and sanitize
    gt = gt / gmax
    torch.nan_to_num(gt, nan=0.0, posinf=0.0, neginf=0.0, out=gt)
    # map [-1, 1] -> [0, 127]: q = round(-64*v + 64), clamp asym positive side
    gtq = (gt.to(torch.float16) * -64.0 + 64.0).clamp(0, 127).round().to(torch.int64)  # (..., G, 8)
    # pack 8×7-bit fields starting at bit 8
    shifts = (torch.arange(8, device=gtq.device, dtype=torch.int64) * 7) + 8  # (8,)
    gtr = (gtq << shifts).sum(dim=-1, dtype=torch.int64)                       # (..., G)
    # add fp8 scale byte in lowest 8 bits
    scale_u8 = gmax.squeeze(-1).to(torch.float8_e5m2).view(torch.uint8).to(torch.int64)  # (..., G)
    gtr = (gtr + scale_u8).cpu()  # int64 result
    # Ensure as little-endian output as uint8 bytes
    # explicit little-endian bytes (b0..b7)
    out = torch.stack([((gtr >> (8 * i)) & 0xFF).to(torch.uint8) for i in range(8)], dim=-1)  # (..., G, 8)
    return out

# Q6F16 quantization: 8 values get quantized to 64 bits, 6-bit normalized int per value + shared fp16 scale factor
# int range is symmetric; we use this fact to encode the max value as -32 to expand the range a little bit
# this is a vectorized version of the Q6F16 quantization
# 8×6-bit values + 1×fp16 scale = 64 bits.
def q6f16(t: torch.Tensor) -> torch.Tensor:
    if torch.cuda.is_available():
        t.max()  # mmap quirk workaround (tiny read)
        t = t.cuda()
    if t.shape[-1] % 8 != 0:
        raise ValueError("last dimension must be a multiple of 8")
    # group into 8s
    gt = t.unflatten(-1, (-1, 8)).to(torch.float32)          # (..., G, 8)
    # signed max element per group
    _, gmaxi = gt.abs().max(-1)                              # (..., G)
    gmax = gt.gather(-1, gmaxi.unsqueeze(-1))                # (..., G, 1) signed
    # fp16 round-trip of the signed scale (keep sign as in q3f8)
    gmax = gmax.to(torch.float16).to(gt.dtype)               # (..., G, 1)
    # normalize by signed scale
    gt = gt / gmax
    torch.nan_to_num(gt, nan=0.0, posinf=0.0, neginf=0.0, out=gt)
    # asymmetric mapping: +max -> 0, -max -> 63
    codes = (gt.to(torch.float16) * -32 + 32).clamp(0, 63).round().to(torch.int64)  # (..., G, 8)
    # pack into a uint64 word first (logical word), then emit LE bytes
    shifts = 16 + torch.arange(8, device=codes.device, dtype=torch.int64) * 6
    gtr = (codes << shifts).sum(-1, dtype=torch.int64)       # (..., G) logical 64-bit
    gtr |= gmax.squeeze(-1).to(torch.float16).view(torch.uint16).to(torch.int64)  # low 16 bits
    # Ensure as little-endian output as uint8 bytes
    # explicit little-endian bytes (b0..b7)
    out = torch.stack([((gtr >> (8 * i)) & 0xFF).to(torch.uint8) for i in range(8)], dim=-1)  # (..., G, 8)
    return out.cpu()

# Q40 quantization: 32 values get quantized to 18 bytes, 16×uint8 (packed nibbles) + 1×fp16 scale (LE)
def q40(t):
    if torch.cuda.is_available():
        t.max() # work around cuda load from mmap using small block size for reading...
        t = t.cuda()
    group_size = 32
    assert t.numel() % group_size == 0
    ori_shape = t.shape
    t = t.float() # convert to float32
    t = t.reshape(-1, group_size)
    # find the max in each group
    tmax = torch.abs(t).max(dim=1).values
    # calculate the scaling factor such that float = quant * scale
    scale = tmax / 7.0
    # scale into range [-7, 7]
    quant = t / scale[:,None]
    # round to nearest integer
    int4val = torch.round(quant).to(torch.int8)
    int4val = torch.clamp(int4val, -7, 7)
    # dequantize by rescaling
    fp32val = (int4val.float() * scale[:,None]).view(-1)
    fp32valr = fp32val.reshape(-1, group_size)
    # calculate the max error in each group
    err = torch.abs(fp32valr - t).max(dim=1).values
    # Pack int4 values into int8 by shifting
    #uint8val = torch.zeros((int4val.shape[0] + 1) // 2, dtype=torch.uint8, device=int4val.device)
    #for i in range(0, int4val.shape[0], 2):
    #    if i + 1 < int4val.shape[0]:
    #        uint8val[i // 2] = ((int4val[i] + 8) & 0x0F) | (((int4val[i + 1] + 8) & 0x0F) << 4)
    #    else:
    #        uint8val[i // 2] = (int4val[i] + 8) & 0x0F
    # Pack int4 values into uint8 using vectorized operations
    # Convert int4 from int8 to uint8, shift to [0, 15] range and convert to uint8
    uint4val = ((int4val + 8) & 0x0F).view(-1).to(torch.uint8)
    padded_size = (uint4val.shape[0] + 1) // 2 * 2
    padded_uint4 = torch.nn.functional.pad(uint4val, (0, padded_size - uint4val.shape[0]))
    lower_nibble = padded_uint4[0::2] & 0x0F
    upper_nibble = (padded_uint4[1::2] & 0x0F) << 4
    uint8val = lower_nibble | upper_nibble
    # find the max error across all groups
    maxerr = err.max().item()
    # 16×uint8 (packed nibbles) + 1×fp16 scale (LE) => 18 bytes/group, no loops
    qbytes = uint8val.contiguous().view(torch.uint8).reshape(-1, 16)         # [G,16]
    scale16_i = scale.to(torch.float16).contiguous().view(torch.uint16).to(torch.int32)
    lo = (scale16_i & 0x00FF).to(torch.uint8).unsqueeze(1)                   # [G,1]
    hi = ((scale16_i >> 8) & 0x00FF).to(torch.uint8).unsqueeze(1)            # [G,1]
    sbytes = torch.cat([lo, hi], dim=1)                                      # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1)                              # [G,18]
    #data = packed.contiguous().cpu().numpy().tobytes()
    data = packed.contiguous().reshape(-1).to(torch.uint8)
    return data #, maxerr

# Q40NL quantization: 32 values get quantized to 18 bytes, 16×int8 (packed nibbles) + 1×fp16 scale (LE)
def q40nl(
    t: torch.Tensor,
    ls_rescale: bool = True,          # optional least-squares rescale of the block scale
    eps: float = 1e-12,                # numerical epsilon for denom
    allow_negative_scale: bool = False # keep scales positive unless explicitly allowed
):
    """
    Pack per 32: 16 nibbles + fp16 scale (LE).
    Dequant path: y = f(q/7), out = scale * y

    If ls_rescale=True, after choosing q from tmax-based normalization,
    refine the stored fp16 scale with the least-squares solution:
        scale_ls = (T·y) / (y·y + eps)
    where T is the original float block and y = f(q/7).
    """

    def _f_decode(x: torch.Tensor) -> torch.Tensor:
        """y = (x*|x| + x) * 0.5, x in [-1,1]."""
        return (x.abs() * x + x) * 0.5

    def _f_inv(y: torch.Tensor) -> torch.Tensor:
        """x = (sqrt((8 * |y|) + 1) - 1) * sign(y) * 0.5."""
        return (torch.sqrt((8.0 * y.abs()) + 1.0) - 1.0) * torch.sign(y) * 0.5
    
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax                                      # fp16 stored
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)

    X = _f_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)         # [G,32]

    if ls_rescale:
        y   = _f_decode(q.to(torch.float32) / 7.0)          # [G,32] in [-1,1]
        num = (T * y).sum(dim=1)                            # [G]
        den = (y * y).sum(dim=1) + eps                      # [G]
        s_ls = num / den                                    # [G]
        if not allow_negative_scale:
            # fall back to tmax if LS went non-positive (rare)
            s_ls = torch.where(s_ls > 0, s_ls, scale)
        scale = s_ls
        
    # pack nibbles + fp16 scale (LE), byte layout unchanged
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    lo = u4[:, 0::2] & 0x0F
    hi = (u4[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                            # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2) # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1).reshape(-1)  # [G,18] -> bytes
    data = packed.contiguous().reshape(-1).to(torch.uint8)
    return data #, scale

# Q41NL quantization: 32 values get quantized to 18 bytes, 16×int8 (packed nibbles) + 1×fp16 scale (LE)
def q41nl(
    t: torch.Tensor,
    ls_rescale: bool = True,          # optional least-squares rescale of the block scale
    eps: float = 1e-12,                # numerical epsilon for denom
    allow_negative_scale: bool = False # keep scales positive unless explicitly allowed
):
    """
    Pack per 32: 16 nibbles + fp16 scale (LE).
    Dequant path: y = f(q/7), out = scale * y

    If ls_rescale=True, after choosing q from tmax-based normalization,
    refine the stored fp16 scale with the least-squares solution:
        scale_ls = (T·y) / (y·y + eps)
    where T is the original float block and y = f(q/7).
    """

    def _f_decode(x: torch.Tensor) -> torch.Tensor:
        """y = x * |x|, x in [-1,1]."""
        return x.abs() * x

    def _f_inv(y: torch.Tensor) -> torch.Tensor:
        """x = sign(y) * sqrt(|y|)."""
        return torch.sign(y) * torch.sqrt(y.abs())    

    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax                                      # fp16 stored
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)

    X = _f_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)         # [G,32]

    if ls_rescale:
        y   = _f_decode(q.to(torch.float32) / 7.0)          # [G,32] in [-1,1]
        num = (T * y).sum(dim=1)                            # [G]
        den = (y * y).sum(dim=1) + eps                      # [G]
        s_ls = num / den                                    # [G]
        if not allow_negative_scale:
            # fall back to tmax if LS went non-positive (rare)
            s_ls = torch.where(s_ls > 0, s_ls, scale)
        scale = s_ls
        
    # pack nibbles + fp16 scale (LE), byte layout unchanged
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    lo = u4[:, 0::2] & 0x0F
    hi = (u4[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                            # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2) # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1).reshape(-1)  # [G,18] -> bytes
    data = packed.contiguous().reshape(-1).to(torch.uint8)
    return data #, scale

# Q42NL quantization: 32 values -> 18 bytes: 16×nibbles + 1×fp8(e5m2) scale + 1×int8 curve
# Dequant path: y = f_curve(q/7, c), out = scale * y
def q42nl_reference(
    t: torch.Tensor,
    eps_scale: float = 1e-6,          # 32-bit safe tiny for scale
    max_bisect_iters: int = 12        # curve search iterations per group
):
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)                    # [G,32]
    G = T.shape[0]

    # per-group scale = tmax
    tmax = T.abs().amax(dim=1)                              # [G]
    scale = tmax.clone()                                    # stored as fp8 e5m2 (or zero if degenerate)
    # round up to next fp8 value to ensure dynamic range is not smaller than needed
    scale_fp8 = scale.to(torch.float8_e5m2)
    scale_rounded = scale_fp8.to(torch.float32)
    # if rounded value is less than original (and not zero/nan/inf), increment fp8 byte to next value
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_bytes = scale_fp8.view(torch.uint8)
    # increment and check if result is still finite
    scale_bytes_up = (scale_bytes + 1).clamp(max=255)
    scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
    scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)
    # scale-safe for normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)     # [G,32] in [-1,1]

    # helpers (scalar c per group; vector ops on tensors)
    def f_curve(x: torch.Tensor, c: torch.Tensor) -> torch.Tensor:
        # c is scalar tensor (one per group); broadcast over x
        return (1.0 - c) * x + c * (x.abs() * x)

    def f_inv_curve(y: torch.Tensor, c: float) -> torch.Tensor:
        # invert y = (1-c)*x + c*|x|*x  for a single scalar c
        # do it on abs and restore sign
        s = torch.sign(y)
        a = y.abs()

        # |c| < tiny -> identity
        tiny = 1e-6
        if abs(c) < tiny:
            x = a
        elif c >= 1.0:
            # y = x^2  -> x = sqrt(y)
            x = torch.sqrt(a)
        elif c <= -1.0:
            # y = 2x - x^2 on x>=0 -> x = 1 - sqrt(1 - y)
            x = 1.0 - torch.sqrt(torch.clamp(1.0 - a, min=0.0))
        else:
            # solve c x^2 + (1-c) x - a = 0 for x>=0
            b = 1.0 - c
            disc = b * b + 4.0 * c * a
            disc = torch.clamp(disc, min=0.0)
            # use the '+' root to get nonnegative x
            x = (-b + torch.sqrt(disc)) / (2.0 * c)
            # numeric safety: clamp to [0,1]
            x = torch.clamp(x, 0.0, 1.0)
        return x * s

    # reconstruction SSE for a given curve c (scalar)
    def group_error(g: int, c: float) -> torch.Tensor:
        # quantize with curve c, reconstruct, compare vs original T[g]
        Yn = Y[g]                              # [32]
        X = f_inv_curve(Yn, c)                 # [32]
        q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)
        yhat = f_curve(q.to(torch.float32) / 7.0, torch.tensor(c, dtype=torch.float32))
        Terr = (T[g] - (yhat * scale[g]))     # [32]
        return (Terr * Terr).sum()

    # search best curve per group
    best_c = torch.zeros(G, dtype=torch.float32)
    for g in range(G):
        if scale[g] < eps_scale:
            best_c[g] = 0.0
            continue

        low, high = -1.0, 1.0
        # endpoints + neutral
        c_best = 0.0
        err_best = group_error(g, 0.0)
        e_left  = group_error(g, low)
        if e_left < err_best:
            err_best, c_best = e_left, low
        e_right = group_error(g, high)
        if e_right < err_best:
            err_best, c_best = e_right, high

        for _ in range(max_bisect_iters):
            mid = 0.5 * (low + high)
            step = 0.25 * (high - low)
            if step < 1e-4:
                step = 1e-4
            # clamp probes to [-1,1]
            cL = max(-1.0, mid - step)
            cR = min( 1.0, mid + step)

            eL = group_error(g, cL)
            eR = group_error(g, cR)
            eM = group_error(g, mid)
            if eM < err_best:
                err_best, c_best = eM, mid
            if eL < eR:
                high = mid
            else:
                low = mid

        # paranoia clamp
        best_c[g] = float(min(1.0, max(-1.0, c_best)))

    # final quantization with chosen curves
    # build nibbles and the two trailer bytes (fp8 scale, int8 curve)
    u4_pairs = []
    scale_bytes = []
    curve_bytes = []

    for g in range(G):
        if scale[g] < eps_scale:
            # 16×0 + uint16(0) trailer
            u4_pairs.append(torch.zeros(16, dtype=torch.uint8))
            scale_bytes.append(torch.tensor([0], dtype=torch.uint8))  # low 8 bits of the uint16(0)
            curve_bytes.append(torch.tensor([0], dtype=torch.uint8))  # high 8 bits of the uint16(0)
            continue

        c = best_c[g].item()
        X = f_inv_curve(Y[g], c)
        q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)      # [32]

        u4 = ((q + 8) & 0x0F).to(torch.uint8)                      # [32] -> [0..15]
        lo = u4[0::2] & 0x0F
        hi = (u4[1::2] & 0x0F) << 4
        packed16 = (lo | hi)                                       # [16]
        u4_pairs.append(packed16)

        # scale: fp8 e5m2
        sb = scale[g:g+1].to(torch.float32).to(torch.float8_e5m2).view(torch.uint8)  # [1]
        scale_bytes.append(sb)

        # curve: int8(round(c*127))
        cb = torch.tensor([int(max(-128, min(127, round(c * 127.0))))], dtype=torch.int8).view(torch.uint8)
        curve_bytes.append(cb)

    qbytes = torch.stack(u4_pairs, dim=0)                               # [G,16]
    sbytes = torch.cat(scale_bytes, dim=0).view(-1, 1)                  # [G,1]
    cbytes = torch.cat(curve_bytes, dim=0).view(-1, 1)                  # [G,1]
    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)     # [G,18] -> [bytes]
    return packed.contiguous().to(torch.uint8)

# Q42NL quantization: 32 values -> 18 bytes: 16×nibbles + 1×fp8(e5m2) scale + 1×int8 curve
# Dequant path: y = f_curve(q/7, c), out = scale * y
def q42nl_old(
    t: torch.Tensor,
    eps_scale: float = 1e-6,      # 32-bit safe tiny for scale
    grid_size: int = 33           # number of candidate c values in [-1, 1]
):
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)              # [G,32]
    G = T.shape[0]
    dev = T.device
    one = torch.tensor(1.0, dtype=torch.float32, device=dev)

    # per-group tmax and fp8(e5m2) "round up to next representable" (keep your semantics)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # [G] (float32)
    # round to fp8 and bump up by 1 code if needed to not shrink dynamic range
    scale_fp8 = scale.to(torch.float8_e5m2)
    scale_rounded = scale_fp8.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_bytes = scale_fp8.view(torch.uint8)
    scale_bytes_up = (scale_bytes + 1).clamp(max=255)
    scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
    scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)   # [G]
    # normalization (avoid div by 0)
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)             # [G,32] in [-1,1]

    # ---- vectorized curve search over a fixed grid ----
    # candidates C in [-1,1]
    K = int(grid_size)
    C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
    Cb = C.view(K, 1, 1)                                                 # [K,1,1]
    # properly broadcast Y to [K,G,32]
    A = Y.unsqueeze(0).expand(K, G, 32).abs()                            # [K,G,32] |Y| for all candidates
    S = Y.unsqueeze(0).expand(K, G, 32).sign()                           # [K,G,32] sign(Y) for all candidates

    # f_inv for batched c: invert y = (1-c)*x + c*|x|*x
    tiny = 1e-6
    c_abs = Cb.abs()                     # [K,1,1]
    mask_id = c_abs < tiny               # near 0: identity on |y|
    mask_sq = Cb >= 1.0                  # c >= 1: y = x^2 => x = sqrt(y)
    mask_qc = Cb <= -1.0                 # c <= -1: y = 2x - x^2 on x>=0 => x = 1 - sqrt(1-y)
    mask_gen = ~(mask_id | mask_sq | mask_qc)

    # allocate x_nonneg then fill per mask (all shapes [K,G,32])
    x_nonneg = torch.empty((K, G, 32), dtype=torch.float32, device=dev)

    # expand masks to [K,G,32] for indexing
    mask_id_exp = mask_id.expand(K, G, 32)    # [K,G,32]
    mask_sq_exp = mask_sq.expand(K, G, 32)    # [K,G,32]
    mask_qc_exp = mask_qc.expand(K, G, 32)    # [K,G,32]
    mask_gen_exp = mask_gen.expand(K, G, 32)  # [K,G,32]

    # identity
    if mask_id.any():
        x_nonneg[mask_id_exp] = A[mask_id_exp]

    # sqrt branch
    if mask_sq.any():
        x_nonneg[mask_sq_exp] = torch.sqrt(A[mask_sq_exp])

    # quadratic clamp branch (c <= -1)
    if mask_qc.any():
        val = 1.0 - torch.sqrt(torch.clamp(1.0 - A[mask_qc_exp], min=0.0))
        x_nonneg[mask_qc_exp] = val

    # general quadratic: c x^2 + (1-c) x - a = 0, take '+' root on x>=0
    if mask_gen.any():
        # compute on full tensors with where to avoid reshaping issues
        b = (1.0 - Cb)
        disc = torch.clamp(b * b + 4.0 * Cb * A, min=0.0)
        xg = (-b + torch.sqrt(disc)) / (2.0 * Cb)
        # numeric safety
        xg = torch.clamp(xg, 0.0, 1.0)
        x_nonneg = torch.where(mask_gen_exp, xg, x_nonneg)

    X = x_nonneg * S                                                      # restore sign, [K,G,32]

    # quantize and reconstruct for each candidate c (all at once)
    q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)            # [K,G,32]
    xq = q_all.to(torch.float32) / 7.0                                    # [K,G,32]
    # yhat = (1-c)*xq + c*|xq|*xq  (broadcast c over G,32)
    yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                         # [K,G,32]

    # SSE against original T with per-group scale
    Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))                  # [K,G,32]
    err = (Terr * Terr).sum(dim=-1)                                       # [K,G]
    best_idx = err.argmin(dim=0)                                          # [G]
    best_c = C[best_idx]                                                  # [G]

    # select q for best c: gather along K
    idx = best_idx.view(1, G, 1).expand(1, G, 32)                         # [1,G,32]
    q_best = q_all.gather(dim=0, index=idx).squeeze(0)                    # [G,32]

    # handle degenerate groups (scale ~ 0): zero out bytes and curve
    zero_mask = scale <= eps_scale                                        # [G]

    # pack 32×4-bit -> 16 bytes
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)                                                    # [G,16]
    qbytes[zero_mask] = 0

    # fp8(e5m2) scale byte (already rounded/bumped)
    sbytes = scale.to(torch.float8_e5m2).view(torch.uint8).view(-1, 1)    # [G,1]
    sbytes[zero_mask] = 0

    # curve byte: int8(round(c*127)) interpreted as uint8 for storage
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,18] -> bytes
    return packed.contiguous().to(torch.uint8)

# ==================== Shared Q42NL/Q43NL Curve Optimization ====================

def optimize_curve_parameter(
    Y: torch.Tensor,        # [G, 32] normalized values in [-1, 1]
    T: torch.Tensor,        # [G, 32] original values
    scale: torch.Tensor,    # [G] scale factors
    method: str = "gradient",
    grid_size: int = 255,
    gd_iterations: int = 5,
    gd_lr: float = 0.3
) -> tuple[torch.Tensor, torch.Tensor]:
    """
    Find optimal curve parameter c for Q42NL/Q43NL quantization.
    
    Args:
        Y: Normalized values in [-1, 1], shape [G, 32]
        T: Original values, shape [G, 32]
        scale: Scale factors, shape [G]
        method: Optimization method - "gradient", "grid", or "coarse_fine"
        grid_size: Number of candidates for grid search (default 255)
        gd_iterations: Iterations for gradient descent (default 5)
        gd_lr: Learning rate for gradient descent (default 0.3)

    Returns:
        q_best: Quantized values in [-7, 7], shape [G, 32], dtype int8
        best_c: Optimal curve parameters, shape [G], dtype float32
    
    Methods:
        - "gradient" (default): Adam optimizer with 12 initializations
          - 6x faster than grid
             - 99.7% quality (with iterations=20, lr=0.1)
             - 99.5% quality (with iterations=5, lr=0.3)
          - Best for: general use, production default
          
        - "coarse_fine": Two-pass grid search (17 coarse + 17 fine per group)
          - 1.5x faster than grid, 99.97% quality  
          - Best for: maximum quality when speed less critical
          
        - "grid": Exhaustive search over 255 candidates
          - Slowest, 100% quality (reference)
          - Best for: benchmarking only
    """
    G = Y.shape[0]
    dev = Y.device
    tiny = 1e-6
    
    # Helper: evaluate quantization error for given c values
    def eval_c_error(c_val):                                              # c_val: [G]
        mask_id = (c_val.abs() < tiny)                                    # [G]
        mask_sq = (c_val >= 1.0)                                          # [G]
        mask_qc = (c_val <= -1.0)                                         # [G]
        mask_gen = ~(mask_id | mask_sq | mask_qc)                         # [G]
        
        A = Y.abs()                                                       # [G,32]
        S = Y.sign()                                                      # [G,32]
        
        x_id = A                                                          # [G,32]
        x_sq = torch.sqrt(A)                                              # [G,32]
        x_qc = 1.0 - torch.sqrt(torch.clamp(1.0 - A, min=0.0))            # [G,32]
        
        b = (1.0 - c_val.view(-1, 1))                                     # [G,1]
        disc = torch.clamp(b * b + 4.0 * c_val.view(-1, 1) * A, min=0.0) # [G,32]
        denom = (2.0 * c_val.view(-1, 1))                                 # [G,1]
        denom_safe = torch.where(mask_gen.view(-1, 1), denom, torch.ones_like(denom))
        x_gen = (-b + torch.sqrt(disc)) / denom_safe                      # [G,32]
        x_gen = torch.clamp(x_gen, 0.0, 1.0)                              # [G,32]
        
        x_nonneg = torch.where(mask_id.view(-1, 1), x_id,
                               torch.where(mask_sq.view(-1, 1), x_sq,
                                           torch.where(mask_qc.view(-1, 1), x_qc, x_gen))) # [G,32]
        X = x_nonneg * S                                                  # [G,32]
        
        q = torch.round(7.0 * X).clamp_(-7, 7)                            # [G,32]
        xq = q / 7.0                                                      # [G,32]
        
        yhat = (1.0 - c_val.view(-1, 1)) * xq + c_val.view(-1, 1) * (xq.abs() * xq) # [G,32]
        residual = T - (yhat * scale.view(-1, 1))                         # [G,32]
        err_per_group = (residual * residual).sum(dim=1)                  # [G]
        
        return err_per_group, X                                           # ([G], [G,32])
    
    if method == "gradient":
        # v3: Adam optimizer with 12 initializations + line search
        Y_abs = Y.abs()                                                   # [G,32]
        Y_sq = Y * Y                                                      # [G,32]
        kurtosis = (Y_sq * Y_sq).mean(dim=1) / (Y_sq.mean(dim=1).clamp_min(1e-6) ** 2 + 1e-6) # [G]
        c_init = torch.tanh((3.0 - kurtosis) * 0.5).clamp(-0.9, 0.9)      # [G]
        
        c_candidates = [                                                  # 12 initializations
            c_init,
            torch.zeros(G, device=dev, dtype=torch.float32),
            torch.full((G,), 0.3, device=dev, dtype=torch.float32),
            torch.full((G,), -0.3, device=dev, dtype=torch.float32),
            torch.full((G,), 0.6, device=dev, dtype=torch.float32),
            torch.full((G,), -0.6, device=dev, dtype=torch.float32),
            torch.full((G,), 0.9, device=dev, dtype=torch.float32),
            torch.full((G,), -0.9, device=dev, dtype=torch.float32),
            torch.tanh(Y_abs.mean(dim=1) - 0.5),
            torch.tanh((Y_abs.max(dim=1)[0] - Y_abs.min(dim=1)[0]) - 0.5),
            torch.tanh(torch.quantile(Y_abs, 0.75, dim=1) - 0.5),
            torch.tanh(torch.quantile(Y_abs, 0.25, dim=1) - 0.5),
        ]
        
        best_c = c_init.clone()                                           # [G]
        best_err = torch.full((G,), float('inf'), device=dev)             # [G]
        
        for c_cand in c_candidates:
            err, _ = eval_c_error(c_cand)                                 # [G]
            improved = err < best_err                                     # [G]
            best_err = torch.where(improved, err, best_err)               # [G]
            best_c = torch.where(improved, c_cand, best_c)                # [G]
        
        # Adam optimizer
        c = best_c.clone()                                                # [G]
        momentum = torch.zeros(G, device=dev, dtype=torch.float32)        # [G]
        velocity = torch.zeros(G, device=dev, dtype=torch.float32)        # [G]
        beta1, beta2, epsilon = 0.9, 0.999, 1e-8
        
        for iter_idx in range(gd_iterations):
            err_per_group, X = eval_c_error(c)                            # ([G], [G,32])
            improved = err_per_group < best_err                           # [G]
            best_err = torch.where(improved, err_per_group, best_err)     # [G]
            best_c = torch.where(improved, c, best_c)                     # [G]
            
            # Central differences gradient
            delta_c = 0.02 / (1.0 + iter_idx * 0.5)
            c_forward = torch.clamp(c + delta_c, -1.0, 1.0)               # [G]
            err_forward, _ = eval_c_error(c_forward)                      # [G]
            c_backward = torch.clamp(c - delta_c, -1.0, 1.0)              # [G]
            err_backward, _ = eval_c_error(c_backward)                    # [G]
            
            grad_c = (err_forward - err_backward) / (2.0 * delta_c)       # [G]
            grad_c = torch.clamp(grad_c, -10.0, 10.0)                     # [G]
            
            # Adam update with bias correction
            momentum = beta1 * momentum + (1 - beta1) * grad_c            # [G]
            velocity = beta2 * velocity + (1 - beta2) * (grad_c * grad_c) # [G]
            momentum_hat = momentum / (1 - beta1 ** (iter_idx + 1))       # [G]
            velocity_hat = velocity / (1 - beta2 ** (iter_idx + 1))       # [G]
            
            lr = gd_lr * (0.6 ** iter_idx)
            c = c - lr * momentum_hat / (torch.sqrt(velocity_hat) + epsilon) # [G]
            c = torch.clamp(c, -1.0, 1.0)                                 # [G]
            
            if iter_idx > 3 and torch.abs(grad_c).max() < 1e-4:
                break
        
        # Line search refinement (if gd_iterations >= 10)
        if gd_iterations >= 10:
            refinement_steps = torch.linspace(-0.1, 0.1, 7, device=dev)
            for step in refinement_steps:
                c_test = torch.clamp(best_c + step, -1.0, 1.0)            # [G]
                err_test, _ = eval_c_error(c_test)                        # [G]
                improved = err_test < best_err                            # [G]
                best_err = torch.where(improved, err_test, best_err)      # [G]
                best_c = torch.where(improved, c_test, best_c)            # [G]
        
        _, X = eval_c_error(best_c)                                       # ([G], [G,32])
        q_best = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)        # [G,32]
        
    elif method == "coarse_fine":
        # Coarse-to-fine: 17 coarse + 17 fine per group
        K_coarse = 17
        C_coarse = torch.linspace(-1.0, 1.0, K_coarse, device=dev, dtype=torch.float32) # [17]
        C_coarse = torch.clamp(torch.round(C_coarse * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
        
        # Coarse pass (vectorized)
        A = Y.abs().unsqueeze(0)                                          # [1,G,32]
        S = Y.sign().unsqueeze(0)                                         # [1,G,32]
        A_b = A.expand(K_coarse, G, 32)                                   # [17,G,32]
        S_b = S.expand(K_coarse, G, 32)                                   # [17,G,32]
        
        Cb = C_coarse.view(K_coarse, 1, 1)                                # [17,1,1]
        mask_id = (Cb.abs() < tiny)                                       # [17,1,1]
        mask_sq = (Cb >= 1.0)                                             # [17,1,1]
        mask_qc = (Cb <= -1.0)                                            # [17,1,1]
        mask_gen = ~(mask_id | mask_sq | mask_qc)                         # [17,1,1]
        
        m_id = mask_id.expand(K_coarse, G, 32)                            # [17,G,32]
        m_sq = mask_sq.expand(K_coarse, G, 32)                            # [17,G,32]
        m_qc = mask_qc.expand(K_coarse, G, 32)                            # [17,G,32]
        m_gen = mask_gen.expand(K_coarse, G, 32)                          # [17,G,32]
        
        x_id = A_b                                                        # [17,G,32]
        x_sq = torch.sqrt(A_b)                                            # [17,G,32]
        x_qc = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))          # [17,G,32]
        
        b = (1.0 - Cb)                                                    # [17,1,1]
        disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)               # [17,G,32]
        denom = (2.0 * Cb).expand_as(A_b)                                 # [17,G,32]
        denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))   # [17,G,32]
        x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe      # [17,G,32]
        x_gen = torch.clamp(x_gen, 0.0, 1.0)                              # [17,G,32]
        
        x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen))) # [17,G,32]
        X = x_nonneg * S_b                                                # [17,G,32]
        
        q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)         # [17,G,32]
        xq = q_all.to(torch.float32) / 7.0                                # [17,G,32]
        yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                     # [17,G,32]
        
        Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))              # [17,G,32]
        err_coarse = (Terr * Terr).sum(dim=-1)                            # [17,G]
        best_idx_coarse = err_coarse.argmin(dim=0)                        # [G]
        best_c_coarse = C_coarse[best_idx_coarse]                         # [G]
        
        # Fine pass (per-group sequential)
        K_fine = 17
        step = 2.0 / 127.0
        q_best = torch.zeros(G, 32, dtype=torch.int8, device=dev)         # [G,32]
        best_c = torch.zeros(G, device=dev, dtype=torch.float32)          # [G]
        
        for g in range(G):
            c_center = best_c_coarse[g].item()
            c_min = max(-1.0, c_center - 8 * step)
            c_max = min(1.0, c_center + 8 * step)
            
            C_fine = torch.linspace(c_min, c_max, K_fine, device=dev, dtype=torch.float32) # [17]
            C_fine = torch.clamp(torch.round(C_fine * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
            
            A_g = Y[g].abs().unsqueeze(0)                                 # [1,32]
            S_g = Y[g].sign().unsqueeze(0)                                # [1,32]
            T_g = T[g].unsqueeze(0)                                       # [1,32]
            scale_g = scale[g]                                            # scalar
            
            best_err_g = float('inf')
            best_q_g = None
            best_c_g = c_center
            
            for c_val in C_fine:
                mask_id_g = abs(c_val.item()) < tiny
                mask_sq_g = c_val.item() >= 1.0
                mask_qc_g = c_val.item() <= -1.0
                
                if mask_id_g:
                    x_g = A_g
                elif mask_sq_g:
                    x_g = torch.sqrt(A_g)
                elif mask_qc_g:
                    x_g = 1.0 - torch.sqrt(torch.clamp(1.0 - A_g, min=0.0))
                else:
                    b_g = 1.0 - c_val
                    disc_g = torch.clamp(b_g * b_g + 4.0 * c_val * A_g, min=0.0)
                    x_g = (-b_g + torch.sqrt(disc_g)) / (2.0 * c_val)
                    x_g = torch.clamp(x_g, 0.0, 1.0)
                
                X_g = x_g * S_g                                           # [1,32]
                q_g = torch.round(7.0 * X_g).clamp_(-7, 7).to(torch.int8) # [1,32]
                xq_g = q_g.to(torch.float32) / 7.0                        # [1,32]
                yhat_g = (1.0 - c_val) * xq_g + c_val * (xq_g.abs() * xq_g) # [1,32]
                
                err_g = ((T_g - yhat_g * scale_g) ** 2).sum().item()
                
                if err_g < best_err_g:
                    best_err_g = err_g
                    best_q_g = q_g.squeeze()                              # [32]
                    best_c_g = c_val.item()
            
            q_best[g] = best_q_g                                          # [32]
            best_c[g] = best_c_g                                          # scalar
    
    else:  # method == "grid"
        # Full grid search (exhaustive over 255 candidates)
        K = int(grid_size)
        C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32) # [K]
        if K == 255:
            C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
        Cb = C.view(K, 1, 1)                                              # [K,1,1]
        
        A = Y.abs().unsqueeze(0)                                          # [1,G,32]
        S = Y.sign().unsqueeze(0)                                         # [1,G,32]
        A_b = A.expand(K, G, 32)                                          # [K,G,32]
        S_b = S.expand(K, G, 32)                                          # [K,G,32]
        
        mask_id = (Cb.abs() < tiny)                                       # [K,1,1]
        mask_sq = (Cb >= 1.0)                                             # [K,1,1]
        mask_qc = (Cb <= -1.0)                                            # [K,1,1]
        mask_gen = ~(mask_id | mask_sq | mask_qc)                         # [K,1,1]
        
        m_id = mask_id.expand(K, G, 32)                                   # [K,G,32]
        m_sq = mask_sq.expand(K, G, 32)                                   # [K,G,32]
        m_qc = mask_qc.expand(K, G, 32)                                   # [K,G,32]
        m_gen = mask_gen.expand(K, G, 32)                                 # [K,G,32]
        
        x_id = A_b                                                        # [K,G,32]
        x_sq = torch.sqrt(A_b)                                            # [K,G,32]
        x_qc = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))          # [K,G,32]
        
        b = (1.0 - Cb)                                                    # [K,1,1]
        disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)               # [K,G,32]
        denom = (2.0 * Cb).expand_as(A_b)                                 # [K,G,32]
        denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))   # [K,G,32]
        x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe      # [K,G,32]
        x_gen = torch.clamp(x_gen, 0.0, 1.0)                              # [K,G,32]
        
        x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen))) # [K,G,32]
        X = x_nonneg * S_b                                                # [K,G,32]
        
        q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)         # [K,G,32]
        xq = q_all.to(torch.float32) / 7.0                                # [K,G,32]
        yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                     # [K,G,32]
        
        Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))              # [K,G,32]
        err = (Terr * Terr).sum(dim=-1)                                   # [K,G]
        best_idx = err.argmin(dim=0)                                      # [G]
        best_c = C[best_idx]                                              # [G]
        
        idx = best_idx.view(1, G, 1).expand(1, G, 32)                     # [1,G,32]
        q_best = q_all.gather(dim=0, index=idx).squeeze(0)                # [G,32]
    
    return q_best, best_c                                                 # ([G,32] int8, [G] float32)


# ==================== Q42NL / Q43NL Quantization ====================

# Q42NL quantization: 32 values -> 18 bytes: 16×nibbles + 1×fp8(e5m2) scale + 1×int8 curve
# Dequant path: y = f_curve(q/7, c), out = scale * y
def q42nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,
    method: str = "gradient",
    grid_size: int = 255,
    gd_iterations: int = 20,
    gd_lr: float = 0.1
) -> torch.Tensor:
    """
    Quantize a tensor using the Q42NL method (FP8 scale + per-group curve).
    
    See optimize_curve_parameter() for method details.
    """
    assert t.numel() % 32 == 0, "Tensor size must be divisible by 32"
    T = t.to(torch.float32).view(-1, 32)
    G = T.shape[0]
    dev = T.device

    # per-group tmax and fp8(e5m2) "round up to next representable"
    tmax = T.abs().amax(dim=1)
    scale = tmax.clone()

    scale_fp8 = scale.to(torch.float8_e5m2)
    scale_rounded = scale_fp8.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_bytes = scale_fp8.view(torch.uint8)
    scale_bytes_up = (scale_bytes + 1).clamp(max=255)
    scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
    scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)

    # normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)

    # Use shared optimizer to find optimal curve parameter
    q_best, best_c = optimize_curve_parameter(
        Y, T, scale,
        method=method,
        grid_size=grid_size,
        gd_iterations=gd_iterations,
        gd_lr=gd_lr
    )
    
    # handle degenerate groups (scale ~ 0)
    zero_mask = (scale <= eps_scale)

    # pack 32×4-bit -> 16 bytes
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)                                                    # [G,16]
    qbytes[zero_mask] = 0

    # fp8(e5m2) scale byte
    sbytes = scale.to(torch.float8_e5m2).view(torch.uint8).view(-1, 1)    # [G,1]
    sbytes[zero_mask] = 0

    # curve byte
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,18] -> bytes
    return packed.contiguous().to(torch.uint8)

# Process large tensors in chunks to save memory, otherwise there is a risk of out-of-memory and/or slowdowns
# due to too big temporary tensors.
def q42nl_chunked(t: torch.Tensor, chunk_elems: int = 32*8192, **kw) -> torch.Tensor:
    """Quantize in chunks to cap memory. chunk_elems must be a multiple of 32."""
    assert chunk_elems % 32 == 0
    out = []
    flat = t.view(-1)
    for i in range(0, flat.numel(), chunk_elems):
        out.append(q42nl(flat[i:i+chunk_elems], **kw))
    return torch.cat(out, dim=0)

# Q43NL quantization: 32 values -> 19 bytes: 16×nibbles + 1×fp16 scale + 1×int8 curve
# Dequant path: y = f_curve(q/7, c), out = scale * y
# This is Q42NL with FP16 scale instead of FP8 e5m2 for better precision (+1.2 dB PSNR)
def q43nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,      # 32-bit safe tiny for scale
    method: str = "gradient",      # optimization method: "gradient" (default), "grid", "coarse_fine"
    grid_size: int = 255,          # number of candidate c values (for grid search)
    gd_iterations: int = 20,       # number of gradient descent iterations
    gd_lr: float = 0.1             # learning rate for gradient descent (0.1 for best quality)
) -> torch.Tensor:
    """
    Quantize a tensor using the Q43NL method (Q42NL with FP16 scale + per-group curve).
    
    See optimize_curve_parameter() for method details.
    """
    assert t.numel() % 32 == 0, "Tensor size must be divisible by 32"
    T = t.to(torch.float32).view(-1, 32)              # [G,32]
    G = T.shape[0]
    dev = T.device

    # per-group tmax and fp16 "round up to next representable"
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # [G] (float32)

    scale_fp16 = scale.to(torch.float16)
    scale_rounded = scale_fp16.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_words = scale_fp16.view(torch.uint16)
    scale_words_up = ((scale_words.to(torch.int32) + 1).clamp(max=0xFFFF)).to(torch.uint16)
    scale_up = scale_words_up.view(torch.float16).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_words = torch.where(safe_to_up, scale_words_up.to(torch.int32), scale_words.to(torch.int32)).to(torch.uint16)
    scale = scale_words.view(torch.float16).to(torch.float32)          # [G]

    # normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)                  # [G,32]

    # Use shared optimizer to find optimal curve parameter
    q_best, best_c = optimize_curve_parameter(
        Y, T, scale,
        method=method,
        grid_size=grid_size,
        gd_iterations=gd_iterations,
        gd_lr=gd_lr
    )

    # handle degenerate groups (scale ~ 0)
    zero_mask = (scale <= eps_scale)                                      # [G]

    # pack 32×4-bit -> 16 bytes
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)                                                    # [G,16]
    qbytes[zero_mask] = 0

    # fp16 scale bytes (2 bytes, little-endian)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1, 2)       # [G,2]
    sbytes[zero_mask] = 0

    # curve byte
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,19] -> bytes
    return packed.contiguous().to(torch.uint8)

# Process large tensors in chunks to save memory, otherwise there is a risk of out-of-memory and/or slowdowns
# due to too big temporary tensors.
def q43nl_chunked(t: torch.Tensor, chunk_elems: int = 32*8192, **kw) -> torch.Tensor:
    """Quantize in chunks to cap memory. chunk_elems must be a multiple of 32."""
    assert chunk_elems % 32 == 0
    out = []
    flat = t.view(-1)
    for i in range(0, flat.numel(), chunk_elems):
        out.append(q43nl(flat[i:i+chunk_elems], **kw))
    return torch.cat(out, dim=0)

# Q80 quantization: 32 values get quantized to 34 bytes, 32×int8 + 1×fp16 scale
def q80(t):
    if torch.cuda.is_available():
        t.max() # work around cuda load from mmap using small block size for reading...
        t = t.cuda()
    group_size = 32
    assert t.numel() % group_size == 0
    ori_shape = t.shape
    t = t.float() # convert to float32
    t = t.reshape(-1, group_size)
    # find the max in each group
    tmax = torch.abs(t).max(dim=1).values
    # calculate the scaling factor such that float = quant * scale
    scale = tmax / 127.0
    # Convert scale to float16
    scale16 = scale.to(torch.float16)
    # Convert scale back to float32 for safetensors packing 
    scale = scale16.to(torch.float32)
    # scale into range [-127, 127]
    quant = t / scale[:,None]
    # round to nearest integer
    int8val = torch.round(quant).to(torch.int8)
    # dequantize by rescaling
    fp32val = (int8val.float() * scale[:,None]).view(-1)
    fp32valr = fp32val.reshape(-1, group_size)    
    # calculate the max error in each group
    err = torch.abs(fp32valr - t).max(dim=1).values
    # find the max error across all groups
    maxerr = err.max().item()
    # Pack data in 34-byte chunks: 32×int8 + 1×fp16 scale
    #qbytes = int8val.contiguous().view(torch.uint8)        # [G,32]
    # 1 x fp16 -> 2 x uint8 bytes (native endian)
    #sbytes = scale16.contiguous().view(torch.uint16).view(torch.uint8).reshape(-1, 2)  # [G,2]
    # concat to [G, 34] then flatten to bytes
    #packed = torch.cat([qbytes.reshape(-1, group_size), sbytes], dim=1)  # [G,34]
    #data = packed.contiguous().cpu().numpy().tobytes()  # bytes; per-group: 32 int8 + 1 fp16    
    qbytes = int8val.contiguous().view(torch.uint8).reshape(-1, group_size)  # [G,32]
    s16_i  = scale16.contiguous().view(torch.uint16).to(torch.int32)         # [G]
    lo     = (s16_i & 0x00FF).to(torch.uint8).unsqueeze(1)                   # [G,1]
    hi     = ((s16_i >> 8) & 0x00FF).to(torch.uint8).unsqueeze(1)            # [G,1]
    sbytes = torch.cat([lo, hi], dim=1)                                      # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1)                              # [G,34]
    #data  = packed.contiguous().cpu().numpy().tobytes()   
    data   = packed.contiguous().reshape(-1).to(torch.uint8)
    return data

# If vocab expanded for any architecture, pad embedding & output matrices before preprocessing/scaling
if metadata["vocab_size"] != original_vocab_size:
    new_vs = metadata["vocab_size"]
    emb_keys = [
        "model.embed_tokens.weight",      # common
        "model.tok_embeddings.weight",    # internlm2
        "model.transformer.wte.weight",   # olmo
        "transformer.wte.weight"          # dbrx
    ]
    for k in emb_keys:
        if k in weights and weights[k].shape[0] < new_vs:
            old_vs = weights[k].shape[0]
            dim = weights[k].shape[1]
            pad = new_vs - old_vs
            base = weights[k]
            mu = base.mean().item()
            std = base.std(unbiased=False).item()
            if std == 0:
                std = (1.0 / max(1, dim)) ** 0.5
            init_rows = torch.empty(pad, dim, dtype=base.dtype)
            init_rows.normal_(mean=mu, std=std)
            weights[k] = torch.cat([base, init_rows], dim=0)
            print(f"[convert.py] Expanded embedding {k}: {old_vs} -> {new_vs}")
    # Output projection(s)
    head_keys = [
        "lm_head.weight",
        "output.weight",
        "model.transformer.ff_out.weight"  # olmo untied
    ]
    for k in head_keys:
        if k in weights and weights[k].shape[0] < new_vs:
            old_vs = weights[k].shape[0]
            dim = weights[k].shape[1]
            pad = new_vs - old_vs
            base = weights[k]
            mu = base.mean().item()
            std = base.std(unbiased=False).item()
            if std == 0:
                std = (1.0 / max(1, dim)) ** 0.5
            init_rows = torch.empty(pad, dim, dtype=base.dtype)
            init_rows.normal_(mean=mu, std=std)
            weights[k] = torch.cat([base, init_rows], dim=0)
            print(f"[convert.py] Expanded output head {k}: {old_vs} -> {new_vs}")

# => "[ 1.0, 2.0, 3.0 ]"
def convert_float_array_to_string(arr):
    return f"[ {', '.join(map(str, arr))} ]"

# XIELU
if metadata["act_type"] == "xielu":
    # scan for single tensor weights named
    # "model.layers.{l}.mlp.act_fn.alpha_n"
    # "model.layers.{l}.mlp.act_fn.alpha_p"
    # "model.layers.{l}.mlp.act_fn.beta"
    # "model.layers.{l}.mlp.act_fn.eps"
    # and collect them into arrays
    act_fn_alpha_n = []
    act_fn_alpha_p = []
    act_fn_beta = []
    act_fn_eps = []
    for l in range(n_layers):
        alpha_n_name = f"model.layers.{l}.mlp.act_fn.alpha_n"
        alpha_p_name = f"model.layers.{l}.mlp.act_fn.alpha_p"
        beta_name = f"model.layers.{l}.mlp.act_fn.beta"
        eps_name = f"model.layers.{l}.mlp.act_fn.eps"
        if alpha_n_name in weights:
            act_fn_alpha_n.append(weights[alpha_n_name].item())
            del weights[alpha_n_name]
        else:
            act_fn_alpha_n.append(0.8)
        if alpha_p_name in weights:
            act_fn_alpha_p.append(weights[alpha_p_name].item())
            del weights[alpha_p_name]
        else:
            act_fn_alpha_p.append(0.8)
        if beta_name in weights:
            act_fn_beta.append(weights[beta_name].item())
            del weights[beta_name]
        else:
            act_fn_beta.append(0.5)
        if eps_name in weights:
            act_fn_eps.append(weights[eps_name].item())
            del weights[eps_name]
        else:
            act_fn_eps.append(-1e-6)
    # convert to array weights for better linear access
    weights["model.act_fn_alpha_n"] = torch.tensor(act_fn_alpha_n, dtype=torch.float32)
    weights["model.act_fn_alpha_p"] = torch.tensor(act_fn_alpha_p, dtype=torch.float32)
    weights["model.act_fn_beta"] = torch.tensor(act_fn_beta, dtype=torch.float32)
    weights["model.act_fn_eps"] = torch.tensor(act_fn_eps, dtype=torch.float32)
    # add to tensors to be saved
    tensors["model.act_fn_alpha_n"] = weights["model.act_fn_alpha_n"]
    tensors["model.act_fn_alpha_p"] = weights["model.act_fn_alpha_p"]
    tensors["model.act_fn_beta"] = weights["model.act_fn_beta"]
    tensors["model.act_fn_eps"] = weights["model.act_fn_eps"]

# preprocess weights
if arch == "minicpm":
    # apply various scaling factors that other models don't have to tensors
    embed_scale = config["scale_emb"]
    resid_scale = config["scale_depth"] / (config["num_hidden_layers"] ** 0.5)
    final_scale = config["dim_model_base"] / config["hidden_size"]

    weights["model.norm.weight"] *= final_scale / (1.0 if config.get("tie_word_embeddings", None) == False else embed_scale)
    weights["model.embed_tokens.weight"] *= embed_scale

    for l in range(config["num_hidden_layers"]):
        weights[f"model.layers.{l}.self_attn.o_proj.weight"] *= resid_scale

        if "num_experts" in config:
            for e in range(config["num_experts"]):
                weights[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] *= resid_scale
        else:
            weights[f"model.layers.{l}.mlp.down_proj.weight"] *= resid_scale
elif arch == "gemma":
    # gemma's norm weights are stored relative to 1.0
    weights["model.norm.weight"] = weights["model.norm.weight"].float() + 1

    for l in range(config["num_hidden_layers"]):
        weights[f"model.layers.{l}.input_layernorm.weight"] = weights[f"model.layers.{l}.input_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.post_attention_layernorm.weight"] = weights[f"model.layers.{l}.post_attention_layernorm.weight"].float() + 1

    # apply embedding scale (and counter it since output weights are tied)
    # this improves precision for fp8
    embed_scale = config["hidden_size"] ** 0.5

    weights["model.norm.weight"] *= 1 / embed_scale
    weights["model.embed_tokens.weight"] = weights["model.embed_tokens.weight"].float() * embed_scale
elif arch == "gemma2":
    # gemma2's norm weights are stored relative to 1.0
    weights["model.norm.weight"] = weights["model.norm.weight"].float() + 1

    for l in range(config["num_hidden_layers"]):
        weights[f"model.layers.{l}.input_layernorm.weight"] = weights[f"model.layers.{l}.input_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.post_attention_layernorm.weight"] = weights[f"model.layers.{l}.post_attention_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.pre_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.pre_feedforward_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.post_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.post_feedforward_layernorm.weight"].float() + 1

    # apply embedding scale (and counter it since output weights are tied)
    # this improves precision for fp8
    embed_scale = config["hidden_size"] ** 0.5

    #weights["model.norm.weight"] *= 1 / embed_scale
    weights["model.embed_tokens.weight"] = weights["model.embed_tokens.weight"].float() * embed_scale
elif arch == "gemma3":
    # gemma3's norm weights are stored relative to 1.0
    weights["model.norm.weight"] = weights["model.norm.weight"].float() + 1

    for l in range(config["num_hidden_layers"]):
        weights[f"model.layers.{l}.input_layernorm.weight"] = weights[f"model.layers.{l}.input_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.post_attention_layernorm.weight"] = weights[f"model.layers.{l}.post_attention_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.pre_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.pre_feedforward_layernorm.weight"].float() + 1
        weights[f"model.layers.{l}.post_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.post_feedforward_layernorm.weight"].float() + 1

    # apply embedding scale (and counter it since output weights are tied)
    # this improves precision for fp8
    embed_scale = config["hidden_size"] ** 0.5

    #weights["model.norm.weight"] *= 1 / embed_scale
    weights["model.embed_tokens.weight"] = weights["model.embed_tokens.weight"].float() * embed_scale
elif arch == "cohere":
    weights["model.norm.weight"] *= config["logit_scale"]

# convert weights
progress = 0
def conv(t):
    global progress
    progress += 1
    print(f"\rConverting tensor {progress}: {t.shape}", end="", flush=True)
    # Check if q80 quantization is requested
    if args.dtype == "q80":
        return q80(t)
    # Check if q40nl quantization is requested
    elif args.dtype == "q40nl":
        return q40nl(t) #, ls_rescale=args.ls_rescale, allow_negative_scale=args.allow_negative_scale)
    elif args.dtype == "q41nl":
        return q41nl(t) #, ls_rescale=args.ls_rescale, allow_negative_scale=args.allow_negative_scale)
    elif args.dtype == "q42nl":
        return q42nl_chunked(t, method=args.q4xnl_method,
                             gd_iterations=args.q4xnl_gd_iterations,
                             gd_lr=args.q4xnl_gd_lr) # Q42NL: 16 nibbles + fp8(e5m2) scale + int8 curve
    elif args.dtype == "q43nl":
        return q43nl_chunked(t, method=args.q4xnl_method,
                             gd_iterations=args.q4xnl_gd_iterations,
                             gd_lr=args.q4xnl_gd_lr) # Q43NL: 16 nibbles + fp16 scale + int8 curve (+1.2 dB vs Q42NL)
    # Check if q40 quantization is requested
    elif args.dtype == "q40":
        return q40(t)
    # Check if q7f8 quantization is requested
    elif args.dtype == "q7f8":
        return q7f8(t)
    # Check if q6f16 quantization is requested
    elif args.dtype == "q6f16":
        return q6f16(t)
    # Check if q3f8 quantization is requested
    elif args.dtype == "q3f8":
        return q3f8(t)
    else:
        return t.to(dtype) # return q3f8(t) if dtype == torch.uint8 else t.to(dtype)

if arch in ["llama", "mistral", "mixtral", "qwen2", "qwen3", "qwen3moe", "gemma", "gemma2", "gemma3", "minicpm", "cohere", "xverse", "olmoe", "smollm3", "apertus"]:

    if arch in ["olmoe"]:
        print("Warning: OLMoE is using QK norm which is not tested yet, so it may not work correctly yet.")

    tensors["model.embed.weight"] = conv(weights["model.embed_tokens.weight"])
    quantizedtensors["model.embed.weight"] = True

    for l in range(config["num_hidden_layers"]):

        # attention norms
        if arch in ["apertus"]:
            tensors[f"model.layers.{l}.attn.norm.weight"] = weights[f"model.layers.{l}.attention_layernorm.weight"].float()
            tensors[f"model.layers.{l}.ffn.norm.weight"] = weights[f"model.layers.{l}.feedforward_layernorm.weight"].float()
        else:
            tensors[f"model.layers.{l}.attn.norm.weight"] = weights[f"model.layers.{l}.input_layernorm.weight"].float() 

        rotary_dim = metadata["rotary_dim"]
        head_dim = metadata["head_dim"]
        n_heads = config["num_attention_heads"]
        n_kv_heads = config.get("num_key_value_heads", n_heads)

        if (arch in ["cohere"]) or ((arch in ["qwen3", "qwen3moe", "apertus"]) and allow_noninterleaved):
            tensors[f"model.layers.{l}.attn.wq.weight"] = conv(weights[f"model.layers.{l}.self_attn.q_proj.weight"])
            tensors[f"model.layers.{l}.attn.wk.weight"] = conv(weights[f"model.layers.{l}.self_attn.k_proj.weight"])
        else:
            tensors[f"model.layers.{l}.attn.wq.weight"] = conv(permute_reverse(weights[f"model.layers.{l}.self_attn.q_proj.weight"], n_heads, rotary_dim))
            tensors[f"model.layers.{l}.attn.wk.weight"] = conv(permute_reverse(weights[f"model.layers.{l}.self_attn.k_proj.weight"], n_kv_heads, rotary_dim))
        quantizedtensors[f"model.layers.{l}.attn.wq.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wk.weight"] = True

        tensors[f"model.layers.{l}.attn.wv.weight"] = conv(weights[f"model.layers.{l}.self_attn.v_proj.weight"])
        tensors[f"model.layers.{l}.attn.wo.weight"] = conv(weights[f"model.layers.{l}.self_attn.o_proj.weight"])
        quantizedtensors[f"model.layers.{l}.attn.wv.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wo.weight"] = True

        if arch in ["qwen2"]:
            tensors[f"model.layers.{l}.attn.wq.bias"] = permute_reverse(weights[f"model.layers.{l}.self_attn.q_proj.bias"], n_heads, rotary_dim).float()
            tensors[f"model.layers.{l}.attn.wk.bias"] = permute_reverse(weights[f"model.layers.{l}.self_attn.k_proj.bias"], n_kv_heads, rotary_dim).float()
            tensors[f"model.layers.{l}.attn.wv.bias"] = weights[f"model.layers.{l}.self_attn.v_proj.bias"].float()

        if arch in ["qwen3", "qwen3moe", "olmoe", "apertus"]:
            if (arch in ["qwen3", "qwen3moe", "apertus"]) and not allow_noninterleaved:
                tensors[f"model.layers.{l}.attn.wq_norm.weight"] = permute_reverse_single_head(weights[f"model.layers.{l}.self_attn.q_norm.weight"], rotary_dim).float()
                tensors[f"model.layers.{l}.attn.wk_norm.weight"] = permute_reverse_single_head(weights[f"model.layers.{l}.self_attn.k_norm.weight"], rotary_dim).float()
            else:
                tensors[f"model.layers.{l}.attn.wq_norm.weight"] = weights[f"model.layers.{l}.self_attn.q_norm.weight"].float()
                tensors[f"model.layers.{l}.attn.wk_norm.weight"] = weights[f"model.layers.{l}.self_attn.k_norm.weight"].float()

        if not (arch in ["cohere", "apertus"]):
            tensors[f"model.layers.{l}.mlp.norm.weight"] = weights[f"model.layers.{l}.post_attention_layernorm.weight"].float() # MLP norms (rms_ffn_weigts)

        if arch in ["gemma2", "gemma3"]:
            tensors[f"model.layers.{l}.pre_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.pre_feedforward_layernorm.weight"].float()   
            tensors[f"model.layers.{l}.post_feedforward_layernorm.weight"] = weights[f"model.layers.{l}.post_feedforward_layernorm.weight"].float()     

        if arch in ["mixtral"]:
            tensors[f"model.layers.{l}.moegate.weight"] = conv(weights[f"model.layers.{l}.block_sparse_moe.gate.weight"])
            quantizedtensors[f"model.layers.{l}.moegate.weight"] = True

            for e in range(config["num_local_experts"]):
                tensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = conv(weights[f"model.layers.{l}.block_sparse_moe.experts.{e}.w1.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = conv(weights[f"model.layers.{l}.block_sparse_moe.experts.{e}.w2.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = conv(weights[f"model.layers.{l}.block_sparse_moe.experts.{e}.w3.weight"])
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = True

        elif arch in ["minicpm"] and "num_experts" in config:
            tensors[f"model.layers.{l}.moegate.weight"] = conv(weights[f"model.layers.{l}.mlp.gate.weight"])
            quantizedtensors[f"model.layers.{l}.moegate.weight"] = True

            for e in range(config["num_experts"]):
                tensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.w1.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.w2.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.w3.weight"])
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = True

        elif arch in ["qwen3moe"]:
            tensors[f"model.layers.{l}.moegate.weight"] = conv(weights[f"model.layers.{l}.mlp.gate.weight"])
            quantizedtensors[f"model.layers.{l}.moegate.weight"] = True

            for e in range(config["num_experts"]):                          
                tensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.gate_proj.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.down_proj.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.up_proj.weight"])
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = True

        elif arch in ["olmoe"]:
            tensors[f"model.layers.{l}.moegate.weight"] = conv(weights[f"model.layers.{l}.mlp.gate.weight"])
            quantizedtensors[f"model.layers.{l}.moegate.weight"] = True

            for e in range(config["num_experts"]):
                tensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.gate_proj.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.down_proj.weight"])
                tensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = conv(weights[f"model.layers.{l}.mlp.experts.{e}.up_proj.weight"])
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w1.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w2.weight"] = True
                quantizedtensors[f"model.layers.{l}.mlp.experts.{e}.w3.weight"] = True

        elif arch in ["apertus"]:
            if not (metadata["act_type"] == "xielu"):
                tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(weights[f"model.layers.{l}.mlp.gate_proj.weight"])
            tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.down_proj.weight"])
            tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(weights[f"model.layers.{l}.mlp.up_proj.weight"])
            quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
            quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

        else:
            tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(weights[f"model.layers.{l}.mlp.gate_proj.weight"])
            tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.down_proj.weight"])
            tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(weights[f"model.layers.{l}.mlp.up_proj.weight"])
            quantizedtensors[f"model.layers.{l}.mlp.w1.weight"] = True
            quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
            quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

    tensors["model.norm.weight"] = weights["model.norm.weight"].float() # final pre-classifier norm
    if (config.get("tie_word_embeddings", None) != True) and (weights.get("lm_head.weight") is not None):
        tensors["model.output.weight"] = conv(weights["lm_head.weight"])
        quantizedtensors["model.output.weight"] = True
elif arch == "internlm2":
    tensors["model.embed.weight"] = conv(weights["model.tok_embeddings.weight"])
    quantizedtensors["model.embed.weight"] = True

    for l in range(config["num_hidden_layers"]):
        tensors[f"model.layers.{l}.attn.norm.weight"] = weights[f"model.layers.{l}.attention_norm.weight"].float()

        head_dim = metadata["head_dim"]
        n_heads = config["num_attention_heads"]
        n_kv_heads = config.get("num_key_value_heads", n_heads)
        kv_mul = n_heads // n_kv_heads

        wqkv = weights[f"model.layers.{l}.attention.wqkv.weight"]
        wqkv = wqkv.unflatten(0, (n_kv_heads, kv_mul + 2, head_dim))

        tensors[f"model.layers.{l}.attn.wq.weight"] = conv(permute_reverse(wqkv[:, :kv_mul].flatten(0, 2), n_heads, head_dim))
        tensors[f"model.layers.{l}.attn.wk.weight"] = conv(permute_reverse(wqkv[:, kv_mul].flatten(0, 1), n_kv_heads, head_dim))
        quantizedtensors[f"model.layers.{l}.attn.wq.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wk.weight"] = True

        tensors[f"model.layers.{l}.attn.wv.weight"] = conv(wqkv[:, kv_mul+1].flatten(0, 1))
        tensors[f"model.layers.{l}.attn.wo.weight"] = conv(weights[f"model.layers.{l}.attention.wo.weight"])
        quantizedtensors[f"model.layers.{l}.attn.wv.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wo.weight"] = True

        tensors[f"model.layers.{l}.mlp.norm.weight"] = weights[f"model.layers.{l}.ffn_norm.weight"].float()

        tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(weights[f"model.layers.{l}.feed_forward.w1.weight"])
        tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"model.layers.{l}.feed_forward.w2.weight"])
        tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(weights[f"model.layers.{l}.feed_forward.w3.weight"])
        quantizedtensors[f"model.layers.{l}.mlp.w1.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

    tensors["model.norm.weight"] = weights["model.norm.weight"].float()
    tensors["model.output.weight"] = conv(weights["output.weight"])
    quantizedtensors["model.output.weight"] = True
elif arch == "olmo":
    tensors["model.embed.weight"] = conv(weights["model.transformer.wte.weight"])
    quantizedtensors["model.embed.weight"] = True

    for l in range(config["n_layers"]):
        tensors[f"model.layers.{l}.attn.norm.weight"] = torch.ones(config["d_model"], dtype=torch.float32)

        dim = config["d_model"]
        head_dim = dim // config["n_heads"]
        hidden_dim = (config["mlp_hidden_size"] or config["d_model"] * config["mlp_ratio"]) // 2

        attn_proj = weights[f"model.transformer.blocks.{l}.att_proj.weight"]
        assert attn_proj.shape == (dim * 3, dim)

        tensors[f"model.layers.{l}.attn.wq.weight"] = conv(permute_reverse(attn_proj[:dim], config["n_heads"], head_dim))
        tensors[f"model.layers.{l}.attn.wk.weight"] = conv(permute_reverse(attn_proj[dim:dim*2], config["n_heads"], head_dim))
        tensors[f"model.layers.{l}.attn.wv.weight"] = conv(attn_proj[dim*2:])
        tensors[f"model.layers.{l}.attn.wo.weight"] = conv(weights[f"model.transformer.blocks.{l}.attn_out.weight"])
        quantizedtensors[f"model.layers.{l}.attn.wq.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wk.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wv.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wo.weight"] = True

        tensors[f"model.layers.{l}.mlp.norm.weight"] = torch.ones(config["d_model"], dtype=torch.float32)

        mlp_proj = weights[f"model.transformer.blocks.{l}.ff_proj.weight"]
        assert mlp_proj.shape == (hidden_dim * 2, dim)

        tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(mlp_proj[hidden_dim:])
        tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"model.transformer.blocks.{l}.ff_out.weight"])
        tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(mlp_proj[:hidden_dim])
        quantizedtensors[f"model.layers.{l}.mlp.w1.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

    tensors["model.norm.weight"] = torch.ones(config["d_model"], dtype=torch.float32)
    if not config["weight_tying"]:
        tensors["model.output.weight"] = conv(weights["model.transformer.ff_out.weight"])
        quantizedtensors["model.output.weight"] = True
elif arch == "dbrx":
    tensors["model.embed.weight"] = conv(weights["transformer.wte.weight"])
    quantizedtensors["model.embed.weight"] = True

    for l in range(config["n_layers"]):
        tensors[f"model.layers.{l}.attn.norm.weight"] = weights[f"transformer.blocks.{l}.norm_attn_norm.norm_1.weight"].float()

        head_dim = config["d_model"] // config["n_heads"]
        n_heads = config["n_heads"]
        n_kv_heads = config["attn_config"]["kv_n_heads"]

        dim = config["d_model"]
        hidden_dim = config["ffn_config"]["ffn_hidden_size"]
        n_experts = config["ffn_config"]["moe_num_experts"]

        wqkv = weights[f"transformer.blocks.{l}.norm_attn_norm.attn.Wqkv.weight"]

        tensors[f"model.layers.{l}.attn.wq.weight"] = conv(permute_reverse(wqkv[:n_heads*head_dim], n_heads, head_dim))
        tensors[f"model.layers.{l}.attn.wk.weight"] = conv(permute_reverse(wqkv[n_heads*head_dim:(n_heads+n_kv_heads)*head_dim], n_kv_heads, head_dim))
        tensors[f"model.layers.{l}.attn.wv.weight"] = conv(wqkv[(n_heads+n_kv_heads)*head_dim:])
        tensors[f"model.layers.{l}.attn.wo.weight"] = conv(weights[f"transformer.blocks.{l}.norm_attn_norm.attn.out_proj.weight"])
        quantizedtensors[f"model.layers.{l}.attn.wq.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wk.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wv.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wo.weight"] = True

        tensors[f"model.layers.{l}.mlp.norm.weight"] = weights[f"transformer.blocks.{l}.norm_attn_norm.norm_2.weight"].float()

        tensors[f"model.layers.{l}.moegate.weight"] = conv(weights[f"transformer.blocks.{l}.ffn.router.layer.weight"])
        quantizedtensors[f"model.layers.{l}.moegate.weight"] = True

        tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(weights[f"transformer.blocks.{l}.ffn.experts.mlp.w1"].view(n_experts, hidden_dim, dim))
        tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"transformer.blocks.{l}.ffn.experts.mlp.w2"].view(n_experts, hidden_dim, dim).transpose(1, 2).contiguous())
        tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(weights[f"transformer.blocks.{l}.ffn.experts.mlp.v1"].view(n_experts, hidden_dim, dim))
        quantizedtensors[f"model.layers.{l}.mlp.w1.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

    tensors["model.norm.weight"] = weights["transformer.norm_f.weight"].float()
    tensors["model.output.weight"] = conv(weights["lm_head.weight"])
    quantizedtensors["model.output.weight"] = True

elif arch in ["phi3", "kphi3"]:
    
    # If kphi3, convert to phi3 layout first
    if arch == "kphi3":
        # Convert kphi3 weights to plain phi3 layout (in-place)

        def kphi3_build_dense_grouped_linear(Wg):
            """
            Wg: numpy array with shape [G, in_per, out_per] from GroupedLinearFast.weight
            returns dense W with shape [out, in] (PyTorch Linear convention)
            """
            G, in_per, out_per = Wg.shape
            C_in  = G * in_per
            C_out = G * out_per
            W = np.zeros((C_out, C_in), dtype=Wg.dtype)
            for g in range(G):
                r0, r1 = g * out_per, (g + 1) * out_per
                c0, c1 = g * in_per,  (g + 1) * in_per
                # einsum used x @ Wg[g] where Wg[g] is [in_per, out_per],
                # so dense block in PyTorch layout is (Wg[g].T) at [rows=r0:r1, cols=c0:c1]
                W[r0:r1, c0:c1] = Wg[g].T
            return W

        def kphi3_build_dense_grouped_bias(bg):
            # bg: [G, out_per]  ->  b: [G * out_per]
            if bg is None:
                return None
            return bg.reshape(-1)

        def kphi3_interleave_perm(C_in, groups):
            """
            InterleaveChannelsFast with last_dim=2 and step_size = input_group_size (in_per).
            Builds perm s.t.  x_interleaved = x[perm]
            """
            in_per = C_in // groups
            perm = np.empty(C_in, dtype=np.int64)
            # new index j receives old index i = (j % groups) * in_per + (j // groups)
            for j in range(C_in):
                g = j % groups
                off = j // groups
                perm[j] = g * in_per + off
            return perm

        def kphi3_fold_io_block(weights, base_key):
            """
            Returns (dense_weight [out, in], optional_bias or None) for either:
              - standard Linear at f"{base_key}.weight"  (PyTorch [out, in])
              - or IO block:
                  f"{base_key}.first_pointwise_conv.weight"   [G, in_per, out_per]
                  f"{base_key}.second_pointwise_conv.weight"  [G, in_per, out_per]
            """
            std = f"{base_key}.weight"
            stdb = f"{base_key}.bias"

            W = None
            B = None

            if std in weights:
                W = weights[std]
                B = weights.get(stdb, None)
            else:
                k1 = f"{base_key}.first_pointwise_conv.weight"
                k2 = f"{base_key}.second_pointwise_conv.weight"
                b1 = f"{base_key}.first_pointwise_conv.bias"
                b2 = f"{base_key}.second_pointwise_conv.bias"

                if k1 not in weights:
                    raise KeyError(f"Missing {std} and {k1} for {base_key}")

                W1g = weights[k1]  # [G, in_per, out_per]
                W1  = kphi3_build_dense_grouped_linear(W1g)
                B1  = kphi3_build_dense_grouped_bias(weights.get(b1, None))

                W = W1
                B = B1

                if k2 in weights:
                    W2g = weights[k2]
                    W2  = kphi3_build_dense_grouped_linear(W2g)
                    B2  = kphi3_build_dense_grouped_bias(weights.get(b2, None))

                    G, in_per, _ = W2g.shape
                    C_in = G * in_per
                    perm = kphi3_interleave_perm(C_in, G)

                    # Equivalent to W2 @ P  where P applies interleave to the input: just permute columns
                    W2P = W2[:, perm]
                    W = W1 + W2P

                    # Bias is additive (interleave acts on inputs, not outputs)
                    if (B1 is not None) or (B2 is not None):
                        if B1 is None:
                            B1 = np.zeros(W.shape[0], dtype=W.dtype)
                        if B2 is None:
                            B2 = np.zeros(W.shape[0], dtype=W.dtype)
                        B = B1 + B2

            return W, B

        def kphi3_convert_base(base_key: str):
            # Writes <base_key>.weight and optional <base_key>.bias, deletes kphi3 branch keys if present
            try:
                W, B = kphi3_fold_io_block(weights, base_key)
            except KeyError:
                return  # not present on this model/layer
            weights[f"{base_key}.weight"] = W
            if B is not None:
                weights[f"{base_key}.bias"] = B
            for k in (
                f"{base_key}.first_pointwise_conv.weight",
                f"{base_key}.second_pointwise_conv.weight",
                f"{base_key}.first_pointwise_conv.bias",
                f"{base_key}.second_pointwise_conv.bias",
            ):
                if k in weights:
                    del weights[k]

        # Per-layer conversions
        num_layers = config.get("num_hidden_layers") or config.get("n_layer") or config["num_layers"]
        for l in range(num_layers):
            prefix = f"model.layers.{l}."
            kphi3_convert_base(prefix + "self_attn.qkv_proj")
            kphi3_convert_base(prefix + "self_attn.o_proj")
            kphi3_convert_base(prefix + "mlp.gate_up_proj")
            kphi3_convert_base(prefix + "mlp.down_proj")

        # Optional bridge if present
        kphi3_convert_base("model.embed_to_hidden")

        # Continue with normal phi3 conversion
        arch = "phi3"

    tensors["model.embed.weight"] = conv(weights["model.embed_tokens.weight"])
    quantizedtensors["model.embed.weight"] = True

    for l in range(config["num_hidden_layers"]):
        tensors[f"model.layers.{l}.attn.norm.weight"] = weights[f"model.layers.{l}.input_layernorm.weight"].float()

        head_dim = config["hidden_size"] // config["num_attention_heads"]
        n_heads = config["num_attention_heads"]
        n_kv_heads = config.get("num_key_value_heads", n_heads)

        wqkv = weights[f"model.layers.{l}.self_attn.qkv_proj.weight"]

        tensors[f"model.layers.{l}.attn.wq.weight"] = conv(permute_reverse(wqkv[:n_heads*head_dim], n_heads, head_dim))
        tensors[f"model.layers.{l}.attn.wk.weight"] = conv(permute_reverse(wqkv[n_heads*head_dim:(n_heads+n_kv_heads)*head_dim], n_kv_heads, head_dim))
        quantizedtensors[f"model.layers.{l}.attn.wq.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wk.weight"] = True

        tensors[f"model.layers.{l}.attn.wv.weight"] = conv(wqkv[(n_heads+n_kv_heads)*head_dim:])
        tensors[f"model.layers.{l}.attn.wo.weight"] = conv(weights[f"model.layers.{l}.self_attn.o_proj.weight"])
        quantizedtensors[f"model.layers.{l}.attn.wv.weight"] = True
        quantizedtensors[f"model.layers.{l}.attn.wo.weight"] = True

        tensors[f"model.layers.{l}.mlp.norm.weight"] = weights[f"model.layers.{l}.post_attention_layernorm.weight"].float()

        hidden_dim = config["intermediate_size"]

        mlp_proj = weights[f"model.layers.{l}.mlp.gate_up_proj.weight"]

        tensors[f"model.layers.{l}.mlp.w1.weight"] = conv(mlp_proj[:hidden_dim])
        tensors[f"model.layers.{l}.mlp.w2.weight"] = conv(weights[f"model.layers.{l}.mlp.down_proj.weight"])
        tensors[f"model.layers.{l}.mlp.w3.weight"] = conv(mlp_proj[hidden_dim:])
        quantizedtensors[f"model.layers.{l}.mlp.w1.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w2.weight"] = True
        quantizedtensors[f"model.layers.{l}.mlp.w3.weight"] = True

    tensors["model.norm.weight"] = weights["model.norm.weight"].float()
    tensors["model.output.weight"] = conv(weights["lm_head.weight"])
    quantizedtensors["model.output.weight"] = True

# add tokenizer tensors at the end (to maximize the chance of model tensor alignment)
# note: we concatenate all bytes of all tokens into a single tensor, but with a uint32 prefix for each token length
print(f"\rConverting tokenizer tensors..." + " " * 40)
#tensors["tokenizer.tokens"] = torch.cat([torch.tensor([x for x in b] + [0], dtype=torch.uint8) for b in tokens]) # null-terminated tokens (old format, not used anymore)
tensors["tokenizer.tokens"] = torch.cat([torch.tensor(list(struct.pack('<I', len(b))) + list(b), dtype=torch.uint8) for b in tokens]) # tokens with uint32 length prefix each
tensors["tokenizer.scores"] = torch.tensor(scores, dtype=torch.float32)

print(f"\rSaving {len(tensors)} tensors..." + " " * 40)

# Add chat_template, bos_token, and eos_token to the metadata, when available
if chat_template is not None:
    metadata["chat_template"] = chat_template
if bos_token_value is not None:
    metadata["bos_token"] = bos_token_value
if eos_token_value is not None:
    metadata["eos_token"] = eos_token_value

# Add optional inference parameters to metadata if provided via command line
if args.temperature is not None:
    metadata["temperature"] = args.temperature
if args.top_p is not None:
    metadata["top_p"] = args.top_p
if args.penalty_last_n is not None:
    metadata["penalty_last_n"] = args.penalty_last_n
if args.penalty_repeat is not None:
    metadata["penalty_repeat"] = args.penalty_repeat
if args.penalty_frequency is not None:
    metadata["penalty_frequency"] = args.penalty_frequency
if args.penalty_presence is not None:
    metadata["penalty_presence"] = args.penalty_presence

# in a perfect world, we would just use HF safetensors.torch.save_file
# however, not only does it not support fp8 (https://github.com/huggingface/safetensors/pull/404), it also copies every tensor
# our models are large, so we'll implement a custom save function. could even materialize converted tensors lazily later.
def save_file(tensors, filename, metadata=None):
    _TYPES = {
        torch.float32: "F32",
        torch.float16: "F16",
        torch.bfloat16: "BF16",
        getattr(torch, "float8_e5m2", None): "F8_E5M2",
        getattr(torch, "float8_e4m3fn", None): "F8_E4M3",
        torch.int64: "I64",
        torch.int32: "I32",
        torch.int16: "I16",
        torch.int8: "I8",
        torch.uint8: "U8",
    }
    _ALIGN = 4096 # 4 KiB alignment for safetensors, since it is the most common memory page size 

    header = {}
    offset = 0
    offsets = {}
    if metadata:
        header["__metadata__"] = metadata
    for k, v in tensors.items():
        size = v.numel() * v.element_size()
        quantized = k in quantizedtensors and quantizedtensors[k] # Check if the tensor is quantized
        header[k] = { 
            "dtype": _TYPES[v.dtype], # For safetensors compatibility, use the base data types
            "shape": v.shape, # shape of the tensor
            "data_offsets": [offset, offset + size] # offsets of the tensor data in the file 
        }
        if quantized:
            header[k]["qtype"] = args.dtype.upper() # if quantized, the quantization data type as well, so that the LLM engine do know which quantization to use, independent of the dtype
            # if the quantization type is FP8, use the F8_E5M2 type for safetensors compatibility
            if(header[k]["qtype"] == "FP8"):
                header[k]["qtype"] = "F8_E5M2"
        offsets[k] = offset # used to seek to the tensor data in the file for writing
        offset += size
        # Align the offset to 4 KiB for optimal memory page size padding, since the file will be memory-mapped while being used 
        if (offset % _ALIGN) != 0:
            offset = offset + ((_ALIGN - (offset % _ALIGN)) % _ALIGN)

    hjson = json.dumps(header).encode("utf-8")
    if len(hjson) % _ALIGN != 0:
        # Pad the header to 4 KiB alignment
        # This is needed for safetensors format, which requires the header to be aligned to 4 KiB
        # The padding is done with null bytes
        hjson += b" " * (-(len(hjson) + 8) % _ALIGN)

    with open(filename, "wb") as f:
        jsonLen = len(hjson)
        f.write(jsonLen.to_bytes(8, byteorder="little"))
        f.write(hjson)
        startOffset = jsonLen + 8 # start of the tensor data in the file
        lastOffset = startOffset
        for k, v in tensors.items():
            # Write null padding to align the tensor data to their start offsets
            tensorStartOffset = startOffset + offsets[k]
            tensorData = v.view(torch.uint8).cpu().numpy()
            tensorSize = tensorData.nbytes
            tensorEndOffset = tensorStartOffset + tensorSize
            if lastOffset < tensorStartOffset:
                f.write(b"\x00" * (tensorStartOffset - lastOffset))
            lastOffset = tensorEndOffset
            # Write the tensor data
            assert v.layout == torch.strided and v.is_contiguous()
            tensorData.tofile(f)

# metadata values must be strings in safetensors
save_file(tensors, args.output, {k: str(v) for k, v in metadata.items()})
