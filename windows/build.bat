@echo off
rem MAVProxy Build Script

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "LOG_FILE=%SCRIPT_DIR%\build.log"
set "VENV_DIR=%SCRIPT_DIR%\venv"

echo ========================================== > "%LOG_FILE%"
echo MAVProxy Build Started at %date% %time% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"

echo ==========================================
echo MAVProxy Build Script
echo ==========================================

echo [INFO] Checking Python...
echo [INFO] Checking Python... >> "%LOG_FILE%"

where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found
    echo [ERROR] Python not found >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] Python found >> "%LOG_FILE%"

rem Create venv if not exists
if not exist "%VENV_DIR%" (
    echo [INFO] Creating virtual environment at %VENV_DIR%...
    echo [INFO] Creating virtual environment... >> "%LOG_FILE%"
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        echo [ERROR] Failed to create venv >> "%LOG_FILE%"
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created >> "%LOG_FILE%"
) else (
    echo [OK] Virtual environment already exists at %VENV_DIR% >> "%LOG_FILE%"
)

set "VENV_PYTHON=%VENV_DIR%\Scripts\python.exe"
set "VENV_PIP=%VENV_DIR%\Scripts\pip.exe"

echo [INFO] VENV_PYTHON=%VENV_PYTHON% >> "%LOG_FILE%"
echo [INFO] VENV_PIP=%VENV_PIP% >> "%LOG_FILE%"
echo [INFO] Venv paths:
echo    PYTHON: %VENV_PYTHON%
echo    PIP: %VENV_PIP%

if not exist "%VENV_PYTHON%" (
    echo [ERROR] Venv Python not found: %VENV_PYTHON%
    echo [ERROR] Venv Python not found >> "%LOG_FILE%"
    pause
    exit /b 1
)

rem Get version
echo [INFO] Getting version info from returnVersion.py... >> "%LOG_FILE%"
echo [INFO] Getting version...
for /f "tokens=*" %%a in ('"%VENV_PYTHON%" returnVersion.py') do set "VERSION=%%a"
echo [INFO] Version=%VERSION% >> "%LOG_FILE%"
echo Current Version: %VERSION%
echo.

rem Install MAVProxy - must run from parent dir where setup.py exists
rem Use non-editable install so PyInstaller can find and package all modules
cd /d "%SCRIPT_DIR%\.."
echo [INFO] [1/4] Installing MAVProxy (cwd: %cd%)... >> "%LOG_FILE%"
echo [INFO] [1/4] Installing MAVProxy (non-editable)...
"%VENV_PIP%" uninstall -y MAVProxy >> "%LOG_FILE%" 2>&1
"%VENV_PIP%" install . >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] MAVProxy installation failed
    echo [ERROR] MAVProxy install failed >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] MAVProxy installed >> "%LOG_FILE%"
echo.

rem Install runtime dependencies
echo [INFO] [2/4] Installing runtime dependencies (pyserial, pymavlink, wxpython, matplotlib, python-dateutil, pygame, setuptools)... >> "%LOG_FILE%"
echo [INFO] [2/4] Installing runtime dependencies...
"%VENV_PIP%" install pyserial pymavlink wxpython matplotlib python-dateutil pygame "setuptools<81" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [WARN] Some dependencies failed to install, continuing...
    echo [WARN] Some deps failed >> "%LOG_FILE%"
) else (
    echo [OK] Runtime dependencies installed >> "%LOG_FILE%"
)
echo.

rem Install PyInstaller
echo [INFO] [3/4] Installing PyInstaller... >> "%LOG_FILE%"
echo [INFO] [3/4] Installing PyInstaller...
"%VENV_PYTHON%" -m ensurepip --upgrade >> "%LOG_FILE%" 2>&1
"%VENV_PIP%" install pyinstaller >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] PyInstaller installation failed
    echo [ERROR] PyInstaller install failed >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo [OK] PyInstaller installed >> "%LOG_FILE%"
echo.

rem Build executable
echo [INFO] [4/4] Building executable... >> "%LOG_FILE%"
echo [INFO] [4/4] Building executable...

cd /d "%SCRIPT_DIR%\.."

rem Restore mavproxy.spec from git if missing
if not exist "windows\mavproxy.spec" (
    echo [INFO] Restoring mavproxy.spec from git... >> "%LOG_FILE%"
    git checkout -- windows/mavproxy.spec >> "%LOG_FILE%" 2>&1
)

echo [INFO] Copying mavproxy.spec to MAVProxy... >> "%LOG_FILE%"
copy windows\mavproxy.spec MAVProxy\ /Y >> "%LOG_FILE%" 2>&1

cd /d "%SCRIPT_DIR%\..\MAVProxy"
echo [INFO] Running PyInstaller... >> "%LOG_FILE%"
echo [INFO] Running PyInstaller...

"%VENV_PYTHON%" -m PyInstaller -y --clean mavproxy.spec >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo [ERROR] Build failed
    echo [ERROR] Build failed >> "%LOG_FILE%"
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)

echo [OK] Build completed >> "%LOG_FILE%"

cd /d "%SCRIPT_DIR%"

echo.
echo ==========================================
echo Build Completed!
echo Output: MAVProxy\dist\
echo ==========================================
echo.
echo Log: %LOG_FILE%
echo [INFO] Build finished at %date% %time% >> "%LOG_FILE%"

pause
