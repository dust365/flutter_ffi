cmake_minimum_required(VERSION 3.10)
project(native_lib)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置源文件
set(SOURCE_FILES
    src/native_lib.cpp
    src/long_link_manager.cpp
    src/long_link_worker.cpp
    src/long_link.cpp
)

# 创建动态库
add_library(native_lib SHARED ${SOURCE_FILES})

# 设置输出目录（根据平台不同）
if(ANDROID)
    # Android 平台 - 直接输出到 libs 目录
    set_target_properties(native_lib PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/libs/android/${ANDROID_ABI}"
    )
elseif(IOS)
    # iOS 平台
    set_target_properties(native_lib PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build/ios"
    )
elseif(APPLE)
    # macOS 平台
    set_target_properties(native_lib PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build/macos"
    )
elseif(WIN32)
    # Windows 平台
    set_target_properties(native_lib PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build/windows"
    )
elseif(UNIX)
    # Linux 平台
    set_target_properties(native_lib PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build/linux"
    )
endif()

# Windows 特殊处理：导出所有符号
if(WIN32)
    target_compile_definitions(native_lib PRIVATE BUILDING_DLL)
endif()

# 链接线程库（用于异步调用）
find_package(Threads REQUIRED)
target_link_libraries(native_lib PRIVATE Threads::Threads)

