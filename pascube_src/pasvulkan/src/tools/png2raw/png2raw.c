// png2raw.c
// A small PNG to raw converter using libpng.
//  - 8-bit PNGs are converted to R8 G8 B8 A8
//  - 16-bit PNGs are converted to R16 G16 B16 A16 (little-endian)

#include <stdio.h>
#include <stdlib.h>
#include <png.h>

int main(int argc, char **argv){
  
  // Check for correct number of arguments
  if(argc != 3){
    fprintf(stderr, "Usage: %s [input.png] [output.raw]\n", argv[0]);
    return 1;
  }

  // Get input and output file names
  const char *infile  = argv[1];
  const char *outfile = argv[2];
  
  // Open input PNG file
  FILE *fp = fopen(infile, "rb");
  if(!fp){
    perror("Error opening input file");
    return 1;
  }
  
  // Read and check PNG signature
  png_byte sig[8];
  if((fread(sig, 1, 8, fp) != 8) || !png_check_sig(sig, 8)){
    fprintf(stderr, "Not a valid PNG file: %s\n", infile);
    fclose(fp);
    return 1;
  }
  
  // Create read structs
  png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if(!png_ptr){
    fprintf(stderr, "Failed to create PNG read struct\n");
    fclose(fp);
    return 1;
  }
  png_infop info_ptr = png_create_info_struct(png_ptr);
  if(!info_ptr){
    fprintf(stderr, "Failed to create PNG info struct\n");
    png_destroy_read_struct(&png_ptr, NULL, NULL);
    fclose(fp);
    return 1;
  }
  if(setjmp(png_jmpbuf(png_ptr))){
    fprintf(stderr, "Error during PNG init\n");
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(fp);
    return 1;
  }
  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);
  
  // Read header info
  png_read_info(png_ptr, info_ptr);
  // png_uint_32 width = png_get_image_width(png_ptr, info_ptr); // Unused variable for now
  png_uint_32 height = png_get_image_height(png_ptr, info_ptr);
  int color_type = png_get_color_type(png_ptr, info_ptr);
  int bit_depth = png_get_bit_depth(png_ptr, info_ptr);
  
  // Expand low bits as needed
  if(bit_depth < 8){
    png_set_expand(png_ptr);
  }

  // Expand palette to RGB
  if(color_type == PNG_COLOR_TYPE_PALETTE){
    png_set_palette_to_rgb(png_ptr);
  }

  // Expand transparency
  if(png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS)){
    png_set_tRNS_to_alpha(png_ptr);
  }
  
  // Convert grayscale to RGB
  if((color_type == PNG_COLOR_TYPE_GRAY) || (color_type == PNG_COLOR_TYPE_GRAY_ALPHA)){
    png_set_gray_to_rgb(png_ptr);
  }
  
  // Ensure we have RGBA
  if((color_type == PNG_COLOR_TYPE_RGB) || (color_type == PNG_COLOR_TYPE_GRAY)){
     png_set_filler(png_ptr, 0xFF, PNG_FILLER_AFTER);
  }
  
  // For 16-bit images, swap to little-endian host order
  if(bit_depth == 16){
    png_set_swap(png_ptr);
  }
  
  // Update the transformations
  png_read_update_info(png_ptr, info_ptr);
  
  // Prepare to read rows
  png_size_t rowbytes = png_get_rowbytes(png_ptr, info_ptr);
  png_bytep row = (png_bytep)malloc(rowbytes);
  if(!row){
    fprintf(stderr, "Failed to allocate memory for PNG row\n");
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(fp);
    return 1;
  }
  
  // Create output RAW file
  // The output will be in R8 G8 B8 A8 or R16 G16 B16 A16 format
  FILE *out = fopen(outfile, "wb");
  if(!out){
    perror("Error opening output file");
    free(row);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(fp);
    return 1;
  }
  
  // Read and write each row
  for(png_uint_32 y = 0; y < height; y++){
    png_read_row(png_ptr, row, NULL);
    fwrite(row, 1, rowbytes, out);
  }
  
  // Cleanup
  fclose(out);
  free(row);
  png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
  fclose(fp);
  
  return 0;
}
