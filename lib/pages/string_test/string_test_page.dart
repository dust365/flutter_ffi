import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'string_test_controller.dart';

/// 字符串测试页面
class StringTestPage extends GetView<StringTestController> {
  const StringTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('字符串测试'),
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
                      controller: controller.stringController,
                      decoration: const InputDecoration(
                        labelText: '主字符串',
                        border: OutlineInputBorder(),
                        hintText: '请输入要测试的字符串',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.secondStringController,
                      decoration: const InputDecoration(
                        labelText: '第二个字符串（用于拼接）',
                        border: OutlineInputBorder(),
                        hintText: '可选，留空则使用 "World"',
                      ),
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
                      '字符串操作测试',
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
                                    : controller.testReverseString,
                            child: const Text('反转字符串'),
                          ),
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testToUppercase,
                            child: const Text('转大写'),
                          ),
                          ElevatedButton(
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : controller.testConcatStrings,
                            child: const Text('字符串拼接'),
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
