#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>

static uint32_t escapeBitmap[256 / 32];

static uint32_t hexBitmap[256 / 32];

int main(int argc, char **argv) {
	
  FILE *inputFile, *outputFile;
  
  char* inputFileName = argv[1];
  
  char* variableName = argv[2];
  
  char* outputFileName = argv[3];
    
  if(argc != 4){
    fprintf(stderr, "Usage: %s <input file> <variable name> <output file>\n", argv[0]);
    return 1;
  
  }
  if(!strcmp(inputFileName, "-")){
    inputFile = stdin;
  }else{
    inputFile = fopen(inputFileName, "rb");
  }
  
  if(!inputFile){
    fprintf(stderr, "Can't open input file \"%s\"", inputFileName);
    return errno;
  }
  
  if(!strcmp(outputFileName, "-")){
    outputFile = stdout;
  }else{
    outputFile = fopen(outputFileName, "w");
  }
  
  if(!outputFile){
    fprintf(stderr, "Can't open output file \"%s\"", outputFileName);
    return errno;
  }
  
  fseek(inputFile, 0, SEEK_END);
  size_t inputFileSize = ftell(inputFile);
  fseek(inputFile, 0, SEEK_SET);
  size_t inputPosition = 0;
  
  fprintf(outputFile, "#include <stdint.h>\n");
  fprintf(outputFile, "static const unsigned char %s_data[%zu] = \"", variableName, inputFileSize);
//fprintf(outputFile, "static const uint8_t %s_data[%zu] = {\n", variableName, inputFileSize);
  
  {  
    memset(escapeBitmap, 0xff, sizeof(escapeBitmap));
    for(uint8_t i = 0x20; i <= 0x7e; i++){
      escapeBitmap[i >> 5] &= ~(1 << (i & 31));
    }  
    escapeBitmap[((uint8_t)('"')) >> 5] |= 1 << (((uint8_t)('"'))&31);
    escapeBitmap[((uint8_t)('\\')) >> 5] |= 1 << (((uint8_t)('\\'))&31);
    escapeBitmap[((uint8_t)('\'')) >> 5] |= 1 << (((uint8_t)('\''))&31);
    escapeBitmap[((uint8_t)('?')) >> 5] |= 1 << (((uint8_t)('?'))&31);
  }
  
  {  
    memset(hexBitmap, 0, sizeof(hexBitmap));
    for(uint8_t i = '0'; i <= '9'; i++){
      hexBitmap[i >> 5] |= 1 << (i & 31);
    }  
    for(uint8_t i = 'a'; i <= 'f'; i++){
      hexBitmap[i >> 5] |= 1 << (i & 31);
    }  
    for(uint8_t i = 'A'; i <= 'F'; i++){
      hexBitmap[i >> 5] |= 1 << (i & 31);
    }  
  }

  while(inputPosition < inputFileSize){
    uint8_t buffer[128];
    size_t readSize = fread(buffer, 1, sizeof(buffer), inputFile);
    if(!readSize){
      fprintf(stderr, "Can't read input file \"%s\"", inputFileName);
      return errno;
    }
    for(size_t i = 0; i < readSize; ++i) {
      uint8_t current_byte = buffer[i];
      if((escapeBitmap[current_byte >> 5] & (1 << (current_byte & 31))) != 0){
        char printable[8];
        printable[0] = '\\';
        printable[1] = '0' + ((current_byte >> 6) & 0x7);
        printable[2] = '0' + ((current_byte >> 3) & 0x7);
        printable[3] = '0' + ((current_byte >> 0) & 0x7);
        uint8_t next_byte = ((i + 1) < readSize) ? buffer[i + 1] : 0;
        if((hexBitmap[next_byte >> 5] & (1 << (next_byte & 31))) != 0){
          printable[4] = '"';
          printable[5] = ' ';
          printable[6] = '"';
          printable[7] = 0;
        } else {
          printable[4] = 0;
        }
        fprintf(outputFile, "%s", printable);
      } else {
        fprintf(outputFile, "%c", current_byte);
      }
    }    
    fprintf(outputFile, "\"\n\"");
    inputPosition += readSize;
  }

  fprintf(outputFile, "\";\n"); 

  fprintf(outputFile, "static const uint32_t %s_size = %zu;\n", variableName, inputFileSize);
  fprintf(outputFile, "#if defined(__arm__) || defined(__arm) || defined(__M_ARM)\n"); 
  fprintf(outputFile, "#ifndef __arm__\n"); 
  fprintf(outputFile, "#define __arm__\n"); 
  fprintf(outputFile, "#endif\n"); 
  fprintf(outputFile, "#define CALLCONV\n"); 
  fprintf(outputFile, "#elif defined(__aarch64__) || defined(__aarch64) || defined(__M_ARCH64)\n"); 
  fprintf(outputFile, "#ifndef __aarch64__\n"); 
  fprintf(outputFile, "#define __aarch64__\n"); 
  fprintf(outputFile, "#endif\n"); 
  fprintf(outputFile, "#define CALLCONV\n"); 
  fprintf(outputFile, "#elif defined(__x86_64__) || defined(__M_X64) || defined(__M_AMD64) || defined(__amd64__) || defined(__amd64)\n"); 
  fprintf(outputFile, "#ifndef __x86_64__\n"); 
  fprintf(outputFile, "#define __x86_64__\n"); 
  fprintf(outputFile, "#endif\n"); 
  fprintf(outputFile, "#if defined(__WIN32__) || defined(__WIN64__) || defined(__WINDOWS__) || defined(__WIN32) || defined(__WIN64) || defined(__WINDOWS) || defined(WIN32) || defined(WIN64) || defined(WINDOWS) || defined(__win32__) || defined(__win64__) || defined(__windows__) || defined(__win32) || defined(__win64) || defined(__windows) || defined(win32) || defined(win64) || defined(windows) || defined(__win32__) || defined(__win64__) || defined(__windows__) || defined(__win32) || defined(__win64) || defined(__windows) || defined(win32) || defined(win64) || defined(windows)\n"); 
  fprintf(outputFile, "#define CALLCONV __attribute__((ms_abi))\n"); 
  fprintf(outputFile, "#else\n"); 
  fprintf(outputFile, "#define CALLCONV __attribute__((sysv_abi))\n"); 
  fprintf(outputFile, "#endif\n"); 
  fprintf(outputFile, "#elif defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__) || defined(__i386) || defined(i386) || defined(__X86__) || defined(__M_IX86)\n"); 
  fprintf(outputFile, "#ifndef __i386__\n"); 
  fprintf(outputFile, "#define __i386__\n"); 
  fprintf(outputFile, "#endif\n"); 
  fprintf(outputFile, "#define CALLCONV __attribute__((cdecl))\n"); 
  fprintf(outputFile, "#else\n"); 
  fprintf(outputFile, "#error \"Unsupported target\"\n");
  fprintf(outputFile, "#endif\n");
  fprintf(outputFile, "uint32_t CALLCONV get_%s_size(){\n", variableName);
  fprintf(outputFile, "  return %s_size;\n", variableName);
  fprintf(outputFile, "}\n");
  fprintf(outputFile, "const uint8_t* CALLCONV get_%s_data(){\n", variableName);
  fprintf(outputFile, "  return (void*)&%s_data;\n", variableName);
  fprintf(outputFile, "}\n");

  fclose(inputFile);

  fclose(outputFile);

  return 0;

}
