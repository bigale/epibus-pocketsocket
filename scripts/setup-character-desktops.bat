@echo off
echo 🎭 AI-Kit Industrial IoT - Virtual Desktop Manager
echo ================================================
echo.
echo Select an option:
echo 1. Create all character desktops
echo 2. Interactive menu
echo 3. Create single character desktop
echo 4. Show navigation help only
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -CreateAll
) else if "%choice%"=="2" (
    powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Menu
) else if "%choice%"=="3" (
    echo.
    echo Available characters:
    echo 1. Kyoko - Investigation ^& Analysis
    echo 2. Byakuya - Quality Control  
    echo 3. Chihiro - System Integration
    echo 4. Celestia - UI/UX Design
    echo 5. Sakura - Reliability Testing
    echo.
    set /p char_choice="Select character (1-5): "
    
    if "%char_choice%"=="1" powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Character "Kyoko"
    if "%char_choice%"=="2" powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Character "Byakuya"
    if "%char_choice%"=="3" powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Character "Chihiro"
    if "%char_choice%"=="4" powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Character "Celestia"
    if "%char_choice%"=="5" powershell -ExecutionPolicy Bypass -File "%~dp0windows-virtual-desktops-simple.ps1" -Character "Sakura"
) else if "%choice%"=="4" (
    echo.
    echo 🎮 Virtual Desktop Navigation:
    echo • Ctrl + Win + Left/Right: Switch between desktops
    echo • Win + Tab: Open Task View to see all desktops
    echo • Ctrl + Win + D: Create new desktop
    echo • Ctrl + Win + F4: Close current desktop
    echo.
    echo 📋 Recommended Desktop Layout:
    echo Desktop 1: Main/Overview
    echo Desktop 2: Kyoko - Investigation ^& Analysis
    echo Desktop 3: Byakuya - Quality Control
    echo Desktop 4: Chihiro - System Integration
    echo Desktop 5: Celestia - UI/UX Design
    echo Desktop 6: Sakura - Reliability Testing
) else (
    echo Invalid choice.
)

echo.
pause
