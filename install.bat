@echo off
REM EEEYER Installer for Windows (CMD fallback)
REM Usage: curl -fsSL https://raw.githubusercontent.com/Eeeyer/ChaoxingExam/main/install.bat -o install.bat && install.bat

echo.
echo   EEEYER Installer (CMD)
echo   ======================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Python not found. Please install Python 3.8+
    echo   Download: https://www.python.org/downloads/
    exit /b 1
)

echo   [+] Python found
for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo   [+] %%i

set "INSTALL_DIR=%USERPROFILE%\.eeeeyr"
echo   [i] Install directory: %INSTALL_DIR%

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo   [i] Downloading EEEYER...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/Eeeyer/ChaoxingExam/archive/refs/heads/main.zip' -OutFile '%TEMP%\eeeeyr.zip' -UseBasicParsing"

echo   [i] Extracting...
powershell -Command "Expand-Archive -Path '%TEMP%\eeeeyr.zip' -DestinationPath '%TEMP%\eeeeyr-extract' -Force"

echo   [i] Installing...
robocopy "%TEMP%\eeeeyr-extract\ChaoxingExam-main" "%INSTALL_DIR%" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul

echo   [i] Setting up virtual environment...
python -m venv "%INSTALL_DIR%\venv"
"%INSTALL_DIR%\venv\Scripts\python.exe" -m pip install -r "%INSTALL_DIR%\requirements.txt" --quiet

REM Create wrapper
(
echo @echo off
echo chcp 65001 ^>nul 2^>^&1
echo call "%INSTALL_DIR%\venv\Scripts\python.exe" -m eeeeyr %%*
) > "%INSTALL_DIR%\er.bat"

echo   [+] Wrapper created: %INSTALL_DIR%\er.bat

REM Add to PATH
set "userPath="
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "userPath=%%b"
echo %userPath% | findstr /c:"%INSTALL_DIR%" >nul
if %ERRORLEVEL% NEQ 0 (
    echo   [i] Adding to PATH...
    setx PATH "%userPath%;%INSTALL_DIR%" >nul
    set "PATH=%PATH%;%INSTALL_DIR%"
    echo   [+] Added to PATH
)

REM Show banner
echo.
python -m eeeeyr --mini 2>nul || (
    echo   [EEEYER] Installed successfully!
)

del "%TEMP%\eeeeyr.zip" 2>nul
rmdir /s /q "%TEMP%\eeeeyr-extract" 2>nul

echo.
echo   EEEYER installed!
echo   Restart your terminal and run: er
echo.
