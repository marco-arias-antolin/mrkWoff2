#include <emscripten/emscripten.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <woff2/encode.h>   // MaxWOFF2CompressedSize, ConvertTTFToWOFF2
#include <woff2/decode.h>   // ComputeWOFF2FinalSize, ConvertWOFF2ToTTF

extern "C" {

/**
 * Compresses TTF font data to WOFF2 format
 * @param data Input TTF font data buffer
 * @param length Length of input data
 * @param out_len Output parameter for compressed data length
 * @return Pointer to compressed WOFF2 data or NULL on failure
 */
EMSCRIPTEN_KEEPALIVE
uint8_t* compress_woff2(uint8_t* data, size_t length, uint32_t* out_len) {
  if (!data || length == 0) { *out_len = 0; return NULL; }

  size_t max_out = woff2::MaxWOFF2CompressedSize(data, length);
  uint8_t* out = (uint8_t*)malloc(max_out);
  if (!out) { *out_len = 0; return NULL; }
  size_t outsize = max_out;
  bool ok = woff2::ConvertTTFToWOFF2(data, length, out, &outsize);
  if (!ok) { free(out); *out_len = 0; return NULL; }
  *out_len = (uint32_t)outsize;
  return out;
}

/**
 * Decompress WOFF2 font data to TTF format
 * @param data Input WOFF2 font data buffer
 * @param length Length of input data
 * @param out_len Output parameter for decompressed data length
 * @return Pointer to decompressed TTF data or NULL on failure
 */
EMSCRIPTEN_KEEPALIVE
uint8_t* decompress_woff2(uint8_t* data, size_t length, uint32_t* out_len) {
  if (!data || length == 0) { *out_len = 0; return NULL; }

  size_t final_size = woff2::ComputeWOFF2FinalSize(data, length);
  if (final_size == 0) { *out_len = 0; return NULL; }
  uint8_t* out = (uint8_t*)malloc(final_size);
  if (!out) { *out_len = 0; return NULL; }
  bool ok = woff2::ConvertWOFF2ToTTF(out, final_size, data, length);
  if (!ok) { free(out); *out_len = 0; return NULL; }
  *out_len = (uint32_t)final_size;
  return out;
}

/**
 * Extracts basic information from WOFF2 font data
 * @param data Input WOFF2 font data buffer
 * @param length Length of input data
 * @return Formatted information string about the WOFF2 file
 */
EMSCRIPTEN_KEEPALIVE
char* info_woff2(uint8_t* data, size_t length) {
  const char *too_short = "Not a valid WOFF2 (too short)";
  if (!data || length < 12) {
    char* s = (char*)malloc(strlen(too_short)+1);
    strcpy(s, too_short);
    return s;
  }
  uint32_t sig = (data[0]<<24) | (data[1]<<16) | (data[2]<<8) | data[3];
  char buf[512];
  if (sig != 0x774F4632) { // 'wOF2'
    snprintf(buf, sizeof(buf), "Not WOFF2 signature: 0x%08X", sig);
  } else {
    uint32_t flavor = (data[4]<<24)|(data[5]<<16)|(data[6]<<8)|data[7];
    uint32_t total_len = (data[8]<<24)|(data[9]<<16)|(data[10]<<8)|data[11];
    snprintf(buf, sizeof(buf),
             "WOFF2 file\nflavor: 0x%08X\ndeclared total length: %u bytes\ninput buffer length: %zu bytes\n",
             flavor, total_len, length);
  }
  char* out = (char*)malloc(strlen(buf)+1);
  strcpy(out, buf);
  return out;
}

} // extern "C"
