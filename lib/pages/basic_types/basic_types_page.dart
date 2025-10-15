import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'basic_types_controller.dart';

/// 基础类型测试页面
class BasicTypesPage extends GetView<BasicTypesController> {
  const BasicTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础类型测试'),
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
                    TextField(
                      controller: controller.numberAController,
                      decoration: const InputDecoration(
                        labelText: '数字 A',
                        border: OutlineInputBorder(),
                        hintText: '请输入数字',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.numberBController,
                      decoration: const InputDecoration(
                        labelText: '数字 B',
                        border: OutlineInputBorder(),
                        hintText: '请输入数字',
                      ),
                      keyboardType: TextInputType.number,
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
                      '基础运算测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testAdd,
                            child: const Text('加法'),
                          ),
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testSubtract,
                            child: const Text('减法'),
                          ),
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testMultiply,
                            child: const Text('乘法'),
                          ),
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testDivide,
                            child: const Text('除法'),
                          ),
                        ],
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
