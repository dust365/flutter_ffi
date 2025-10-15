import 'lib/ffi_bridge.dart';

void main() {
  print('===================================');
  print('Flutter FFI Demo - 原生库功能测试');
  print('===================================\n');

  try {
    // 基础类型测试
    print('【基础类型测试】');
    final addResult = nativeLib.add(10, 20);
    print('✓ 加法: 10 + 20 = $addResult');

    final subResult = nativeLib.subtract(50, 15);
    print('✓ 减法: 50 - 15 = $subResult');

    final mulResult = nativeLib.multiply(3.5, 2.0);
    print('✓ 乘法: 3.5 × 2.0 = $mulResult');

    final divResult = nativeLib.divide(10.0, 2.0);
    print('✓ 除法: 10.0 ÷ 2.0 = $divResult\n');

    // 字符串测试
    print('【字符串测试】');
    final reversed = nativeLib.reverseString('Hello');
    print('✓ 反转字符串: "Hello" => "$reversed"');

    final upper = nativeLib.toUppercase('flutter');
    print('✓ 转大写: "flutter" => "$upper"');

    final concat = nativeLib.concatStrings('Hello', ' World');
    print('✓ 字符串拼接: "Hello" + " World" => "$concat"\n');

    // 结构体测试
    print('【结构体测试】');
    final p1 = nativeLib.createPoint(0, 0);
    final p2 = nativeLib.createPoint(3, 4);
    try {
      final dist = nativeLib.distance(p1, p2);
      print('✓ 点 (0, 0) 到点 (3, 4) 的距离: ${dist.toStringAsFixed(2)}');
    } finally {
      nativeLib.freePoint(p1);
      nativeLib.freePoint(p2);
    }

    print('\n===================================');
    print('✅ 所有测试通过！');
    print('===================================\n');
    print('现在可以运行 Flutter 应用:');
    print('  flutter run -d macos');
  } catch (e, stackTrace) {
    print('\n❌ 测试失败！');
    print('错误: $e');
    print('堆栈跟踪:\n$stackTrace');
    print('\n请确保已运行: ./build_native.sh');
  }
}
