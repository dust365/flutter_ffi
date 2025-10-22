#ifndef LONG_LINK_DELEGATE_H
#define LONG_LINK_DELEGATE_H

/**
 * 长连接委托接口
 * 定义长连接库的回调方法
 */
class LongLinkDelegate {
public:
    virtual ~LongLinkDelegate() = default;
    
    /**
     * 连接成功回调
     * 虚函数，子类必须实现
     */
    virtual void onConnected() = 0;
    
    /**
     * 连接失败回调
     * @param error 错误信息
     */
    virtual void onConnectFailed(const char* error) = 0;
    
    /**
     * 接收数据回调
     * @param data 接收到的数据
     * @param length 数据长度
     */
    virtual void onDataReceived(const char* data, int length) = 0;
    
    /**
     * 断开连接回调
     */
    virtual void onDisconnected() = 0;
};

#endif // LONG_LINK_DELEGATE_H
