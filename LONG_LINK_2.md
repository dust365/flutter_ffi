# FFI 接口分析：为什么需要 C 风格接口

## 问题背景

### 1. 语言边界问题

```
┌─────────────────────────────────────────────────────────────────┐
│                        Dart 世界                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Dart 代码     │  │   Dart 运行时   │  │   Dart 垃圾回收  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │ FFI 调用
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                        C 世界 (ABI 标准)                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   C 函数        │  │   C 调用约定    │  │   简单数据类型   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │ 内部调用
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      C++ 世界                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   C++ 类        │  │   C++ 运行时    │  │   复杂对象模型   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2. 为什么不能直接调用 C++？

#### A. 名称修饰 (Name Mangling) 问题

```cpp
// C++ 代码
class LongLinkManager {
public:
    void startConnection(const std::string& url);
    void stopConnection();
};

// 编译后的符号名（简化示例）
_ZNK15LongLinkManager12startConnectionERKSs  // 实际符号名
_ZNK15LongLinkManager12stopConnectionEv      // 实际符号名
```

```c
// C 代码
void start_connection(void* manager, const char* url);
void stop_connection(void* manager);

// 编译后的符号名
start_connection  // 简单明了的符号名
stop_connection   // 简单明了的符号名
```

#### B. 调用约定差异

```cpp
// C++ 调用（需要 this 指针）
manager->startConnection(url);  // 隐含传递 this 指针

// C 调用（显式传递对象指针）
start_connection(manager, url);  // 显式传递对象指针
```

## 解决方案：C 包装器模式

### 1. 架构设计

```
Dart FFI 调用
    │
    ▼
C 风格接口 (long_link.h/cpp)
    │
    ▼
C++ 业务逻辑 (LongLinkManager)
    │
    ▼
C++ 工作线程 (LongLinkWorker)
```

### 2. 具体实现分析

#### A. 对象指针传递

```cpp
// long_link.h - C 接口声明
void* create_long_link_manager();  // 返回 C++ 对象指针
void start_connection(void* manager, const char* url);  // 传递对象指针
```

```cpp
// long_link.cpp - C 接口实现
void* create_long_link_manager() {
    // 创建 C++ 对象，返回 void* 指针
    LongLinkManager* manager = new LongLinkManager();
    return static_cast<void*>(manager);
}

void start_connection(void* manager, const char* url) {
    // 将 void* 转换回 C++ 对象指针
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    m->startConnection(std::string(url));
}
```

#### B. 回调函数处理

```cpp
// 全局回调函数指针（C 风格）
static void (*g_on_connected)() = nullptr;
static void (*g_on_connect_failed)(const char*) = nullptr;

// C++ 委托类（桥接 C++ 回调和 C 回调）
class DartLongLinkDelegate : public LongLinkDelegate {
public:
    void onConnected() override {
        if (g_on_connected) {
            g_on_connected();  // 调用 C 风格回调
        }
    }
};
```

## 详细流程分析

### 1. 初始化流程

```
Dart 端：
    final manager = _createManager();  // 调用 C 函数

C 端：
    void* create_long_link_manager() {
        LongLinkManager* manager = new LongLinkManager();  // 创建 C++ 对象
        return static_cast<void*>(manager);  // 返回 void* 指针
    }

Dart 端：
    _manager = manager;  // 保存 void* 指针
```

### 2. 方法调用流程

```
Dart 端：
    _startConnection(_manager!, urlPtr.cast<ffi.Char>());

C 端：
    void start_connection(void* manager, const char* url) {
        LongLinkManager* m = static_cast<LongLinkManager*>(manager);  // 类型转换
        m->startConnection(std::string(url));  // 调用 C++ 方法
    }
```

### 3. 回调处理流程

```
C++ 端：
    void LongLinkManager::onConnected() {
        if (m_delegate) {
            m_delegate->onConnected();  // 调用委托
        }
    }

C 端：
    void DartLongLinkDelegate::onConnected() {
        if (g_on_connected) {
            g_on_connected();  // 调用全局 C 回调
        }
    }

Dart 端：
    void _onConnectedNative() {
        _onConnectedCallback?.call();  // 调用 Dart 回调
    }
```

## 关键设计模式

### 1. 包装器模式 (Wrapper Pattern)

```cpp
// C++ 复杂接口
class LongLinkManager {
    void startConnection(const std::string& url);
    void setDelegate(LongLinkDelegate* delegate);
};

// C 简单接口
void start_connection(void* manager, const char* url);
void set_long_link_callbacks(void* manager, ...);
```

### 2. 委托模式 (Delegate Pattern)

```cpp
// 三层委托链
Worker -> Manager -> DartLongLinkDelegate -> Dart
```

### 3. 句柄模式 (Handle Pattern)

```cpp
// 使用 void* 作为句柄
void* manager = create_long_link_manager();
start_connection(manager, url);
destroy_long_link_manager(manager);
```

## 内存管理考虑

### 1. 对象生命周期

```cpp
// 创建
void* create_long_link_manager() {
    return new LongLinkManager();  // 堆分配
}

// 销毁
void destroy_long_link_manager(void* manager) {
    delete static_cast<LongLinkManager*>(manager);  // 堆释放
}
```

### 2. 字符串内存管理

```cpp
// 返回字符串（调用者负责释放）
const char* get_connection_status(void* manager) {
    std::string status = m->getConnectionStatus();
    char* result = new char[status.length() + 1];  // 堆分配
    std::strcpy(result, status.c_str());
    return result;
}

// 释放字符串
void free_string(char* str) {
    delete[] str;  // 堆释放
}
```

## 总结

`long_link.h` 文件的作用是：

1. **提供 C 风格接口**：让 Dart FFI 能够调用原生代码
2. **隐藏 C++ 复杂性**：将 C++ 的类、模板、异常等复杂性封装起来
3. **确保 ABI 兼容性**：使用标准的 C 调用约定
4. **管理对象生命周期**：通过 void* 指针管理 C++ 对象
5. **处理回调机制**：建立 C++ 到 Dart 的回调链

这种设计模式在跨语言调用中非常常见，是 FFI 的标准做法。
