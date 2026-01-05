#
# Tux Target CMake Configuration
#
# Shared CMake variable definitions for both local builds and CI.
# This ensures consistent paths between environments.
#
# Usage:
#   . .\scripts\cmake-config.ps1
#   $cmakeArgs = Get-ClientCMakeArgs
#   cmake .. @cmakeArgs
#

param(
    [string]$DepsPath = $null,
    [string]$NelPath = $null
)

# Load manifest for path defaults
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/deps-manifest.ps1"

# Determine paths
if (!$DepsPath) {
    $DepsPath = Get-DepsPath
}
if (!$NelPath) {
    $NelPath = if ($env:NEL_PREFIX_PATH) { $env:NEL_PREFIX_PATH } else { "C:/ryzomcore/build" }
}

# Normalize paths (forward slashes for CMake)
$DepsPath = $DepsPath -replace '\\', '/'
$NelPath = $NelPath -replace '\\', '/'

function Get-CommonCMakeArgs {
    param([string]$Deps = $DepsPath, [string]$Nel = $NelPath)

    return @(
        "-DNEL_PREFIX_PATH=$Nel",
        "-DCMAKE_PREFIX_PATH=$Deps",
        "-DLUA_INCLUDE_DIR:PATH=$Deps/lua/include",
        "-DLUA_LIBRARIES:FILEPATH=$Deps/lua/lib/lua.lib",
        "-DLIBXML2_INCLUDE_DIR:PATH=$Deps/libxml2/include/libxml2",
        "-DLIBXML2_LIBRARY:FILEPATH=$Deps/libxml2/lib/libxml2.lib",
        "-DZLIB_ROOT=$Deps/zlib",
        "-DZLIB_LIBRARY:FILEPATH=$Deps/zlib/lib/zlib.lib",
        "-DFREETYPE_INCLUDE_DIRS:PATH=$Deps/freetype/include/freetype2",
        "-DFREETYPE_LIBRARY:FILEPATH=$Deps/freetype/lib/freetype.lib",
        "-DPNG_PNG_INCLUDE_DIR:PATH=$Deps/libpng/include",
        "-DPNG_LIBRARY:FILEPATH=$Deps/libpng/lib/libpng16.lib",
        "-DJPEG_INCLUDE_DIR:PATH=$Deps/libjpeg/include",
        "-DJPEG_LIBRARY:FILEPATH=$Deps/libjpeg/lib/jpeg.lib"
    )
}

function Get-ClientCMakeArgs {
    param([string]$Deps = $DepsPath, [string]$Nel = $NelPath)

    $common = Get-CommonCMakeArgs -Deps $Deps -Nel $Nel
    $client = @(
        "-DBUILD_CLIENT=ON",
        "-DBUILD_SERVER=OFF",
        "-DWITH_STATIC=ON",
        "-DWITH_STATIC_CURL=ON",
        "-DCURL_ROOT=$Deps/curl",
        "-DCURL_INCLUDE_DIR:PATH=$Deps/curl/include",
        "-DCURL_LIBRARY:FILEPATH=$Deps/curl/lib/libcurl_imp.lib",
        "-DCURL_LIBRARIES:FILEPATH=$Deps/curl/lib/libcurl_imp.lib",
        "-DOPENSSL_ROOT_DIR=$Deps/openssl",
        "-DVORBIS_LIBRARY:FILEPATH=$Deps/vorbis/lib/vorbis.lib",
        "-DVORBISFILE_LIBRARY:FILEPATH=$Deps/vorbis/lib/vorbisfile.lib",
        "-DOGG_LIBRARY:FILEPATH=$Deps/ogg/lib/ogg.lib"
    )

    return $common + $client
}

function Get-ServerCMakeArgs {
    param([string]$Deps = $DepsPath, [string]$Nel = $NelPath)

    $common = Get-CommonCMakeArgs -Deps $Deps -Nel $Nel
    $server = @(
        "-DBUILD_CLIENT=OFF",
        "-DBUILD_SERVER=ON",
        "-DODE_INCLUDE_DIR=$Deps/ode/include",
        "-DODE_LIBRARY=$Deps/ode/lib/ode_doubles.lib"
    )

    return $common + $server
}

function Write-CMakeArgsToFile {
    param(
        [string]$OutputFile,
        [string[]]$Args
    )

    $Args | ForEach-Object { $_ } | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "CMake args written to: $OutputFile"
}

# Print configuration when run directly
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "Tux Target CMake Configuration"
    Write-Host "==============================="
    Write-Host ""
    Write-Host "Dependencies path: $DepsPath"
    Write-Host "NeL path: $NelPath"
    Write-Host ""
    Write-Host "Client CMake args:"
    Get-ClientCMakeArgs | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    Write-Host "Server CMake args:"
    Get-ServerCMakeArgs | ForEach-Object { Write-Host "  $_" }
}

# Export functions
Export-ModuleMember -Function Get-CommonCMakeArgs, Get-ClientCMakeArgs, Get-ServerCMakeArgs, Write-CMakeArgsToFile -ErrorAction SilentlyContinue
