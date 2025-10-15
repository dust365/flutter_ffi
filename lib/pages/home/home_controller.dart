import 'package:get/get.dart';

/// 首页控制器
class HomeController extends GetxController {
  // 测试模块列表
  final List<TestModule> testModules = [
    TestModule(
      title: '基础类型测试',
      description: '测试整数、浮点数的基本运算',
      icon: '🔢',
      route: '/basic-types',
    ),
    TestModule(
      title: '字符串测试',
      description: '测试字符串操作和转换',
      icon: '📝',
      route: '/string-test',
    ),
    TestModule(
      title: '结构体测试',
      description: '测试结构体传递和计算',
      icon: '📐',
      route: '/struct-test',
    ),
    TestModule(
      title: '回调函数测试',
      description: '测试回调函数和进度更新',
      icon: '🔄',
      route: '/callback-test',
    ),
    TestModule(
      title: '异步调用测试',
      description: '测试异步计算和回调',
      icon: '⚡',
      route: '/async-test',
    ),
  ];

  /// 跳转到指定测试页面
  void navigateToTest(String route) {
    Get.toNamed(route);
  }
}

/// 测试模块数据模型
class TestModule {
  final String title;
  final String description;
  final String icon;
  final String route;

  TestModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}
