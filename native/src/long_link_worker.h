#ifndef LONG_LINK_WORKER_H
#define LONG_LINK_WORKER_H

#include <thread>
#include <atomic>
#include <mutex>
#include <condition_variable>
#include <string>
#include <chrono>
#include <random>
#include "long_link_delegate.h"

/**
 * 长连接工作线程
 * 模拟异步网络连接和数据接收
 */
class LongLinkWorker {
public:
    LongLinkWorker();
    ~LongLinkWorker();
    
    /**
     * 设置委托对象
     * @param delegate 委托对象指针
     */
    void setDelegate(LongLinkDelegate* delegate);
    
    /**
     * 开始工作线程
     * @param url 连接地址
     */
    void start(const std::string& url);
    
    /**
     * 停止工作线程
     */
    void stop();
    
    /**
     * 检查是否正在运行
     * @return true 如果正在运行
     */
    bool isRunning() const;
    
    /**
     * 发送数据（模拟）
     * @param data 要发送的数据
     */
    void sendData(const std::string& data);

private:
    /**
     * 工作线程主循环
     */
    void workerLoop();
    
    /**
     * 生成模拟数据
     * @return 模拟的JSON数据
     */
    std::string generateMockData();
    
    /**
     * 获取当前时间戳
     * @return 时间戳字符串
     */
    std::string getCurrentTimestamp();

private:
    LongLinkDelegate* m_delegate;
    std::thread m_workerThread;
    std::atomic<bool> m_running;
    std::atomic<bool> m_shouldStop;
    std::mutex m_mutex;
    std::condition_variable m_condition;
    std::string m_url;
    std::mt19937 m_randomGenerator;
    int m_messageCounter;
    std::chrono::steady_clock::time_point m_startTime;
};

#endif // LONG_LINK_WORKER_H
