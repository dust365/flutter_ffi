import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ffi_bridge.dart';

/// 结构体测试控制器
class StructTestController extends GetxController {
  // 输入控制器
  final TextEditingController pointX1Controller = TextEditingController();
  final TextEditingController pointY1Controller = TextEditingController();
  final TextEditingController pointX2Controller = TextEditingController();
  final TextEditingController pointY2Controller = TextEditingController();

  // 响应式变量
  final RxString result = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    pointX1Controller.dispose();
    pointY1Controller.dispose();
    pointX2Controller.dispose();
    pointY2Controller.dispose();
    super.onClose();
  }

  /// 设置结果
  void _setResult(String newResult) {
    result.value = newResult;
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// 计算点距离测试
  void testPointDistance() {
    try {
      _setLoading(true);
      final x1 = double.parse(pointX1Controller.text);
      final y1 = double.parse(pointY1Controller.text);
      final x2 = double.parse(pointX2Controller.text);
      final y2 = double.parse(pointY2Controller.text);

      final p1 = nativeLib.createPoint(x1, y1);
      final p2 = nativeLib.createPoint(x2, y2);

      try {
        final dist = nativeLib.distance(p1, p2);
        _setResult(
          '点 ($x1, $y1) 到点 ($x2, $y2) 的距离: ${dist.toStringAsFixed(2)}',
        );
      } finally {
        nativeLib.freePoint(p1);
        nativeLib.freePoint(p2);
      }
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 清空输入
  void clearInputs() {
    pointX1Controller.clear();
    pointY1Controller.clear();
    pointX2Controller.clear();
    pointY2Controller.clear();
    result.value = '';
  }

  /// 设置示例数据
  void setExampleData() {
    pointX1Controller.text = '0';
    pointY1Controller.text = '0';
    pointX2Controller.text = '3';
    pointY2Controller.text = '4';
  }
}
