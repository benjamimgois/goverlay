#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Deflate compression
#include <zlib.h>

// LZMA compression
#include <lzma.h>

// Forward transform for 32-bit float data using value-wise delta encoding and order preservation
void ForwardTransform32BitFloatDataValueWiseDelta(const void *aInData, void *aOutData, size_t aDataSize) {
    size_t Count = aDataSize >> 2;
    uint32_t Previous = 0;
    uint32_t Value, Delta;

    for (size_t Index = 0; Index < Count; ++Index) {
        Value = ((uint32_t *)aInData)[Index];
        Value = Value ^ ((uint32_t)((int32_t)((uint32_t)(-(int32_t)(Value >> 31)))) | (uint32_t)0x80000000);
        Delta = Value - Previous;
        Previous = Value;
        ((uint8_t *)aOutData)[Index] = (Delta >> 24) & 0xff;
        ((uint8_t *)aOutData)[Index + Count] = (Delta >> 16) & 0xff;
        ((uint8_t *)aOutData)[Index + (Count * 2)] = (Delta >> 8) & 0xff;
        ((uint8_t *)aOutData)[Index + (Count * 3)] = (Delta >> 0) & 0xff;
    }
}

// Backward transform for 32-bit float data using value-wise delta encoding and order preservation
void BackwardTransform32BitFloatDataValueWiseDelta(const void *aInData, void *aOutData, size_t aDataSize) {
    size_t Count = aDataSize >> 2;
    uint32_t Value = 0;

    for (size_t Index = 0; Index < Count; ++Index) {
        Value += ((uint32_t)((uint8_t *)aInData)[Index] << 24) |
                 ((uint32_t)((uint8_t *)aInData)[Index + Count] << 16) |
                 ((uint32_t)((uint8_t *)aInData)[Index + (Count * 2)] << 8) |
                 ((uint32_t)((uint8_t *)aInData)[Index + (Count * 3)] << 0);
        ((uint32_t *)aOutData)[Index] = Value ^ ((uint32_t)((uint32_t)((Value >> 31) - 1) | (uint32_t)0x80000000));
    }
}

// Forward transform for 32-bit float data using byte-wise delta encoding and order preservation
void ForwardTransform32BitFloatDataBytewiseDelta(const void *aInData, void *aOutData, size_t aDataSize) {
    
    size_t Count = aDataSize >> 2;

    uint8_t PreviousA = 0, PreviousB = 0, PreviousC = 0, PreviousD = 0;   

    for (size_t Index = 0; Index < Count; ++Index) {
        
        uint32_t Value = ((uint32_t *)aInData)[Index];
        Value = Value ^ ((uint32_t)((int32_t)((uint32_t)(-(int32_t)(Value >> 31)))) | (uint32_t)0x80000000);

        uint8_t ValueA = (Value >> 24) & 0xff;
        uint8_t ValueB = (Value >> 16) & 0xff;
        uint8_t ValueC = (Value >> 8) & 0xff;
        uint8_t ValueD = (Value >> 0) & 0xff;

        uint8_t DeltaA = ValueA - PreviousA;
        uint8_t DeltaB = ValueB - PreviousB;
        uint8_t DeltaC = ValueC - PreviousC;
        uint8_t DeltaD = ValueD - PreviousD;

        PreviousA = ValueA;
        PreviousB = ValueB;
        PreviousC = ValueC;
        PreviousD = ValueD;

        ((uint8_t *)aOutData)[Index] = DeltaA;
        ((uint8_t *)aOutData)[Index + Count] = DeltaB;
        ((uint8_t *)aOutData)[Index + (Count * 2)] = DeltaC;
        ((uint8_t *)aOutData)[Index + (Count * 3)] = DeltaD;      

    }

}

// Backward transform for 32-bit float data using byte-wise delta encoding and order preservation
void BackwardTransform32BitFloatDataByteWiseDelta(const void *aInData, void *aOutData, size_t aDataSize) {
  
  size_t Count = aDataSize >> 2;

  uint8_t ValueA = 0, ValueB = 0, ValueC = 0, ValueD = 0;

  for (size_t Index = 0; Index < Count; ++Index) {

    ValueA += ((uint8_t *)aInData)[Index];
    ValueB += ((uint8_t *)aInData)[Index + Count];
    ValueC += ((uint8_t *)aInData)[Index + (Count * 2)];
    ValueD += ((uint8_t *)aInData)[Index + (Count * 3)];
    
    uint32_t Value = ((uint32_t)ValueA << 24) | ((uint32_t)ValueB << 16) | ((uint32_t)ValueC << 8) | ((uint32_t)ValueD << 0);

    ((uint32_t *)aOutData)[Index] = Value ^ ((uint32_t)((uint32_t)((Value >> 31) - 1) | (uint32_t)0x80000000));

  }

}
   
int32_t zlibCompress(const void *aInData, void *aOutData, size_t aInDataSize, size_t* aOutDataSize) {
  z_stream Stream;
  Stream.zalloc = Z_NULL;
  Stream.zfree = Z_NULL;
  Stream.opaque = Z_NULL;
  Stream.avail_in = aInDataSize;
  Stream.next_in = (Bytef *)aInData;
  Stream.avail_out = *aOutDataSize;
  Stream.next_out = (Bytef *)aOutData;
  deflateInit(&Stream, Z_DEFAULT_COMPRESSION);
  int32_t result = deflate(&Stream, Z_FINISH);
  *aOutDataSize = Stream.total_out;
  deflateEnd(&Stream);
  return result;
}

int32_t zlibDecompress(const void *aInData, void *aOutData, size_t aInDataSize, size_t aOutDataSize) {
  z_stream Stream;
  Stream.zalloc = Z_NULL;
  Stream.zfree = Z_NULL;
  Stream.opaque = Z_NULL;
  Stream.avail_in = aInDataSize;
  Stream.next_in = (Bytef *)aInData;
  Stream.avail_out = aOutDataSize;
  Stream.next_out = (Bytef *)aOutData;
  inflateInit(&Stream);
  int32_t result = inflate(&Stream, Z_FINISH);
  inflateEnd(&Stream);
  return result;
}

int32_t lzmaCompress(const void *aInData, void *aOutData, size_t aInDataSize, size_t* aOutDataSize) {
  lzma_stream Stream = LZMA_STREAM_INIT;
  lzma_ret result = lzma_easy_encoder(&Stream, LZMA_PRESET_DEFAULT, LZMA_CHECK_CRC64);
  if(result != LZMA_OK){
    return 0;
  }
  Stream.next_in = (uint8_t *)aInData;
  Stream.avail_in = aInDataSize;
  Stream.next_out = (uint8_t *)aOutData;
  Stream.avail_out = *aOutDataSize;
  result = lzma_code(&Stream, LZMA_FINISH);
  *aOutDataSize = Stream.total_out;
  lzma_end(&Stream);
  return (result == LZMA_OK) ? 1 : 0;
}

int32_t lzmaDecompress(const void *aInData, void *aOutData, size_t aInDataSize, size_t aOutDataSize) {
  lzma_stream Stream = LZMA_STREAM_INIT;
  lzma_ret result = lzma_stream_decoder(&Stream, UINT64_MAX, LZMA_CONCATENATED);
  if(result != LZMA_OK){
    return 0;
  }
  Stream.next_in = (uint8_t *)aInData;
  Stream.avail_in = aInDataSize;
  Stream.next_out = (uint8_t *)aOutData;
  Stream.avail_out = aOutDataSize;
  result = lzma_code(&Stream, LZMA_FINISH);
  lzma_end(&Stream);
  return (result == LZMA_OK) ? 1 : 0;
}

int32_t main(const int32_t aArgc, const char *aArgv[]) {

  void *Data = NULL;
  size_t DataSize = 0;

  // Check for data.bin
  FILE *File = fopen("data.bin", "rb");
  if (File != NULL) {
    
    // Load test data from data.bin 
    fprintf(stdout, "Loading test data from data.bin . . . ");
    fflush(stdout);
    FILE *File = fopen("data.bin", "rb");
    fseek(File, 0, SEEK_END);
    DataSize = ftell(File);
    fseek(File, 0, SEEK_SET);
    Data = malloc(DataSize);
    fread(Data, 1, DataSize, File);
    fclose(File);
    fprintf(stdout, "done!\n");
    fflush(stdout);

  }else{

    // Generate test data
    fprintf(stdout, "Generating test data . . . ");
    fflush(stdout);
    DataSize = 1024 * 1024;
    Data = malloc(DataSize);
    for (size_t Index = 0; Index < DataSize / 4; ++Index) {
      ((float *)Data)[Index] = sinf((float)Index / (float)(DataSize) * 2.0f * 3.14159265359f);
    }
    fprintf(stdout, "done!\n");
    fflush(stdout);

  }  

  // Prefilter data using value-wise delta encoding
  fprintf(stdout, "Prefiltering data using value-wise delta encoding . . . ");
  fflush(stdout);
  void *PrefilteredValueWiseData = malloc(DataSize);
  ForwardTransform32BitFloatDataValueWiseDelta(Data, PrefilteredValueWiseData, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Prefilter data using byte-wise delta encoding
  fprintf(stdout, "Prefiltering data using byte-wise delta encoding . . . ");
  fflush(stdout);
  void *PrefilteredByteWiseData = malloc(DataSize);
  ForwardTransform32BitFloatDataBytewiseDelta(Data, PrefilteredByteWiseData, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress unfiltered data using zlib
  fprintf(stdout, "Compressing unfiltered data using zlib . . . ");
  fflush(stdout);
  size_t CompressedDataSize = DataSize * 2;
  void *CompressedDataZLib = malloc(CompressedDataSize);
  zlibCompress(Data, CompressedDataZLib, DataSize, &CompressedDataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress prefiltered value-wise data using zlib
  fprintf(stdout, "Compressing prefiltered value-wise data using zlib . . . ");
  fflush(stdout);
  size_t CompressedValueWiseDataSize = DataSize * 2;
  void *CompressedValueWiseDataZLib = malloc(CompressedValueWiseDataSize);
  zlibCompress(PrefilteredValueWiseData, CompressedValueWiseDataZLib, DataSize, &CompressedValueWiseDataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress prefiltered byte-wise data using zlib
  fprintf(stdout, "Compressing prefiltered byte-wise data using zlib . . . ");
  fflush(stdout);
  size_t CompressedByteWiseDataSize = DataSize * 2;
  void *CompressedByteWiseDataZLib = malloc(CompressedByteWiseDataSize);
  zlibCompress(PrefilteredByteWiseData, CompressedByteWiseDataZLib, DataSize, &CompressedByteWiseDataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress unfiltered data using lzma
  fprintf(stdout, "Compressing unfiltered data using lzma . . . ");
  fflush(stdout);
  size_t CompressedDataSizeLzma = DataSize * 2;
  void *CompressedDataLzma = malloc(CompressedDataSizeLzma);
  lzmaCompress(Data, CompressedDataLzma, DataSize, &CompressedDataSizeLzma);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress prefiltered value-wise data using lzma
  fprintf(stdout, "Compressing prefiltered value-wise data using lzma . . . ");
  fflush(stdout);
  size_t CompressedValueWiseDataSizeLzma = DataSize * 2;
  void *CompressedValueWiseDataLzma = malloc(CompressedValueWiseDataSizeLzma);
  lzmaCompress(PrefilteredValueWiseData, CompressedValueWiseDataLzma, DataSize, &CompressedValueWiseDataSizeLzma);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compress prefiltered byte-wise data using lzma
  fprintf(stdout, "Compressing prefiltered byte-wise data using lzma . . . ");
  fflush(stdout);
  size_t CompressedByteWiseDataSizeLzma = DataSize * 2;
  void *CompressedByteWiseDataLzma = malloc(CompressedByteWiseDataSizeLzma);
  lzmaCompress(PrefilteredByteWiseData, CompressedByteWiseDataLzma, DataSize, &CompressedByteWiseDataSizeLzma);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Print sizes
  fprintf(stdout, "Original data size: %zu bytes\n", DataSize);
  fprintf(stdout, "zlib compressed data size: %zu bytes\n", CompressedDataSize);
  fprintf(stdout, "zlib compressed value-wise data size: %zu bytes\n", CompressedValueWiseDataSize);
  fprintf(stdout, "zlib compressed byte-wise data size: %zu bytes\n", CompressedByteWiseDataSize);
  fprintf(stdout, "lzma compressed data size: %zu bytes\n", CompressedDataSizeLzma);
  fprintf(stdout, "lzma compressed value-wise data size: %zu bytes\n", CompressedValueWiseDataSizeLzma);
  fprintf(stdout, "lzma compressed byte-wise data size: %zu bytes\n", CompressedByteWiseDataSizeLzma);
  fflush(stdout);
  
  // Decompress compressed value-wise data using zlib
  fprintf(stdout, "Decompressing compressed value-wise data using zlib . . . ");
  fflush(stdout);
  void *DecompressedValueWiseDataZLib = malloc(DataSize);
  zlibDecompress(CompressedValueWiseDataZLib, DecompressedValueWiseDataZLib, CompressedValueWiseDataSize, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Decompress compressed byte-wise data using zlib
  fprintf(stdout, "Decompressing compressed byte-wise data using zlib . . . ");
  fflush(stdout);
  void *DecompressedByteWiseDataZLib = malloc(DataSize);
  zlibDecompress(CompressedByteWiseDataZLib, DecompressedByteWiseDataZLib, CompressedByteWiseDataSize, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Decompress compressed value-wise data using lzma
  fprintf(stdout, "Decompressing compressed value-wise data using lzma . . . ");
  fflush(stdout);
  void *DecompressedValueWiseDataLzma = malloc(DataSize);
  lzmaDecompress(CompressedValueWiseDataLzma, DecompressedValueWiseDataLzma, CompressedValueWiseDataSizeLzma, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Decompress compressed byte-wise data using lzma
  fprintf(stdout, "Decompressing compressed byte-wise data using lzma . . . ");
  fflush(stdout);
  void *DecompressedByteWiseDataLzma = malloc(DataSize);
  lzmaDecompress(CompressedByteWiseDataLzma, DecompressedByteWiseDataLzma, CompressedByteWiseDataSizeLzma, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);
  
  // Postfilter decompressed value-wise data
  fprintf(stdout, "Postfiltering decompressed value-wise data using zlib . . . ");
  fflush(stdout);
  void *PostfilteredValueWiseDataZLib = malloc(DataSize);
  BackwardTransform32BitFloatDataValueWiseDelta(DecompressedValueWiseDataZLib, PostfilteredValueWiseDataZLib, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Postfilter decompressed byte-wise data
  fprintf(stdout, "Postfiltering decompressed byte-wise data using zlib . . . ");
  fflush(stdout);
  void *PostfilteredByteWiseDataZLib = malloc(DataSize);
  BackwardTransform32BitFloatDataByteWiseDelta(DecompressedByteWiseDataZLib, PostfilteredByteWiseDataZLib, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Postfilter decompressed value-wise data using lzma
  fprintf(stdout, "Postfiltering decompressed value-wise data using lzma . . . ");
  fflush(stdout);
  void *PostfilteredValueWiseDataLzma = malloc(DataSize);
  BackwardTransform32BitFloatDataValueWiseDelta(DecompressedValueWiseDataLzma, PostfilteredValueWiseDataLzma, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Postfilter decompressed byte-wise data using lzma
  fprintf(stdout, "Postfiltering decompressed byte-wise data using lzma . . . ");
  fflush(stdout);
  void *PostfilteredByteWiseDataLzma = malloc(DataSize);
  BackwardTransform32BitFloatDataByteWiseDelta(DecompressedByteWiseDataLzma, PostfilteredByteWiseDataLzma, DataSize);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  // Compare original data with postfiltered value-wise data
  fprintf(stdout, "Comparing original data with postfiltered value-wise data using zlib . . . ");
  fflush(stdout);
  int32_t ValueWiseDataComparison = memcmp(Data, PostfilteredValueWiseDataZLib, DataSize);
  fprintf(stdout, "done! (comparison %s)\n", ValueWiseDataComparison == 0 ? "succeeded" : "failed");
  fflush(stdout);

  // Compare original data with postfiltered byte-wise data
  fprintf(stdout, "Comparing original data with postfiltered byte-wise data using zlib . . . ");
  fflush(stdout);
  int32_t ByteWiseDataComparison = memcmp(Data, PostfilteredByteWiseDataZLib, DataSize);
  fprintf(stdout, "done! (comparison %s)\n", ByteWiseDataComparison == 0 ? "succeeded" : "failed");
  fflush(stdout);

  // Compare original data with postfiltered value-wise data using lzma
  fprintf(stdout, "Comparing original data with postfiltered value-wise data using lzma . . . ");
  fflush(stdout);
  int32_t ValueWiseDataComparisonLzma = memcmp(Data, PostfilteredValueWiseDataLzma, DataSize);
  fprintf(stdout, "done! (comparison %s)\n", ValueWiseDataComparisonLzma == 0 ? "succeeded" : "failed");
  fflush(stdout);

  // Compare original data with postfiltered byte-wise data using lzma
  fprintf(stdout, "Comparing original data with postfiltered byte-wise data using lzma . . . ");
  fflush(stdout);
  int32_t ByteWiseDataComparisonLzma = memcmp(Data, PostfilteredByteWiseDataLzma, DataSize);
  fprintf(stdout, "done! (comparison %s)\n", ByteWiseDataComparisonLzma == 0 ? "succeeded" : "failed");
  fflush(stdout);
  
  // Free memory
  fprintf(stdout, "Freeing memory . . . ");
  fflush(stdout);
  free(Data);
  free(PrefilteredValueWiseData);
  free(PrefilteredByteWiseData);
  free(CompressedDataZLib);
  free(CompressedValueWiseDataZLib);
  free(CompressedByteWiseDataZLib);
  free(CompressedDataLzma);
  free(CompressedValueWiseDataLzma);
  free(CompressedByteWiseDataLzma);
  free(DecompressedValueWiseDataZLib);
  free(DecompressedByteWiseDataZLib);
  free(DecompressedValueWiseDataLzma);
  free(DecompressedByteWiseDataLzma);  
  free(PostfilteredValueWiseDataZLib);
  free(PostfilteredByteWiseDataZLib);
  free(PostfilteredValueWiseDataLzma);
  free(PostfilteredByteWiseDataLzma);
  fprintf(stdout, "done!\n");
  fflush(stdout);

  fprintf(stdout, "Test completed!\n");
  fflush(stdout);
  
  return 0;
}
