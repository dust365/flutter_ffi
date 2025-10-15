@echo off
REM Flutter FFI Demo - Native Library Build Script for Windows
REM 用于编译 Windows 平台的原生库

echo =====================================
echo Flutter FFI Demo - 原生库构建脚本
echo =====================================
echo.

set SCRIPT_DIR=%~dp0
set NATIVE_DIR=%SCRIPT_DIR%native
set BUILD_DIR=%NATIVE_DIR%\build\windows

echo 编译 Windows 版本...
echo.

REM 创建构建目录
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

cd /d "%BUILD_DIR%"

REM 配置 CMake
cmake ..\.. -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 17 2022" -A x64
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 尝试使用其他版本的 Visual Studio...
    cmake ..\.. -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 16 2019" -A x64
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo 错误：未找到合适的 Visual Studio 版本
        echo 请确保已安装 Visual Studio 2019 或 2022，并包含 C++ 工具
        pause
        exit /b 1
    )
)

REM 编译
cmake --build . --config Release
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 错误：编译失败
    pause
    exit /b 1
)

echo.
echo =====================================
echo 构建完成！
echo =====================================
echo.
echo 接下来可以运行:
echo   flutter run -d windows
echo.
pause

