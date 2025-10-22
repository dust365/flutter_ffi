#include "long_link.h"
#include "long_link_manager.h"
#include <iostream>
#include <cstring>

// ============================================================================
// 全局回调函数指针 - 用于存储从 Dart 传递过来的回调函数
// ============================================================================
static void (*g_on_connected)() = nullptr;                    // 连接成功回调
static void (*g_on_connect_failed)(const char*) = nullptr;    // 连接失败回调
static void (*g_on_data_received)(const char*, int) = nullptr; // 接收数据回调
static void (*g_on_disconnected)() = nullptr;                 // 断开连接回调

// ============================================================================
// Dart 回调委托类 - 桥接 C++ 回调和 Dart 回调
// ============================================================================
/**
 * Dart 回调委托类
 * 实现 LongLinkDelegate 接口，将 C++ 回调转发给 Dart 回调函数
 */
class DartLongLinkDelegate : public LongLinkDelegate {
public:
    /**
     * 连接成功回调实现
     * 转发给 Dart 的 onConnected 回调
     */
    void onConnected() override {
        if (g_on_connected) {
            g_on_connected();
        }
    }
    
    /**
     * 连接失败回调实现
     * @param error 错误信息
     * 转发给 Dart 的 onConnectFailed 回调
     */
    void onConnectFailed(const char* error) override {
        if (g_on_connect_failed) {
            g_on_connect_failed(error);
        }
    }
    
    /**
     * 接收数据回调实现
     * @param data 接收到的数据
     * @param length 数据长度
     * 转发给 Dart 的 onDataReceived 回调
     */
    void onDataReceived(const char* data, int length) override {
        if (g_on_data_received) {
            g_on_data_received(data, length);
        }
    }
    
    /**
     * 断开连接回调实现
     * 转发给 Dart 的 onDisconnected 回调
     */
    void onDisconnected() override {
        if (g_on_disconnected) {
            g_on_disconnected();
        }
    }
};

// ============================================================================
// FFI 接口实现 - 提供 C 风格接口供 Dart FFI 调用
// ============================================================================
extern "C" {

/**
 * 创建长连接管理器实例
 * @return 管理器实例指针，如果失败返回 nullptr
 * 这个函数由 Dart 调用，用于创建新的长连接管理器
 */
void* create_long_link_manager() {
    std::cout << "FFI: 创建长连接管理器" << std::endl;
    try {
        LongLinkManager* manager = new LongLinkManager();
        return static_cast<void*>(manager);
    } catch (const std::exception& e) {
        std::cerr << "FFI: 创建长连接管理器失败: " << e.what() << std::endl;
        return nullptr;
    }
}

/**
 * 销毁长连接管理器实例
 * @param manager 管理器实例指针
 * 这个函数由 Dart 调用，用于释放管理器资源
 */
void destroy_long_link_manager(void* manager) {
    if (manager) {
        std::cout << "FFI: 销毁长连接管理器" << std::endl;
        LongLinkManager* m = static_cast<LongLinkManager*>(manager);
        delete m;
    }
}

/**
 * 设置 Dart 回调函数
 * @param manager 管理器实例指针
 * @param on_connected 连接成功回调函数
 * @param on_connect_failed 连接失败回调函数
 * @param on_data_received 接收数据回调函数
 * @param on_disconnected 断开连接回调函数
 * 这个函数由 Dart 调用，用于设置各种事件回调
 */
void set_long_link_callbacks(
    void* manager,
    void (*on_connected)(),
    void (*on_connect_failed)(const char*),
    void (*on_data_received)(const char*, int),
    void (*on_disconnected)()
) {
    if (!manager) {
        std::cerr << "FFI: 管理器指针为空，无法设置回调" << std::endl;
        return;
    }
    
    std::cout << "FFI: 设置回调函数" << std::endl;
    
    // 保存全局回调函数指针，供 DartLongLinkDelegate 使用
    g_on_connected = on_connected;
    g_on_connect_failed = on_connect_failed;
    g_on_data_received = on_data_received;
    g_on_disconnected = on_disconnected;
    
    // 创建并设置委托对象，建立回调链：Worker -> Manager -> DartLongLinkDelegate -> Dart
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    static DartLongLinkDelegate delegate;  // 使用静态对象确保生命周期
    m->setDelegate(&delegate);
}

/**
 * 开始连接
 * @param manager 管理器实例指针
 * @param url 连接地址
 * 这个函数由 Dart 调用，用于开始长连接
 */
void start_connection(void* manager, const char* url) {
    if (!manager || !url) {
        std::cerr << "FFI: 管理器指针或URL为空，无法开始连接" << std::endl;
        return;
    }
    
    std::cout << "FFI: 开始连接 " << url << std::endl;
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    m->startConnection(std::string(url));
}

/**
 * 停止连接
 * @param manager 管理器实例指针
 * 这个函数由 Dart 调用，用于停止长连接
 */
void stop_connection(void* manager) {
    if (!manager) {
        std::cerr << "FFI: 管理器指针为空，无法停止连接" << std::endl;
        return;
    }
    
    std::cout << "FFI: 停止连接" << std::endl;
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    m->stopConnection();
}

/**
 * 发送数据
 * @param manager 管理器实例指针
 * @param data 要发送的数据
 * 这个函数由 Dart 调用，用于发送数据到服务器
 */
void send_data(void* manager, const char* data) {
    if (!manager || !data) {
        std::cerr << "FFI: 管理器指针或数据为空，无法发送数据" << std::endl;
        return;
    }
    
    std::cout << "FFI: 发送数据 " << data << std::endl;
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    m->sendData(std::string(data));
}

/**
 * 获取连接状态
 * @param manager 管理器实例指针
 * @return 连接状态字符串（调用者需要释放内存）
 * 这个函数由 Dart 调用，用于获取当前连接状态
 */
const char* get_connection_status(void* manager) {
    if (!manager) {
        std::cerr << "FFI: 管理器指针为空，无法获取连接状态" << std::endl;
        return nullptr;
    }
    
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    std::string status = m->getConnectionStatus();
    
    // 分配内存并复制字符串，Dart 端需要调用 free_string 释放
    char* result = new char[status.length() + 1];
    std::strcpy(result, status.c_str());
    
    return result;
}

/**
 * 检查是否已连接
 * @param manager 管理器实例指针
 * @return 1 如果已连接，0 如果未连接
 * 这个函数由 Dart 调用，用于检查连接状态
 */
int is_connected(void* manager) {
    if (!manager) {
        std::cerr << "FFI: 管理器指针为空，无法检查连接状态" << std::endl;
        return 0;
    }
    
    LongLinkManager* m = static_cast<LongLinkManager*>(manager);
    return m->isConnected() ? 1 : 0;
}

/**
 * 释放字符串内存
 * @param str 要释放的字符串指针
 * 这个函数由 Dart 调用，用于释放 get_connection_status 返回的内存
 */
// void free_string(char* str) {
//     if (str) {
//         delete[] str;
//     }
// }

} // extern "C"
