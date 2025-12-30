@echo off
REM
REM Build Tux Target Server Only (Windows)
REM
REM This script builds only the game server to a separate build-server directory.
REM Usage: scripts\build-server.bat [--clean] [--skip-post-build]
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
set BUILD_DIR=%PROJECT_DIR%\build-server

echo =========================================
echo   Tux Target Server Build (Windows)
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
echo Configuring CMake (Server only)...
cmake .. ^
    -G "Visual Studio 17 2022" ^
    -DBUILD_CLIENT=OFF ^
    -DBUILD_SERVER=ON ^
    -DNEL_PREFIX_PATH=%NEL_PREFIX_PATH% ^
    -DCMAKE_PREFIX_PATH=%TUXDEPS_PREFIX_PATH% ^
    -DCMAKE_LIBRARY_PATH=%NEL_PREFIX_PATH%/lib/Release ^
    -DCMAKE_INCLUDE_PATH=C:/ryzomcore/nel/include ^
    -DNEL_INCLUDE_DIR=C:/ryzomcore/nel/include ^
    -DNEL_LIBRARY_DIR=%NEL_PREFIX_PATH%/lib/Release ^
    -DNELMISC_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelmisc_r.lib ^
    -DNELMISC_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelmisc_r.lib ^
    -DNEL3D_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nel3d_r.lib ^
    -DNEL3D_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nel3d_r.lib ^
    -DNELNET_LIBRARY=%NEL_PREFIX_PATH%/lib/Release/nelnet_r.lib ^
    -DNELNET_LIBRARY_DEBUG=%NEL_PREFIX_PATH%/lib/Release/nelnet_r.lib ^
    -DLIBXML2_INCLUDE_DIR=%TUXDEPS_PREFIX_PATH%/libxml2/include/libxml2 ^
    -DLIBXML2_LIBRARY=%TUXDEPS_PREFIX_PATH%/libxml2/lib/libxml2.lib ^
    -DZLIB_ROOT=%TUXDEPS_PREFIX_PATH%/zlib ^
    -DODE_INCLUDE_DIR=%TUXDEPS_PREFIX_PATH%/ode/include ^
    -DODE_LIBRARY=%TUXDEPS_PREFIX_PATH%/ode/lib/ode_doubles.lib ^
    -DPNG_LIBRARY=%TUXDEPS_PREFIX_PATH%/libpng/lib/libpng16.lib ^
    -DJPEG_LIBRARY=%TUXDEPS_PREFIX_PATH%/libjpeg/lib/jpeg.lib ^
    -DFREETYPE_LIBRARY=%TUXDEPS_PREFIX_PATH%/freetype/lib/freetype.lib ^
    -DLUA_INCLUDE_DIR=%TUXDEPS_PREFIX_PATH%/lua/include ^
    -DLUA_LIBRARIES=%TUXDEPS_PREFIX_PATH%/lua/lib/lua.lib

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    exit /b %ERRORLEVEL%
)
echo.

REM Build
echo Building server with %NUM_CORES% cores...
cmake --build . --config Release -- /m:%NUM_CORES%

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo Build complete!

REM Check for executable
if exist "%BUILD_DIR%\bin\Release\tux-target-srv.exe" (
    echo Server executable: %BUILD_DIR%\bin\Release\tux-target-srv.exe
) else (
    echo Warning: Server executable not found
)

REM Run post-build setup
if %SKIP_POST_BUILD%==0 (
    echo.
    echo Running post-build setup...
    call "%SCRIPT_DIR%post-build.bat" --server-only --build-dir "%BUILD_DIR%\bin\Release"
)

echo.
echo =========================================
echo   Server build finished!
echo =========================================
echo.
echo To run the server:
echo   cd %BUILD_DIR%\bin\Release
echo   tux-target-srv.exe
echo.
echo Or use the run script with log rotation:
echo   scripts\run-server.bat

endlocal
