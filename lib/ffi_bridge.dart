import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'ffi_types.dart';

/// Native Library FFI Bridge
class NativeLibrary {
  late final ffi.DynamicLibrary _lib;

  // 基础类型测试函数
  late final AddDart add;
  late final SubtractDart subtract;
  late final MultiplyDart multiply;
  late final DivideDart divide;

  // 字符串测试函数
  late final ReverseStringDart _reverseString;
  late final ToUppercaseDart _toUppercase;
  late final ConcatStringsDart _concatStrings;
  late final FreeStringDart _freeString;

  // 结构体测试函数
  late final CreatePointDart createPoint;
  late final DistanceDart distance;
  late final FreePointDart freePoint;

  // 回调函数测试
  late final RegisterCallbackDart registerCallback;
  late final TriggerCallbackDart triggerCallback;
  late final ProcessWithProgressDart processWithProgress;

  // 异步调用测试
  late final AsyncComputeDart asyncCompute;

  NativeLibrary() {
    _lib = _loadLibrary();
    _bindFunctions();
  }

  /// 加载动态库
  ffi.DynamicLibrary _loadLibrary() {
    const base = 'native_lib';

    if (Platform.isAndroid) {
      // Android: 从应用的 lib 目录加载（通过 jniLibs 或 CMake）
      return ffi.DynamicLibrary.open('lib$base.so');
    } else if (Platform.isIOS) {
      // iOS 使用静态链接或 process()
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      // macOS: 从 assets 目录加载
      final executableDir = File(Platform.resolvedExecutable).parent.path;
      final libPath =
          '$executableDir/../Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/native/lib$base.dylib';

      print('🔍 尝试从 assets 加载: $libPath');

      try {
        return ffi.DynamicLibrary.open(libPath);
      } catch (e) {
        print('❌ 加载失败: $e');
        throw Exception('无法加载原生库。请确保已将库文件放在 assets/native/ 目录');
      }
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('$base.dll');
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('lib$base.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 绑定所有 C++ 函数
  void _bindFunctions() {
    // 基础类型测试
    add = _lib.lookupFunction<AddNative, AddDart>('add');
    subtract = _lib.lookupFunction<SubtractNative, SubtractDart>('subtract');
    multiply = _lib.lookupFunction<MultiplyNative, MultiplyDart>('multiply');
    divide = _lib.lookupFunction<DivideNative, DivideDart>('divide');

    // 字符串测试
    _reverseString = _lib
        .lookupFunction<ReverseStringNative, ReverseStringDart>(
          'reverse_string',
        );
    _toUppercase = _lib.lookupFunction<ToUppercaseNative, ToUppercaseDart>(
      'to_uppercase',
    );
    _concatStrings = _lib
        .lookupFunction<ConcatStringsNative, ConcatStringsDart>(
          'concat_strings',
        );
    _freeString = _lib.lookupFunction<FreeStringNative, FreeStringDart>(
      'free_string',
    );

    // 结构体测试
    createPoint = _lib.lookupFunction<CreatePointNative, CreatePointDart>(
      'create_point',
    );
    distance = _lib.lookupFunction<DistanceNative, DistanceDart>('distance');
    freePoint = _lib.lookupFunction<FreePointNative, FreePointDart>(
      'free_point',
    );

    // 回调函数测试
    registerCallback = _lib
        .lookupFunction<RegisterCallbackNative, RegisterCallbackDart>(
          'register_callback',
        );
    triggerCallback = _lib
        .lookupFunction<TriggerCallbackNative, TriggerCallbackDart>(
          'trigger_callback',
        );
    processWithProgress = _lib
        .lookupFunction<ProcessWithProgressNative, ProcessWithProgressDart>(
          'process_with_progress',
        );

    // 异步调用测试
    asyncCompute = _lib.lookupFunction<AsyncComputeNative, AsyncComputeDart>(
      'async_compute',
    );
  }

  // ==========================================================================
  // 字符串操作的高级封装（自动处理内存管理）
  // ==========================================================================

  /// 反转字符串
  String reverseString(String input) {
    final inputPtr = input.toNativeUtf8();
    try {
      final resultPtr = _reverseString(inputPtr);
      if (resultPtr == ffi.nullptr) {
        return '';
      }
      try {
        return resultPtr.toDartString();
      } finally {
        _freeString(resultPtr);
      }
    } finally {
      malloc.free(inputPtr);
    }
  }

  /// 转换为大写
  String toUppercase(String input) {
    final inputPtr = input.toNativeUtf8();
    try {
      final resultPtr = _toUppercase(inputPtr);
      if (resultPtr == ffi.nullptr) {
        return '';
      }
      try {
        return resultPtr.toDartString();
      } finally {
        _freeString(resultPtr);
      }
    } finally {
      malloc.free(inputPtr);
    }
  }

  /// 拼接字符串
  String concatStrings(String a, String b) {
    final aPtr = a.toNativeUtf8();
    final bPtr = b.toNativeUtf8();
    try {
      final resultPtr = _concatStrings(aPtr, bPtr);
      if (resultPtr == ffi.nullptr) {
        return '';
      }
      try {
        return resultPtr.toDartString();
      } finally {
        _freeString(resultPtr);
      }
    } finally {
      malloc.free(aPtr);
      malloc.free(bPtr);
    }
  }

  // ==========================================================================
  // 回调函数的高级封装
  // ==========================================================================

  /// 注册回调函数（使用 Dart 回调）
  void registerDartCallback(void Function(int) callback) {
    void nativeCallbackFunction(int value) {
      callback(value);
    }

    final nativeCallback = ffi.NativeCallable<IntCallbackNative>.listener(
      nativeCallbackFunction,
    );
    registerCallback(nativeCallback.nativeFunction);
    // 注意：在实际应用中，需要管理 nativeCallback 的生命周期
  }

  /// 带进度的处理（使用 Dart 回调）
  void processWithDartProgress(int count, void Function(int) onProgress) {
    void nativeProgressCallback(int progress) {
      onProgress(progress);
    }

    final nativeCallback = ffi.NativeCallable<ProgressCallbackNative>.listener(
      nativeProgressCallback,
    );
    processWithProgress(count, nativeCallback.nativeFunction);
    // 回调完成后释放
    nativeCallback.close();
  }

  /// 异步计算（使用 Dart 回调）
  void asyncComputeWithCallback(int value, void Function(int) onComplete) {
    void nativeAsyncCallback(int result) {
      onComplete(result);
    }

    final nativeCallback = ffi.NativeCallable<IntCallbackNative>.listener(
      nativeAsyncCallback,
    );
    asyncCompute(value, nativeCallback.nativeFunction);
    // 注意：不能立即 close，因为是异步的
  }
}

/// 单例实例
final nativeLib = NativeLibrary();
