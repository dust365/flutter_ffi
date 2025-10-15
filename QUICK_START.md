# 快速开始指南

## ⚡ 5分钟快速上手

### 步骤 1️⃣: 编译原生库
```bash
./build_native.sh
```
**期望输出**: ✅ macOS 版本编译完成

### 步骤 2️⃣: 测试原生库
```bash
dart run test_native.dart
```
**期望输出**: ✅ 所有测试通过！

### 步骤 3️⃣: 运行应用
```bash
flutter run -d macos
```

## 🎮 使用界面

### 基础操作测试
1. 输入两个数字（如 `10` 和 `20`）
2. 点击 **加法** 按钮
3. 查看结果：`10 + 20 = 30`

### 字符串测试
1. 输入字符串（如 `Hello`）
2. 点击 **反转字符串** 按钮
3. 查看结果：`"Hello" => "olleH"`

### 点距离计算
1. 点 X: `0`, 点 Y: `0`
2. 数字 A: `3`, 数字 B: `4`
3. 点击 **计算点距离** 按钮
4. 查看结果：距离为 `5.00`

### 异步计算
1. 数字 A: `5`
2. 点击 **异步计算** 按钮
3. 等待 2 秒
4. 查看结果：`5 × 5 = 25`

## 📱 多平台运行

### macOS
```bash
flutter run -d macos
```

### Windows
```bash
build_native.bat
flutter run -d windows
```

### Linux
```bash
./build_native.sh
flutter run -d linux
```

### Android
```bash
flutter run
# 原生库会自动通过 Gradle 编译
```

## 🔍 故障排查

### 问题: 无法加载动态库
**解决**: 
```bash
rm -rf native/build
./build_native.sh
```

### 问题: Dart 分析错误
**解决**:
```bash
flutter pub get
dart analyze
```

### 问题: Flutter 应用启动失败
**解决**:
```bash
flutter clean
flutter pub get
flutter run -d macos
```

## 📝 代码示例

### 调用原生函数
```dart
import 'ffi_bridge.dart';

void main() {
  // 基础类型
  final result = nativeLib.add(10, 20);
  print(result); // 30
  
  // 字符串
  final reversed = nativeLib.reverseString('Hello');
  print(reversed); // olleH
  
  // 结构体
  final p1 = nativeLib.createPoint(0, 0);
  final p2 = nativeLib.createPoint(3, 4);
  final dist = nativeLib.distance(p1, p2);
  nativeLib.freePoint(p1);
  nativeLib.freePoint(p2);
  print(dist); // 5.0
}
```

## 🎯 测试清单

- [x] 编译原生库成功
- [x] Dart 测试通过
- [x] Flutter 应用启动
- [ ] 点击每个测试按钮
- [ ] 验证所有功能正常

## 💡 提示

1. **首次运行**: 编译可能需要几分钟
2. **修改 C++ 代码后**: 需要重新运行 `./build_native.sh`
3. **清理构建**: `flutter clean && rm -rf native/build`
4. **查看日志**: 应用的控制台会显示详细信息

---

**准备好了吗？运行 `flutter run -d macos` 开始体验！** 🚀

