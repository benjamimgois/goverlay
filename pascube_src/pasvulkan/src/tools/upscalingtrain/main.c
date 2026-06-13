/*
 * main.c — CNN Image Upscaler: CLI, Training Loop, Inference
 *
 * Commands:
 *   ./upscaler train  --data <dir> --factor <2|4> [options] --output model.bin
 *   ./upscaler infer  --model <file> --input <png> --output <png> [options]
 *   ./upscaler export --model <file> --format <binary|glsl> --output <file>
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#include "upscaler.h"
#include <dirent.h>
#include <sys/stat.h>
#include <time.h>

/* ============================================================================
 * Usage
 * ========================================================================= */

static void print_usage(const char *prog)
{
    printf(
        "CNN Image Upscaler (ESPCN) — Training & Inference Tool\n"
        "Part of PasVulkan engine toolchain\n"
        "\n"
        "Usage:\n"
        "  %s train  [options]\n"
        "  %s infer  [options]\n"
        "  %s export [options]\n"
        "\n"
        "TRAIN options:\n"
        "  --data <dir>          Training data directory (PNG files)\n"
        "  --factor <2|4>        Upscale factor (default: 2)\n"
        "  --channels <3|4>      3=RGB, 4=RGB+Depth (default: 3)\n"
        "  --colorspace <srgb|linear>  Working color space (default: srgb)\n"
        "  --epochs <n>          Number of epochs (default: 200)\n"
        "  --batch <n>           Batch size (default: 16)\n"
        "  --lr <f>              Initial learning rate (default: 0.001)\n"
        "  --lr-decay <n>        Halve LR every n epochs (default: 100)\n"
        "  --patch <n>           LR patch size (default: 32)\n"
        "  --loss <l1|mse>       Loss function (default: l1)\n"
        "  --feat1 <n>           First hidden layer features (default: 64)\n"
        "  --feat2 <n>           Second hidden layer features (default: 32)\n"
        "  --deep                Use 4-layer architecture\n"
        "  --seed <n>            RNG seed (default: 42)\n"
        "  --output <path>       Output model path (default: model.bin)\n"
        "  --save-every <n>      Checkpoint every n epochs (default: 50)\n"
        "  --iters-per-epoch <n> Iterations per epoch (default: auto)\n"
        "  --resume <path>       Resume training from checkpoint\n"
#ifdef USE_VULKAN
        "  --gpu                 Use Vulkan compute backend\n"
        "  --host-mem            Force host-visible memory (slower, for debugging)\n"
#endif
        "\n"
        "INFER options:\n"
        "  --model <file>        Model file\n"
        "  --input <png>         Input LR image\n"
        "  --output <png>        Output HR image\n"
        "  --depth <file>        Optional depth file (raw float32)\n"
        "  --depth-w <n>         Depth width\n"
        "  --depth-h <n>         Depth height\n"
        "  --scale-from <25|50|75>  Input scale percentage (default: 50)\n"
        "  --colorspace <srgb|linear>  Input color space (default: srgb)\n"
        "  --tonemap <none|brian_karis|amd>  Tonemapping (default: none)\n"
        "  --tile <n>            Tile size for large images (0=off, default: 0)\n"
#ifdef USE_VULKAN
        "  --gpu                 Use Vulkan compute backend\n"
        "  --host-mem            Force host-visible memory (slower, for debugging)\n"
#endif
        "\n"
        "EXPORT options:\n"
        "  --model <file>        Model file\n"
        "  --format <binary|glsl>  Export format\n"
        "  --output <file>       Output file path\n"
        "  --tonemap <none|brian_karis|amd>  Tonemapping in GLSL (default: none)\n"
        "\n",
        prog, prog, prog);
}

/* ============================================================================
 * Helper: collect PNG files from a directory
 * ========================================================================= */

static int ends_with_png(const char *name)
{
    size_t len = strlen(name);
    if (len < 4) return 0;
    const char *ext = name + len - 4;
    /* Case-insensitive compare without POSIX strcasecmp */
    return ((ext[0] == '.' || ext[0] == '.') &&
            (ext[1] == 'p' || ext[1] == 'P') &&
            (ext[2] == 'n' || ext[2] == 'N') &&
            (ext[3] == 'g' || ext[3] == 'G'));
}

static char **collect_png_files(const char *dir, int *count)
{
    DIR *d = opendir(dir);
    if (!d) {
        fprintf(stderr, "ERROR: cannot open directory %s\n", dir);
        return NULL;
    }

    int cap = 256;
    int n   = 0;
    char **files = (char **)malloc((size_t)cap * sizeof(char *));

    struct dirent *ent;
    while ((ent = readdir(d)) != NULL) {
        if (!ends_with_png(ent->d_name)) continue;
        if (n >= cap) {
            cap *= 2;
            files = (char **)realloc(files, (size_t)cap * sizeof(char *));
        }
        size_t plen = strlen(dir) + 1 + strlen(ent->d_name) + 1;
        files[n] = (char *)malloc(plen);
        snprintf(files[n], plen, "%s/%s", dir, ent->d_name);
        n++;
    }
    closedir(d);

    *count = n;
    if (n == 0) {
        fprintf(stderr, "ERROR: no PNG files found in %s\n", dir);
        free(files);
        return NULL;
    }

    printf("Found %d PNG files in %s\n", n, dir);
    return files;
}

/* ============================================================================
 * Helper: try to load matching depth file for a PNG
 *         e.g. "image.png" → "image.depth.raw"
 * ========================================================================= */

static float *try_load_depth(const char *png_path, int w, int h)
{
    /* Replace .png with .depth.raw */
    size_t len = strlen(png_path);
    char *dpath = (char *)malloc(len + 16);
    memcpy(dpath, png_path, len - 4);
    strcpy(dpath + len - 4, ".depth.raw");

    float *depth = image_load_depth(dpath, w, h);
    free(dpath);
    return depth;
}

/* ============================================================================
 * TRAIN
 * ========================================================================= */

static void train_mode(int argc, char **argv)
{
    /* Defaults */
    const char *data_dir    = NULL;
    const char *output_path = "model.bin";
    const char *resume_path = NULL;
    int factor      = DEFAULT_SCALE;
    int in_channels = 3;
    int colorspace  = COLORSPACE_SRGB;
    int epochs      = DEFAULT_EPOCHS;
    int batch_size  = DEFAULT_BATCH_SIZE;
    float lr        = DEFAULT_LR;
    int lr_decay    = DEFAULT_LR_DECAY;
    int patch_size  = DEFAULT_PATCH_SIZE;
    int loss_type   = LOSS_L1;
    int feat1       = DEFAULT_FEATURES_1;
    int feat2       = DEFAULT_FEATURES_2;
    int deep        = 0;
    uint32_t seed   = DEFAULT_SEED;
    int save_every  = DEFAULT_SAVE_EVERY;
    int iters_per_epoch = 0;  /* 0 = auto */
    int use_gpu __attribute__((unused))  = 0;
    int host_mem __attribute__((unused)) = 0;

    /* Parse arguments */
    for (int i = 2; i < argc; i++) {
        if      (!strcmp(argv[i], "--data")    && i+1 < argc) data_dir    = argv[++i];
        else if (!strcmp(argv[i], "--output")  && i+1 < argc) output_path = argv[++i];
        else if (!strcmp(argv[i], "--resume")  && i+1 < argc) resume_path = argv[++i];
        else if (!strcmp(argv[i], "--factor")  && i+1 < argc) factor      = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--channels")&& i+1 < argc) in_channels = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--epochs")  && i+1 < argc) epochs      = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--batch")   && i+1 < argc) batch_size  = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--lr")      && i+1 < argc) lr          = (float)atof(argv[++i]);
        else if (!strcmp(argv[i], "--lr-decay")&& i+1 < argc) lr_decay    = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--patch")   && i+1 < argc) patch_size  = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--feat1")   && i+1 < argc) feat1       = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--feat2")   && i+1 < argc) feat2       = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--seed")    && i+1 < argc) seed        = (uint32_t)atoi(argv[++i]);
        else if (!strcmp(argv[i], "--save-every") && i+1 < argc) save_every = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--iters-per-epoch") && i+1 < argc) iters_per_epoch = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--deep"))   deep = 1;
        else if (!strcmp(argv[i], "--gpu"))    use_gpu = 1;
        else if (!strcmp(argv[i], "--host-mem")) host_mem = 1;
        else if (!strcmp(argv[i], "--colorspace") && i+1 < argc) {
            i++;
            if      (!strcmp(argv[i], "linear")) colorspace = COLORSPACE_LINEAR;
            else if (!strcmp(argv[i], "srgb"))   colorspace = COLORSPACE_SRGB;
            else { fprintf(stderr, "Unknown colorspace: %s\n", argv[i]); return; }
        }
        else if (!strcmp(argv[i], "--loss") && i+1 < argc) {
            i++;
            if      (!strcmp(argv[i], "l1"))  loss_type = LOSS_L1;
            else if (!strcmp(argv[i], "mse")) loss_type = LOSS_MSE;
            else { fprintf(stderr, "Unknown loss: %s\n", argv[i]); return; }
        }
        else { fprintf(stderr, "Unknown option: %s\n", argv[i]); return; }
    }

    if (!data_dir) {
        fprintf(stderr, "ERROR: --data is required\n");
        return;
    }
    if (factor != 2 && factor != 4) {
        fprintf(stderr, "ERROR: --factor must be 2 or 4\n");
        return;
    }

    rng_seed(seed);

    /* Load training images */
    int num_files = 0;
    char **files = collect_png_files(data_dir, &num_files);
    if (!files) return;

    printf("Loading training images...\n");
    float **images    = (float **)calloc((size_t)num_files, sizeof(float *));
    float **depths    = (float **)calloc((size_t)num_files, sizeof(float *));
    int   *img_w      = (int *)calloc((size_t)num_files, sizeof(int));
    int   *img_h      = (int *)calloc((size_t)num_files, sizeof(int));
    int    num_loaded  = 0;

    for (int i = 0; i < num_files; i++) {
        int w, h, ch;
        float *img = image_load_png(files[i], &w, &h, &ch);
        if (!img) continue;

        /* Minimum size: must fit at least one HR patch */
        int hps = patch_size * factor;
        if (w < hps || h < hps) {
            fprintf(stderr, "SKIP: %s too small (%dx%d, need %dx%d)\n",
                    files[i], w, h, hps, hps);
            free(img);
            continue;
        }

        /* Colour space conversion */
        if (colorspace == COLORSPACE_LINEAR) {
            image_srgb_to_linear(img, 3 * w * h);
        }

        images[num_loaded] = img;
        img_w[num_loaded]  = w;
        img_h[num_loaded]  = h;

        /* Try loading depth if 4-channel model */
        if (in_channels == 4) {
            depths[num_loaded] = try_load_depth(files[i], w, h);
        }

        num_loaded++;
    }

    /* Free file paths */
    for (int i = 0; i < num_files; i++) free(files[i]);
    free(files);

    if (num_loaded == 0) {
        fprintf(stderr, "ERROR: no usable training images\n");
        free(images); free(depths); free(img_w); free(img_h);
        return;
    }
    printf("Loaded %d training images\n", num_loaded);

    /* Create or resume model */
    Model *model;
    int start_epoch = 0;
    if (resume_path) {
        model = model_load(resume_path);
        if (!model) {
            fprintf(stderr, "ERROR: cannot load checkpoint %s\n", resume_path);
            goto cleanup;
        }
        printf("Resuming from %s\n", resume_path);
    } else {
        model = model_create(factor, in_channels, feat1, feat2, deep, colorspace);
    }

    /* Print model info */
    {
        int total = 0;
        for (int i = 0; i < model->num_layers; i++)
            total += model->w_count[i] + model->b_count[i];
        printf("\nModel: %d× upscale, %d layers, %d params (%.1f KB)\n",
               factor, model->num_layers, total, (float)(total * 4) / 1024.0f);
        printf("Training: %d epochs, batch %d, patch %d (LR), loss=%s, lr=%.6f\n",
               epochs, batch_size, patch_size,
               loss_type == LOSS_L1 ? "L1" : "MSE", (double)lr);
        printf("Color space: %s\n",
               colorspace == COLORSPACE_LINEAR ? "linear" : "sRGB");
        printf("Backend: %s\n\n", use_gpu ? "Vulkan GPU" : "CPU");
    }

    /* Auto-compute iterations per epoch if not set */
    if (iters_per_epoch <= 0) {
        /* Estimate: enough iterations to see each image ~10 times per epoch */
        iters_per_epoch = (num_loaded * 10) / batch_size;
        if (iters_per_epoch < 50) iters_per_epoch = 50;
        if (iters_per_epoch > 2000) iters_per_epoch = 2000;
    }
    printf("Iterations per epoch: %d\n\n", iters_per_epoch);

    /* Allocate patch buffers (single sample, not batched) */
    const int lps = patch_size;
    const int hps = patch_size * factor;
    float *lr_patch = (float *)malloc((size_t)in_channels * lps * lps * sizeof(float));
    float *hr_patch = (float *)malloc((size_t)3 * hps * hps * sizeof(float));
    float *output   = (float *)malloc((size_t)3 * hps * hps * sizeof(float));
    float *grad     = (float *)malloc((size_t)3 * hps * hps * sizeof(float));

    /* GPU batched buffers (only allocated when --gpu) */
    float *lr_batch = NULL;
    float *hr_batch = NULL;

#ifdef USE_VULKAN
    VkCNN *gpu = NULL;
    if (use_gpu) {
        gpu = vkcnn_create(model, host_mem, /*training=*/1);
        lr_batch = (float *)malloc((size_t)batch_size * in_channels * lps * lps * sizeof(float));
        hr_batch = (float *)malloc((size_t)batch_size * 3 * hps * hps * sizeof(float));
    }
#else
    if (use_gpu) {
        fprintf(stderr, "ERROR: --gpu requires building with VULKAN=1\n");
        model_free(model);
        goto cleanup;
    }
#endif

    int adam_step = start_epoch * iters_per_epoch + 1;
    float current_lr = lr;
    clock_t t_start = clock();

    /* ---- Training loop ------------------------------------------------ */
    for (int epoch = start_epoch; epoch < epochs; epoch++) {

        /* Learning rate decay */
        if (lr_decay > 0 && epoch > 0 && epoch % lr_decay == 0) {
            current_lr *= 0.5f;
            printf("  LR decayed to %.6f\n", (double)current_lr);
        }

        double epoch_loss = 0.0;
        int    epoch_samples = 0;

        for (int iter = 0; iter < iters_per_epoch; iter++) {

#ifdef USE_VULKAN
            if (use_gpu) {
                /* ---- GPU training path -------------------------------- */
                /* Build batch on CPU */
                int actual_batch = 0;
                for (int b = 0; b < batch_size; b++) {
                    int idx = rng_int(0, num_loaded - 1);
                    if (!image_extract_patch_pair(images[idx], depths[idx],
                                                  img_w[idx], img_h[idx],
                                                  factor, lps, in_channels,
                                                  lr_patch, hr_patch))
                        continue;
                    image_augment(lr_patch, hr_patch, lps, hps, in_channels, 3);

                    memcpy(lr_batch + (size_t)actual_batch * in_channels * lps * lps,
                           lr_patch, (size_t)in_channels * lps * lps * sizeof(float));
                    memcpy(hr_batch + (size_t)actual_batch * 3 * hps * hps,
                           hr_patch, (size_t)3 * hps * hps * sizeof(float));
                    actual_batch++;
                }
                if (actual_batch == 0) continue;

                /* Full combined step: zero+fwd+loss+bwd+scale+adam in ONE submission */
                float batch_loss = vkcnn_train_step_full(gpu, lr_batch, hr_batch,
                                                          actual_batch, lps, lps,
                                                          loss_type, current_lr,
                                                          DEFAULT_BETA1, DEFAULT_BETA2,
                                                          DEFAULT_EPSILON, adam_step);
                adam_step++;

                epoch_loss += (double)(batch_loss / (float)actual_batch);
                epoch_samples += actual_batch;
            } else
#endif
            {
                /* ---- CPU training path -------------------------------- */
                model_zero_grad(model);
                float batch_loss = 0.0f;

                for (int b = 0; b < batch_size; b++) {
                    int idx = rng_int(0, num_loaded - 1);
                    if (!image_extract_patch_pair(images[idx], depths[idx],
                                                  img_w[idx], img_h[idx],
                                                  factor, lps, in_channels,
                                                  lr_patch, hr_patch))
                        continue;
                    image_augment(lr_patch, hr_patch, lps, hps, in_channels, 3);
                    model_forward(model, lr_patch, output, 1, lps, lps);

                    const int out_count = 3 * hps * hps;
                    float sample_loss = 0.0f;
                    if (loss_type == LOSS_L1) {
                        for (int j = 0; j < out_count; j++) {
                            float diff = output[j] - hr_patch[j];
                            sample_loss += fabsf(diff);
                            grad[j] = (diff >= 0.0f ? 1.0f : -1.0f)
                                      / (float)out_count;
                        }
                        sample_loss /= (float)out_count;
                    } else {
                        for (int j = 0; j < out_count; j++) {
                            float diff = output[j] - hr_patch[j];
                            sample_loss += diff * diff;
                            grad[j] = 2.0f * diff / (float)out_count;
                        }
                        sample_loss /= (float)out_count;
                    }
                    batch_loss += sample_loss;
                    model_backward(model, grad);
                }

                model_scale_grads(model, 1.0f / (float)batch_size);
                model_adam_update(model, current_lr,
                                  DEFAULT_BETA1, DEFAULT_BETA2, DEFAULT_EPSILON,
                                  adam_step);
                adam_step++;

                epoch_loss += (double)(batch_loss / (float)batch_size);
                epoch_samples += batch_size;
            }
        }

        epoch_loss /= (double)iters_per_epoch;

        double psnr = 0.0;
        if (loss_type == LOSS_MSE && epoch_loss > 1e-10) {
            psnr = 10.0 * log10(1.0 / epoch_loss);
        } else if (loss_type == LOSS_L1 && epoch_loss > 1e-10) {
            psnr = 10.0 * log10(1.0 / (epoch_loss * epoch_loss));
        }

        double elapsed = (double)(clock() - t_start) / CLOCKS_PER_SEC;
        printf("Epoch %4d/%d  loss=%.6f  psnr≈%.2f dB  lr=%.6f  samples=%d  (%.1fs)\n",
               epoch + 1, epochs, epoch_loss, psnr,
               (double)current_lr, epoch_samples, elapsed);

        /* Checkpoint */
        if (save_every > 0 && (epoch + 1) % save_every == 0
            && epoch + 1 < epochs) {
#ifdef USE_VULKAN
            if (use_gpu) vkcnn_download_weights(gpu, model);
#endif
            char ckpt[512];
            snprintf(ckpt, sizeof(ckpt), "%s.epoch%d",
                     output_path, epoch + 1);
            model_save(model, ckpt);
        }
    }

    /* Download final weights from GPU */
#ifdef USE_VULKAN
    if (use_gpu) vkcnn_download_weights(gpu, model);
#endif

    /* Save final model */
    model_save(model, output_path);

    /* Cleanup */
    free(lr_patch);
    free(hr_patch);
    free(output);
    free(grad);
    free(lr_batch);
    free(hr_batch);
#ifdef USE_VULKAN
    if (gpu) vkcnn_destroy(gpu);
#endif
    model_free(model);

cleanup:
    for (int i = 0; i < num_loaded; i++) {
        free(images[i]);
        free(depths[i]);
    }
    free(images);
    free(depths);
    free(img_w);
    free(img_h);
}

/* ============================================================================
 * INFER
 * ========================================================================= */

static void infer_mode(int argc, char **argv)
{
    const char *model_path  = NULL;
    const char *input_path  = NULL;
    const char *output_path = NULL;
    const char *depth_path  = NULL;
    int depth_w = 0, depth_h = 0;
    int scale_from  = 50;
    int colorspace  = COLORSPACE_SRGB;
    int tonemap_var = TONEMAP_NONE;
    int tile_size   = 0;
    int use_gpu __attribute__((unused)) = 0;
    int host_mem __attribute__((unused)) = 0;

    for (int i = 2; i < argc; i++) {
        if      (!strcmp(argv[i], "--model")  && i+1 < argc) model_path  = argv[++i];
        else if (!strcmp(argv[i], "--input")  && i+1 < argc) input_path  = argv[++i];
        else if (!strcmp(argv[i], "--output") && i+1 < argc) output_path = argv[++i];
        else if (!strcmp(argv[i], "--depth")  && i+1 < argc) depth_path  = argv[++i];
        else if (!strcmp(argv[i], "--depth-w")&& i+1 < argc) depth_w     = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--depth-h")&& i+1 < argc) depth_h     = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--scale-from") && i+1 < argc) scale_from = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--tile")   && i+1 < argc) tile_size   = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--gpu"))    use_gpu = 1;
        else if (!strcmp(argv[i], "--host-mem")) host_mem = 1;
        else if (!strcmp(argv[i], "--colorspace") && i+1 < argc) {
            i++;
            if      (!strcmp(argv[i], "linear")) colorspace = COLORSPACE_LINEAR;
            else if (!strcmp(argv[i], "srgb"))   colorspace = COLORSPACE_SRGB;
        }
        else if (!strcmp(argv[i], "--tonemap") && i+1 < argc) {
            i++;
            if      (!strcmp(argv[i], "brian_karis")) tonemap_var = TONEMAP_BRIAN_KARIS;
            else if (!strcmp(argv[i], "amd"))         tonemap_var = TONEMAP_AMD;
            else                                     tonemap_var = TONEMAP_NONE;
        }
        else { fprintf(stderr, "Unknown option: %s\n", argv[i]); return; }
    }

    if (!model_path || !input_path || !output_path) {
        fprintf(stderr, "ERROR: --model, --input, and --output are required\n");
        return;
    }

    /* Load model */
    Model *model = model_load(model_path);
    if (!model) return;

    const int r = model->scale_factor;

    /* Load input image */
    int iw, ih, ich;
    float *input = image_load_png(input_path, &iw, &ih, &ich);
    if (!input) { model_free(model); return; }

    printf("Input: %dx%d (%d channels)\n", iw, ih, ich);

    /* Optional colour space conversion */
    if (colorspace == COLORSPACE_LINEAR && model->colorspace == COLORSPACE_LINEAR) {
        image_srgb_to_linear(input, 3 * iw * ih);
    } else if (colorspace == COLORSPACE_SRGB && model->colorspace == COLORSPACE_LINEAR) {
        /* sRGB input → linear model: convert sRGB→linear first */
        image_srgb_to_linear(input, 3 * iw * ih);
    } else if (colorspace == COLORSPACE_LINEAR && model->colorspace == COLORSPACE_SRGB) {
        /* linear input → sRGB model: apply tonemapping  */
        if (tonemap_var != TONEMAP_NONE)
            image_apply_tonemapping(input, iw, ih, tonemap_var);
        else
            image_linear_to_srgb(input, 3 * iw * ih);
    }

    /* Optional depth channel */
    float *depth = NULL;
    if (depth_path && model->in_channels == 4) {
        if (depth_w <= 0) depth_w = iw;
        if (depth_h <= 0) depth_h = ih;
        depth = image_load_depth(depth_path, depth_w, depth_h);
    }

    /* Prepare input tensor (in_channels × H × W) */
    float *input_tensor;
    if (model->in_channels > 3 && depth) {
        input_tensor = (float *)malloc((size_t)model->in_channels * iw * ih * sizeof(float));
        memcpy(input_tensor, input, (size_t)3 * iw * ih * sizeof(float));
        memcpy(input_tensor + 3 * iw * ih, depth,
               (size_t)1 * iw * ih * sizeof(float));
    } else if (model->in_channels > 3) {
        /* No depth: zero-fill */
        input_tensor = (float *)calloc((size_t)model->in_channels * iw * ih, sizeof(float));
        memcpy(input_tensor, input, (size_t)3 * iw * ih * sizeof(float));
    } else {
        input_tensor = input;
        input = NULL; /* avoid double-free */
    }

    /* Allocate output (3 × oh × ow) */
    int ow = iw * r;
    int oh = ih * r;
    float *output;

    if (tile_size > 0) {
        /* Tiled inference for large images */
        const int overlap = 8; /* border overlap in LR pixels */
        output = (float *)calloc((size_t)3 * oh * ow, sizeof(float));

        printf("Tiled inference: tile=%d overlap=%d\n", tile_size, overlap);

        for (int ty = 0; ty < ih; ty += tile_size) {
            for (int tx = 0; tx < iw; tx += tile_size) {
                /* Tile boundaries with overlap */
                int x0 = tx - overlap; if (x0 < 0) x0 = 0;
                int y0 = ty - overlap; if (y0 < 0) y0 = 0;
                int x1 = tx + tile_size + overlap; if (x1 > iw) x1 = iw;
                int y1 = ty + tile_size + overlap; if (y1 > ih) y1 = ih;
                int tw = x1 - x0;
                int th = y1 - y0;

                /* Extract tile */
                float *tile = (float *)malloc((size_t)model->in_channels * tw * th * sizeof(float));
                for (int c = 0; c < model->in_channels; c++)
                    for (int y = 0; y < th; y++)
                        for (int x = 0; x < tw; x++)
                            tile[(c * th + y) * tw + x] =
                                input_tensor[(c * ih + y0 + y) * iw + x0 + x];

                /* Process tile */
                float *tile_out = (float *)malloc((size_t)3 * (th * r) * (tw * r) * sizeof(float));
                model_forward(model, tile, tile_out, 1, th, tw);

                /* Copy interior to output (skip overlap region) */
                int out_x0 = (tx - x0) * r;
                int out_y0 = (ty - y0) * r;
                int copy_w = (tx + tile_size > iw ? iw - tx : tile_size) * r;
                int copy_h = (ty + tile_size > ih ? ih - ty : tile_size) * r;

                for (int c = 0; c < 3; c++)
                    for (int y = 0; y < copy_h; y++)
                        for (int x = 0; x < copy_w; x++)
                            output[(c * oh + ty * r + y) * ow + tx * r + x] =
                                tile_out[(c * th * r + out_y0 + y) * tw * r + out_x0 + x];

                free(tile);
                free(tile_out);
            }
        }
    } else {
        /* Full-image inference */
        output = (float *)malloc((size_t)3 * oh * ow * sizeof(float));
        printf("Running inference: %dx%d → %dx%d", iw, ih, ow, oh);

        clock_t t0 = clock();

#ifdef USE_VULKAN
        if (use_gpu) {
            printf(" (Vulkan GPU)\n");
            VkCNN *gpu = vkcnn_create(model, host_mem, /*training=*/0);
            vkcnn_forward(gpu, input_tensor, output, 1, ih, iw);
            vkcnn_destroy(gpu);
        } else
#endif
        {
            printf(" (CPU)\n");
            model_forward(model, input_tensor, output, 1, ih, iw);
        }

        double elapsed = (double)(clock() - t0) / CLOCKS_PER_SEC;
        printf("Inference time: %.3f s\n", elapsed);
    }

    /* Handle 75% case: 2x upscale → 150%, then downsample to 100% */
    float *final_output = output;
    int final_w = ow;
    int final_h = oh;

    if (scale_from == 75) {
        /* Input was 75% of target, we 2x'd to 150%, now downsample to 100%.
         * Target = (input_size / 0.75) = input_size * 4/3
         * We have: output = input * 2  (i.e. 75% * 2 = 150% of target)
         * Need:    target = 100%       = 2/3 of output
         */
        int target_w = (iw * 4 + 2) / 3;  /* round to nearest */
        int target_h = (ih * 4 + 2) / 3;
        printf("75%% mode: downscaling %dx%d → %dx%d\n", ow, oh, target_w, target_h);
        final_output = image_downscale_bilinear(output, ow, oh, 3,
                                                 target_w, target_h);
        final_w = target_w;
        final_h = target_h;
        free(output);
    }

    /* Reverse colour space conversion */
    if (colorspace == COLORSPACE_LINEAR && model->colorspace == COLORSPACE_SRGB) {
        if (tonemap_var != TONEMAP_NONE)
            image_apply_inverse_tonemapping(final_output, final_w, final_h,
                                             tonemap_var);
        else
            image_srgb_to_linear(final_output, 3 * final_w * final_h);
    }
    if (model->colorspace == COLORSPACE_LINEAR) {
        /* Convert back to sRGB for PNG output */
        image_linear_to_srgb(final_output, 3 * final_w * final_h);
    }

    /* Save */
    if (image_save_png(output_path, final_output, final_w, final_h, 3))
        printf("Saved: %s (%dx%d)\n", output_path, final_w, final_h);

    /* Cleanup */
    free(final_output);
    free(input);
    free(depth);
    if (input_tensor != input) free(input_tensor);
    model_free(model);
}

/* ============================================================================
 * EXPORT
 * ========================================================================= */

static void export_mode(int argc, char **argv)
{
    const char *model_path  = NULL;
    const char *output_path = NULL;
    const char *format      = "binary";
    int tonemap_var = TONEMAP_NONE;

    for (int i = 2; i < argc; i++) {
        if      (!strcmp(argv[i], "--model")  && i+1 < argc) model_path  = argv[++i];
        else if (!strcmp(argv[i], "--output") && i+1 < argc) output_path = argv[++i];
        else if (!strcmp(argv[i], "--format") && i+1 < argc) format      = argv[++i];
        else if (!strcmp(argv[i], "--tonemap") && i+1 < argc) {
            i++;
            if      (!strcmp(argv[i], "brian_karis")) tonemap_var = TONEMAP_BRIAN_KARIS;
            else if (!strcmp(argv[i], "amd"))         tonemap_var = TONEMAP_AMD;
        }
        else { fprintf(stderr, "Unknown option: %s\n", argv[i]); return; }
    }

    if (!model_path || !output_path) {
        fprintf(stderr, "ERROR: --model and --output are required\n");
        return;
    }

    Model *model = model_load(model_path);
    if (!model) return;

    if (!strcmp(format, "glsl")) {
        model_export_glsl(model, output_path, tonemap_var);
    } else if (!strcmp(format, "binary")) {
        model_save(model, output_path);
    } else {
        fprintf(stderr, "ERROR: unknown format '%s' (use binary or glsl)\n", format);
    }

    model_free(model);
}

/* ============================================================================
 * Main
 * ========================================================================= */

int main(int argc, char **argv)
{
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }

    if      (!strcmp(argv[1], "train"))  train_mode(argc, argv);
    else if (!strcmp(argv[1], "infer"))  infer_mode(argc, argv);
    else if (!strcmp(argv[1], "export")) export_mode(argc, argv);
    else if (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-h"))
        print_usage(argv[0]);
    else {
        fprintf(stderr, "Unknown command: %s\n", argv[1]);
        print_usage(argv[0]);
        return 1;
    }

    return 0;
}
