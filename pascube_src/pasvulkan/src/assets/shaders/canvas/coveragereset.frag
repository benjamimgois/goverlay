#version 450 core

// Copyright (C) 2017, Benjamin 'BeRo' Rosseaux (benjamin@rosseaux.de)
// License: zlib

layout(early_fragment_tests) in;

// Coverage buffer for transparent shape rendering (set = 0, binding = 0)
// Uses R32_UINT format with packed stamp (24 bits) + coverage (8 bits)
layout(set = 0, binding = 0, r32ui) uniform uimage2D uCoverageBuffer;

void main(){
  imageStore(uCoverageBuffer, ivec2(gl_FragCoord.xy), uvec4(0u));
}
