@echo off
setlocal enabledelayedexpansion

echo.
echo ============================================
echo   Photo Essay Skill Installer for Windows
echo ============================================
echo.
echo This will install the Photo Essay skill for Claude Code.
echo It turns your photos into magazine-style HTML documents.
echo.

:: -------------------------------------------
:: 1. Check for Python
:: -------------------------------------------
set "PYTHON_CMD="

python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    goto :found_python
)

py --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=py"
    goto :found_python
)

echo ERROR: Python 3 is not installed or not on your PATH.
echo.
echo To install Python:
echo   1. Open the Microsoft Store
echo   2. Search for "Python 3.12"
echo   3. Click "Get" (it's free)
echo   4. After install, close this window and double-click this file again
echo.
goto :done

:found_python
echo [OK] Found Python: %PYTHON_CMD%

:: -------------------------------------------
:: 2. Check for pip
:: -------------------------------------------
%PYTHON_CMD% -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: pip is not available.
    echo.
    echo Try reinstalling Python from the Microsoft Store, or run:
    echo   %PYTHON_CMD% -m ensurepip
    echo.
    goto :done
)
echo [OK] Found pip

:: -------------------------------------------
:: 3. Set target directory
:: -------------------------------------------
set "SKILL_DIR=%USERPROFILE%\.claude\skills\photo-essay"

if exist "%SKILL_DIR%\skills\photo-essay\SKILL.md" (
    echo.
    echo The skill is already installed at:
    echo   %SKILL_DIR%
    echo.
    choice /C YN /M "Reinstall? (Y=Yes, N=Skip to dependency install)"
    if !errorlevel! equ 2 goto :install_deps
    echo Removing old installation...
    rmdir /S /Q "%SKILL_DIR%" 2>nul
)

:: -------------------------------------------
:: 4. Download the skill
:: -------------------------------------------
echo.
echo Downloading Photo Essay skill...

:: Create parent directory
if not exist "%USERPROFILE%\.claude\skills" (
    mkdir "%USERPROFILE%\.claude\skills"
)

:: Try git first
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Using git...
    git clone https://github.com/Proofbound/photo-essay-skill.git "%SKILL_DIR%"
    if !errorlevel! neq 0 (
        echo ERROR: git clone failed. Check your internet connection.
        goto :done
    )
    goto :download_done
)

:: Fall back to PowerShell zip download
echo Git not found, downloading zip instead...
set "ZIP_FILE=%TEMP%\photo-essay-skill.zip"
set "EXTRACT_DIR=%TEMP%\photo-essay-extract"

powershell -Command "Invoke-WebRequest -Uri 'https://github.com/Proofbound/photo-essay-skill/archive/refs/heads/main.zip' -OutFile '%ZIP_FILE%'" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Download failed. Check your internet connection.
    echo.
    echo You can also download manually:
    echo   1. Go to https://github.com/Proofbound/photo-essay-skill
    echo   2. Click "Code" then "Download ZIP"
    echo   3. Extract to: %SKILL_DIR%
    goto :done
)

echo Extracting...
if exist "%EXTRACT_DIR%" rmdir /S /Q "%EXTRACT_DIR%"
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"
if %errorlevel% neq 0 (
    echo ERROR: Failed to extract the download.
    goto :done
)

:: Move from the subfolder GitHub creates
xcopy "%EXTRACT_DIR%\photo-essay-skill-main\*" "%SKILL_DIR%\" /E /I /Y >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy files to skill directory.
    goto :done
)

:: Clean up temp files
del "%ZIP_FILE%" 2>nul
rmdir /S /Q "%EXTRACT_DIR%" 2>nul

:download_done
echo [OK] Skill downloaded to %SKILL_DIR%

:: -------------------------------------------
:: 5. Install Python dependencies
:: -------------------------------------------
:install_deps
echo.
echo Installing Python packages (Pillow, pillow-heif)...
%PYTHON_CMD% -m pip install Pillow pillow-heif -q
if %errorlevel% neq 0 (
    echo.
    echo WARNING: pip install had errors. Trying again without quiet mode:
    %PYTHON_CMD% -m pip install Pillow pillow-heif
)

:: -------------------------------------------
:: 6. Verify installation
:: -------------------------------------------
echo.
echo Verifying...

set "VERIFY_OK=1"

if not exist "%SKILL_DIR%\skills\photo-essay\SKILL.md" (
    echo [!!] Skill files not found at expected location.
    set "VERIFY_OK=0"
)

%PYTHON_CMD% -c "from PIL import Image; print('[OK] Pillow')" 2>nul
if %errorlevel% neq 0 (
    echo [!!] Pillow package not working
    set "VERIFY_OK=0"
)

%PYTHON_CMD% -c "import pillow_heif; print('[OK] HEIC support')" 2>nul
if %errorlevel% neq 0 (
    echo [!!] HEIC support not working (iPhone photos may not work)
    echo     This is optional - the skill will still work with JPEG and PNG.
)

echo.
if "%VERIFY_OK%"=="1" (
    echo ============================================
    echo   Installation complete!
    echo ============================================
    echo.
    echo To use it, open Claude Code and say:
    echo.
    echo   "Make a photo essay from C:\Users\%USERNAME%\Photos\my-trip"
    echo.
    echo Replace the path with wherever your photos are.
) else (
    echo Installation may have issues. See errors above.
    echo For manual install steps, see WINDOWS-INSTALL.md
)

:done
echo.
pause
