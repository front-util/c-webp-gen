#include <stdio.h>
#include <emscripten/emscripten.h>
#include "../../libs/libwebp/src/webp/encode.h"


int main(int argc, char ** argv) {
    printf("Launch cwebpgen application...\n");
}

#ifdef __cplusplus
extern "C" {
#endif

int EMSCRIPTEN_KEEPALIVE transformToWebp(int a, int b) {
  return a + b;
}

EMSCRIPTEN_KEEPALIVE
int version() {
  return WebPGetEncoderVersion();
}

#ifdef __cplusplus
}
#endif