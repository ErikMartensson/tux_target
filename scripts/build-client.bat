@echo off
REM
REM Build Tux Target Client (Windows)
REM
REM Prerequisites: Run setup-deps.ps1 first to install dependencies
REM
REM Usage:
REM   scripts\build-client.bat              - Build client
REM   scripts\build-client.bat --clean      - Clean build
REM   scripts\build-client.bat --skip-post-build  - Skip post-build setup
REM

setlocal enabledelayedexpansion

REM Setup MSVC environment if needed
call "%~dp0setup-msvc-env.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

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

REM Check dependencies (default: deps/ directory in repo)
set DEPS_PATH=%PROJECT_DIR%\deps
if defined TUXDEPS_PATH set DEPS_PATH=%TUXDEPS_PATH%
echo Dependencies path: %DEPS_PATH%

if not exist "%DEPS_PATH%\lua\lib\lua.lib" (
    echo.
    echo ERROR: Dependencies not found at %DEPS_PATH%
    echo Please run: scripts\setup-deps.bat
    echo.
    exit /b 1
)
echo Dependencies: OK
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

REM Set NeL path (check repo ryzomcore/ first, then env var, then default)
set NEL_PATH=
if exist "%PROJECT_DIR%\ryzomcore\build\lib\nelmisc_r.lib" (
    set NEL_PATH=%PROJECT_DIR%/ryzomcore/build
    echo Using local ryzomcore/
) else if defined NEL_PREFIX_PATH (
    set NEL_PATH=%NEL_PREFIX_PATH%
    echo Using NEL_PREFIX_PATH: %NEL_PREFIX_PATH%
) else if exist "C:\ryzomcore\build\lib\nelmisc_r.lib" (
    set NEL_PATH=C:/ryzomcore/build
    echo Using C:/ryzomcore/build
) else (
    echo.
    echo ERROR: RyzomCore/NeL not found!
    echo Please run: powershell -ExecutionPolicy Bypass -File scripts\setup-ryzomcore.ps1
    echo.
    exit /b 1
)
echo NeL path: %NEL_PATH%
echo.

REM Configure CMake using Ninja generator
echo Configuring CMake (Client)...
cmake .. ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_CLIENT=ON ^
    -DBUILD_SERVER=OFF ^
    -DWITH_STATIC=ON ^
    -DWITH_STATIC_CURL=ON ^
    -DNEL_PREFIX_PATH=%NEL_PATH% ^
    -DCMAKE_PREFIX_PATH=%DEPS_PATH% ^
    -DLUA_INCLUDE_DIR:PATH=%DEPS_PATH%/lua/include ^
    -DLUA_LIBRARIES:FILEPATH=%DEPS_PATH%/lua/lib/lua.lib ^
    -DLIBXML2_INCLUDE_DIR:PATH=%DEPS_PATH%/libxml2/include/libxml2 ^
    -DLIBXML2_LIBRARY:FILEPATH=%DEPS_PATH%/libxml2/lib/libxml2.lib ^
    -DZLIB_ROOT=%DEPS_PATH%/zlib ^
    -DZLIB_LIBRARY:FILEPATH=%DEPS_PATH%/zlib/lib/zlib.lib ^
    -DCURL_ROOT=%DEPS_PATH%/curl ^
    -DCURL_INCLUDE_DIR:PATH=%DEPS_PATH%/curl/include ^
    -DCURL_LIBRARY:FILEPATH=%DEPS_PATH%/curl/lib/libcurl_imp.lib ^
    -DCURL_LIBRARIES:FILEPATH=%DEPS_PATH%/curl/lib/libcurl_imp.lib ^
    -DOPENSSL_ROOT_DIR=%DEPS_PATH%/openssl ^
    -DFREETYPE_INCLUDE_DIRS:PATH=%DEPS_PATH%/freetype/include/freetype2 ^
    -DFREETYPE_LIBRARY:FILEPATH=%DEPS_PATH%/freetype/lib/freetype.lib ^
    -DPNG_PNG_INCLUDE_DIR:PATH=%DEPS_PATH%/libpng/include ^
    -DPNG_LIBRARY:FILEPATH=%DEPS_PATH%/libpng/lib/libpng16.lib ^
    -DJPEG_INCLUDE_DIR:PATH=%DEPS_PATH%/libjpeg/include ^
    -DJPEG_LIBRARY:FILEPATH=%DEPS_PATH%/libjpeg/lib/jpeg.lib ^
    -DVORBIS_LIBRARY:FILEPATH=%DEPS_PATH%/vorbis/lib/vorbis.lib ^
    -DVORBISFILE_LIBRARY:FILEPATH=%DEPS_PATH%/vorbis/lib/vorbisfile.lib ^
    -DOGG_LIBRARY:FILEPATH=%DEPS_PATH%/ogg/lib/ogg.lib

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    exit /b %ERRORLEVEL%
)
echo.

REM Build (Ninja uses all cores by default)
echo Building client...
cmake --build .

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo.
echo Build complete!

REM Check for executable (Ninja outputs to bin/, not bin/Release/)
if exist "%BUILD_DIR%\bin\tux-target.exe" (
    echo Client executable: %BUILD_DIR%\bin\tux-target.exe
) else (
    echo Warning: Client executable not found
)

REM Run post-build setup
if %SKIP_POST_BUILD%==0 (
    echo.
    echo Running post-build setup...
    call "%SCRIPT_DIR%post-build.bat" --client-only --build-dir "%BUILD_DIR%\bin"
)

echo.
echo =========================================
echo   Client build finished!
echo =========================================
echo.
echo To run the client:
echo   scripts\run-client.bat
echo.

endlocal
