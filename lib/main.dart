import 'package:flutter/material.dart';
import 'ffi_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFI Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter FFI 测试演示'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _numberAController = TextEditingController();
  final TextEditingController _numberBController = TextEditingController();
  final TextEditingController _stringController = TextEditingController();
  final TextEditingController _pointXController = TextEditingController();
  final TextEditingController _pointYController = TextEditingController();

  String _result = '';
  double _progress = 0.0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _numberAController.dispose();
    _numberBController.dispose();
    _stringController.dispose();
    _pointXController.dispose();
    _pointYController.dispose();
    super.dispose();
  }

  void _setResult(String result) {
    setState(() {
      _result = result;
    });
  }

  // ==========================================================================
  // 基础类型测试
  // ==========================================================================

  void _testAdd() {
    try {
      final a = int.parse(_numberAController.text);
      final b = int.parse(_numberBController.text);
      final result = nativeLib.add(a, b);
      _setResult('加法结果: $a + $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testSubtract() {
    try {
      final a = int.parse(_numberAController.text);
      final b = int.parse(_numberBController.text);
      final result = nativeLib.subtract(a, b);
      _setResult('减法结果: $a - $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testMultiply() {
    try {
      final a = double.parse(_numberAController.text);
      final b = double.parse(_numberBController.text);
      final result = nativeLib.multiply(a, b);
      _setResult('乘法结果: $a × $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testDivide() {
    try {
      final a = double.parse(_numberAController.text);
      final b = double.parse(_numberBController.text);
      final result = nativeLib.divide(a, b);
      _setResult('除法结果: $a ÷ $b = $result');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  // ==========================================================================
  // 字符串测试
  // ==========================================================================

  void _testReverseString() {
    try {
      final input = _stringController.text;
      final result = nativeLib.reverseString(input);
      _setResult('反转字符串: "$input" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testToUppercase() {
    try {
      final input = _stringController.text;
      final result = nativeLib.toUppercase(input);
      _setResult('转大写: "$input" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testConcatStrings() {
    try {
      final a = _stringController.text;
      final b =
          _numberAController.text.isNotEmpty
              ? _numberAController.text
              : 'World';
      final result = nativeLib.concatStrings(a, b);
      _setResult('字符串拼接: "$a" + "$b" => "$result"');
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  // ==========================================================================
  // 结构体测试
  // ==========================================================================

  void _testPointDistance() {
    try {
      final x1 = double.parse(_pointXController.text);
      final y1 = double.parse(_pointYController.text);
      final x2 = double.parse(_numberAController.text);
      final y2 = double.parse(_numberBController.text);

      final p1 = nativeLib.createPoint(x1, y1);
      final p2 = nativeLib.createPoint(x2, y2);

      try {
        final dist = nativeLib.distance(p1, p2);
        _setResult(
          '点 ($x1, $y1) 到点 ($x2, $y2) 的距离: ${dist.toStringAsFixed(2)}',
        );
      } finally {
        nativeLib.freePoint(p1);
        nativeLib.freePoint(p2);
      }
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  // ==========================================================================
  // 回调函数测试
  // ==========================================================================

  void _testCallback() {
    try {
      nativeLib.registerDartCallback((value) {
        _setResult('收到回调，值: $value');
      });

      final value = int.parse(_numberAController.text);
      nativeLib.triggerCallback(value);
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  void _testProgressCallback() async {
    try {
      setState(() {
        _isProcessing = true;
        _progress = 0.0;
        _result = '处理中...';
      });

      final count = int.parse(
        _numberAController.text.isEmpty ? '10' : _numberAController.text,
      );

      // 在单独的 Isolate 或使用 Future 来避免阻塞 UI
      nativeLib.processWithDartProgress(count, (progress) {
        setState(() {
          _progress = progress / 100.0;
          _result = '进度: $progress%';
        });
      });

      setState(() {
        _isProcessing = false;
        _result = '处理完成！';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _result = '错误: $e';
      });
    }
  }

  // ==========================================================================
  // 异步调用测试
  // ==========================================================================

  void _testAsyncCompute() {
    try {
      final value = int.parse(
        _numberAController.text.isEmpty ? '5' : _numberAController.text,
      );

      _setResult('开始异步计算 $value × $value，请稍候...');

      nativeLib.asyncComputeWithCallback(value, (result) {
        _setResult('异步计算完成: $value × $value = $result');
      });
    } catch (e) {
      _setResult('错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入框区域
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
                      controller: _numberAController,
                      decoration: const InputDecoration(
                        labelText: '数字 A',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _numberBController,
                      decoration: const InputDecoration(
                        labelText: '数字 B',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _stringController,
                      decoration: const InputDecoration(
                        labelText: '字符串',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pointXController,
                            decoration: const InputDecoration(
                              labelText: '点 X',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _pointYController,
                            decoration: const InputDecoration(
                              labelText: '点 Y',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 基础类型测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基础类型测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _testAdd,
                          child: const Text('加法'),
                        ),
                        ElevatedButton(
                          onPressed: _testSubtract,
                          child: const Text('减法'),
                        ),
                        ElevatedButton(
                          onPressed: _testMultiply,
                          child: const Text('乘法'),
                        ),
                        ElevatedButton(
                          onPressed: _testDivide,
                          child: const Text('除法'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 字符串测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '字符串测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _testReverseString,
                          child: const Text('反转字符串'),
                        ),
                        ElevatedButton(
                          onPressed: _testToUppercase,
                          child: const Text('转大写'),
                        ),
                        ElevatedButton(
                          onPressed: _testConcatStrings,
                          child: const Text('字符串拼接'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 结构体测试
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testPointDistance,
                      child: const Text('计算点距离'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 回调函数测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '回调函数测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _testCallback,
                          child: const Text('回调测试'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isProcessing ? null : _testProgressCallback,
                          child: const Text('进度回调'),
                        ),
                      ],
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _progress),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 异步调用测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '异步调用测试',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _testAsyncCompute,
                      child: const Text('异步计算（2秒后返回）'),
                    ),
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
                      '结果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result.isEmpty ? '点击上方按钮进行测试...' : _result,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _result.startsWith('错误')
                                ? Colors.red
                                : Colors.black87,
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
