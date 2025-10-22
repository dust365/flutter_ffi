import 'dart:ffi' as ffi;

/// 长连接 FFI 类型定义

// ==========================================================================
// C 函数签名（Native）
// ==========================================================================

/// 创建长连接管理器
typedef CreateLongLinkManagerNative = ffi.Pointer<ffi.Void> Function();

/// 销毁长连接管理器
typedef DestroyLongLinkManagerNative = ffi.Void Function(ffi.Pointer<ffi.Void>);

/// 设置回调函数
typedef SetLongLinkCallbacksNative =
    ffi.Void Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.NativeFunction<OnConnectedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnConnectFailedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnDataReceivedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnDisconnectedNative>>,
    );

/// 开始连接
typedef StartConnectionNative =
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>);

/// 停止连接
typedef StopConnectionNative = ffi.Void Function(ffi.Pointer<ffi.Void>);

/// 发送数据
typedef SendDataNative =
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>);

/// 获取连接状态
typedef GetConnectionStatusNative =
    ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>);

/// 检查是否已连接
typedef IsConnectedNative = ffi.Int32 Function(ffi.Pointer<ffi.Void>);

/// 释放字符串内存
typedef FreeStringNative = ffi.Void Function(ffi.Pointer<ffi.Char>);

// ==========================================================================
// 回调函数类型（Native）
// ==========================================================================

/// 连接成功回调
typedef OnConnectedNative = ffi.Void Function();

/// 连接失败回调
typedef OnConnectFailedNative = ffi.Void Function(ffi.Pointer<ffi.Char>);

/// 接收数据回调
typedef OnDataReceivedNative =
    ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int32);

/// 断开连接回调
typedef OnDisconnectedNative = ffi.Void Function();

// ==========================================================================
// Dart 函数签名
// ==========================================================================

/// 创建长连接管理器
typedef CreateLongLinkManagerDart = ffi.Pointer<ffi.Void> Function();

/// 销毁长连接管理器
typedef DestroyLongLinkManagerDart = void Function(ffi.Pointer<ffi.Void>);

/// 设置回调函数
typedef SetLongLinkCallbacksDart =
    void Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.NativeFunction<OnConnectedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnConnectFailedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnDataReceivedNative>>,
      ffi.Pointer<ffi.NativeFunction<OnDisconnectedNative>>,
    );

/// 开始连接
typedef StartConnectionDart =
    void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>);

/// 停止连接
typedef StopConnectionDart = void Function(ffi.Pointer<ffi.Void>);

/// 发送数据
typedef SendDataDart =
    void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>);

/// 获取连接状态
typedef GetConnectionStatusDart =
    ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>);

/// 检查是否已连接
typedef IsConnectedDart = int Function(ffi.Pointer<ffi.Void>);

/// 释放字符串内存
typedef FreeStringDart = void Function(ffi.Pointer<ffi.Char>);

// ==========================================================================
// 连接状态枚举
// ==========================================================================

/// 连接状态
enum ConnectionStatus {
  disconnected, // 未连接
  connecting, // 连接中
  connected, // 已连接
  disconnecting, // 断开中
}

/// 连接状态扩展
extension ConnectionStatusExtension on ConnectionStatus {
  /// 获取状态描述
  String get description {
    switch (this) {
      case ConnectionStatus.disconnected:
        return '未连接';
      case ConnectionStatus.connecting:
        return '连接中';
      case ConnectionStatus.connected:
        return '已连接';
      case ConnectionStatus.disconnecting:
        return '断开中';
    }
  }

  /// 获取状态颜色
  String get color {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'grey';
      case ConnectionStatus.connecting:
        return 'orange';
      case ConnectionStatus.connected:
        return 'green';
      case ConnectionStatus.disconnecting:
        return 'red';
    }
  }
}

// ==========================================================================
// 数据模型
// ==========================================================================

/// 接收到的数据项
class ReceivedDataItem {
  final String data;
  final DateTime timestamp;
  final String type;

  ReceivedDataItem({
    required this.data,
    required this.timestamp,
    required this.type,
  });

  /// 从 JSON 字符串解析类型
  factory ReceivedDataItem.fromJson(String jsonData) {
    final timestamp = DateTime.now();
    String type = 'unknown';

    try {
      // 简单的 JSON 解析，提取 type 字段
      if (jsonData.contains('"type":"heartbeat"')) {
        type = 'heartbeat';
      } else if (jsonData.contains('"type":"message"')) {
        type = 'message';
      } else if (jsonData.contains('"type":"status"')) {
        type = 'status';
      } else if (jsonData.contains('"type":"system"')) {
        type = 'system';
      }
    } catch (e) {
      // 解析失败，使用默认类型
    }

    return ReceivedDataItem(data: jsonData, timestamp: timestamp, type: type);
  }

  /// 获取类型图标
  String get icon {
    switch (type) {
      case 'heartbeat':
        return '💓';
      case 'message':
        return '💬';
      case 'status':
        return '📊';
      case 'system':
        return '⚙️';
      default:
        return '📄';
    }
  }

  /// 获取类型描述
  String get typeDescription {
    switch (type) {
      case 'heartbeat':
        return '心跳包';
      case 'message':
        return '消息';
      case 'status':
        return '状态更新';
      case 'system':
        return '系统信息';
      default:
        return '未知';
    }
  }
}
