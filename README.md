# Flutter FFI Demo

一个完整的 Flutter FFI（Foreign Function Interface）演示项目，展示如何在 Flutter 中调用 C++ 原生代码。

## 项目特性

本项目演示了以下 FFI 功能：

### ✅ 基础类型传递
- 整数加法、减法
- 浮点数乘法、除法

### ✅ 字符串操作
- 字符串反转
- 字符串转大写
- 字符串拼接
- 内存管理（自动释放 C++ 分配的内存）

### ✅ 结构体操作
- 创建 Point 结构体
- 计算两点之间的距离
- 结构体内存管理

### ✅ 回调函数
- 注册和触发回调
- 带进度的处理回调
- Dart 与 C++ 之间的回调桥接

### ✅ 异步调用
- 在 C++ 中使用多线程
- 异步计算并通过回调返回结果

## 项目结构

```
ffi_demo/
├── lib/
│   ├── main.dart                 # Flutter UI 主应用
│   └── ffi_bridge.dart          # FFI 绑定层
├── native/                       # C++ 原生库
│   ├── CMakeLists.txt           # CMake 构建配置
│   ├── src/
│   │   ├── native_lib.h         # C++ 头文件
│   │   └── native_lib.cpp       # C++ 实现
│   └── build/                    # 编译输出目录
├── android/                      # Android 平台配置
├── ios/                          # iOS 平台配置
├── macos/                        # macOS 平台配置
├── windows/                      # Windows 平台配置
├── linux/                        # Linux 平台配置
├── build_native.sh              # macOS/Linux 构建脚本
├── build_native.bat             # Windows 构建脚本
└── pubspec.yaml
```

## 支持的平台

- ✅ Android (armeabi-v7a, arm64-v8a, x86, x86_64)
- ✅ iOS (模拟器和真机)
- ✅ macOS (arm64, x86_64)
- ✅ Windows (x64)
- ✅ Linux (x64)

## 环境要求

### 通用要求
- Flutter SDK (>= 3.7.2)
- Dart SDK (>= 3.7.2)

### macOS/iOS 开发
- Xcode (最新版本)
- CMake (>= 3.10)
  ```bash
  brew install cmake
  ```

### Android 开发
- Android Studio
- Android NDK
- CMake (Android Studio 自带)

### Windows 开发
- Visual Studio 2019 或 2022
- C++ 桌面开发工具
- CMake (>= 3.10)

### Linux 开发
- GCC/G++ 编译器
- CMake (>= 3.13)
- GTK 3 开发库
  ```bash
  sudo apt-get install cmake build-essential libgtk-3-dev
  ```

## 快速开始

### 1. 克隆项目（如果从仓库克隆）

```bash
cd /path/to/ffi_demo
```

### 2. 安装 Flutter 依赖

```bash
flutter pub get
```

### 3. 编译原生库

#### macOS/Linux:
```bash
./build_native.sh
```

#### Windows:
```cmd
build_native.bat
```

### 4. 运行项目

#### macOS:
```bash
flutter run -d macos
```

#### Windows:
```cmd
flutter run -d windows
```

#### Linux:
```bash
flutter run -d linux
```

#### Android:
```bash
flutter run
# 或
flutter run -d <device_id>
```

#### iOS (需要在 macOS 上):
```bash
flutter run -d ios
```

## 使用说明

### 基础类型测试
1. 在"数字 A"和"数字 B"输入框中输入数字
2. 点击"加法"、"减法"、"乘法"或"除法"按钮
3. 查看结果显示区域

### 字符串测试
1. 在"字符串"输入框中输入文本
2. 点击"反转字符串"、"转大写"或"字符串拼接"按钮
3. 查看处理结果

### 结构体测试
1. 在"点 X"和"点 Y"中输入第一个点的坐标
2. 在"数字 A"和"数字 B"中输入第二个点的坐标
3. 点击"计算点距离"按钮
4. 查看两点之间的欧几里得距离

### 回调函数测试
1. 点击"回调测试"按钮，测试简单回调
2. 点击"进度回调"按钮，观看进度条更新
   - 可在"数字 A"中输入迭代次数（默认 10）

### 异步调用测试
1. 在"数字 A"中输入一个数字（默认 5）
2. 点击"异步计算"按钮
3. 等待 2 秒后查看计算结果（值的平方）

## 开发指南

### 添加新的 C++ 函数

1. 在 `native/src/native_lib.h` 中声明函数
2. 在 `native/src/native_lib.cpp` 中实现函数
3. 在 `lib/ffi_bridge.dart` 中添加 FFI 绑定
4. 重新编译原生库并运行

### 内存管理注意事项

- **字符串**: C++ 中使用 `malloc` 分配的字符串，Dart 侧使用后必须调用 `free_string` 释放
- **结构体**: C++ 中使用 `malloc` 分配的结构体，Dart 侧使用后必须调用相应的 `free_*` 函数
- **回调函数**: 使用 `NativeCallable.listener()` 创建的回调需要在适当时机调用 `close()` 释放

### 关键技术点

#### 1. 加载动态库
```dart
ffi.DynamicLibrary _loadLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libnative_lib.so');
  } else if (Platform.isMacOS) {
    return ffi.DynamicLibrary.open('libnative_lib.dylib');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('native_lib.dll');
  }
  // ...
}
```

#### 2. 函数绑定
```dart
typedef AddNative = ffi.Int Function(ffi.Int a, ffi.Int b);
typedef AddDart = int Function(int a, int b);

final add = _lib.lookupFunction<AddNative, AddDart>('add');
```

#### 3. 字符串传递
```dart
String reverseString(String input) {
  final inputPtr = input.toNativeUtf8();
  try {
    final resultPtr = _reverseString(inputPtr);
    try {
      return resultPtr.toDartString();
    } finally {
      _freeString(resultPtr);
    }
  } finally {
    malloc.free(inputPtr);
  }
}
```

#### 4. 回调函数
```dart
void registerDartCallback(void Function(int) callback) {
  final nativeCallback =
      ffi.NativeCallable<IntCallbackNative>.listener((value) {
    callback(value);
  });
  registerCallback(nativeCallback.nativeFunction);
}
```

## 故障排除

### macOS: "libnative_lib.dylib" 无法打开
```bash
# 重新编译原生库
./build_native.sh
```

### Android: CMake 编译失败
确保已安装 Android NDK，并在 Android Studio 的 SDK Manager 中安装 CMake。

### Windows: 找不到 Visual Studio
安装 Visual Studio 2019 或 2022，并确保勾选"使用 C++ 的桌面开发"工作负载。

### iOS: 库文件找不到
```bash
cd ios
./build_native.sh
```

## 许可证

本项目仅用于学习和演示目的。

## 参考资料

- [Flutter FFI 官方文档](https://dart.dev/guides/libraries/c-interop)
- [Dart FFI 包文档](https://pub.dev/packages/ffi)
- [CMake 官方文档](https://cmake.org/documentation/)

## 作者

Flutter FFI Demo Project

---

如有问题或建议，欢迎提 Issue！
