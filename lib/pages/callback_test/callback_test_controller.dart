import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ffi_bridge.dart';

/// 回调函数测试控制器
class CallbackTestController extends GetxController {
  // 输入控制器
  final TextEditingController valueController = TextEditingController();
  final TextEditingController countController = TextEditingController();

  // 响应式变量
  final RxString result = ''.obs;
  final RxBool isLoading = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onClose() {
    valueController.dispose();
    countController.dispose();
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

  /// 设置处理状态
  void _setProcessing(bool processing) {
    isProcessing.value = processing;
  }

  /// 设置进度
  void _setProgress(double newProgress) {
    progress.value = newProgress;
  }

  /// 简单回调测试
  void testCallback() {
    try {
      _setLoading(true);
      nativeLib.registerDartCallback((value) {
        _setResult('收到回调，值: $value');
      });

      final value = int.parse(valueController.text);
      nativeLib.triggerCallback(value);
    } catch (e) {
      _setResult('错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 进度回调测试
  void testProgressCallback() async {
    try {
      _setProcessing(true);
      _setProgress(0.0);
      _setResult('处理中...');

      final count = int.parse(
        countController.text.isEmpty ? '10' : countController.text,
      );

      // 在单独的 Isolate 或使用 Future 来避免阻塞 UI
      nativeLib.processWithDartProgress(count, (progress) {
        _setProgress(progress / 100.0);
        _setResult('进度: $progress%');
      });

      _setProcessing(false);
      _setResult('处理完成！');
    } catch (e) {
      _setProcessing(false);
      _setResult('错误: $e');
    }
  }

  /// 清空输入
  void clearInputs() {
    valueController.clear();
    countController.clear();
    result.value = '';
    progress.value = 0.0;
  }

  /// 设置示例数据
  void setExampleData() {
    valueController.text = '42';
    countController.text = '5';
  }
}
