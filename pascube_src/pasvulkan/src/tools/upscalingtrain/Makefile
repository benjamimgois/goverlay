# CNN Image Upscaler - Training & Inference Tool
# ================================================
# Build: make [CC=clang] [OPENMP=1] [VULKAN=1]
# Debug: make debug
# Clean: make clean

CC       ?= gcc
CFLAGS    = -std=c17 -Wall -Wextra -Wpedantic -O2 -march=native
LDFLAGS   = -lm -lpng

DBGFLAGS  = -std=c17 -Wall -Wextra -Wpedantic -g -O0 -DDEBUG -fsanitize=address,undefined
DBGLD     = -lm -lpng -fsanitize=address,undefined

# Optional OpenMP support: make OPENMP=1
ifdef OPENMP
CFLAGS   += -fopenmp
LDFLAGS  += -fopenmp
DBGFLAGS += -fopenmp
DBGLD    += -fopenmp
endif

# Optional Vulkan compute backend: make VULKAN=1
# Requires: Vulkan SDK (libvulkan-dev), glslc
ifdef VULKAN
CFLAGS   += -DUSE_VULKAN
LDFLAGS  += -lvulkan
DBGFLAGS += -DUSE_VULKAN
DBGLD    += -lvulkan
VK_SRCS   = vk_backend.c vk_cnn.c
VK_HDRS   = vk_backend.h vk_cnn.h shader_spirv.h
else
VK_SRCS   =
VK_HDRS   =
endif

TARGET    = upscaler
SRCS      = main.c cnn.c image.c export.c $(VK_SRCS)
HEADERS   = upscaler.h $(VK_HDRS)

.PHONY: all debug clean spirv

all: $(TARGET)

# Generate SPIR-V header (only needed when building with VULKAN=1)
spirv: gen_spirv.sh shaders/*.comp
	./gen_spirv.sh

shader_spirv.h: gen_spirv.sh shaders/*.comp
	./gen_spirv.sh

$(TARGET): $(SRCS) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(LDFLAGS)

debug: $(SRCS) $(HEADERS)
	$(CC) $(DBGFLAGS) -o $(TARGET)-debug $(SRCS) $(DBGLD)

clean:
	rm -f $(TARGET) $(TARGET)-debug shader_spirv.h shaders/*.spv
