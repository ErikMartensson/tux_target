@echo off
REM
REM Build Tux Target Client Only (Windows)
REM
REM This script builds only the game client to a separate build-client directory.
REM Usage: scripts\build-client.bat [--clean] [--skip-post-build]
REM

setlocal enabledelayedexpansion

REM Parse arguments
set CLEAN_BUILD=0
set SKIP_POST_BUILD=0
for %%a in (%*) do (
    if "%%a"=="--clean" set CLEAN_BUILD=1
    if "%%a"=="--skip-post-build" set SKIP_POST_BUILD=1
)

REM Determine directories
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..
set BUILD_DIR=%PROJECT_DIR%\build-client

echo =========================================
echo   Tux Target Client Build (Windows)
echo =========================================
echo.
echo Project directory: %PROJECT_DIR%
echo Build directory:   %BUILD_DIR%
echo.

REM Clean build if requested
if %CLEAN_BUILD%==1 (
    echo Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
)

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM Get number of processors
set NUM_CORES=%NUMBER_OF_PROCESSORS%
if "%NUM_CORES%"=="" set NUM_CORES=4
echo Using %NUM_CORES% CPU cores for build
echo.

REM Set dependency paths (check environment variables first, then use defaults)
if "%NEL_PREFIX_PATH%"=="" (
    set NEL_PREFIX_PATH=C:/ryzomcore/build
)
if "%TUXDEPS_PREFIX_PATH%"=="" (
    set TUXDEPS_PREFIX_PATH=C:/tux_target_deps
)

echo Dependency configuration:
echo   NEL_PREFIX_PATH: %NEL_PREFIX_PATH%
echo   TUXDEPS_PREFIX_PATH: %TUXDEPS_PREFIX_PATH%
echo.

REM Configure CMake with explicit paths for dependencies
echo Configuring CMake (Client only)...
cmake .. ^
    -G "Visual Studio 17 2022" ^
    -DBUILD_CLIENT=ON ^
    -DBUILD_SERVER=OFF ^
    -DWITH_STATIC=ON ^
    -DWITH_STATIC_LIBXML2=ON ^
    -DWITH_STATIC_CURL=ON ^
    -DNEL_PREFIX_PATH=%NEL_PREFIX_PATH% ^
    -DCMAKE_PREFIX_PATH=%TUXDEPS_PREFIX_PATH% ^
    -DCMAKE_LIBRARY_PATH=%NEL_PREFIX_PATH%/lib/Release;%TUXDEPS_PREFIX_PATH%/libpng/lib;%TUXDEPS_PREFIX_PATH%/libjpeg/lib;%TUXDEPS_PREFIX_PATH%/freetype/lib ^
    -DCMAKE_INCLUDE_PATH=C:/ryzomcore/nel/include;%TUXDEPS_PREFIX_PATH%/libpng/include;%TUXDEPS_PREFIX_PATH%/libjpeg/include;%TUXDEPS_PREFIX_PATH%/freetype/include ^
    -DNEL_INCLUDE_DIR=C:/ryzomcore/nel/include ^
    -DNEL_LIBRARY_DIR=%NEL_PREFIX_PATH%/lib/Release ^
    -DNELMISC_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelmisc_r.lib ^
    -DNELMISC_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelmisc_r.lib ^
    -DNEL3D_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nel3d_r.lib ^
    -DNEL3D_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nel3d_r.lib ^
    -DNELSOUND_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelsound_r.lib ^
    -DNELSOUND_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelsound_r.lib ^
    -DNELSNDDRV_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelsnd_lowlevel_r.lib ^
    -DNELSNDDRV_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelsnd_lowlevel_r.lib ^
    -DNELGEORGES_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelgeorges_r.lib ^
    -DNELGEORGES_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelgeorges_r.lib ^
    -DNELLIGO_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelligo_r.lib ^
    -DNELLIGO_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelligo_r.lib ^
    -DNELNET_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelnet_r.lib ^
    -DNELNET_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelnet_r.lib ^
    -DLIBXML2_INCLUDE_DIR=%TUXDEPS_PREFIX_PATH%/libxml2/include/libxml2 ^
    -DLIBXML2_LIBRARY=%TUXDEPS_PREFIX_PATH%/libxml2/lib/libxml2.lib ^
    -DZLIB_ROOT=%TUXDEPS_PREFIX_PATH%/zlib ^
    -DCURL_ROOT=%TUXDEPS_PREFIX_PATH%/curl ^
    -DOPENSSL_ROOT_DIR=%TUXDEPS_PREFIX_PATH%/openssl ^
    -DSSLEAY_LIBRARY=%TUXDEPS_PREFIX_PATH%/openssl/lib/libssl.lib ^
    -DEAY_LIBRARY=%TUXDEPS_PREFIX_PATH%/openssl/lib/libcrypto.lib ^
    -DLUA_INCLUDE_DIR=%TUXDEPS_PREFIX_PATH%/lua/include ^
    -DLUA_LIBRARIES=%TUXDEPS_PREFIX_PATH%/lua/lib/lua.lib

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    exit /b %ERRORLEVEL%
)
echo.

REM Build
echo Building client with %NUM_CORES% cores...
cmake --build . --config Release -- /m:%NUM_CORES%

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo Build complete!

REM Check for executable
if exist "%BUILD_DIR%\bin\Release\tux-target.exe" (
    echo Client executable: %BUILD_DIR%\bin\Release\tux-target.exe
) else (
    echo Warning: Client executable not found
)

REM Run post-build setup
if %SKIP_POST_BUILD%==0 (
    echo.
    echo Running post-build setup...
    call "%SCRIPT_DIR%post-build.bat" --client-only --build-dir "%BUILD_DIR%\bin\Release"
)

echo.
echo =========================================
echo   Client build finished!
echo =========================================
echo.
echo To run the client:
echo   cd %BUILD_DIR%\bin\Release
echo   tux-target.exe
echo.
echo Or use the run script with log rotation:
echo   scripts\run-client.bat

endlocal
