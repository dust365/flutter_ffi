import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ffi_bridge.dart';

/// 基础类型测试控制器
class BasicTypesController extends GetxController {
  // 输入控制器
  final TextEditingController numberAController = TextEditingController();
  final TextEditingController numberBController = TextEditingController();

  // 响应式变量
  final RxString result = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    numberAController.dispose();
    numberBController.dispose();
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

  /// 加法测试
  void testAdd() {
    try {
      _setLoading(true);
      final a = int.parse(numberAController.text);
      final b = int.parse(numberBController.text);
      final result = nativeLib.add(a, b);
      _setResult('加法结果: $a + $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 减法测试
  void testSubtract() {
    try {
      _setLoading(true);
      final a = int.parse(numberAController.text);
      final b = int.parse(numberBController.text);
      final result = nativeLib.subtract(a, b);
      _setResult('减法结果: $a - $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 乘法测试
  void testMultiply() {
    try {
      _setLoading(true);
      final a = double.parse(numberAController.text);
      final b = double.parse(numberBController.text);
      final result = nativeLib.multiply(a, b);
      _setResult('乘法结果: $a × $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 除法测试
  void testDivide() {
    try {
      _setLoading(true);
      final a = double.parse(numberAController.text);
      final b = double.parse(numberBController.text);
      final result = nativeLib.divide(a, b);
      _setResult('除法结果: $a ÷ $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 清空输入
  void clearInputs() {
    numberAController.clear();
    numberBController.clear();
    result.value = '';
  }
}
