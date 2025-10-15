import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ffi_bridge.dart';

/// 字符串测试控制器
class StringTestController extends GetxController {
  // 输入控制器
  final TextEditingController stringController = TextEditingController();
  final TextEditingController secondStringController = TextEditingController();

  // 响应式变量
  final RxString result = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    stringController.dispose();
    secondStringController.dispose();
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

  /// 反转字符串测试
  void testReverseString() {
    try {
      _setLoading(true);
      final input = stringController.text;
      final result = nativeLib.reverseString(input);
      _setResult('反转字符串: "$input" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 转大写测试
  void testToUppercase() {
    try {
      _setLoading(true);
      final input = stringController.text;
      final result = nativeLib.toUppercase(input);
      _setResult('转大写: "$input" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 字符串拼接测试
  void testConcatStrings() {
    try {
      _setLoading(true);
      final a = stringController.text;
      final b =
          secondStringController.text.isNotEmpty
              ? secondStringController.text
              : 'World';
      final result = nativeLib.concatStrings(a, b);
      _setResult('字符串拼接: "$a" + "$b" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 清空输入
  void clearInputs() {
    stringController.clear();
    secondStringController.clear();
    result.value = '';
  }
}
