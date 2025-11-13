@echo off
setlocal enabledelayedexpansion

npm run protos
npm run protos-go

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

REM Define target platforms for cross-compilation
set PLATFORMS[0]=darwin/arm64
set PLATFORMS[1]=darwin/amd64
set PLATFORMS[2]=linux/amd64
set PLATFORMS[3]=linux/arm64
set PLATFORMS[4]=windows/amd64

REM Build binaries for all platforms
for /L %%i in (0,1,4) do (
    set "platform=!PLATFORMS[%%i]!"
    for /f "tokens=1,2 delims=/" %%a in ("!platform!") do (
        set GOOS=%%a
        set GOARCH=%%b
    )

    echo Building for !GOOS!/!GOARCH!...

    REM Build cline binary
    if "!GOOS!"=="windows" (
        set OUTPUT_NAME=bin\cline-!GOOS!-!GOARCH!.exe
    ) else (
        set OUTPUT_NAME=bin\cline-!GOOS!-!GOARCH!
    )

    set GO111MODULE=on
    set GOOS=!GOOS!
    set GOARCH=!GOARCH!
    go build -ldflags "%LDFLAGS%" -o "!OUTPUT_NAME!" .\cmd\cline
    if !errorlevel! neq 0 exit /b !errorlevel!
    echo   ✓ !OUTPUT_NAME! built

    REM Build cline-host binary
    if "!GOOS!"=="windows" (
        set OUTPUT_NAME=bin\cline-host-!GOOS!-!GOARCH!.exe
    ) else (
        set OUTPUT_NAME=bin\cline-host-!GOOS!-!GOARCH!
    )

    go build -ldflags "%LDFLAGS%" -o "!OUTPUT_NAME!" .\cmd\cline-host
    if !errorlevel! neq 0 exit /b !errorlevel!
    echo   ✓ !OUTPUT_NAME! built
)

echo.
echo All platform binaries built successfully!

REM Copy binaries to dist-standalone/bin
cd ..
mkdir dist-standalone\bin 2>nul
copy cli\bin\cline-* dist-standalone\bin\
echo Copied all platform binaries to dist-standalone\bin\
