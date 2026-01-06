@echo off
REM Setup MSVC environment if not already configured
REM This script is called by build-client.bat and build-server.bat

REM Check if cl.exe is already available
where cl >nul 2>nul
if %ERRORLEVEL%==0 goto :eof

echo MSVC compiler not in PATH, searching for Visual Studio...

REM Try common VS 2022 installation paths
set "VCVARS="

REM VS 2022 Build Tools
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    set "VCVARS=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    goto found
)

REM VS 2022 Community
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VCVARS=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    goto found
)

REM VS 2022 Professional
if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    set "VCVARS=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
    goto found
)

REM VS 2022 Enterprise
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    set "VCVARS=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    goto found
)

REM Try using vswhere if available
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
        if exist "%%i\VC\Auxiliary\Build\vcvars64.bat" (
            set "VCVARS=%%i\VC\Auxiliary\Build\vcvars64.bat"
            goto found
        )
    )
)

echo.
echo ERROR: Visual Studio 2022 with C++ tools not found!
echo Please install Visual Studio 2022 Build Tools with "Desktop development with C++"
echo Download from: https://visualstudio.microsoft.com/downloads/
exit /b 1

:found
echo Found: %VCVARS%
echo Setting up MSVC environment...
call "%VCVARS%" >nul
if %ERRORLEVEL% neq 0 (
    echo Failed to set up MSVC environment
    exit /b 1
)
echo MSVC environment configured successfully
