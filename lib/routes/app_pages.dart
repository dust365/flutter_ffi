import 'package:get/get.dart';
import '../pages/home/home_page.dart';
import '../pages/home/home_controller.dart';
import '../pages/basic_types/basic_types_page.dart';
import '../pages/basic_types/basic_types_controller.dart';
import '../pages/string_test/string_test_page.dart';
import '../pages/string_test/string_test_controller.dart';
import '../pages/struct_test/struct_test_page.dart';
import '../pages/struct_test/struct_test_controller.dart';
import '../pages/callback_test/callback_test_page.dart';
import '../pages/callback_test/callback_test_controller.dart';
import '../pages/async_test/async_test_page.dart';
import '../pages/async_test/async_test_controller.dart';
import '../pages/long_link_test/long_link_test_page.dart';
import '../pages/long_link_test/long_link_controller.dart';
import 'app_routes.dart';

/// 应用页面路由配置
class AppPages {
  // 私有构造函数，防止实例化
  AppPages._();

  /// 路由配置列表
  static final List<GetPage> routes = [
    // 首页
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

    // 基础类型测试页
    GetPage(
      name: AppRoutes.basicTypes,
      page: () => const BasicTypesPage(),
      binding: BasicTypesBinding(),
    ),

    // 字符串测试页
    GetPage(
      name: AppRoutes.stringTest,
      page: () => const StringTestPage(),
      binding: StringTestBinding(),
    ),

    // 结构体测试页
    GetPage(
      name: AppRoutes.structTest,
      page: () => const StructTestPage(),
      binding: StructTestBinding(),
    ),

    // 回调函数测试页
    GetPage(
      name: AppRoutes.callbackTest,
      page: () => const CallbackTestPage(),
      binding: CallbackTestBinding(),
    ),

    // 异步调用测试页
    GetPage(
      name: AppRoutes.asyncTest,
      page: () => const AsyncTestPage(),
      binding: AsyncTestBinding(),
    ),

    // 长连接测试页
    GetPage(
      name: AppRoutes.longLinkTest,
      page: () => const LongLinkTestPage(),
      binding: LongLinkTestBinding(),
    ),
  ];
}

/// 首页依赖注入
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

/// 基础类型测试页依赖注入
class BasicTypesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BasicTypesController>(() => BasicTypesController());
  }
}

/// 字符串测试页依赖注入
class StringTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StringTestController>(() => StringTestController());
  }
}

/// 结构体测试页依赖注入
class StructTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StructTestController>(() => StructTestController());
  }
}

/// 回调函数测试页依赖注入
class CallbackTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallbackTestController>(() => CallbackTestController());
  }
}

/// 异步调用测试页依赖注入
class AsyncTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsyncTestController>(() => AsyncTestController());
  }
}

/// 长连接测试页依赖注入
class LongLinkTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LongLinkController>(() => LongLinkController());
  }
}
