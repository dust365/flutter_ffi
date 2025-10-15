import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'struct_test_controller.dart';

/// 结构体测试页面
class StructTestPage extends GetView<StructTestController> {
  const StructTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('结构体测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '输入参数',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 第一个点
                    const Text(
                      '第一个点 (P1)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.pointX1Controller,
                            decoration: const InputDecoration(
                              labelText: 'X 坐标',
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.pointY1Controller,
                            decoration: const InputDecoration(
                              labelText: 'Y 坐标',
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 第二个点
                    const Text(
                      '第二个点 (P2)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.pointX2Controller,
                            decoration: const InputDecoration(
                              labelText: 'X 坐标',
                              border: OutlineInputBorder(),
                              hintText: '3',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.pointY2Controller,
                            decoration: const InputDecoration(
                              labelText: 'Y 坐标',
                              border: OutlineInputBorder(),
                              hintText: '4',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.clearInputs,
                            child: const Text('清空'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.setExampleData,
                            child: const Text('示例数据'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 测试按钮区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '结构体测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '计算两个点之间的欧几里得距离',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.testPointDistance,
                          child: const Text('计算点距离'),
                        ),
                      ),
                    ),
                    if (controller.isLoading.value) ...[
                      const SizedBox(height: 12),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 结果显示
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '测试结果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.result.value.isEmpty
                            ? '点击上方按钮进行测试...'
                            : controller.result.value,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              controller.result.value.startsWith('错误')
                                  ? Colors.red
                                  : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
