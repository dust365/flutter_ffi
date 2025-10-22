import 'dart:ffi' as ffi;
import 'dart:io';

/// 原生库加载器工具类
/// 统一处理不同平台的动态库加载逻辑
class NativeLibraryLoader {
  /// 加载原生动态库
  ///
  /// [libraryName] 库的基础名称，不包含平台特定的前缀和后缀
  /// 例如：'native_lib' 会加载为 'libnative_lib.so' (Android/Linux) 或 'libnative_lib.dylib' (macOS)
  static ffi.DynamicLibrary loadLibrary(String libraryName) {
    if (Platform.isAndroid) {
      // Android: 从应用的 lib 目录加载（通过 jniLibs 或 CMake）
      return ffi.DynamicLibrary.open('lib$libraryName.so');
    } else if (Platform.isIOS) {
      // iOS 使用静态链接或 process()
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      // macOS: 从 assets 目录加载
      final executableDir = File(Platform.resolvedExecutable).parent.path;
      final libPath =
          '$executableDir/../Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/native/lib$libraryName.dylib';

      print('🔍 尝试从 assets 加载: $libPath');

      try {
        return ffi.DynamicLibrary.open(libPath);
      } catch (e) {
        print('❌ 加载失败: $e');
        throw Exception('无法加载原生库。请确保已将库文件放在 assets/native/ 目录');
      }
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('$libraryName.dll');
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('lib$libraryName.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
