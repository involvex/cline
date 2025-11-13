@echo off
echo Installing Cline CLI globally...

:: Create the installation directory
if not exist "%USERPROFILE%\.cline\bin" mkdir "%USERPROFILE%\.cline\bin"

:: Copy the CLI binary
copy "dist-standalone\bin\cline.exe" "%USERPROFILE%\.cline\bin\cline.exe" >nul 2>&1
if errorlevel 1 (
    echo Error: Could not copy CLI binary. Make sure dist-standalone\bin\cline.exe exists.
    echo Run 'npm run build:cli' first if it doesn't exist.
    pause
    exit /b 1
)

:: Add to PATH
setx PATH "%USERPROFILE%\.cline\bin;%PATH%" >nul 2>&1
if errorlevel 1 (
    echo Warning: Could not add to permanent PATH. You may need to add %USERPROFILE%\.cline\bin to PATH manually.
) else (
    echo Added to PATH permanently.
)

echo.
echo Cline CLI installed successfully!
echo Location: %USERPROFILE%\.cline\bin\cline.exe
echo.
echo IMPORTANT: Restart PowerShell/Command Prompt and run:
echo   cline version
echo.
echo Or run a task:
echo   cline "Create a hello world script"
echo.
pause
