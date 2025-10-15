import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// =============================================================================
// 结构体定义
// =============================================================================

/// Point 结构体定义
final class Point extends ffi.Struct {
  @ffi.Double()
  external double x;

  @ffi.Double()
  external double y;
}

// =============================================================================
// 回调函数类型定义
// =============================================================================

typedef IntCallbackNative = ffi.Void Function(ffi.Int value);
typedef IntCallbackDart = void Function(int value);

typedef ProgressCallbackNative = ffi.Void Function(ffi.Int progress);
typedef ProgressCallbackDart = void Function(int progress);

// =============================================================================
// 基础类型函数类型定义
// =============================================================================

typedef AddNative = ffi.Int Function(ffi.Int a, ffi.Int b);
typedef AddDart = int Function(int a, int b);

typedef SubtractNative = ffi.Int Function(ffi.Int a, ffi.Int b);
typedef SubtractDart = int Function(int a, int b);

typedef MultiplyNative = ffi.Double Function(ffi.Double a, ffi.Double b);
typedef MultiplyDart = double Function(double a, double b);

typedef DivideNative = ffi.Double Function(ffi.Double a, ffi.Double b);
typedef DivideDart = double Function(double a, double b);

// =============================================================================
// 字符串函数类型定义
// =============================================================================

typedef ReverseStringNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> str);
typedef ReverseStringDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> str);

typedef ToUppercaseNative = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> str);
typedef ToUppercaseDart = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> str);

typedef ConcatStringsNative =
    ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> a, ffi.Pointer<Utf8> b);
typedef ConcatStringsDart =
    ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8> a, ffi.Pointer<Utf8> b);

typedef FreeStringNative = ffi.Void Function(ffi.Pointer<Utf8> str);
typedef FreeStringDart = void Function(ffi.Pointer<Utf8> str);

// =============================================================================
// 结构体函数类型定义
// =============================================================================

typedef CreatePointNative =
    ffi.Pointer<Point> Function(ffi.Double x, ffi.Double y);
typedef CreatePointDart = ffi.Pointer<Point> Function(double x, double y);

typedef DistanceNative =
    ffi.Double Function(ffi.Pointer<Point> p1, ffi.Pointer<Point> p2);
typedef DistanceDart =
    double Function(ffi.Pointer<Point> p1, ffi.Pointer<Point> p2);

typedef FreePointNative = ffi.Void Function(ffi.Pointer<Point> p);
typedef FreePointDart = void Function(ffi.Pointer<Point> p);

// =============================================================================
// 回调函数类型定义
// =============================================================================

typedef RegisterCallbackNative =
    ffi.Void Function(
      ffi.Pointer<ffi.NativeFunction<IntCallbackNative>> callback,
    );
typedef RegisterCallbackDart =
    void Function(ffi.Pointer<ffi.NativeFunction<IntCallbackNative>> callback);

typedef TriggerCallbackNative = ffi.Void Function(ffi.Int value);
typedef TriggerCallbackDart = void Function(int value);

typedef ProcessWithProgressNative =
    ffi.Void Function(
      ffi.Int count,
      ffi.Pointer<ffi.NativeFunction<ProgressCallbackNative>> progress,
    );
typedef ProcessWithProgressDart =
    void Function(
      int count,
      ffi.Pointer<ffi.NativeFunction<ProgressCallbackNative>> progress,
    );

// =============================================================================
// 异步调用函数类型定义
// =============================================================================

typedef AsyncComputeNative =
    ffi.Void Function(
      ffi.Int value,
      ffi.Pointer<ffi.NativeFunction<IntCallbackNative>> callback,
    );
typedef AsyncComputeDart =
    void Function(
      int value,
      ffi.Pointer<ffi.NativeFunction<IntCallbackNative>> callback,
    );
