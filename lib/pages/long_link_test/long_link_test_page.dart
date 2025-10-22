import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'long_link_controller.dart';

/// 长连接测试页面
class LongLinkTestPage extends GetView<LongLinkController> {
  const LongLinkTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('长连接测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: controller.clearReceivedData,
            tooltip: '清空数据',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 连接控制区域
            _buildConnectionCard(),

            const SizedBox(height: 16),

            // 状态显示区域
            _buildStatusCard(),

            const SizedBox(height: 16),

            // 接收数据区域
            _buildReceivedDataCard(),
          ],
        ),
      ),
    );
  }

  /// 构建连接控制卡片
  Widget _buildConnectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '连接控制',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // URL 输入框
            TextField(
              controller: controller.urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                border: OutlineInputBorder(),
                hintText: 'ws://localhost:8080/websocket',
              ),
              enabled: controller.canConnect,
            ),

            const SizedBox(height: 12),

            // 连接/断开按钮
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.canConnect
                              ? controller.startConnection
                              : null,
                      icon:
                          controller.isConnecting.value
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.link),
                      label: Text(
                        controller.isConnecting.value ? '连接中...' : '连接',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.canDisconnect
                              ? controller.stopConnection
                              : null,
                      icon: const Icon(Icons.link_off),
                      label: const Text('断开'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态显示卡片
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '连接状态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Obx(
              () => Row(
                children: [
                  // 状态指示器
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: controller.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 状态文本
                  Text(
                    controller.statusDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // 连接时长
                  if (controller.connectionTime.value.isNotEmpty)
                    Text(
                      '连接时长: ${controller.connectionTime.value}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),

            // 错误信息
            Obx(() {
              if (controller.lastError.value.isNotEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.lastError.value,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: controller.clearError,
                            color: Colors.red[600],
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// 构建接收数据卡片
  Widget _buildReceivedDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '接收数据',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '共 ${controller.receivedData.length} 条',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.receivedData.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          '暂无接收数据',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: controller.receivedData.length,
                  itemBuilder: (context, index) {
                    // 倒序显示：最新的数据在顶部
                    final reversedIndex =
                        controller.receivedData.length - 1 - index;
                    final item = controller.receivedData[reversedIndex];
                    return _buildDataItem(item);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建数据项
  Widget _buildDataItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                item.typeDescription,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 数据内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              item.data,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
