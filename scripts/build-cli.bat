@echo off
setlocal enabledelayedexpansion

echo Running npm run protos...
call npm run protos
echo protos errorlevel: %errorlevel%
if %errorlevel% neq 0 exit /b %errorlevel%

echo Running npm run protos-go...
call npm run protos-go
echo protos-go errorlevel: %errorlevel%
if %errorlevel% neq 0 exit /b %errorlevel%

mkdir dist-standalone\extension 2>nul
copy package.json dist-standalone\extension\

REM Extract version information for ldflags
for /f "delims=" %%i in ('node -p "require('./package.json').version"') do set CORE_VERSION=%%i
for /f "delims=" %%i in ('node -p "require('./cli/package.json').version"') do set CLI_VERSION=%%i
for /f "delims=" %%i in ('git rev-parse --short HEAD 2^>nul ^|^| echo unknown') do set COMMIT=%%i

REM Get current date/time in ISO format
for /f "delims=" %%i in ('powershell -command "Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'"') do set DATE=%%i
set BUILT_BY=%USERNAME%
if "%BUILT_BY%"=="" set BUILT_BY=unknown

REM Build ldflags to inject version info
set LDFLAGS=-X 'github.com/cline/cli/pkg/cli/global.Version=%CORE_VERSION%' -X 'github.com/cline/cli/pkg/cli/global.CliVersion=%CLI_VERSION%' -X 'github.com/cline/cli/pkg/cli/global.Commit=%COMMIT%' -X 'github.com/cline/cli/pkg/cli/global.Date=%DATE%' -X 'github.com/cline/cli/pkg/cli/global.BuiltBy=%BUILT_BY%'

cd cli

REM Detect current platform
set OS=windows
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set ARCH=amd64
) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set ARCH=arm64
) else (
    set ARCH=amd64
)

echo Building for current platform (%OS%-%ARCH%)...

set GO111MODULE=on
go build -ldflags "%LDFLAGS%" -o bin\cline.exe .\cmd\cline
if %errorlevel% neq 0 exit /b %errorlevel%
echo   ✓ bin\cline.exe built (includes both CLI and host functionality)

echo.
echo Build complete for current platform!

REM Copy binaries to dist-standalone/bin with platform-specific names AND generic names
cd ..
mkdir dist-standalone\bin 2>nul
copy cli\bin\cline.exe dist-standalone\bin\cline.exe
copy cli\bin\cline.exe dist-standalone\bin\cline-%OS%-%ARCH%.exe
REM Copy the same binary as cline-host (bundled functionality)
copy cli\bin\cline.exe dist-standalone\bin\cline-host.exe
copy cli\bin\cline.exe dist-standalone\bin\cline-host-%OS%-%ARCH%.exe
echo Copied binaries to dist-standalone\bin\ (both generic and platform-specific names)
