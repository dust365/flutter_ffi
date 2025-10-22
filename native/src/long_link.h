#ifndef LONG_LINK_H
#define LONG_LINK_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * 长连接 FFI 接口
 * 提供 C 风格的接口供 Dart FFI 调用
 */

/**
 * 创建长连接管理器实例
 * @return 管理器实例指针
 */
void* create_long_link_manager();

/**
 * 销毁长连接管理器实例
 * @param manager 管理器实例指针
 */
void destroy_long_link_manager(void* manager);

/**
 * 设置 Dart 回调函数
 * @param manager 管理器实例指针
 * @param on_connected 连接成功回调
 * @param on_connect_failed 连接失败回调
 * @param on_data_received 接收数据回调
 * @param on_disconnected 断开连接回调
 */
void set_long_link_callbacks(
    void* manager,
    void (*on_connected)(),
    void (*on_connect_failed)(const char*),
    void (*on_data_received)(const char*, int),
    void (*on_disconnected)()
);

/**
 * 开始连接
 * @param manager 管理器实例指针
 * @param url 连接地址
 */
void start_connection(void* manager, const char* url);

/**
 * 停止连接
 * @param manager 管理器实例指针
 */
void stop_connection(void* manager);

/**
 * 发送数据
 * @param manager 管理器实例指针
 * @param data 要发送的数据
 */
void send_data(void* manager, const char* data);

/**
 * 获取连接状态
 * @param manager 管理器实例指针
 * @return 连接状态字符串（调用者需要释放内存）
 */
const char* get_connection_status(void* manager);

/**
 * 检查是否已连接
 * @param manager 管理器实例指针
 * @return 1 如果已连接，0 如果未连接
 */
int is_connected(void* manager);

/**
 * 释放字符串内存
 * @param str 要释放的字符串指针
 */
// void free_string(char* str);

#ifdef __cplusplus
}
#endif

#endif // LONG_LINK_H
