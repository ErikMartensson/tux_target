@echo off
REM Post-Build Setup Script for Tux Target (Windows)
REM
REM This script copies all required runtime files to the build directory
REM after compiling the client and server.
REM
REM Usage: scripts\post_build.bat

echo =========================================
echo Tux Target Post-Build Setup
echo =========================================
echo.

set RYZOMCORE_DIR=C:\ryzomcore
set PROJECT_DIR=%~dp0..
set RELEASE_DIR=%PROJECT_DIR%\build\bin\Release

if not exist "%RELEASE_DIR%" (
    echo Error: Build directory not found: %RELEASE_DIR%
    echo Please build the project first with: cd build ^&^& cmake --build . --config Release
    exit /b 1
)

echo Build directory: %RELEASE_DIR%
echo.

REM 1. Copy NeL Driver DLLs
echo 1. Copying NeL driver DLLs...
if exist "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_opengl_win_r.dll" (
    copy /Y "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_opengl_win_r.dll" "%RELEASE_DIR%\" >nul
    echo    - Copied: nel_drv_opengl_win_r.dll
) else (
    echo    ! Missing: nel_drv_opengl_win_r.dll
)

if exist "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_openal_win_r.dll" (
    copy /Y "%RYZOMCORE_DIR%\build\bin\Release\nel_drv_openal_win_r.dll" "%RELEASE_DIR%\" >nul
    echo    - Copied: nel_drv_openal_win_r.dll
) else (
    echo    ! Missing: nel_drv_openal_win_r.dll
)
echo.

REM 2. Copy Font Files
echo 2. Copying font files...
if not exist "%RELEASE_DIR%\data\font" mkdir "%RELEASE_DIR%\data\font"

if exist "%RYZOMCORE_DIR%\nel\samples\3d\cegui\datafiles\n019003l.pfb" (
    copy /Y "%RYZOMCORE_DIR%\nel\samples\3d\cegui\datafiles\n019003l.pfb" "%RELEASE_DIR%\data\font\" >nul
    echo    - Copied: n019003l.pfb
) else (
    echo    ! Missing: n019003l.pfb
)

if exist "%RYZOMCORE_DIR%\nel\samples\3d\font\beteckna.ttf" (
    copy /Y "%RYZOMCORE_DIR%\nel\samples\3d\font\beteckna.ttf" "%RELEASE_DIR%\data\font\bigfont.ttf" >nul
    echo    - Copied: bigfont.ttf
) else (
    echo    ! Missing: beteckna.ttf
)
echo.

REM 3. Create required directories
echo 3. Creating directory structure...
if not exist "%RELEASE_DIR%\data\level" mkdir "%RELEASE_DIR%\data\level"
if not exist "%RELEASE_DIR%\data\lua" mkdir "%RELEASE_DIR%\data\lua"
if not exist "%RELEASE_DIR%\data\shape" mkdir "%RELEASE_DIR%\data\shape"
if not exist "%RELEASE_DIR%\data\sound" mkdir "%RELEASE_DIR%\data\sound"
if not exist "%RELEASE_DIR%\data\misc" mkdir "%RELEASE_DIR%\data\misc"
if not exist "%RELEASE_DIR%\data\particle" mkdir "%RELEASE_DIR%\data\particle"
if not exist "%RELEASE_DIR%\data\smiley" mkdir "%RELEASE_DIR%\data\smiley"
echo    - Directory structure created
echo.

REM 4. Copy corrected data files
echo 4. Copying corrected data files...

REM Copy corrected config file
if exist "%PROJECT_DIR%\data\config\mtp_target_default.cfg" (
    copy /Y "%PROJECT_DIR%\data\config\mtp_target_default.cfg" "%RELEASE_DIR%\" >nul
    echo    - Copied: mtp_target_default.cfg (with water fix)
) else if exist "%PROJECT_DIR%\client\mtp_target_default.cfg" (
    copy /Y "%PROJECT_DIR%\client\mtp_target_default.cfg" "%RELEASE_DIR%\" >nul
    echo    ! Warning: Using original config (may need water fix)
)

REM Copy server config if not exists
if not exist "%RELEASE_DIR%\mtp_target_service.cfg" (
    if exist "%PROJECT_DIR%\server\mtp_target_service_default.cfg" (
        copy /Y "%PROJECT_DIR%\server\mtp_target_service_default.cfg" "%RELEASE_DIR%\mtp_target_service.cfg" >nul
        echo    - Copied: mtp_target_service.cfg
    )
)
echo.

REM 5. Copy corrected level files
echo 5. Copying corrected level files...
if exist "%PROJECT_DIR%\data\level" (
    copy /Y "%PROJECT_DIR%\data\level\*.lua" "%RELEASE_DIR%\data\level\" >nul 2>nul
    for /f %%a in ('dir /b "%RELEASE_DIR%\data\level\*.lua" 2^>nul ^| find /c /v ""') do set LEVEL_COUNT=%%a
    echo    - Copied %LEVEL_COUNT% level files (with fixed ServerLua paths)
) else (
    echo    ! Warning: Corrected level files not found
)
echo.

REM 6. Copy corrected skybox
echo 6. Copying corrected skybox...
if exist "%PROJECT_DIR%\data\shape\sky.shape" (
    copy /Y "%PROJECT_DIR%\data\shape\sky.shape" "%RELEASE_DIR%\data\shape\" >nul
    echo    - Copied: sky.shape (snow variant)
) else (
    echo    ! Warning: Corrected skybox not found
)
echo.

REM 7. Verify executables
echo 7. Verifying executables...
if exist "%RELEASE_DIR%\tux-target.exe" (
    echo    - Client: tux-target.exe
) else (
    echo    ! Client executable not found
)

if exist "%RELEASE_DIR%\tux-target-srv.exe" (
    echo    - Server: tux-target-srv.exe
) else (
    echo    ! Server executable not found
)
echo.

echo =========================================
echo Post-Build Setup Complete!
echo =========================================
echo.
echo Next steps:
echo   1. Check user config: C:\Users\User\AppData\Roaming\tux-target.cfg
echo   2. Start login service: cd login-service-deno ^&^& deno task login
echo   3. Start server: cd %RELEASE_DIR% ^&^& tux-target-srv.exe
echo   4. Start client: cd %RELEASE_DIR% ^&^& tux-target.exe
echo.
echo Controls:
echo   - Arrow keys: Steer penguin (requires speed in ball mode)
echo   - CTRL: Toggle ball/gliding modes
echo   - Enter: Open chat (press again to send)
echo.
echo For troubleshooting, see: docs\RUNTIME_FIXES.md
pause
