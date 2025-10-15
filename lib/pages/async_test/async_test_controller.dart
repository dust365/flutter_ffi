import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ffi_bridge.dart';

/// 异步调用测试控制器
class AsyncTestController extends GetxController {
  // 输入控制器
  final TextEditingController valueController = TextEditingController();

  // 响应式变量
  final RxString result = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    valueController.dispose();
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

  /// 异步计算测试
  void testAsyncCompute() {
    try {
      _setLoading(true);
      final value = int.parse(
        valueController.text.isEmpty ? '5' : valueController.text,
      );

      _setResult('开始异步计算 $value × $value，请稍候...');

      nativeLib.asyncComputeWithCallback(value, (result) {
        _setResult('异步计算完成: $value × $value = $result');
        _setLoading(false);
      });
    } catch (e) {
      _setResult('错误: $e');
      _setLoading(false);
    }
  }

  /// 清空输入
  void clearInputs() {
    valueController.clear();
    result.value = '';
  }

  /// 设置示例数据
  void setExampleData() {
    valueController.text = '7';
  }
}
