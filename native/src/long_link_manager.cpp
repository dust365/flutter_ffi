#include "long_link_manager.h"
#include <iostream>

/**
 * 长连接管理器构造函数
 * 初始化管理器状态，创建工作线程并设置委托关系
 */
LongLinkManager::LongLinkManager()
    : m_delegate(nullptr)                                    // 初始化委托对象为空
    , m_worker(std::make_unique<LongLinkWorker>())          // 创建唯一的工作线程对象
    , m_status(ConnectionStatus::Disconnected) {            // 初始状态为未连接
    
    // 设置工作线程的委托为当前对象，形成回调链：
    // Worker -> Manager -> Dart回调
    m_worker->setDelegate(this);
}

/**
 * 长连接管理器析构函数
 * 确保在销毁前停止所有连接
 */
LongLinkManager::~LongLinkManager() {
    stopConnection();
}

/**
 * 设置委托对象
 * @param delegate 委托对象指针，用于接收回调通知
 */
void LongLinkManager::setDelegate(LongLinkDelegate* delegate) {
    m_delegate = delegate;
}

/**
 * 开始连接
 * @param url 连接地址
 * 检查当前状态，避免重复连接，然后启动工作线程
 */
void LongLinkManager::startConnection(const std::string& url) {
    // 状态检查：如果已经连接或正在连接中，则直接返回
    if (m_status == ConnectionStatus::Connected || 
        m_status == ConnectionStatus::Connecting) {
        std::cout << "LongLinkManager: 已经连接或正在连接中" << std::endl;
        return;
    }
    
    std::cout << "LongLinkManager: 开始连接 " << url << std::endl;
    m_status = ConnectionStatus::Connecting;  // 设置状态为连接中
    m_currentUrl = url;                       // 保存当前连接地址
    
    // 启动工作线程，开始异步连接过程
    m_worker->start(url);
}

/**
 * 停止连接
 * 安全地停止工作线程并更新状态
 */
void LongLinkManager::stopConnection() {
    // 如果已经断开连接，直接返回
    if (m_status == ConnectionStatus::Disconnected) {
        return;
    }
    
    std::cout << "LongLinkManager: 停止连接" << std::endl;
    m_status = ConnectionStatus::Disconnecting;  // 设置状态为断开中
    
    // 停止工作线程，这会触发断开连接回调
    m_worker->stop();
    
    // 更新最终状态
    m_status = ConnectionStatus::Disconnected;
    m_currentUrl.clear();  // 清空当前连接地址
}

/**
 * 发送数据
 * @param data 要发送的数据
 * 只有在已连接状态下才能发送数据
 */
void LongLinkManager::sendData(const std::string& data) {
    // 状态检查：只有已连接状态才能发送数据
    if (m_status != ConnectionStatus::Connected) {
        std::cout << "LongLinkManager: 未连接，无法发送数据" << std::endl;
        return;
    }
    
    std::cout << "LongLinkManager: 发送数据: " << data << std::endl;
    // 委托给工作线程处理数据发送
    m_worker->sendData(data);
}

/**
 * 获取连接状态字符串
 * @return 连接状态的中文描述
 */
std::string LongLinkManager::getConnectionStatus() const {
    switch (m_status) {
        case ConnectionStatus::Disconnected:
            return "未连接";
        case ConnectionStatus::Connecting:
            return "连接中";
        case ConnectionStatus::Connected:
            return "已连接";
        case ConnectionStatus::Disconnecting:
            return "断开中";
        default:
            return "未知状态";
    }
}

/**
 * 检查是否已连接
 * @return true 如果当前状态为已连接
 */
bool LongLinkManager::isConnected() const {
    return m_status == ConnectionStatus::Connected;
}

// ============================================================================
// LongLinkDelegate 接口实现 - 接收来自工作线程的回调通知
// ============================================================================

/**
 * 连接成功回调
 * 由工作线程调用，表示连接已建立
 */
void LongLinkManager::onConnected() {
    std::cout << "LongLinkManager: 连接成功" << std::endl;
    m_status = ConnectionStatus::Connected;  // 更新状态为已连接
    
    // 转发回调给上层委托对象（Dart回调）
    if (m_delegate) {
        m_delegate->onConnected();
    }
}

/**
 * 连接失败回调
 * @param error 错误信息
 * 由工作线程调用，表示连接失败
 */
void LongLinkManager::onConnectFailed(const char* error) {
    std::cout << "LongLinkManager: 连接失败: " << error << std::endl;
    m_status = ConnectionStatus::Disconnected;  // 更新状态为未连接
    
    // 转发错误信息给上层委托对象
    if (m_delegate) {
        m_delegate->onConnectFailed(error);
    }
}

/**
 * 接收数据回调
 * @param data 接收到的数据
 * @param length 数据长度
 * 由工作线程调用，表示接收到新数据
 */
void LongLinkManager::onDataReceived(const char* data, int length) {
    std::cout << "LongLinkManager: 接收数据 (" << length << " bytes): " 
              << std::string(data, length) << std::endl;
    
    // 转发数据给上层委托对象
    if (m_delegate) {
        m_delegate->onDataReceived(data, length);
    }
}

/**
 * 断开连接回调
 * 由工作线程调用，表示连接已断开
 */
void LongLinkManager::onDisconnected() {
    std::cout << "LongLinkManager: 连接断开" << std::endl;
    m_status = ConnectionStatus::Disconnected;  // 更新状态为未连接
    
    // 转发断开通知给上层委托对象
    if (m_delegate) {
        m_delegate->onDisconnected();
    }
}
