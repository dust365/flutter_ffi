import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../long_link_bridge.dart';
import '../../long_link_types.dart';

/// 长连接测试控制器
class LongLinkController extends GetxController {
  // 输入控制器
  final TextEditingController urlController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // 响应式变量
  final Rx<ConnectionStatus> connectionStatus =
      ConnectionStatus.disconnected.obs;
  final RxList<ReceivedDataItem> receivedData = <ReceivedDataItem>[].obs;
  final RxBool isConnecting = false.obs;
  final RxString connectionTime = ''.obs;
  final RxString lastError = ''.obs;

  // 连接开始时间
  DateTime? _connectionStartTime;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initializeLongLink();
    _setDefaultUrl();
  }

  @override
  void onClose() {
    _stopConnection();
    _timer?.cancel();
    urlController.dispose();
    messageController.dispose();
    longLinkBridge.dispose();
    super.onClose();
  }

  /// 初始化长连接
  void _initializeLongLink() {
    try {
      longLinkBridge.initialize();
      longLinkBridge.setCallbacks(
        onConnected: _onConnected,
        onConnectFailed: _onConnectFailed,
        onDataReceived: _onDataReceived,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      lastError.value = '初始化失败: $e';
    }
  }

  /// 设置默认 URL
  void _setDefaultUrl() {
    urlController.text = 'ws://localhost:8080/websocket';
  }

  /// 开始连接
  void startConnection() {
    if (isConnecting.value) {
      return;
    }

    final url = urlController.text.trim();
    if (url.isEmpty) {
      lastError.value = '请输入连接地址';
      return;
    }

    try {
      isConnecting.value = true;
      lastError.value = '';
      connectionStatus.value = ConnectionStatus.connecting;
      _connectionStartTime = DateTime.now();

      longLinkBridge.startConnection(url);
    } catch (e) {
      isConnecting.value = false;
      connectionStatus.value = ConnectionStatus.disconnected;
      lastError.value = '连接失败: $e';
    }
  }

  /// 停止连接
  void _stopConnection() {
    try {
      longLinkBridge.stopConnection();
      _timer?.cancel();
      _connectionStartTime = null;
      connectionTime.value = '';
    } catch (e) {
      lastError.value = '断开连接失败: $e';
    }
  }

  /// 停止连接（用户操作）
  void stopConnection() {
    _stopConnection();
  }

  /// 发送消息
  void sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      lastError.value = '请输入要发送的消息';
      return;
    }

    if (!longLinkBridge.isConnected()) {
      lastError.value = '未连接，无法发送消息';
      return;
    }

    try {
      longLinkBridge.sendData(message);
      messageController.clear();
      lastError.value = '';
    } catch (e) {
      lastError.value = '发送失败: $e';
    }
  }

  /// 清空接收数据
  void clearReceivedData() {
    receivedData.clear();
  }

  /// 清空错误信息
  void clearError() {
    lastError.value = '';
  }

  /// 获取连接状态描述
  String get statusDescription => connectionStatus.value.description;

  /// 获取连接状态颜色
  Color get statusColor {
    switch (connectionStatus.value) {
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnecting:
        return Colors.red;
    }
  }

  /// 检查是否可以连接
  bool get canConnect =>
      !isConnecting.value &&
      connectionStatus.value == ConnectionStatus.disconnected;

  /// 检查是否可以断开
  bool get canDisconnect =>
      connectionStatus.value == ConnectionStatus.connected;

  /// 检查是否可以发送
  bool get canSend => connectionStatus.value == ConnectionStatus.connected;

  // ==========================================================================
  // 回调函数
  // ==========================================================================

  void _onConnected() {
    isConnecting.value = false;
    connectionStatus.value = ConnectionStatus.connected;
    _connectionStartTime = DateTime.now();
    _startTimer();
    lastError.value = '';
  }

  void _onConnectFailed(String error) {
    isConnecting.value = false;
    connectionStatus.value = ConnectionStatus.disconnected;
    lastError.value = '连接失败: $error';
    _timer?.cancel();
    _connectionStartTime = null;
    connectionTime.value = '';
  }

  void _onDataReceived(String data, int length) {
    try {
      final item = ReceivedDataItem.fromJson(data);
      receivedData.add(item);

      // 限制列表长度，避免内存过多占用
      if (receivedData.length > 100) {
        receivedData.removeAt(0);
      }
    } catch (e) {
      // 如果解析失败，添加原始数据
      receivedData.add(
        ReceivedDataItem(
          data: data,
          timestamp: DateTime.now(),
          type: 'unknown',
        ),
      );
    }
  }

  void _onDisconnected() {
    isConnecting.value = false;
    connectionStatus.value = ConnectionStatus.disconnected;
    _timer?.cancel();
    _connectionStartTime = null;
    connectionTime.value = '';
  }

  // ==========================================================================
  // 定时器相关
  // ==========================================================================

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_connectionStartTime != null) {
        final duration = DateTime.now().difference(_connectionStartTime!);
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        connectionTime.value =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    });
  }
}
