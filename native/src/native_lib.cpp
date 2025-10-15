#include "native_lib.h"
#include <cstring>
#include <cmath>
#include <cctype>
#include <thread>
#include <chrono>
#include <cstdlib>

// =============================================================================
// 基础类型测试
// =============================================================================

int add(int a, int b) {
    return a + b;
}

int subtract(int a, int b) {
    return a - b;
}

double multiply(double a, double b) {
    return a * b;
}

double divide(double a, double b) {
    if (b == 0.0) {
        return 0.0; // 避免除零错误
    }
    return a / b;
}

// =============================================================================
// 字符串测试
// =============================================================================

char* reverse_string(const char* str) {
    if (str == nullptr) {
        return nullptr;
    }
    
    size_t len = strlen(str);
    char* result = (char*)malloc(len + 1);
    
    if (result == nullptr) {
        return nullptr;
    }
    
    for (size_t i = 0; i < len; i++) {
        result[i] = str[len - 1 - i];
    }
    result[len] = '\0';
    
    return result;
}

char* to_uppercase(const char* str) {
    if (str == nullptr) {
        return nullptr;
    }
    
    size_t len = strlen(str);
    char* result = (char*)malloc(len + 1);
    
    if (result == nullptr) {
        return nullptr;
    }
    
    for (size_t i = 0; i < len; i++) {
        result[i] = toupper(str[i]);
    }
    result[len] = '\0';
    
    return result;
}

char* concat_strings(const char* a, const char* b) {
    if (a == nullptr || b == nullptr) {
        return nullptr;
    }
    
    size_t len_a = strlen(a);
    size_t len_b = strlen(b);
    char* result = (char*)malloc(len_a + len_b + 1);
    
    if (result == nullptr) {
        return nullptr;
    }
    
    strcpy(result, a);
    strcat(result, b);
    
    return result;
}

void free_string(char* str) {
    if (str != nullptr) {
        free(str);
    }
}

// =============================================================================
// 结构体测试
// =============================================================================

Point* create_point(double x, double y) {
    Point* p = (Point*)malloc(sizeof(Point));
    if (p != nullptr) {
        p->x = x;
        p->y = y;
    }
    return p;
}

double distance(Point* p1, Point* p2) {
    if (p1 == nullptr || p2 == nullptr) {
        return 0.0;
    }
    
    double dx = p2->x - p1->x;
    double dy = p2->y - p1->y;
    return sqrt(dx * dx + dy * dy);
}

void free_point(Point* p) {
    if (p != nullptr) {
        free(p);
    }
}

// =============================================================================
// 回调函数测试
// =============================================================================

static IntCallback g_callback = nullptr;

void register_callback(IntCallback callback) {
    g_callback = callback;
}

void trigger_callback(int value) {
    if (g_callback != nullptr) {
        g_callback(value);
    }
}

void process_with_progress(int count, ProgressCallback progress) {
    if (progress == nullptr) {
        return;
    }
    
    for (int i = 0; i <= count; i++) {
        // 模拟一些处理时间
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        
        // 报告进度
        int percentage = (i * 100) / count;
        progress(percentage);
    }
}

// =============================================================================
// 异步调用测试
// =============================================================================

void async_compute(int value, IntCallback callback) {
    if (callback == nullptr) {
        return;
    }
    
    // 在新线程中执行计算
    std::thread([value, callback]() {
        // 模拟耗时计算
        std::this_thread::sleep_for(std::chrono::seconds(2));
        
        // 计算结果
        int result = value * value;
        
        // 调用回调函数
        callback(result);
    }).detach();
}

