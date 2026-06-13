> [!IMPORTANT]
> The primary repository has moved to [git.rosseaux.net/BeRo1985/pasllm](https://git.rosseaux.net/BeRo1985/pasllm).
> This GitHub repository is kept up-to-date via push mirroring.

# PasLLM

A high-performance Large Language Model inference engine written in pure Object Pascal.

## Overview

PasLLM is a native Pascal implementation for running LLMs locally with optimized quantization and inference capabilities. It supports multiple model architectures and features advanced 4-bit quantization formats for efficient model deployment.

It is currently CPU-only, with no GPU acceleration. GPU acceleration will be added in the future using my PasVulkan framework, but this will take time and effort. Until at least Q2 2026, I'm focusing on other professional projects, so please be patient. The same applies to support for multi-modal models, models with newer architectures (Mamba, etc.) and so on.

## Features

- **Pure Object Pascal** - No Python or external dependencies for inference
- **Cross-Platform** - Compatible with Delphi ≥11.2 and FreePascal ≥3.3.1
- **Multiple Architectures** - Support for Llama, Qwen, Phi, Gemma, Mixtral, and more
- **Advanced Quantization** - Custom Q4*NL formats (Q40NL, Q41NL, Q42NL, Q43NL) with superior tail reconstruction
- **Optimized Performance** - Native Pascal implementation with platform-specific optimizations
- **CLI and GUI** - Both command-line interface and visual applications (FMX, VCL, LCL)

## Quantization Formats

PasLLM implements several custom 4-bit and 8-bit quantization formats designed for optimal quality/size tradeoff:

- **Q40NL** - 4.5 bits/weight with non-linear decode (often better than Q40) 
- **Q41NL** - Alternative non-linearity with increased tail emphasis
- **Q42NL** - Enhanced variant with improved reconstruction
- **Q43NL** - Advanced format with multiple optimization methods (gradient, coarse-fine, grid)
- **Q40** - 4 bits/weight standard quantization (matches llama.cpp Q4_0 quality)
- **Q80** - 8-bit quantization for higher quality (matches llama.cpp Q8_0 quality)
- **Q3F8** - 8x 3 bits weights + 1x 8-bit float FP8 scale per block for 4-bits/weight efficiency
- **FP8** - 8-bit floating point support
- **FP16** - 16-bit floating point support
- **BF16** - Brain Floating Point 16-bit support (basically truncated 32-bit float where the lower 16 bits are cut)
- **FP32** - Standard 32-bit floating point support (for reference and testing)

These formats achieve 99.5-99.97% of full precision quality while maintaining compact model sizes.

## Supported Models

Pre-quantized models are available at [https://mega.nz/folder/krcgHCpZ#0tjLqup_Hc4THWC9itDrTg](https://mega.nz/folder/krcgHCpZ#0tjLqup_Hc4THWC9itDrTg), which must be placed in the `bin/models/` directory. Supported architectures include: 

- **Llama** - 3/3.1/3.2 (1B, 3B, 8B variants, including abliterated/uncensored)
- **Qwen 2.5** - 0.5B, 1.5B, 3B, 7B Instruct
- **Qwen 3** - 0.6B, 1.7B, 4B, 8B, 14B, 32B (including thinking/coder/abliterated variants, 30B MoE models)
- **Phi-3** - Mini, Medium (4K context)
- **Gemma** - 1.1 (2B) (support for Gemma 2 and 3 coming later)
- **SmolLM 2** - 135M, 360M, 1.7B
- **SmolLM 3** - 3B
- **Mixtral** - 8x7B Instruct
- **EuroMoE** - 2.6B (0.6B active)
- **SimpleChat** - 4B, 14B
- **DeepSeek** - R1 variants
- **TinyLlama** - 1.1B Chat

## Quick Start

### Command Line Interface

```bash
# Run inference with a quantized model
./bin/pasllmcli -model=bin/models/qwen2.5_0.5b_instruct_q40nl.safetensors
```

### Building from Source

**FreePascal:**
```bash
fpc -O3 src/pasllmcli/pasllmcli.dpr
```

**Delphi:**
Open `src/pasllmcli/pasllmcli.dproj` in Delphi IDE and build.

## Project Structure

```
src/
  ├── PasLLM.pas              # Core inference engine
  ├── PasLLMChatControl.pas   # Chat interface control
  ├── pasllmcli/              # Command-line interface
  ├── pasllmappfmx/           # FireMonkey GUI app
  ├── pasllmappvcl/           # VCL GUI app
  └── pasllmapplcl/           # Lazarus LCL GUI app
tools/
  └── convert.py              # Model conversion utilities
docs/
  └── quant_4bit_formats.md   # Detailed format specifications
```

## Conversion of Models

Models from Hugging Face can be converted to PasLLM format using the `convert.py` script in the `tools/` directory. Example usage:

```bash
cd ${modelpath}

# Q40NL conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q40nl --cpu ${pasllmbasepath}/bin/models/${modelname}_q40nl.safetensors

# Q41NL conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q41nl --cpu ${pasllmbasepath}/bin/models/${modelname}_q41nl.safetensors 

# Q42NL conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q42nl --cpu ${pasllmbasepath}/bin/models/${modelname}_q42nl.safetensors

# Q43NL conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q43nl --cpu ${pasllmbasepath}/bin/models/${modelname}_q43nl.safetensors

# Q40 conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q40 --cpu ${pasllmbasepath}/bin/models/${modelname}_q40.safetensors

# Q80 conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q80 --cpu ${pasllmbasepath}/bin/models/${modelname}_q80.safetensors

# Q3F8 conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype q3f8 --cpu ${pasllmbasepath}/bin/models/${modelname}_q3f8.safetensors

# FP8 conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype fp8 --cpu ${pasllmbasepath}/bin/models/${modelname}_fp8.safetensors

# FP16 conversion example
python ${pasllmbasepath}/tools/convert.py --config config.json --tokenizer tokenizer.json --models model*.safetensors --dtype fp16 --cpu ${pasllmbasepath}/bin/models/${modelname}_fp16.safetensors

# and so on for BF16 and FP32...

```

## Documentation

- [4-bit Quantization Formats](docs/quant_4bit_formats.md) - Complete specification of Q4*NL formats

## License

Dual-licensed under:
- **AGPL 3.0** for open-source use
- **Commercial license** available for proprietary applications (contact: benjamin@rosseaux.com)

## Author

**Benjamin Rosseaux** (BeRo)  
GitHub: [@BeRo1985](https://github.com/BeRo1985)  
Contact: benjamin@rosseaux.com

## Additional Information

- Code is compatible with both Delphi ≥11.2 and FreePascal ≥3.3.1
- Compiles on 32-bit and 64-bit platforms (x86-32, x86-64, ARM, ARM64), but 64-bit is preferred due to model sizes (32-bit may run out of memory). The 64-bit targets are more tested and verified. 32-bit support is unofficial and at your own risk.
- No platform-specific or third-party dependencies (unless out-ifdef-able)
