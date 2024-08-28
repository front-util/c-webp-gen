#!/bin/bash

BUILD_DIR=build
LIBS_DIR=libs
MAIN_FILE_PATH=src/cpp/main.cpp
MAIN_TS_FILE_PATH=src/ts/scripts/initializeApp.ts
OUTPUT_FILE=cwebpgen.js
HTML_TEMPLATE_FILE=index.html

function deleteBuildDir {
    if [ -d "$BUILD_DIR" ];
    then 
        rm -rf $BUILD_DIR 
        echo "Build directory deleted!"
    fi
}

function compileWebpPackage {
    cd libwebp/webp_js

    emcmake cmake -DWEBP_BUILD_WEBP_JS=ON ../
    emmake make

    cd ../../
}

function downloadAndCompileWebpPackage {
    cd $LIBS_DIR
    git clone https://github.com/webmproject/libwebp
    compileWebpPackage
    cd ..
}

function createWorkingDirs {
    mkdir $BUILD_DIR
    echo "Build directory created!"

    if [ ! -d "$LIBS_DIR" ]; then
        mkdir $LIBS_DIR
        downloadAndCompileWebpPackage
        echo "LibWebp package compiled!"
    fi
}



function buildWASM {
    echo "Compiling WASM..."

    emcc -O3 -s WASM=1 -s EXPORTED_RUNTIME_METHODS='["cwrap"]' \
    -I $LIBS_DIR/libwebp \
    $MAIN_FILE_PATH \
    $LIBS_DIR/libwebp/src/{dec,dsp,demux,enc,mux,utils}/*.c \
    $LIBS_DIR/libwebp/sharpyuv/*.c \
    -o $BUILD_DIR/$OUTPUT_FILE
    # --shell-file src/html/$HTML_TEMPLATE_FILE
}

function buildJS {
    bun build $MAIN_TS_FILE_PATH --outdir $BUILD_DIR \
        --minify --splitting --format esm

    echo "Ts files compiled!"
}

function copyHTMLTemplate {
    cp src/html/$HTML_TEMPLATE_FILE $BUILD_DIR

    echo "Copy html template!"
}

function build {
    echo "Build started..."

    deleteBuildDir
    createWorkingDirs
    buildJS
    copyHTMLTemplate
    buildWASM

    echo "Build finished!"
}

function dev {
    emrun --browser chrome $BUILD_DIR/$HTML_TEMPLATE_FILE
}

case $1 in
    build)
        build
        ;;
    dev)
        dev
        ;;
esac