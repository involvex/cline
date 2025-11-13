@echo off
setlocal enabledelayedexpansion

:: Colors for Windows CMD
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "MAGENTA=[95m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

:: Configuration
set "INSTALL_DIR=%USERPROFILE%\.cline\bin"
set "SOURCE_DIR=dist-standalone\bin"

:: Print colored message
:print_message
set "color=%~1"
set "message=%~2"
echo %color%%message%%RESET%
goto :eof

:: Print step
:print_step
set "message=%~1"
call :print_message "%CYAN%" "→ %message%"
goto :eof

:: Print success
:print_ok
set "message=%~1"
call :print_message "%GREEN%" "✓ %message%"
goto :eof

:: Print error
:print_error
set "message=%~1"
call :print_message "%RED%" "✗ %message%"
goto :eof

:main
echo.
call :print_message "%MAGENTA%" "╔══════════════════════════════════════╗"
call :print_message "%MAGENTA%" "║           CLINE INSTALLER            ║"
call :print_message "%MAGENTA%" "╚══════════════════════════════════════╝"
echo.

:: Check if source exists
if not exist "%SOURCE_DIR%" (
    call :print_error "Source directory %SOURCE_DIR% not found"
    call :print_error "Please run 'npm run build:cli' first"
    exit /b 1
)

:: Check if CLI binary exists
if not exist "%SOURCE_DIR%\cline.exe" (
    call :print_error "CLI binary not found at %SOURCE_DIR%\cline.exe"
    call :print_error "Please run 'npm run build:cli' first"
    exit /b 1
)

call :print_step "Installing Cline CLI locally"

:: Create install directory
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" 2>nul
    if errorlevel 1 (
        call :print_error "Failed to create directory %INSTALL_DIR%"
        exit /b 1
    )
)

:: Copy CLI binary
copy "%SOURCE_DIR%\cline.exe" "%INSTALL_DIR%\" >nul 2>&1
if errorlevel 1 (
    call :print_error "Failed to copy CLI binary"
    exit /b 1
)

call :print_ok "CLI binary installed to %INSTALL_DIR%"

:: Check if already in PATH
echo %PATH% | findstr /C:"%INSTALL_DIR%" >nul 2>&1
if %errorlevel% equ 0 (
    call :print_ok "CLI already in PATH"
) else (
    call :print_step "Adding to PATH"

    :: Try to add to user PATH permanently
    setx PATH "%INSTALL_DIR%;%PATH%" >nul 2>&1
    if errorlevel 1 (
        call :print_message "%YELLOW%" "Warning: Could not add to permanent PATH"
        call :print_message "%YELLOW%" "You may need to add %INSTALL_DIR% to your PATH manually"
        call :print_message "%YELLOW%" "Or run this command as Administrator"
    ) else (
        call :print_ok "Added to PATH permanently"
    )

    :: Also set for current session
    set "PATH=%INSTALL_DIR%;%PATH%"
)

:: Verify installation
call :print_step "Verifying installation"

"%INSTALL_DIR%\cline.exe" version >nul 2>&1
if errorlevel 1 (
    call :print_error "CLI verification failed"
    exit /b 1
)

call :print_ok "Installation verified"

:: Success message
echo.
call :print_message "%GREEN%" "╔══════════════════════════════════════╗"
call :print_message "%GREEN%" "║        INSTALLATION COMPLETE         ║"
call :print_message "%GREEN%" "╚══════════════════════════════════════╝"
echo.
call :print_message "%WHITE%" "Cline CLI is now available globally!"
echo.
call :print_message "%CYAN%" "Run this to test:"
echo.
call :print_message "%YELLOW%" "    cline version"
echo.
call :print_message "%CYAN%" "Or run a task:"
echo.
call :print_message "%YELLOW%" "    cline ""Create a hello world script"""
echo.

goto :eof
