#!/bin/bash

CURRENT_PATH=$PWD
DIST_PATH=$CURRENT_PATH/../dist
SRC_PATH=$CURRENT_PATH/../src

# Production
cd $CURRENT_PATH/PhysX/physx/compiler/emscripten-release/

rm sdk_source_bin/physx-js-webidl.wasm.*
make -j8
cp sdk_source_bin/physx-js-webidl.wasm.js $SRC_PATH/trident-physx-js-webidl.wasm.js
cp sdk_source_bin/physx-js-webidl.wasm.wasm $DIST_PATH/trident-physx-js-webidl.wasm.wasm