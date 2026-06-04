/******************************************************************************
 *                              PasTerm font2pas                              *
 ******************************************************************************
 *                        Version 2025-01-18-08-48-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2024-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 *****************************************************************************/

// This program is used to convert font data from BDF, BIN and HEX files to a 
// Pascal unit with two arrays: one for the bitmaps (16 bytes with 8x16 pixels 
// or 16 words with 16x16 pixels) and one for the map of the bitmaps (131072
// signed int32's with the index of the bitmap for each character), where
// negative means 16x16 pixels, positive means 8x16 pixels and -0x80000000 means
// no bitmap. The output is written to a file "VGAFont.pas".

// It needs the following files:
// - u_vga16.bdf: 
//     Uni-VGA 8x16 font as primary source (8x16 pixels)
//     Source: https://www.inp.nsk.su/~bolkhov/files/fonts/univga/
// - unscii-16.hex:
//     Unscii 8x16 font with some 16x16 characters (wide characters) for second order fill-in of some missing characters
//     Source: https://github.com/viznut/unscii
// - vga.bin: 
//     VGA 8x16 font from the original IBM VGA ROM (8x16 pixels) for the first 256 characters to be used as a first-order 
//     fill-in of some missing characters, especially for the first 32 characters
//     It's provided in this repository 

#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

// Combine font data to a Pascal unit with two arrays: one for the bitmaps (16bytes with 8x16 pixels or 16words with 
// 16x16 picel) and one for the map of the bitmaps (131072 signed int32's with the index of the bitmap for each character),
// where negative means, 16x16 pixels, positive means 8x16 pixels and -0x80000000 means no bitmap. The output is written to a 
// file "VGAFont.pas"

const char *fontnameBDF = "u_vga16.bdf"; // Uni-VGA 8x16 font as primary source (8x16 pixels)
const char *fontnameBIN = "vga.bin"; // VGA 8x16 font from the original IBM VGA ROM (8x16 pixels) for the first 256 characters to be used as a first-order fill-in of some missing characters, especially for the first 32 characters
const char *fontnameHEX = "unscii-16.hex"; // Unscii 8x16 font with some 16x16 characters (wide characters) for second order fill-in of some missing characters
const char *outputname = "VGAFont.pas";

#define COUNT_UNICODE_CHARACTERS 131072 // last unscii character is 0x1fbf9 so that should be enough 

static uint8_t bitmap8[65536][16]; // 16 bytes for each character (8x16 pixels) in a unicode subset (max 65536 graphs)
static uint16_t bitmap16[65536][16]; // 32 bytes for each character (16x16 pixels) in a unicode subset (max 65536 graphs)
static uint32_t bitmapWidths[65536]; // 16 bytes for each character (8x16 pixels / 16x16 pixels) in a unicode subset (max 65536 graphs) 
static uint32_t map[COUNT_UNICODE_CHARACTERS]; // 32-bit index for each character in the unicode subset
static uint32_t codepoints8[65536]; // 32-bit codepoint for each character in the unicode subset (8x16 pixels) 
static uint32_t codepoints16[65536]; // 32-bit codepoint for each character in the unicode subset (16x16 pixels)

static int32_t count8 = 0, count16 = 0;

void clear(){
  for(int i = 0; i < COUNT_UNICODE_CHARACTERS; i++){
    map[i] = 0x00000000;
  }
  for(int i = 0; i < 65536; i++){
    for(int j = 0; j < 16; j++){
      bitmap8[i][j] = 0;
      bitmap16[i][j] = 0;
    }
    bitmapWidths[i] = 0;
    codepoints8[i] = 0;
    codepoints16[i] = 0;
  }
}

int32_t hex_to_dec(char c){
  return ((c >= 'A') && (c <= 'F')) ? ((c - 'A') + 10) : (((c >= 'a') && (c <= 'f')) ? ((c - 'a') + 10) : (c - '0'));
}

void loadBDF(){

  FILE *f = fopen(fontnameBDF, "r");
  if(f == NULL){
    printf("Error: could not open file %s\n", fontnameBDF);
    exit(1);
  }

  char line[256];
  int32_t charcode = 0, index, ignore = 1;
  while(fgets(line, 256, f) != NULL){
    if(strncmp(line, "ENCODING", 8) == 0){
      charcode = strtol(line + 9, NULL, 10);
      if(map[charcode] != 0){
        ignore = 1; // Already from other resource
      }else{
        ignore = 0;
        index = count8++;
        map[charcode] = ((uint32_t)index) | 0x01000000;
        codepoints8[index] = charcode;
        bitmapWidths[index] = 8;
      }
    }
    if((strncmp(line, "BITMAP", 6) == 0) && (ignore == 0)){
      for(int i = 0; i < 16; i++){
        fgets(line, 256, f);
        uint8_t b = strtol(line, NULL, 16);
        uint8_t v = 0;
        for(int k = 0; k < 8; k++){
          v = (v << 1) | (b & 1);
          b >>= 1;
        }
        bitmap8[index][i] = v;
      }
    }
  }

  fclose(f);

}

static uint8_t vgabindata[4096]; // 16 bytes for each character (8x16 pixels) in the first 256 characters of the VGA font
void loadBIN(int32_t limit){

  FILE *f = fopen(fontnameBIN, "rb");
  if(f == NULL){
    printf("Error: could not open file %s\n", fontnameBIN);
    exit(1);
  }

  fread(vgabindata, 1, 4096, f);

  fclose(f);

  for(int32_t i = 0; i < limit; i++){
    if(map[i] != 0){
      continue; // Already from other resource
    }
    int32_t index = count8++;
    map[i] = ((uint32_t)index) | 0x01000000;
    codepoints8[index] = i;
    bitmapWidths[index] = 8;
    for(int j = 0; j < 16; j++){
      uint8_t b = vgabindata[(i * 16) + j], v = 0;
      for(int k = 0; k < 8; k++){
        v = (v << 1) | (b & 1);
        b >>= 1;
      }
      bitmap8[index][j] = v;
    }
  } 

}

void loadHEX(){

  FILE *f = fopen(fontnameHEX, "r");
  if(f == NULL){
    printf("Error: could not open file %s\n", fontnameHEX);
    exit(1);
  }

  char line[256];
  while(fgets(line, 256, f) != NULL){

    int linelen = strlen(line) - 1;
    if((linelen != (6 + 32)) && (linelen != (6 + 64))){
      continue;
    }

    // extract the character code from the first 5 characters in hex (with converting to decimal)
    int32_t charcode = 0;
    
    int i = 0;
    for(; i < 5; i++){
      charcode = (charcode << 4) | hex_to_dec(line[i]);
    }
    
    if(map[charcode] != 0){
      continue; // Already from other resource
    }

    // skip ":"
    if(line[i] != ':'){
      printf("Error: invalid line format\n");
      break;
    }
    i++;

    // extract the bitmap bits from the rest of the line, 16 or 32 bytes in hex (with converting to decimal)
    if(linelen == (6 + 32)){
      int32_t index = count8++;
      map[charcode] = ((uint32_t)index) | 0x01000000;
      codepoints8[index] = charcode;
      bitmapWidths[index] = 8;
      for(int j = 0; j < 16; j++){
        uint8_t b = 0, v = 0;
        for(int k = 0; k < 2; k++){
          b = (b << 4) | hex_to_dec(line[i++]);
        }
        for(int k = 0; k < 8; k++){
          v = (v << 1) | (b & 1);
          b >>= 1;
        }
        bitmap8[index][j] = v;
     }
    }else if(linelen == (6 + 64)){
      int32_t index = count16++;
      map[charcode] = ((uint32_t)index) | 0x02000000;
      codepoints16[index] = charcode;
      bitmapWidths[index] = 16;
      for(int j = 0; j < 16; j++){
        uint16_t b = 0, v = 0;
        for(int k = 0; k < 4; k++){
          b = (b << 4) | hex_to_dec(line[i++]);
        }
        for(int k = 0; k < 16; k++){
          v = (v << 1) | (b & 1);
          b >>= 1;
        }
        bitmap16[index][j] = v;
      }
    }
  }

  fclose(f);

}


// 512 pages with 256 characters each for 131072 characters in total for second-level mapping to save space
static int32_t mapPageMap[512]; 
static int32_t mapPageCount = 0;
static uint32_t mapPages[512][256]; 

void constructMapPages(){
  
  // clear the map pages
  for(int i = 0; i < 512; i++){
    mapPageMap[i] = -1;
    for(int j = 0; j < 256; j++){
      mapPages[i][j] = 0u;
    }
  }
  mapPageCount = 0;

  // fill the map pages
  for(int i = 0; i < COUNT_UNICODE_CHARACTERS; i++){
    uint32_t mapValue = map[i];
    if(mapValue != 0u){
      int32_t mapPageIndex = i >> 8;
      int32_t mapPageMapIndex = mapPageMap[mapPageIndex];
      if(mapPageMapIndex < 0){
        mapPageMap[mapPageIndex] = mapPageCount++;
        mapPageMapIndex = mapPageMap[mapPageIndex];
      }
      mapPages[mapPageMapIndex][i & 0xff] = mapValue;
    }
  }

}

void save(){

  FILE *f = fopen(outputname, "w");
  if(f == NULL){
    printf("Error: could not open file %s\n", outputname);
    exit(1);
  }

  if(count8 == 0){
    // Create a dummy font with a single space character
    count8 = 1;
    bitmap8[0][0] = 0x00;
  }

  if(count16 == 0){
    // Create a dummy font with a single space character
    count16 = 1;
    bitmap16[0][0] = 0x0000;
  }

  fprintf(f, "unit VGAFont;\n");
  fprintf(f, "{$ifdef fpc}{$mode delphi}{$endif}\n");
  fprintf(f, "interface\n");
  fprintf(f, "type TVGAFont8Char=array[0..15] of UInt8;\n");
  fprintf(f, "     PVGAFont8Char=^TVGAFont8Char;\n");
  fprintf(f, "     TVGAFont8Chars=array[0..%d] of TVGAFont8Char;\n", count8 - 1);
  fprintf(f, "     TVGAFont16Char=array[0..15] of UInt16;\n");
  fprintf(f, "     PVGAFont16Char=^TVGAFont16Char;\n");
  fprintf(f, "     TVGAFont16Chars=array[0..%d] of TVGAFont16Char;\n", count16 - 1);
  fprintf(f, "     TVGAFontMapPage=array[0..255] of UInt32;\n");
  fprintf(f, "     PVGAFontMapPage=^TVGAFontMapPage;\n");
  fprintf(f, "     TVGAFontMapPages=array[0..%d] of TVGAFontMapPage;\n", mapPageCount - 1);
  fprintf(f, "     PVGAFontMapPages=^TVGAFontMapPages;\n");
  if(mapPageCount < 255){
    fprintf(f, "     TVGAFontMapPageMap=array[0..511] of UInt8;\n");
  }else{
    fprintf(f, "     TVGAFontMapPageMap=array[0..511] of UInt16;\n");
  }
  fprintf(f, "const VGAFont8Chars:TVGAFont8Chars=\n");
  fprintf(f, "       (\n");
  for(int i = 0; i < count8; i++){
    fprintf(f, "        (");
    for(int j = 0; j < 16; j++){
      fprintf(f, "$%02x", bitmap8[i][j]);
      if(j < 15){
        fprintf(f, ",");
      }
    }
    fprintf(f, ")");
    if(i < (count8 - 1)){
      fprintf(f, ",");
    }else{
      fprintf(f, " ");
    }
    fprintf(f, " // codepoint: $%08x\n", codepoints8[i]);
  }
  fprintf(f, "      );\n");
  fprintf(f, "const VGAFont16Chars:TVGAFont16Chars=\n");
  fprintf(f, "       (\n");
  for(int i = 0; i < count16; i++){
    fprintf(f, "        (");
    for(int j = 0; j < 16; j++){
      fprintf(f, "$%04x", bitmap16[i][j]);
      if(j < 15){
        fprintf(f, ",");
      }
    }
    fprintf(f, ")");
    if(i < (count16 - 1)){
      fprintf(f, ",");
    }else{
      fprintf(f, " ");
    }
    fprintf(f, " // codepoint: $%08x\n", codepoints16[i]);
  }
  fprintf(f, "      );\n");
  fprintf(f, "const VGAFontMapPages:TVGAFontMapPages=\n");
  fprintf(f, "       (\n");
  for(int i = 0; i < mapPageCount; i++){
    fprintf(f, "        ( // page: %d\n         ", i);
    for(int j = 0; j < 256; j++){
      fprintf(f, "$%08x", mapPages[i][j]);      
      if(j < 255){
        fprintf(f, ",");
      }
      if((j & 31) == 31){
        if(j < 255){
          fprintf(f, "\n         ");
        }else{
          fprintf(f, "\n");
        }
      }
    }
    fprintf(f, "        )");
    if(i < (mapPageCount - 1)){
      fprintf(f, ",");
    }else{
      fprintf(f, " ");
    }
    fprintf(f, "\n");
  }
  fprintf(f, "      );\n");
  fprintf(f, "const VGAFontMapPageMap:TVGAFontMapPageMap=\n");
  fprintf(f, "       (\n        ");
  for(int i = 0; i < 512; i++){
    if(mapPageCount < 255){
      fprintf(f, "$%02x", mapPageMap[i] + 1);
    }else{
      fprintf(f, "$%04x", mapPageMap[i] + 1);
    }
    if(i < 511){
      fprintf(f, ",");
    }
    if((i & 31) == 31){
      if(i < 511){
        fprintf(f, "\n        ");
      }else{
        fprintf(f, "\n");
      }
    }
  }
  fprintf(f, "      );\n");
  fprintf(f, "implementation\n");
  fprintf(f, "end.\n");
  
  fclose(f);

}

int main(){

  clear();
  loadBIN(32); 
  loadBDF(); 
  loadHEX(); 
  loadBIN(256); 
  constructMapPages();
  save();

  return 0;

} 