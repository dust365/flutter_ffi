#include "long_link_worker.h"
#include <iostream>
#include <sstream>
#include <iomanip>

/**
 * 长连接工作线程构造函数
 * 初始化所有成员变量，包括线程状态、随机数生成器等
 */
LongLinkWorker::LongLinkWorker()
    : m_delegate(nullptr)                                    // 委托对象为空
    , m_running(false)                                       // 线程未运行
    , m_shouldStop(false)                                    // 不需要停止
    , m_randomGenerator(std::random_device{}())             // 初始化随机数生成器
    , m_messageCounter(0) {                                  // 消息计数器从0开始
}

/**
 * 长连接工作线程析构函数
 * 确保线程安全停止
 */
LongLinkWorker::~LongLinkWorker() {
    stop();
}

/**
 * 设置委托对象
 * @param delegate 委托对象指针，用于回调通知
 * 线程安全地设置委托对象
 */
void LongLinkWorker::setDelegate(LongLinkDelegate* delegate) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_delegate = delegate;
}

/**
 * 开始工作线程
 * @param url 连接地址
 * 启动新的工作线程来模拟网络连接和数据接收
 */
void LongLinkWorker::start(const std::string& url) {
    std::lock_guard<std::mutex> lock(m_mutex);
    
    // 如果已经在运行，直接返回
    if (m_running) {
        return;
    }
    
    // 初始化连接参数
    m_url = url;                                           // 保存连接地址
    m_shouldStop = false;                                  // 重置停止标志
    m_running = true;                                      // 设置运行状态
    m_startTime = std::chrono::steady_clock::now();       // 记录开始时间
    
    // 启动工作线程，执行 workerLoop 方法
    m_workerThread = std::thread(&LongLinkWorker::workerLoop, this);
}

/**
 * 停止工作线程
 * 安全地停止工作线程并等待其结束
 */
void LongLinkWorker::stop() {
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        // 如果未运行，直接返回
        if (!m_running) {
            return;
        }
        
        // 设置停止标志并通知等待的线程
        m_shouldStop = true;
        m_condition.notify_all();
    }
    
    // 等待工作线程结束
    if (m_workerThread.joinable()) {
        m_workerThread.join();
    }
    
    m_running = false;
}

/**
 * 检查是否正在运行
 * @return true 如果工作线程正在运行
 */
bool LongLinkWorker::isRunning() const {
    return m_running;
}

/**
 * 发送数据（模拟实现）
 * @param data 要发送的数据
 * 在实际实现中，这里会通过网络发送数据
 */
void LongLinkWorker::sendData(const std::string& data) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_running && m_delegate) {
        // 模拟发送数据，这里只是打印日志
        // 在实际实现中，这里会调用网络库发送数据
        std::cout << "LongLinkWorker: 发送数据: " << data << std::endl;
    }
}

/**
 * 工作线程主循环
 * 模拟网络连接过程：连接 -> 接收数据 -> 断开连接
 */
void LongLinkWorker::workerLoop() {
    std::cout << "LongLinkWorker: 工作线程启动，连接地址: " << m_url << std::endl;
    
    // ============================================================================
    // 第一阶段：模拟连接过程
    // ============================================================================
    // 模拟网络连接延迟，实际实现中这里会进行真实的网络连接
    std::this_thread::sleep_for(std::chrono::seconds(1));
    
    // 检查是否需要停止，如果不需要则调用连接成功回调
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_delegate && !m_shouldStop.load()) {
            m_delegate->onConnected();
        }
    }
    
    // ============================================================================
    // 第二阶段：模拟数据接收循环
    // ============================================================================
    while (!m_shouldStop.load()) {
        // 等待5秒或直到收到停止信号
        // 使用条件变量实现可中断的等待
        std::unique_lock<std::mutex> lock(m_mutex);
        if (m_condition.wait_for(lock, std::chrono::seconds(5), [this] { return m_shouldStop.load(); })) {
            break; // 收到停止信号，退出循环
        }
        
        // 生成并发送模拟数据
        if (m_delegate && !m_shouldStop.load()) {
            std::string mockData = generateMockData();
            m_delegate->onDataReceived(mockData.c_str(), static_cast<int>(mockData.length()));
        }
    }
    
    // ============================================================================
    // 第三阶段：清理和断开连接
    // ============================================================================
    // 调用断开连接回调
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_delegate) {
            m_delegate->onDisconnected();
        }
    }
    
    std::cout << "LongLinkWorker: 工作线程结束" << std::endl;
}

/**
 * 生成模拟数据
 * @return 模拟的JSON格式数据
 * 生成不同类型的模拟数据，用于测试数据接收功能
 */
std::string LongLinkWorker::generateMockData() {
    m_messageCounter++;  // 递增消息计数器
    
    // 随机选择数据类型（1-4）
    std::uniform_int_distribution<int> typeDist(1, 4);
    int dataType = typeDist(m_randomGenerator);
    
    std::ostringstream json;
    json << "{";
    
    // 根据数据类型生成不同的JSON内容
    switch (dataType) {
        case 1: // 心跳包 - 用于保持连接活跃
            json << "\"type\":\"heartbeat\",";
            json << "\"timestamp\":" << getCurrentTimestamp() << ",";
            json << "\"counter\":" << m_messageCounter;
            break;
            
        case 2: // 消息通知 - 模拟聊天消息
            json << "\"type\":\"message\",";
            json << "\"content\":\"New message #" << m_messageCounter << "\",";
            json << "\"timestamp\":" << getCurrentTimestamp();
            break;
            
        case 3: // 状态更新 - 模拟在线用户数变化
            json << "\"type\":\"status\",";
            json << "\"online\":" << (100 + m_messageCounter % 50) << ",";
            json << "\"timestamp\":" << getCurrentTimestamp();
            break;
            
        case 4: // 系统信息 - 模拟系统监控数据
            json << "\"type\":\"system\",";
            json << "\"memory\":" << (512 + m_messageCounter % 256) << ",";
            json << "\"cpu\":" << (20 + m_messageCounter % 30) << ",";
            json << "\"timestamp\":" << getCurrentTimestamp();
            break;
    }
    
    json << "}";
    return json.str();
}

/**
 * 获取当前时间戳
 * @return 时间戳字符串（秒+毫秒）
 * 生成用于模拟数据的时间戳
 */
std::string LongLinkWorker::getCurrentTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
        now.time_since_epoch()) % 1000;
    
    std::ostringstream oss;
    oss << std::put_time(std::localtime(&time_t), "%s");  // 秒数
    oss << std::setfill('0') << std::setw(3) << ms.count();  // 毫秒数
    
    return oss.str();
}
