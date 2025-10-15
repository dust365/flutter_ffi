#!/bin/bash

set -e

# iOS 模拟器使用 macOS 构建的库
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NATIVE_DIR="$SCRIPT_DIR/../native"
BUILD_DIR="$NATIVE_DIR/build/macos"

# 创建构建目录
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

# 配置 CMake
cmake ../.. -DCMAKE_BUILD_TYPE=Release -DAPPLE=ON

# 编译
cmake --build . --config Release

# 创建输出目录
mkdir -p "$SCRIPT_DIR/Runner"

# 复制库文件
cp -f "$BUILD_DIR/libnative_lib.dylib" "$SCRIPT_DIR/Runner/" || true

echo "Native library built successfully for iOS"

