#ifndef NATIVE_LIB_H
#define NATIVE_LIB_H

#ifdef __cplusplus
extern "C" {
#endif

// =============================================================================
// 基础类型测试
// =============================================================================

/**
 * 整数加法
 */
int add(int a, int b);

/**
 * 整数减法
 */
int subtract(int a, int b);

/**
 * 浮点数乘法
 */
double multiply(double a, double b);

/**
 * 浮点数除法
 */
double divide(double a, double b);

// =============================================================================
// 字符串测试
// =============================================================================

/**
 * 反转字符串
 * 注意：返回的字符串需要调用 free_string 释放
 */
char* reverse_string(const char* str);

/**
 * 转换为大写
 * 注意：返回的字符串需要调用 free_string 释放
 */
char* to_uppercase(const char* str);

/**
 * 拼接两个字符串
 * 注意：返回的字符串需要调用 free_string 释放
 */
char* concat_strings(const char* a, const char* b);

/**
 * 释放字符串内存
 */
void free_string(char* str);

// =============================================================================
// 结构体测试
// =============================================================================

/**
 * 点结构体
 */
typedef struct {
    double x;
    double y;
} Point;

/**
 * 创建点
 * 注意：返回的点需要调用 free_point 释放
 */
Point* create_point(double x, double y);

/**
 * 计算两点之间的距离
 */
double distance(Point* p1, Point* p2);

/**
 * 释放点内存
 */
void free_point(Point* p);

// =============================================================================
// 回调函数测试
// =============================================================================

/**
 * 回调函数类型定义
 */
typedef void (*IntCallback)(int value);
typedef void (*ProgressCallback)(int progress);

/**
 * 注册回调函数
 */
void register_callback(IntCallback callback);

/**
 * 触发回调函数
 */
void trigger_callback(int value);

/**
 * 带进度的处理函数
 */
void process_with_progress(int count, ProgressCallback progress);

// =============================================================================
// 异步调用测试
// =============================================================================

/**
 * 异步计算（模拟耗时操作）
 * 在新线程中计算 value * value，完成后调用 callback
 */
void async_compute(int value, IntCallback callback);

#ifdef __cplusplus
}
#endif

#endif // NATIVE_LIB_H

