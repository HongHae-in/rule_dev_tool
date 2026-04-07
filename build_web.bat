@echo off
echo ========================================
echo Building Flutter Web Application...
echo ========================================

call flutter build web

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b 1
)

echo.
echo ========================================
echo Packaging Web Application...
echo ========================================

set BUILD_DIR=build\web
set OUTPUT_FILE=rule_dev_tool_web.zip

if exist "%OUTPUT_FILE%" (
    echo Removing existing package...
    del "%OUTPUT_FILE%"
)

echo Creating package: %OUTPUT_FILE%
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath '%OUTPUT_FILE%' -Force"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Package created successfully!
    echo Location: %OUTPUT_FILE%
    echo ========================================
) else (
    echo.
    echo Failed to create package!
    exit /b 1
)

echo.
echo To deploy, extract the zip file and upload the contents to your web server.
