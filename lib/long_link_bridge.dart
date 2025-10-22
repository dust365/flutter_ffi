import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'long_link_types.dart';
import 'native_library_loader.dart';

/// 长连接 FFI 桥接层
class LongLinkBridge {
  late final ffi.DynamicLibrary _lib;

  // FFI 函数引用
  late final CreateLongLinkManagerDart _createManager;
  late final DestroyLongLinkManagerDart _destroyManager;
  late final SetLongLinkCallbacksDart _setCallbacks;
  late final StartConnectionDart _startConnection;
  late final StopConnectionDart _stopConnection;
  late final SendDataDart _sendData;
  late final GetConnectionStatusDart _getConnectionStatus;
  late final IsConnectedDart _isConnected;
  late final FreeStringDart _freeString;

  // 管理器实例
  ffi.Pointer<ffi.Void>? _manager;

  // 回调函数引用（保持引用防止被垃圾回收）
  ffi.NativeCallable<OnConnectedNative>? _onConnectedCallable;
  ffi.NativeCallable<OnConnectFailedNative>? _onConnectFailedCallable;
  ffi.NativeCallable<OnDataReceivedNative>? _onDataReceivedCallable;
  ffi.NativeCallable<OnDisconnectedNative>? _onDisconnectedCallable;

  // Dart 回调函数
  void Function()? _onConnectedCallback;
  void Function(String)? _onConnectFailedCallback;
  void Function(String, int)? _onDataReceivedCallback;
  void Function()? _onDisconnectedCallback;

  LongLinkBridge() {
    _lib = NativeLibraryLoader.loadLibrary('native_lib');
    _bindFunctions();
  }

  /// 绑定所有 C 函数
  void _bindFunctions() {
    _createManager = _lib
        .lookupFunction<CreateLongLinkManagerNative, CreateLongLinkManagerDart>(
          'create_long_link_manager',
        );
    _destroyManager = _lib.lookupFunction<
      DestroyLongLinkManagerNative,
      DestroyLongLinkManagerDart
    >('destroy_long_link_manager');

    _setCallbacks = _lib
        .lookupFunction<SetLongLinkCallbacksNative, SetLongLinkCallbacksDart>(
          'set_long_link_callbacks',
        );
    _startConnection = _lib
        .lookupFunction<StartConnectionNative, StartConnectionDart>(
          'start_connection',
        );
    _stopConnection = _lib
        .lookupFunction<StopConnectionNative, StopConnectionDart>(
          'stop_connection',
        );
    _sendData = _lib.lookupFunction<SendDataNative, SendDataDart>('send_data');
    _getConnectionStatus = _lib
        .lookupFunction<GetConnectionStatusNative, GetConnectionStatusDart>(
          'get_connection_status',
        );
    _isConnected = _lib.lookupFunction<IsConnectedNative, IsConnectedDart>(
      'is_connected',
    );
    _freeString = _lib.lookupFunction<FreeStringNative, FreeStringDart>(
      'free_string',
    );
  }

  /// 初始化管理器
  void initialize() {
    if (_manager != null) {
      return; // 已经初始化
    }

    print('🔧 初始化长连接管理器');
    _manager = _createManager();

    if (_manager == ffi.nullptr) {
      throw Exception('创建长连接管理器失败');
    }
  }

  /// 设置回调函数
  void setCallbacks({
    void Function()? onConnected,
    void Function(String)? onConnectFailed,
    void Function(String, int)? onDataReceived,
    void Function()? onDisconnected,
  }) {
    if (_manager == null) {
      throw Exception('管理器未初始化');
    }

    // 保存回调函数
    _onConnectedCallback = onConnected;
    _onConnectFailedCallback = onConnectFailed;
    _onDataReceivedCallback = onDataReceived;
    _onDisconnectedCallback = onDisconnected;

    // 创建 NativeCallable 对象
    _onConnectedCallable = ffi.NativeCallable<OnConnectedNative>.listener(
      _onConnectedNative,
    );
    _onConnectFailedCallable =
        ffi.NativeCallable<OnConnectFailedNative>.listener(
          _onConnectFailedNative,
        );
    _onDataReceivedCallable = ffi.NativeCallable<OnDataReceivedNative>.listener(
      _onDataReceivedNative,
    );
    _onDisconnectedCallable = ffi.NativeCallable<OnDisconnectedNative>.listener(
      _onDisconnectedNative,
    );

    // 设置回调
    _setCallbacks(
      _manager!,
      _onConnectedCallable!.nativeFunction,
      _onConnectFailedCallable!.nativeFunction,
      _onDataReceivedCallable!.nativeFunction,
      _onDisconnectedCallable!.nativeFunction,
    );
  }

  /// 开始连接
  void startConnection(String url) {
    if (_manager == null) {
      throw Exception('管理器未初始化');
    }

    print('🔗 开始连接: $url');
    final urlPtr = url.toNativeUtf8();
    try {
      _startConnection(_manager!, urlPtr.cast<ffi.Char>());
    } finally {
      malloc.free(urlPtr);
    }
  }

  /// 停止连接
  void stopConnection() {
    if (_manager == null) {
      return;
    }

    print('🔌 停止连接');
    _stopConnection(_manager!);
  }

  /// 发送数据
  void sendData(String data) {
    if (_manager == null) {
      throw Exception('管理器未初始化');
    }

    print('📤 发送数据: $data');
    final dataPtr = data.toNativeUtf8();
    try {
      _sendData(_manager!, dataPtr.cast<ffi.Char>());
    } finally {
      malloc.free(dataPtr);
    }
  }

  /// 获取连接状态
  String getConnectionStatus() {
    if (_manager == null) {
      return '未初始化';
    }

    final statusPtr = _getConnectionStatus(_manager!);
    if (statusPtr == ffi.nullptr) {
      return '未知状态';
    }

    try {
      return statusPtr.cast<Utf8>().toDartString();
    } finally {
      _freeString(statusPtr);
    }
  }

  /// 检查是否已连接
  bool isConnected() {
    if (_manager == null) {
      return false;
    }

    return _isConnected(_manager!) == 1;
  }

  /// 销毁管理器
  void dispose() {
    if (_manager != null) {
      print('🗑️ 销毁长连接管理器');
      _destroyManager(_manager!);
      _manager = null;
    }

    // 释放回调函数
    _onConnectedCallable?.close();
    _onConnectFailedCallable?.close();
    _onDataReceivedCallable?.close();
    _onDisconnectedCallable?.close();

    _onConnectedCallable = null;
    _onConnectFailedCallable = null;
    _onDataReceivedCallable = null;
    _onDisconnectedCallable = null;
  }

  // ==========================================================================
  // Native 回调函数实现
  // ==========================================================================

  void _onConnectedNative() {
    print('✅ 连接成功回调');
    _onConnectedCallback?.call();
  }

  void _onConnectFailedNative(ffi.Pointer<ffi.Char> error) {
    final errorStr = error.cast<Utf8>().toDartString();
    print('❌ 连接失败回调: $errorStr');
    _onConnectFailedCallback?.call(errorStr);
  }

  void _onDataReceivedNative(ffi.Pointer<ffi.Char> data, int length) {
    final dataStr = data.cast<Utf8>().toDartString();
    print('📥 接收数据回调: $dataStr (长度: $length)');
    _onDataReceivedCallback?.call(dataStr, length);
  }

  void _onDisconnectedNative() {
    print('🔌 断开连接回调');
    _onDisconnectedCallback?.call();
  }
}

/// 单例实例
final longLinkBridge = LongLinkBridge();
