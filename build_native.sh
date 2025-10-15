#!/bin/bash

# Flutter FFI Demo - Native Library Build Script
# 用于编译各平台的原生库

set -e

echo "====================================="
echo "Flutter FFI Demo - 原生库构建脚本"
echo "====================================="
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NATIVE_DIR="$SCRIPT_DIR/native"

MACHINE=android
echo "当前编译平台: $MACHINE"
echo ""

# 编译 macOS 版本
build_macos() {
    echo "🔨 编译 macOS 版本..."
    BUILD_DIR="$NATIVE_DIR/build/macos"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake ../.. -DCMAKE_BUILD_TYPE=Release -DAPPLE=ON
    cmake --build . --config Release
    
    echo "✅ macOS 版本编译完成"
    echo "   库文件位置: $BUILD_DIR/libnative_lib.dylib"
    echo ""
}

# 编译 iOS 版本（使用 macOS 构建作为模拟器）
build_ios() {
    echo "🔨 编译 iOS 版本（模拟器使用 macOS 版本）..."
    
    # iOS 模拟器可以使用 macOS 构建的库
    mkdir -p "$SCRIPT_DIR/ios/Runner"
    if [ -f "$NATIVE_DIR/build/macos/libnative_lib.dylib" ]; then
        cp -f "$NATIVE_DIR/build/macos/libnative_lib.dylib" "$SCRIPT_DIR/ios/Runner/"
        echo "✅ iOS 版本准备完成"
    else
        echo "⚠️  请先编译 macOS 版本"
    fi
    echo ""
}

# 编译 Linux 版本
build_linux() {
    echo "🔨 编译 Linux 版本..."
    BUILD_DIR="$NATIVE_DIR/build/linux"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake ../.. -DCMAKE_BUILD_TYPE=Release
    cmake --build . --config Release
    
    echo "✅ Linux 版本编译完成"
    echo ""
}

# 复制 Android 库到 jniLibs
copy2androidjni() {
    echo "📦 复制 Android 库文件到 jniLibs..."
    
    SOURCE_DIR="$NATIVE_DIR/libs/android"
    TARGET_DIR="$SCRIPT_DIR/android/app/src/main/jniLibs"
    
    # 创建目标目录
    mkdir -p "$TARGET_DIR"
    
    # 复制所有架构的库文件
    for ABI in armeabi-v7a arm64-v8a x86 x86_64; do
        if [ -f "$SOURCE_DIR/$ABI/libnative_lib.so" ]; then
            mkdir -p "$TARGET_DIR/$ABI"
            cp -f "$SOURCE_DIR/$ABI/libnative_lib.so" "$TARGET_DIR/$ABI/"
            echo "  ✅ 已复制 $ABI"
        else
            echo "  ⚠️  未找到 $ABI 库文件"
        fi
    done
    
    echo "✅ 库文件已复制android 路径下: $TARGET_DIR"
    echo ""
}

# 编译 Android 版本
build_android() {
    echo "🔨 编译 Android 版本..."
    
    # 检查 NDK 环境变量
    if [ -z "$ANDROID_NDK" ]; then
        echo "⚠️  警告: ANDROID_NDK 环境变量未设置"
        echo "正在尝试从 Android SDK 中查找 NDK..."
        
        if [ -d "$HOME/Library/Android/sdk/ndk" ]; then
            # macOS
            ANDROID_NDK=$(ls -d "$HOME/Library/Android/sdk/ndk"/* | tail -n 1)
            export ANDROID_NDK
        elif [ -d "$ANDROID_HOME/ndk" ]; then
            ANDROID_NDK=$(ls -d "$ANDROID_HOME/ndk"/* | tail -n 1)
            export ANDROID_NDK
        else
            echo "❌ 错误: 找不到 Android NDK"
            echo "请安装 Android NDK 或设置 ANDROID_NDK 环境变量"
            return 1
        fi
    fi
    
    echo "使用 NDK: $ANDROID_NDK"
    
    # Android ABI 列表
    ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
    
    for ABI in "${ANDROID_ABIS[@]}"; do
        echo ""
        echo "编译 $ABI..."
        BUILD_DIR="$NATIVE_DIR/build/android/$ABI"
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"
        
        cmake ../../.. \
            -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
            -DANDROID_ABI="$ABI" \
            -DANDROID_PLATFORM=android-21 \
            -DCMAKE_BUILD_TYPE=Release \
            -DANDROID=ON
        
        cmake --build . --config Release
        
        echo "✅ $ABI 编译完成"
    done
    
    echo ""
    echo "✅ Android 所有架构编译完成"
    echo "   库文件位置: $NATIVE_DIR/libs/android/"
    echo ""
    
    # 复制到 jniLibs
    copy2androidjni
}

# 主函数
main() {
    if [ "$MACHINE" = "Mac" ]; then
        build_macos
        build_ios
    elif [ "$MACHINE" = "Linux" ]; then
        build_linux
    elif [ "$MACHINE" = "android" ]; then
            build_android    
    elif [ "$MACHINE" = "Windows" ]; then
        echo "❌ Windows 请使用 build_native.bat 脚本"
        exit 1
    fi
    
    echo "====================================="
    echo "✅ 构建完成！"
    echo "====================================="
    echo ""
    echo "接下来可以运行:"
    echo "  flutter run -d macos      # 运行 macOS 版本"
    echo "  flutter run -d linux      # 运行 Linux 版本"
    echo "  flutter run               # 运行到连接的设备"
    echo ""
}

# 执行主函数
main

