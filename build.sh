#!/bin/bash

BUILD_DIR=build
LIBS_DIR=libs
MAIN_FILE=main.cpp
OUTPUT_FILE=cwebpgen.html
HTML_TEMPLATE_FILE=template.html

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
    echo "Compiling..."

    emcc -O3 -s WASM=1 -s EXPORTED_RUNTIME_METHODS='["cwrap"]' \
    -I $LIBS_DIR/libwebp \
    src/cpp/$MAIN_FILE \
    $LIBS_DIR/libwebp/src/{dec,dsp,demux,enc,mux,utils}/*.c \
    $LIBS_DIR/libwebp/sharpyuv/*.c \
    -o $BUILD_DIR/$OUTPUT_FILE \
    --shell-file src/html/$HTML_TEMPLATE_FILE
}

function build {
    echo "Build started..."

    deleteBuildDir
    createWorkingDirs
    buildWASM
    
    echo "Build finished!"
}

function dev {
    emrun --browser chrome build/$OUTPUT_FILE
}

case $1 in
    build)
        build
        ;;
    dev)
        dev
        ;;
esac