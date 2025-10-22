#ifndef LONG_LINK_MANAGER_H
#define LONG_LINK_MANAGER_H

#include <string>
#include <memory>
#include "long_link_delegate.h"
#include "long_link_worker.h"

/**
 * 连接状态枚举
 */
enum class ConnectionStatus {
    Disconnected,   // 未连接
    Connecting,     // 连接中
    Connected,      // 已连接
    Disconnecting   // 断开中
};

/**
 * 长连接管理器
 * 管理长连接的生命周期和状态
 */
class LongLinkManager : public LongLinkDelegate {
public:
    LongLinkManager();
    ~LongLinkManager();
    
    /**
     * 设置委托对象
     * @param delegate 委托对象指针
     */
    void setDelegate(LongLinkDelegate* delegate);
    
    /**
     * 开始连接
     * @param url 连接地址
     */
    void startConnection(const std::string& url);
    
    /**
     * 停止连接
     */
    void stopConnection();
    
    /**
     * 发送数据
     * @param data 要发送的数据
     */
    void sendData(const std::string& data);
    
    /**
     * 获取连接状态
     * @return 连接状态字符串
     */
    std::string getConnectionStatus() const;
    
    /**
     * 检查是否已连接
     * @return true 如果已连接
     */
    bool isConnected() const;

    // LongLinkDelegate 接口实现
    void onConnected() override;
    void onConnectFailed(const char* error) override;
    void onDataReceived(const char* data, int length) override;
    void onDisconnected() override;

private:
    LongLinkDelegate* m_delegate;
    std::unique_ptr<LongLinkWorker> m_worker;
    ConnectionStatus m_status;
    std::string m_currentUrl;
};

#endif // LONG_LINK_MANAGER_H
