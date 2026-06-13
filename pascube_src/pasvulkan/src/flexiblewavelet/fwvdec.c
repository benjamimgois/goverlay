/******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************/
/*
 * fwvdec.c — GPU decode + validation harness.
 *
 * Includes fwvwave.c as the codec / container format / CPU reference. For every frame it:
 *   1. CPU-encodes the frame (encode_frame_coefdiff) to get a valid bit-plane stream,
 *   2. uploads the block bytes, the per-block offset tables and the quant-step map,
 *   3. decodes entirely on the GPU:
 *        bitplane_unpack (one workgroup per block) -> dequant -> inverse wavelet -> round ->
 *        YCoCg-R -> RGB into an rgba8 image,
 *   4. reads the image back and compares it to the CPU decode (PSNR), and times the GPU.
 *
 * It proves the raw bit-plane format decodes fully in parallel on the GPU and that the GPU
 * matches the CPU reference. quality == 0 selects the lossless integer 5/3 path (bit-exact);
 * quality >= 1 the lossy 9/7 path.
 *
 *     ./fwvdec in.(mp4|y4m) [quality=8] [levels=5] [max_frames=4]
 */
#define FWV_NO_MAIN
#include "fwvwave.c"
#include <vulkan/vulkan.h>

// Abort with file/line if a Vulkan call returns an error.
#define VK_CHECK(expression) do {                                              \
    VkResult _result = (expression);                                           \
    if (_result) {                                                             \
      fprintf(stderr, "vk error %d at %d\n", _result, __LINE__);               \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)

#define HOST_VISIBLE_COHERENT (VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
#define DEVICE_LOCAL          VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT

static VkDevice device;
static VkPhysicalDevice physical_device;
static VkCommandBuffer command_buffer;

// ---------------------------------------------------------------- Vulkan helpers

// First memory type that satisfies the buffer's type bits and has all the requested properties.
static uint32_t find_memory_type(uint32_t type_bits, VkMemoryPropertyFlags wanted) {
  VkPhysicalDeviceMemoryProperties memory_properties;
  vkGetPhysicalDeviceMemoryProperties(physical_device, &memory_properties);
  for (uint32_t i = 0; i < memory_properties.memoryTypeCount; i++) {
    if ((type_bits & (1u << i)) && ((memory_properties.memoryTypes[i].propertyFlags & wanted) == wanted)) {
      return i;
    }
  }
  die("no suitable memory type");
  return 0;
}

// Create a storage buffer (usable as transfer source and destination too) plus its backing memory.
static void create_buffer(VkDeviceSize size, VkMemoryPropertyFlags properties, VkBuffer *out_buffer, VkDeviceMemory *out_memory) {
  VkBufferCreateInfo buffer_info = { VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
  buffer_info.size = size ? size : 4;
  buffer_info.usage = (VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT) | VK_BUFFER_USAGE_TRANSFER_DST_BIT;
  VK_CHECK(vkCreateBuffer(device, &buffer_info, 0, out_buffer));

  VkMemoryRequirements requirements;
  vkGetBufferMemoryRequirements(device, *out_buffer, &requirements);
  VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  allocate_info.allocationSize = requirements.size;
  allocate_info.memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, properties);
  VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, out_memory));
  VK_CHECK(vkBindBufferMemory(device, *out_buffer, *out_memory, 0));
}

static uint32_t *load_spirv(const char *path, size_t *out_size) {
  FILE *file = fopen(path, "rb");
  if (!file) {
    fprintf(stderr, "open %s\n", path);
    exit(1);
  }
  fseek(file, 0, SEEK_END);
  long size = ftell(file);
  fseek(file, 0, SEEK_SET);
  uint32_t *code = checked_malloc(size);
  if (fread(code, 1, size, file) != (size_t)size) {
    die("spirv read");
  }
  fclose(file);
  *out_size = size;
  return code;
}

// Descriptor set layout with `storage_buffer_count` storage buffers, optionally a trailing storage image.
static VkDescriptorSetLayout create_descriptor_set_layout(int storage_buffer_count, int has_storage_image) {
  VkDescriptorSetLayoutBinding bindings[8];
  int binding_count = 0;
  for (int i = 0; i < storage_buffer_count; i++) {
    bindings[binding_count++] = (VkDescriptorSetLayoutBinding){ i, VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 };
  }
  if (has_storage_image) {
    bindings[binding_count++] = (VkDescriptorSetLayoutBinding){ storage_buffer_count, VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 };
  }
  VkDescriptorSetLayoutCreateInfo info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
  info.bindingCount = binding_count;
  info.pBindings = bindings;
  VkDescriptorSetLayout layout;
  VK_CHECK(vkCreateDescriptorSetLayout(device, &info, 0, &layout));
  return layout;
}

static VkPipelineLayout create_pipeline_layout(VkDescriptorSetLayout set_layout, uint32_t push_constant_size) {
  VkPushConstantRange push_range = { VK_SHADER_STAGE_COMPUTE_BIT, 0, push_constant_size };
  VkPipelineLayoutCreateInfo info = { VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
  info.setLayoutCount = 1;
  info.pSetLayouts = &set_layout;
  info.pushConstantRangeCount = 1;
  info.pPushConstantRanges = &push_range;
  VkPipelineLayout layout;
  VK_CHECK(vkCreatePipelineLayout(device, &info, 0, &layout));
  return layout;
}

static VkPipeline create_compute_pipeline(const char *spirv_path, VkPipelineLayout layout) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);

  VkComputePipelineCreateInfo pipeline_info = { VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
  pipeline_info.stage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
  pipeline_info.stage.stage = VK_SHADER_STAGE_COMPUTE_BIT;
  pipeline_info.stage.module = module;
  pipeline_info.stage.pName = "main";
  pipeline_info.layout = layout;
  VkPipeline pipeline;
  VK_CHECK(vkCreateComputePipelines(device, 0, 1, &pipeline_info, 0, &pipeline));
  return pipeline;
}

static VkDescriptorSet allocate_descriptor_set(VkDescriptorPool pool, VkDescriptorSetLayout layout) {
  VkDescriptorSetAllocateInfo info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
  info.descriptorPool = pool;
  info.descriptorSetCount = 1;
  info.pSetLayouts = &layout;
  VkDescriptorSet set;
  VK_CHECK(vkAllocateDescriptorSets(device, &info, &set));
  return set;
}

// Point bindings 0..count-1 of a descriptor set at the given storage buffers.
static void bind_storage_buffers(VkDescriptorSet set, VkBuffer *buffers, int count) {
  VkDescriptorBufferInfo buffer_infos[4];
  VkWriteDescriptorSet writes[4] = { 0 };
  for (int i = 0; i < count; i++) {
    buffer_infos[i] = (VkDescriptorBufferInfo){ buffers[i], 0, VK_WHOLE_SIZE };
    writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    writes[i].dstSet = set;
    writes[i].dstBinding = i;
    writes[i].descriptorCount = 1;
    writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    writes[i].pBufferInfo = &buffer_infos[i];
  }
  vkUpdateDescriptorSets(device, count, writes, 0, 0);
}

// Full compute-to-compute memory barrier (shader writes visible to following shader reads/writes).
static void memory_barrier(void) {
  VkMemoryBarrier barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
  barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
  barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
  vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &barrier, 0, 0, 0, 0);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: %s in.(mp4|y4m) [quality=8] [levels=5] [max_frames=4] [--420|--422|--chroma-format=420|422]\n", argv[0]);
    return 1;
  }
  // Positional args (quality/levels/max_frames) plus optional chroma flags (--420/--422/--chroma-format=).
  // The chroma flag drives BOTH the in-process CPU encode and the GPU decode via one g_chroma_format
  // (mirrors fwvenc's parsing). When set, the codec runs the colordiff path (which subsamples Co/Cg).
  const char *input = argv[1];
  const char *positional[8];
  int positional_count = 0;
  int mode_3ddwt = 0;   // --mode 3ddwt: validate the open-loop temporal 3D-DWT GOP decode
  for (int i = 0; i < argc; i++) {
    if (!strncmp(argv[i], "--chroma-format", 15)) {   // --chroma-format=420|422|444
      g_chroma_format = strstr(argv[i], "420") ? 2 : (strstr(argv[i], "422") ? 1 : 0);
    } else if (!strcmp(argv[i], "--420")) {
      g_chroma_format = 2;
    } else if (!strcmp(argv[i], "--422")) {
      g_chroma_format = 1;
    } else if (!strcmp(argv[i], "--mode") && ((i + 1) < argc)) {
      mode_3ddwt = strstr(argv[++i], "3d") ? 1 : 0;
    } else if (!strcmp(argv[i], "--twavelet") && ((i + 1) < argc)) {
      const char *value = argv[++i];
      g_temporal_wavelet = strstr(value, "97") ? 2 : (strstr(value, "53") ? 1 : 0);
    } else if (!strcmp(argv[i], "--temporal-levels") && ((i + 1) < argc)) {
      g_temporal_levels = atoi(argv[++i]);
    } else if (positional_count < 8) {
      positional[positional_count++] = argv[i];   // positional[0]=prog, [1]=input, [2]=quality, ...
    }
  }
  int quality = (positional_count > 2) ? atoi(positional[2]) : 8;
  int levels = (positional_count > 3) ? atoi(positional[3]) : 5;
  long max_frames = (positional_count > 4) ? atol(positional[4]) : 4;
  int gop = (positional_count > 5) ? atoi(positional[5]) : 16;   // 3D-DWT GOP / decode unit
  if (mode_3ddwt) {
    if (gop < 2) {
      gop = 16;
    }
    if (gop > MAX_GOP) {
      gop = MAX_GOP;
    }
    if (g_temporal_levels < 1) {
      g_temporal_levels = 1;
    }
    if (g_temporal_levels > 6) {
      g_temporal_levels = 6;
    }
    // 3D-DWT honours --420 / --422 like the intra path; lossless is forced back to 4:4:4 below.
  }
  int use_colordiff = (g_chroma_format != 0);   // colordiff subsamples Co/Cg; coefdiff is 4:4:4-only (default, unchanged)

  int width;
  int height;
  if (probe_video_dimensions(input, &width, &height) != 0) {
    die("ffprobe failed");
  }
  int level_limit = maximum_levels(width, height);
  if (levels > level_limit) {
    levels = level_limit;
  }
  if (levels < 1) {
    levels = 1;
  }
  if (quality < 0) {
    quality = 0;
  }
  int lossless = (quality == 0);   // Q0 = reversible integer 5/3, no quant/dequant/round
  if (lossless) {
    g_chroma_format = 0;   // Q0 is lossless 4:4:4 (the codec only subsamples in the lossy path)
    use_colordiff = 0;
  }
  int blocks_x = block_count_x(width);
  int blocks_y = block_count_y(height);
  int block_count = blocks_x * blocks_y;   // luma (full-res) block count; chroma per-plane (subsampled -> fewer)
  // Per-plane block count (luma full-res; chroma fewer when subsampled). 4:4:4 -> all three equal block_count.
  int block_count_plane[3];
  for (int p = 0; p < 3; p++) {
    block_count_plane[p] = block_count_x(plane_width(p, width)) * block_count_y(plane_height(p, height));
  }
  int pixel_count = width * height;

  // ---- Vulkan instance, device and compute queue ----
  VkApplicationInfo application_info = { VK_STRUCTURE_TYPE_APPLICATION_INFO };
  application_info.apiVersion = VK_API_VERSION_1_1;
  VkInstanceCreateInfo instance_info = { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
  instance_info.pApplicationInfo = &application_info;
  VkInstance instance;
  VK_CHECK(vkCreateInstance(&instance_info, 0, &instance));

  uint32_t device_count = 0;
  vkEnumeratePhysicalDevices(instance, &device_count, 0);
  VkPhysicalDevice *devices = checked_malloc(device_count * sizeof(*devices));
  vkEnumeratePhysicalDevices(instance, &device_count, devices);
  physical_device = devices[0];

  VkPhysicalDeviceProperties device_properties;
  vkGetPhysicalDeviceProperties(physical_device, &device_properties);
  double timestamp_period = device_properties.limits.timestampPeriod;

  uint32_t queue_family_count = 0;
  vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, 0);
  VkQueueFamilyProperties *queue_families = checked_malloc(queue_family_count * sizeof(*queue_families));
  vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families);
  uint32_t queue_family_index = 0;
  for (uint32_t i = 0; i < queue_family_count; i++) {
    if (queue_families[i].queueFlags & VK_QUEUE_COMPUTE_BIT) {
      queue_family_index = i;
      break;
    }
  }

  float queue_priority = 1;
  VkDeviceQueueCreateInfo queue_info = { VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
  queue_info.queueFamilyIndex = queue_family_index;
  queue_info.queueCount = 1;
  queue_info.pQueuePriorities = &queue_priority;
  VkDeviceCreateInfo device_info = { VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
  device_info.queueCreateInfoCount = 1;
  device_info.pQueueCreateInfos = &queue_info;
  VK_CHECK(vkCreateDevice(physical_device, &device_info, 0, &device));
  VkQueue queue;
  vkGetDeviceQueue(device, queue_family_index, 0, &queue);
  printf("fwvdec GPU: %s | %dx%d quality=%d levels=%d | %d blocks | chroma %s\n",
         device_properties.deviceName, width, height, quality, levels, block_count,
         (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4"));

  // ---- buffers ----
  // data_buffer: the packed bit-plane bytes of all blocks of all planes (host-visible upload).
  // offset_buffer[plane]: per-block byte offsets into data_buffer.
  // coeff_buffer[plane]: the working coefficient plane (device-local).
  // scratch_buffer: transpose scratch shared across planes.
  // step_buffer: the quant-step map. readback_buffer: unused legacy (kept for buffer parity).
  VkBuffer data_buffer, offset_buffer[3], coeff_buffer[3], scratch_buffer, step_buffer[3], readback_buffer;   // step is per-plane (chroma subsampled -> its own subband layout)
  VkDeviceMemory data_memory, offset_memory[3], coeff_memory[3], scratch_memory, step_memory[3], readback_memory;
  size_t plane_bytes = (size_t)pixel_count * 4;
  create_buffer(((size_t)pixel_count * 4) + ((size_t)block_count * 16), HOST_VISIBLE_COHERENT, &data_buffer, &data_memory);
  for (int plane = 0; plane < 3; plane++) {
    create_buffer((size_t)block_count * 4, HOST_VISIBLE_COHERENT, &offset_buffer[plane], &offset_memory[plane]);
    create_buffer(plane_bytes, DEVICE_LOCAL, &coeff_buffer[plane], &coeff_memory[plane]);
    create_buffer(plane_bytes, HOST_VISIBLE_COHERENT, &step_buffer[plane], &step_memory[plane]);
  }
  // DWT transpose scratch: a W x H plane is transposed to H x W and stored with row stride max(W,H),
  // so it spans max(W,H)^2 elements. pixel_count (W*H) is too small for non-square planes (1920x1080
  // needs 1920^2) and let the transpose go out of bounds, zeroing the right columns (broke lossless).
  size_t scratch_side = (size_t)((width > height) ? width : height);
  create_buffer(((scratch_side * scratch_side) * 4), DEVICE_LOCAL, &scratch_buffer, &scratch_memory);
  create_buffer(plane_bytes, HOST_VISIBLE_COHERENT, &readback_buffer, &readback_memory);

  // The reconstructed RGB is written by the colour shader into this rgba8 image, then copied out.
  VkImageCreateInfo image_info = { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
  image_info.imageType = VK_IMAGE_TYPE_2D;
  image_info.format = VK_FORMAT_R8G8B8A8_UNORM;
  image_info.extent = (VkExtent3D){ width, height, 1 };
  image_info.mipLevels = 1;
  image_info.arrayLayers = 1;
  image_info.samples = 1;
  image_info.tiling = VK_IMAGE_TILING_OPTIMAL;
  image_info.usage = VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
  VkImage image;
  VK_CHECK(vkCreateImage(device, &image_info, 0, &image));
  VkMemoryRequirements image_requirements;
  vkGetImageMemoryRequirements(device, image, &image_requirements);
  VkMemoryAllocateInfo image_allocate = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  image_allocate.allocationSize = image_requirements.size;
  image_allocate.memoryTypeIndex = find_memory_type(image_requirements.memoryTypeBits, DEVICE_LOCAL);
  VkDeviceMemory image_memory;
  VK_CHECK(vkAllocateMemory(device, &image_allocate, 0, &image_memory));
  vkBindImageMemory(device, image, image_memory, 0);

  VkImageViewCreateInfo view_info = { VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
  view_info.image = image;
  view_info.viewType = VK_IMAGE_VIEW_TYPE_2D;
  view_info.format = VK_FORMAT_R8G8B8A8_UNORM;
  view_info.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  VkImageView image_view;
  VK_CHECK(vkCreateImageView(device, &view_info, 0, &image_view));

  void *data_map, *offset_map[3], *step_map[3], *readback_map;
  VK_CHECK(vkMapMemory(device, data_memory, 0, VK_WHOLE_SIZE, 0, &data_map));
  for (int plane = 0; plane < 3; plane++) {
    VK_CHECK(vkMapMemory(device, offset_memory[plane], 0, VK_WHOLE_SIZE, 0, &offset_map[plane]));
    VK_CHECK(vkMapMemory(device, step_memory[plane], 0, VK_WHOLE_SIZE, 0, &step_map[plane]));
  }
  VK_CHECK(vkMapMemory(device, readback_memory, 0, VK_WHOLE_SIZE, 0, &readback_map));

  // ---- pipelines ----
  // Descriptor set layouts by the number of storage buffers (+ a trailing image for colour).
  VkDescriptorSetLayout layout_1_buffer = create_descriptor_set_layout(1, 0);
  VkDescriptorSetLayout layout_2_buffers = create_descriptor_set_layout(2, 0);
  VkDescriptorSetLayout layout_3_buffers = create_descriptor_set_layout(3, 0);
  VkDescriptorSetLayout layout_colour = create_descriptor_set_layout(3, 1);
  VkPipelineLayout pipeline_layout_unpack = create_pipeline_layout(layout_3_buffers, 16);
  VkPipelineLayout pipeline_layout_dequant = create_pipeline_layout(layout_2_buffers, 8);   // { pixel_count, chroma_multiplier } (dequant97 expects both)
  VkPipelineLayout pipeline_layout_transpose = create_pipeline_layout(layout_2_buffers, 16);
  VkPipelineLayout pipeline_layout_row = create_pipeline_layout(layout_1_buffer, 16);
  VkPipelineLayout pipeline_layout_round = create_pipeline_layout(layout_1_buffer, 4);
  VkPipelineLayout pipeline_layout_colour = create_pipeline_layout(layout_colour, 24);   // { width, height, shift_x, shift_y, small_w, small_h }

  VkPipeline pipeline_unpack = create_compute_pipeline("shaders/bitplane_unpack.spv", pipeline_layout_unpack);
  VkPipeline pipeline_dequant = create_compute_pipeline("shaders/dequant97.spv", pipeline_layout_dequant);
  VkPipeline pipeline_transpose = create_compute_pipeline("shaders/transpose_f.spv", pipeline_layout_transpose);
  VkPipeline pipeline_inverse_row_97 = create_compute_pipeline("shaders/idwt97row.spv", pipeline_layout_row);
  VkPipeline pipeline_round = create_compute_pipeline("shaders/round97.spv", pipeline_layout_round);
  VkPipeline pipeline_colour = create_compute_pipeline("shaders/color.spv", pipeline_layout_colour);
  // Lossless path uses the integer 5/3 inverse row transform instead of dequant + 9/7 + round.
  VkPipeline pipeline_inverse_row_53 = create_compute_pipeline("shaders/idwt53row.spv", pipeline_layout_row);
  VkPipeline pipeline_inverse_row = lossless ? pipeline_inverse_row_53 : pipeline_inverse_row_97;

  VkDescriptorPoolSize pool_sizes[2] = {
    { VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 64 },
    { VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1 },
  };
  VkDescriptorPoolCreateInfo pool_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
  pool_info.maxSets = 24;
  pool_info.poolSizeCount = 2;
  pool_info.pPoolSizes = pool_sizes;
  VkDescriptorPool descriptor_pool;
  VK_CHECK(vkCreateDescriptorPool(device, &pool_info, 0, &descriptor_pool));

  // Per plane: unpack (data+offset -> coeff), dequant (coeff+step), the two transpose directions
  // (coeff<->scratch), and the row transform in place on coeff. The colour set reads all 3 planes.
  VkDescriptorSet set_unpack[3], set_dequant[3], set_coeff_to_scratch[3], set_scratch_to_coeff[3], set_row[3];
  VkDescriptorSet set_row_scratch, set_colour;
  for (int plane = 0; plane < 3; plane++) {
    set_unpack[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_unpack[plane], (VkBuffer[]){ data_buffer, offset_buffer[plane], coeff_buffer[plane] }, 3);
    set_dequant[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_dequant[plane], (VkBuffer[]){ coeff_buffer[plane], step_buffer[plane] }, 2);
    set_coeff_to_scratch[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_coeff_to_scratch[plane], (VkBuffer[]){ coeff_buffer[plane], scratch_buffer }, 2);
    set_scratch_to_coeff[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_scratch_to_coeff[plane], (VkBuffer[]){ scratch_buffer, coeff_buffer[plane] }, 2);
    set_row[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
    bind_storage_buffers(set_row[plane], (VkBuffer[]){ coeff_buffer[plane] }, 1);
  }
  set_row_scratch = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
  bind_storage_buffers(set_row_scratch, (VkBuffer[]){ scratch_buffer }, 1);

  set_colour = allocate_descriptor_set(descriptor_pool, layout_colour);
  {
    VkDescriptorBufferInfo colour_buffers[3];
    VkDescriptorImageInfo colour_image = { 0, image_view, VK_IMAGE_LAYOUT_GENERAL };
    VkWriteDescriptorSet writes[4] = { 0 };
    for (int i = 0; i < 3; i++) {
      colour_buffers[i] = (VkDescriptorBufferInfo){ coeff_buffer[i], 0, VK_WHOLE_SIZE };
      writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
      writes[i].dstSet = set_colour;
      writes[i].dstBinding = i;
      writes[i].descriptorCount = 1;
      writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
      writes[i].pBufferInfo = &colour_buffers[i];
    }
    writes[3].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    writes[3].dstSet = set_colour;
    writes[3].dstBinding = 3;
    writes[3].descriptorCount = 1;
    writes[3].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    writes[3].pImageInfo = &colour_image;
    vkUpdateDescriptorSets(device, 4, writes, 0, 0);
  }

  // 3D-DWT: per-plane GOP-resident buffers + the temporal-DWT pipeline. Each subband frame
  // is spatially inverse-transformed into a GOP slot; the temporal-inverse shader then reconstructs the
  // display frames along the time axis before the colour pass.
  VkBuffer gop_buffer[3] = { 0, 0, 0 };
  VkDeviceMemory gop_memory[3] = { 0, 0, 0 };
  VkPipelineLayout pipeline_layout_temporal = 0;
  VkPipeline pipeline_temporal_int = 0, pipeline_temporal_float = 0;
  VkDescriptorSet set_temporal[3] = { 0, 0, 0 };
  if (mode_3ddwt) {
    for (int plane = 0; plane < 3; plane++) {   // chroma slots are smaller when subsampled (4:2:0 / 4:2:2)
      int plane_pixels = plane_width(plane, width) * plane_height(plane, height);
      create_buffer((size_t)gop * plane_pixels * 4, DEVICE_LOCAL, &gop_buffer[plane], &gop_memory[plane]);
    }
    pipeline_layout_temporal = create_pipeline_layout(layout_1_buffer, 20);   // { pixel_count, num_frames, levels, wavelet, inverse }
    pipeline_temporal_int = create_compute_pipeline("shaders/tdwt_int.spv", pipeline_layout_temporal);
    pipeline_temporal_float = create_compute_pipeline("shaders/tdwt_float.spv", pipeline_layout_temporal);
    for (int plane = 0; plane < 3; plane++) {
      set_temporal[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
      bind_storage_buffers(set_temporal[plane], (VkBuffer[]){ gop_buffer[plane] }, 1);
    }
  }

  VkCommandPoolCreateInfo command_pool_info = { VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
  command_pool_info.queueFamilyIndex = queue_family_index;
  command_pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
  VkCommandPool command_pool;
  VK_CHECK(vkCreateCommandPool(device, &command_pool_info, 0, &command_pool));
  VkCommandBufferAllocateInfo command_buffer_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
  command_buffer_info.commandPool = command_pool;
  command_buffer_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  command_buffer_info.commandBufferCount = 1;
  vkAllocateCommandBuffers(device, &command_buffer_info, &command_buffer);

  VkQueryPoolCreateInfo query_pool_info = { VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO };
  query_pool_info.queryType = VK_QUERY_TYPE_TIMESTAMP;
  query_pool_info.queryCount = 5;   // 0=top, 1/2/3=after luma/Co/Cg plane, 4=after colour combine
  VkQueryPool query_pool;
  VK_CHECK(vkCreateQueryPool(device, &query_pool_info, 0, &query_pool));

  // ---- per frame: CPU-encode -> upload -> GPU decode -> compare to CPU decode ----
  char command[4096];
  if (max_frames) {
    snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" -frames:v %ld -f rawvideo -pix_fmt rgb24 -", input, max_frames);
  } else {
    snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" -f rawvideo -pix_fmt rgb24 -", input);
  }
  FILE *input_pipe = popen(command, "r");
  if (!input_pipe) {
    die("popen ffmpeg");
  }

  size_t frame_bytes = (size_t)pixel_count * 3;
  uint8_t *rgb = checked_malloc(frame_bytes);
  uint8_t *cpu_rgb = checked_malloc(frame_bytes);
  int *step = checked_malloc(pixel_count * sizeof(int));
  for (int plane = 0; plane < 3; plane++) {   // per-plane quant map (chroma subsampled -> its own layout); 4:4:4 -> all identical
    int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
    build_quantization_steps(step, plane_w, plane_h, levels, quality);
    memcpy(step_map[plane], step, (size_t)(plane_w * plane_h) * 4);
  }

  long frame_index = 0;
  double sum_psnr = 0;
  double gpu_milliseconds = 0;
  double gpu_luma = 0, gpu_co = 0, gpu_cg = 0, gpu_colour = 0;   // per-phase decode time (for the 4:2:0 projection)
  int pixel_workgroups = (pixel_count + 255) / 256;   // frame-level: the colour pass writes full-res RGB

  if (mode_3ddwt) {
    // ---- 3D-DWT GOP decode validation: CPU-encode a GOP, GPU-decode it, compare to CPU ----
    int temporal_wavelet = g_temporal_wavelet;
    if (lossless && (temporal_wavelet == 2)) {
      temporal_wavelet = 1;
    }
    printf("  3D-DWT mode: GOP=%d temporal_levels=%d twavelet=%s chroma=%s\n", gop, g_temporal_levels,
           (temporal_wavelet == 2) ? "9/7" : ((temporal_wavelet == 1) ? "5/3" : "Haar"),
           (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4"));
    int scratch_stride = (width > height) ? width : height;
    // Per-plane dimensions + level pyramids (luma full-res; chroma subsampled when g_chroma_format != 0).
    int plane_w[3], plane_h[3], plane_pixels[3], plane_blocks[3], plane_level_count[3];
    int plane_level_width[3][16], plane_level_height[3][16];
    for (int plane = 0; plane < 3; plane++) {
      plane_w[plane] = plane_width(plane, width);
      plane_h[plane] = plane_height(plane, height);
      plane_pixels[plane] = plane_w[plane] * plane_h[plane];
      plane_blocks[plane] = block_count_x(plane_w[plane]) * block_count_y(plane_h[plane]);
      int lc = 0, cw = plane_w[plane], ch = plane_h[plane];
      for (int level = 0; (level < levels) && (cw >= 2) && (ch >= 2); level++) {
        plane_level_width[plane][lc] = cw;
        plane_level_height[plane][lc] = ch;
        lc++;
        cw = (cw + 1) / 2;
        ch = (ch + 1) / 2;
      }
      plane_level_count[plane] = lc;
    }
    uint8_t **gop_rgb = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **cpu_gop_rgb = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **gop_encoded = checked_malloc((size_t)gop * sizeof(uint8_t *));
    size_t *gop_encoded_length = checked_malloc((size_t)gop * sizeof(size_t));
    for (int g = 0; g < gop; g++) {
      gop_rgb[g] = checked_malloc(frame_bytes);
      cpu_gop_rgb[g] = checked_malloc(frame_bytes);
    }
    VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    submit.commandBufferCount = 1;
    submit.pCommandBuffers = &command_buffer;
    for (;;) {
      int filled = 0;
      while ((filled < gop) && ((!max_frames) || ((frame_index + filled) < max_frames))
             && (fread(gop_rgb[filled], 1, frame_bytes, input_pipe) == frame_bytes)) {
        filled++;
      }
      if (filled == 0) {
        break;
      }
      encode_gop_3ddwt(gop_rgb, filled, width, height, levels, quality, gop_encoded, gop_encoded_length);
      decode_gop_3ddwt(gop_encoded, gop_encoded_length, filled, width, height, levels, quality, cpu_gop_rgb);

      // Phase 1: each subband frame -> GPU spatial inverse -> GOP buffer slot (no round; keep float/int).
      for (int g = 0; g < filled; g++) {
        int level = temporal_quant_level(g, filled, g_temporal_levels);
        int effective_quality = lossless ? 0 : (int)(((float)quality * temporal_quant_scale(level)) + 0.5f);
        if (!lossless && (effective_quality < 1)) {
          effective_quality = 1;
        }
        uint32_t *parse_offsets[3] = { (uint32_t *)offset_map[0], (uint32_t *)offset_map[1], (uint32_t *)offset_map[2] };
        int parsed_block_count;
        const uint8_t *mv_data;
        uint32_t mv_length;
        const uint8_t *frame_data = parse_frame_header(gop_encoded[g], block_count_plane, &parsed_block_count, parse_offsets, &mv_data, &mv_length);
        (void)mv_data;
        (void)mv_length;
        size_t data_length = gop_encoded_length[g] - (size_t)(frame_data - gop_encoded[g]);
        memcpy(data_map, frame_data, data_length);

        vkResetCommandBuffer(command_buffer, 0);
        vkBeginCommandBuffer(command_buffer, &begin_info);
        for (int plane = 0; plane < 3; plane++) {
          int pw = plane_w[plane], ph = plane_h[plane], pp = plane_pixels[plane];
          if (!lossless) {   // per-plane, temporally-scaled quant steps (chroma subsampled), as the encoder builds them
            build_quantization_steps(step, pw, ph, levels, effective_quality);
            memcpy(step_map[plane], step, (size_t)pp * 4);
          }
          int32_t unpack_push[4] = { pw, ph, block_count_x(pw), block_count_y(ph) };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_unpack);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_unpack[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, unpack_push);
          vkCmdDispatch(command_buffer, (plane_blocks[plane] + 63) / 64, 1, 1);
          memory_barrier();
          if (!lossless) {
            int32_t dequant_push[2] = { pp, 0 };
            float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;   // must match encode + decode_gop_3ddwt
            memcpy(&dequant_push[1], &chroma_multiplier, sizeof(float));
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_dequant);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_dequant, 0, 1, &set_dequant[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_dequant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, dequant_push);
            vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
            memory_barrier();
          }
          for (int level_i = plane_level_count[plane] - 1; level_i >= 0; level_i--) {
            int level_w = plane_level_width[plane][level_i], level_h = plane_level_height[plane][level_i];
            int32_t transpose_push_1[4] = { pw, level_w, level_h, scratch_stride };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
            vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
            memory_barrier();
            int32_t row_push_1[4] = { scratch_stride, level_h, level_w, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
            vkCmdDispatch(command_buffer, level_w, 1, 1);
            memory_barrier();
            int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, pw };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
            vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
            memory_barrier();
            int32_t row_push_2[4] = { pw, level_w, level_h, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
            vkCmdDispatch(command_buffer, level_h, 1, 1);
            memory_barrier();
          }
          // Spatial inverse (compute write) -> copy into the GOP slot (transfer read).
          VkMemoryBarrier to_copy = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
          to_copy.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
          to_copy.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
          vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &to_copy, 0, 0, 0, 0);
          VkBufferCopy copy = { 0, (VkDeviceSize)g * pp * 4, (VkDeviceSize)pp * 4 };
          vkCmdCopyBuffer(command_buffer, coeff_buffer[plane], gop_buffer[plane], 1, &copy);
        }
        vkEndCommandBuffer(command_buffer);
        VK_CHECK(vkQueueSubmit(queue, 1, &submit, 0));
        VK_CHECK(vkQueueWaitIdle(queue));
      }

      // Phase 2: temporal inverse along the frame axis (per plane, at each plane's size, in place on the GOP buffer).
      vkResetCommandBuffer(command_buffer, 0);
      vkBeginCommandBuffer(command_buffer, &begin_info);
      VkPipeline temporal_pipeline = lossless ? pipeline_temporal_int : pipeline_temporal_float;
      for (int plane = 0; plane < 3; plane++) {
        int32_t temporal_push[5] = { plane_pixels[plane], filled, g_temporal_levels, temporal_wavelet, 1 };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, temporal_pipeline);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_temporal, 0, 1, &set_temporal[plane], 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_temporal, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, temporal_push);
        vkCmdDispatch(command_buffer, (plane_pixels[plane] + 255) / 256, 1, 1);
      }
      vkEndCommandBuffer(command_buffer);
      VK_CHECK(vkQueueSubmit(queue, 1, &submit, 0));
      VK_CHECK(vkQueueWaitIdle(queue));

      // Phase 3: per display frame -> copy slot to coeff -> round (lossy) -> colour -> readback -> compare.
      for (int g = 0; g < filled; g++) {
        vkResetCommandBuffer(command_buffer, 0);
        vkBeginCommandBuffer(command_buffer, &begin_info);
        VkImageMemoryBarrier to_general = { VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
        to_general.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        to_general.newLayout = VK_IMAGE_LAYOUT_GENERAL;
        to_general.srcQueueFamilyIndex = to_general.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        to_general.image = image;
        to_general.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
        to_general.dstAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 0, 0, 0, 0, 1, &to_general);
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pixels[plane];
          VkBufferCopy copy = { (VkDeviceSize)g * pp * 4, 0, (VkDeviceSize)pp * 4 };
          vkCmdCopyBuffer(command_buffer, gop_buffer[plane], coeff_buffer[plane], 1, &copy);
          VkMemoryBarrier to_shader = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
          to_shader.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
          to_shader.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
          vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &to_shader, 0, 0, 0, 0);
          if (!lossless) {
            int32_t pixel_count_push = pp;
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_round);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_round, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_push);
            vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
            memory_barrier();
          }
        }
        // YCoCg-R -> RGB, bilinear-upsampling subsampled chroma (4:4:4 -> shift 0 + chroma dims == frame dims).
        int32_t colour_push[6] = { width, height, chroma_shift_x(), chroma_shift_y(), plane_width(1, width), plane_height(1, height) };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, colour_push);
        vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
        VkImageMemoryBarrier to_src = to_general;
        to_src.oldLayout = VK_IMAGE_LAYOUT_GENERAL;
        to_src.newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
        to_src.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
        to_src.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, 0, 0, 0, 1, &to_src);
        VkBufferImageCopy image_copy = { 0 };
        image_copy.imageSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
        image_copy.imageExtent = (VkExtent3D){ width, height, 1 };
        vkCmdCopyImageToBuffer(command_buffer, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, readback_buffer, 1, &image_copy);
        vkEndCommandBuffer(command_buffer);
        VK_CHECK(vkQueueSubmit(queue, 1, &submit, 0));
        VK_CHECK(vkQueueWaitIdle(queue));

        const uint8_t *gpu_rgba = readback_map;
        const uint8_t *reference = cpu_gop_rgb[g];
        double mean_squared_error = 0;
        for (int i = 0; i < pixel_count; i++) {
          for (int channel = 0; channel < 3; channel++) {
            int difference = (int)gpu_rgba[(i * 4) + channel] - (int)reference[(i * 3) + channel];
            mean_squared_error += (double)difference * difference;
          }
        }
        mean_squared_error /= frame_bytes;
        double psnr = (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));
        if (psnr < 40) {
          printf("  frame %ld: GPU-vs-CPU %.1f dB (LOW -> shader/data bug)\n", frame_index, psnr);
        }
        sum_psnr += psnr;
        frame_index++;
      }
      for (int g = 0; g < filled; g++) {
        free(gop_encoded[g]);
      }
      if (filled < gop) {
        break;
      }
    }
    for (int g = 0; g < gop; g++) {
      free(gop_rgb[g]);
      free(cpu_gop_rgb[g]);
    }
    free(gop_rgb);
    free(cpu_gop_rgb);
    free(gop_encoded);
    free(gop_encoded_length);
  } else {
    while ((fread(rgb, 1, frame_bytes, input_pipe) == frame_bytes) && ((!max_frames) || (frame_index < max_frames))) {
      // CPU-encode this frame, then split the payload into the block bytes and the offset tables. colordiff
      // (used when chroma is subsampled) carries the down/upsampled Co/Cg; coefdiff is the 4:4:4-only default.
      uint8_t *encoded;
      size_t encoded_length = use_colordiff ? encode_frame_colordiff(rgb, width, height, levels, quality, &encoded, NULL, 0)
                                            : encode_frame_coefdiff(rgb, width, height, levels, quality, &encoded, NULL, 0);
      // Prefix-sum the u16 sizes straight into the (host-visible) GPU offset buffers.
      uint32_t *parse_offsets[3] = { (uint32_t *)offset_map[0], (uint32_t *)offset_map[1], (uint32_t *)offset_map[2] };
      int frame_block_count;
      const uint8_t *mv_data;
      uint32_t mv_length;
      const uint8_t *frame_data = parse_frame_header(encoded, block_count_plane, &frame_block_count, parse_offsets, &mv_data, &mv_length);   // intra: no motion
      (void)mv_data;
      (void)mv_length;
      size_t data_length = encoded_length - (size_t)(frame_data - encoded);

      // Upload the block bytes (the offset tables were written in place above).
      memcpy(data_map, frame_data, data_length);

      // The CPU reference decode. coefdiff (4:4:4): compare the GPU against this CPU decode (the existing
      // metric). colordiff (subsampled): compare the GPU against the ORIGINAL frame instead, so the number
      // reflects true codec quality (~38 dB for 4:2:0) — the CPU decode here is only for parity / debug.
      if (use_colordiff) {
        decode_frame_colordiff(encoded, encoded_length, width, height, levels, quality, cpu_rgb, NULL, 0);
      } else {
        decode_frame_coefdiff(encoded, encoded_length, width, height, levels, quality, cpu_rgb, NULL, 0);
      }
      const uint8_t *compare_target = use_colordiff ? rgb : cpu_rgb;   // 420/422 -> vs original; 444 -> vs CPU decode

      // ---- record the GPU decode ----
      VK_CHECK(vkResetCommandBuffer(command_buffer, 0));
      VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
      begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
      vkBeginCommandBuffer(command_buffer, &begin_info);
      vkCmdResetQueryPool(command_buffer, query_pool, 0, 5);

      // Move the output image into GENERAL so the colour shader can store into it.
      VkImageMemoryBarrier image_barrier = { VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
      image_barrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
      image_barrier.newLayout = VK_IMAGE_LAYOUT_GENERAL;
      image_barrier.srcQueueFamilyIndex = image_barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
      image_barrier.image = image;
      image_barrier.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
      image_barrier.dstAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
      vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 0, 0, 0, 0, 1, &image_barrier);
      vkCmdWriteTimestamp(command_buffer, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, query_pool, 0);

      for (int plane = 0; plane < 3; plane++) {
        // Per-plane dimensions: luma is full-res; chroma is subsampled when g_chroma_format != 0 (4:4:4 ->
        // these equal the frame dims, so 4:4:4 behaviour is unchanged). plane_w is the buffer ROW STRIDE.
        int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
        // The transpose scratch needs a stride large enough for the transposed (tall) region: for WIDE
        // planes max == plane_w (unchanged), for TALL planes it grows to plane_h to avoid row overlap.
        int scratch_stride = (plane_w > plane_h) ? plane_w : plane_h;
        int plane_pixels = plane_w * plane_h;
        int plane_blocks_x = block_count_x(plane_w), plane_blocks_y = block_count_y(plane_h);
        int plane_block_count = plane_blocks_x * plane_blocks_y;
        int plane_pixel_workgroups = (plane_pixels + 255) / 256;
        int plane_unpack_workgroups = (plane_block_count + 63) / 64;
        int32_t unpack_push[4] = { plane_w, plane_h, plane_blocks_x, plane_blocks_y };
        int32_t pixel_count_push = plane_pixels;

        // Bit-plane unpack: one workgroup per block, writes integer coefficients into coeff_buffer.
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_unpack);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_unpack[plane], 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, unpack_push);
        vkCmdDispatch(command_buffer, plane_unpack_workgroups, 1, 1);
        memory_barrier();

        if (!lossless) {
          // Lossy: multiply each coefficient by its quant step (writes float bit-patterns in place). coefdiff
          // (4:4:4) keeps the legacy 4-byte push (chroma_multiplier = encoder default 1.0) so its result is
          // byte-identical to before; colordiff (subsampled) pushes the explicit per-plane multiplier.
          int32_t dequant_push[2] = { pixel_count_push, 0 };
          uint32_t dequant_push_size = 4;
          if (use_colordiff) {
            float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
            memcpy(&dequant_push[1], &chroma_multiplier, sizeof(float));
            dequant_push_size = 8;
          }
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_dequant);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_dequant, 0, 1, &set_dequant[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_dequant, VK_SHADER_STAGE_COMPUTE_BIT, 0, dequant_push_size, dequant_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }

        // Inverse 2D wavelet, level by level (coarsest first), as separable row transforms with a
        // transpose between the two directions. The level pyramid is per-plane (from plane_w/plane_h).
        int level_width[16], level_height[16], level_count = 0, current_width = plane_w, current_height = plane_h;
        for (int level = 0; (level < levels) && (current_width >= 2) && (current_height >= 2); level++) {
          level_width[level_count] = current_width;
          level_height[level_count] = current_height;
          level_count++;
          current_width = (current_width + 1) / 2;
          current_height = (current_height + 1) / 2;
        }
        for (int level = level_count - 1; level >= 0; level--) {
          int level_w = level_width[level];
          int level_h = level_height[level];

          // coeff (stride plane_w) -> scratch (stride scratch_stride): dest is scratch.
          int32_t transpose_push_1[4] = { plane_w, level_w, level_h, scratch_stride };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
          vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
          memory_barrier();

          // Row pass on scratch: stride scratch_stride.
          int32_t row_push_1[4] = { scratch_stride, level_h, level_w, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
          vkCmdDispatch(command_buffer, level_w, 1, 1);
          memory_barrier();

          // scratch (stride scratch_stride) -> coeff (stride plane_w): dest is coeff.
          int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, plane_w };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
          vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
          memory_barrier();

          int32_t row_push_2[4] = { plane_w, level_w, level_h, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
          vkCmdDispatch(command_buffer, level_h, 1, 1);
          memory_barrier();
        }

        if (!lossless) {
          // Lossy: round the float result back to integer coefficients.
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_round);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_round, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }
        vkCmdWriteTimestamp(command_buffer, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, query_pool, 1 + plane);   // after this plane's decode
      }

      // YCoCg-R -> RGB for all three planes into the output image, bilinear-upsampling subsampled chroma.
      // 4:4:4 -> shift 0 + small dims == frame dims, so the colour shader reads chroma[y*W+x] unchanged.
      int32_t colour_push[6] = { width, height, chroma_shift_x(), chroma_shift_y(), plane_width(1, width), plane_height(1, height) };
      vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
      vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
      vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, colour_push);
      vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
      vkCmdWriteTimestamp(command_buffer, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, query_pool, 4);   // after colour combine

      // Copy the image out to the readback buffer (rgba8).
      VkImageMemoryBarrier copy_barrier = image_barrier;
      copy_barrier.oldLayout = VK_IMAGE_LAYOUT_GENERAL;
      copy_barrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
      copy_barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
      copy_barrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
      vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, 0, 0, 0, 1, &copy_barrier);
      VkBufferImageCopy copy = { 0 };
      copy.imageSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
      copy.imageExtent = (VkExtent3D){ width, height, 1 };
      vkCmdCopyImageToBuffer(command_buffer, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, readback_buffer, 1, &copy);

      vkEndCommandBuffer(command_buffer);
      VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
      submit.commandBufferCount = 1;
      submit.pCommandBuffers = &command_buffer;
      VK_CHECK(vkQueueSubmit(queue, 1, &submit, 0));
      VK_CHECK(vkQueueWaitIdle(queue));

      uint64_t timestamps[5];
      vkGetQueryPoolResults(device, query_pool, 0, 5, sizeof timestamps, timestamps, 8, VK_QUERY_RESULT_64_BIT | VK_QUERY_RESULT_WAIT_BIT);
      double to_ms = timestamp_period * 1e-6;
      gpu_luma += (timestamps[1] - timestamps[0]) * to_ms;
      gpu_co += (timestamps[2] - timestamps[1]) * to_ms;
      gpu_cg += (timestamps[3] - timestamps[2]) * to_ms;
      gpu_colour += (timestamps[4] - timestamps[3]) * to_ms;
      gpu_milliseconds += (timestamps[4] - timestamps[0]) * to_ms;

      // Compare the GPU rgba8 readback against the reference (CPU decode for 4:4:4, original for 4:2:x).
      uint8_t *gpu_rgba = readback_map;
      double mean_squared_error = 0;
      for (int i = 0; i < pixel_count; i++) {
        for (int channel = 0; channel < 3; channel++) {
          int difference = (int)gpu_rgba[(i * 4) + channel] - (int)compare_target[(i * 3) + channel];
          mean_squared_error += (double)difference * difference;
        }
      }
      mean_squared_error /= frame_bytes;
      double psnr = (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));
      // 4:4:4 (vs CPU decode) should be near-identical, so <40 dB flags a shader/data bug. 4:2:x (vs the
      // ORIGINAL) is genuinely lossy (~38 dB for 4:2:0), so a moderate number there is expected, not a bug.
      if (!use_colordiff && (psnr < 40)) {
        printf("  frame %ld: GPU-vs-CPU %.1f dB (LOW -> shader/data bug, deterministic)\n", frame_index, psnr);
      } else if (use_colordiff) {
        printf("  frame %ld: GPU-vs-original %.1f dB\n", frame_index, psnr);
      }
      sum_psnr += psnr;
      free(encoded);
      frame_index++;
    }
  }
  pclose(input_pipe);

  printf("%ld frames | GPU-decode vs %s: %.2f dB (inf=identical) | GPU %.3f ms/frame\n",
         frame_index, (use_colordiff && !mode_3ddwt) ? "original" : "CPU-decode", frame_index ? (sum_psnr / frame_index) : 0,
         frame_index ? (gpu_milliseconds / frame_index) : 0);
  if (frame_index) {
    double n = (double)frame_index;
    double luma = gpu_luma / n, co = gpu_co / n, cg = gpu_cg / n, colour = gpu_colour / n;
    double total = ((luma + co) + cg) + colour;
    double chroma = co + cg;
    // 4:2:0 would shrink each chroma plane to 1/4 the pixels -> chroma decode ~/4; colour combine stays (still full-res RGB out).
    double projected_420 = (luma + (chroma * 0.25)) + colour;
    printf("  per-phase ms: luma %.3f | Co %.3f | Cg %.3f | colour %.3f  (total %.3f)\n", luma, co, cg, colour, total);
    printf("  chroma = %.3f ms = %.1f%% of decode | projected 4:2:0 decode %.3f ms = %.1f%% (saves %.1f%%)\n",
           chroma, (total > 0) ? (100.0 * chroma / total) : 0, projected_420,
           (total > 0) ? (100.0 * projected_420 / total) : 0, (total > 0) ? (100.0 * (total - projected_420) / total) : 0);
  }
  return 0;
}
