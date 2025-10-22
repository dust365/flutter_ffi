# 长连接模块流程图

## 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Dart 应用层                              │
├─────────────────────────────────────────────────────────────────┤
│  LongLinkController  │  LongLinkTestPage  │  UI 组件            │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    Dart FFI 桥接层                              │
├─────────────────────────────────────────────────────────────────┤
│  LongLinkBridge  │  NativeCallable  │  回调函数管理              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    C++ FFI 接口层                               │
├─────────────────────────────────────────────────────────────────┤
│  long_link.cpp  │  DartLongLinkDelegate  │  全局回调指针         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    C++ 业务逻辑层                               │
├─────────────────────────────────────────────────────────────────┤
│  LongLinkManager  │  状态管理  │  生命周期管理                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    C++ 工作线程层                               │
├─────────────────────────────────────────────────────────────────┤
│  LongLinkWorker  │  模拟网络连接  │  数据生成  │  线程管理        │
└─────────────────────────────────────────────────────────────────┘
```

## 详细流程图

### 1. 初始化流程

```
Dart 应用启动
    │
    ▼
LongLinkBridge 构造函数
    │
    ▼
NativeLibraryLoader.loadLibrary()
    │
    ▼
加载原生库 (libnative_lib.so/dylib)
    │
    ▼
绑定 FFI 函数
    │
    ▼
创建 LongLinkManager 实例
    │
    ▼
创建 LongLinkWorker 实例
    │
    ▼
设置委托关系: Worker -> Manager
    │
    ▼
初始化完成
```

### 2. 连接建立流程

```
用户点击连接按钮
    │
    ▼
LongLinkController.startConnection()
    │
    ▼
LongLinkBridge.startConnection()
    │
    ▼
FFI: start_connection()
    │
    ▼
LongLinkManager.startConnection()
    │
    ▼
状态检查 (避免重复连接)
    │
    ▼
设置状态: Connecting
    │
    ▼
LongLinkWorker.start()
    │
    ▼
启动工作线程
    │
    ▼
workerLoop() 开始执行
    │
    ▼
模拟连接延迟 (1秒)
    │
    ▼
调用 onConnected() 回调
    │
    ▼
LongLinkManager.onConnected()
    │
    ▼
设置状态: Connected
    │
    ▼
DartLongLinkDelegate.onConnected()
    │
    ▼
调用 Dart 回调函数
    │
    ▼
LongLinkController._onConnectedNative()
    │
    ▼
更新 UI 状态
    │
    ▼
连接建立完成
```

### 3. 数据接收流程

```
工作线程运行中
    │
    ▼
每5秒生成一次模拟数据
    │
    ▼
generateMockData()
    │
    ▼
随机选择数据类型 (心跳/消息/状态/系统)
    │
    ▼
生成 JSON 格式数据
    │
    ▼
调用 onDataReceived() 回调
    │
    ▼
LongLinkManager.onDataReceived()
    │
    ▼
DartLongLinkDelegate.onDataReceived()
    │
    ▼
调用 Dart 回调函数
    │
    ▼
LongLinkController._onDataReceivedNative()
    │
    ▼
添加到接收数据列表
    │
    ▼
更新 UI 显示
    │
    ▼
数据接收完成
```

### 4. 连接断开流程

```
用户点击断开按钮
    │
    ▼
LongLinkController.stopConnection()
    │
    ▼
LongLinkBridge.stopConnection()
    │
    ▼
FFI: stop_connection()
    │
    ▼
LongLinkManager.stopConnection()
    │
    ▼
设置状态: Disconnecting
    │
    ▼
LongLinkWorker.stop()
    │
    ▼
设置停止标志: m_shouldStop = true
    │
    ▼
通知工作线程停止
    │
    ▼
工作线程退出循环
    │
    ▼
调用 onDisconnected() 回调
    │
    ▼
LongLinkManager.onDisconnected()
    │
    ▼
设置状态: Disconnected
    │
    ▼
DartLongLinkDelegate.onDisconnected()
    │
    ▼
调用 Dart 回调函数
    │
    ▼
LongLinkController._onDisconnectedNative()
    │
    ▼
更新 UI 状态
    │
    ▼
连接断开完成
```

### 5. 数据发送流程

```
用户输入消息并点击发送
    │
    ▼
LongLinkController.sendMessage()
    │
    ▼
LongLinkBridge.sendData()
    │
    ▼
FFI: send_data()
    │
    ▼
LongLinkManager.sendData()
    │
    ▼
状态检查 (只有已连接才能发送)
    │
    ▼
LongLinkWorker.sendData()
    │
    ▼
模拟发送数据 (打印日志)
    │
    ▼
数据发送完成
```

## 关键组件说明

### 1. LongLinkDelegate 接口
- **作用**: 定义回调接口规范
- **实现类**: DartLongLinkDelegate
- **回调方法**: onConnected, onConnectFailed, onDataReceived, onDisconnected

### 2. LongLinkManager
- **作用**: 管理长连接的生命周期和状态
- **职责**: 状态管理、委托转发、业务逻辑控制
- **状态**: Disconnected, Connecting, Connected, Disconnecting

### 3. LongLinkWorker
- **作用**: 工作线程，模拟网络连接和数据接收
- **职责**: 异步连接、数据生成、线程管理
- **特点**: 使用条件变量实现可中断等待

### 4. FFI 桥接
- **作用**: 连接 Dart 和 C++ 代码
- **关键点**: 全局回调指针、静态委托对象、内存管理

## 线程安全说明

1. **LongLinkWorker**: 使用 mutex 和 condition_variable 保证线程安全
2. **状态管理**: 使用原子操作和锁保护共享状态
3. **回调调用**: 在锁保护下进行，避免竞态条件
4. **内存管理**: 使用 RAII 和智能指针管理资源

## 错误处理

1. **连接失败**: 通过 onConnectFailed 回调通知
2. **参数验证**: 在 FFI 层进行空指针检查
3. **异常捕获**: 在关键函数中使用 try-catch
4. **资源清理**: 在析构函数中确保资源释放
