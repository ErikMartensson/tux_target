#!/bin/bash
#
# Build Tux Target Server Only
#
# This script builds only the game server to a separate build-server directory.
# Usage: ./scripts/build-server.sh [--clean] [--skip-post-build]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
CLEAN_BUILD=false
SKIP_POST_BUILD=false
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN_BUILD=true
            ;;
        --skip-post-build)
            SKIP_POST_BUILD=true
            ;;
    esac
done

# Determine project directory (script is in scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build-server"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Tux Target Server Build${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Project directory: ${PROJECT_DIR}"
echo "Build directory:   ${BUILD_DIR}"
echo ""

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf "${BUILD_DIR}"
fi

# Create build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Detect number of CPU cores
if command -v nproc &> /dev/null; then
    NUM_CORES=$(nproc)
elif command -v sysctl &> /dev/null; then
    NUM_CORES=$(sysctl -n hw.ncpu)
else
    NUM_CORES=4
fi
echo "Using ${NUM_CORES} CPU cores for build"
echo ""

# Set dependency paths (check environment variables first, then use defaults)
NEL_PREFIX_PATH="${NEL_PREFIX_PATH:-/usr/local/ryzomcore/build}"
TUXDEPS_PREFIX_PATH="${TUXDEPS_PREFIX_PATH:-/usr/local/tux_target_deps}"

echo "Dependency configuration:"
echo "  NEL_PREFIX_PATH: ${NEL_PREFIX_PATH}"
echo "  TUXDEPS_PREFIX_PATH: ${TUXDEPS_PREFIX_PATH}"
echo ""

# Configure CMake with explicit paths for dependencies
echo -e "${GREEN}Configuring CMake (Server only)...${NC}"
cmake .. \
    -DBUILD_CLIENT=OFF \
    -DBUILD_SERVER=ON \
    -DNEL_PREFIX_PATH="${NEL_PREFIX_PATH}" \
    -DCMAKE_PREFIX_PATH="${TUXDEPS_PREFIX_PATH}" \
    -DLIBXML2_INCLUDE_DIR="${TUXDEPS_PREFIX_PATH}/libxml2/include/libxml2" \
    -DLIBXML2_LIBRARY="${TUXDEPS_PREFIX_PATH}/libxml2/lib/libxml2.a" \
    -DZLIB_ROOT="${TUXDEPS_PREFIX_PATH}/zlib" \
    -DODE_DIR="${TUXDEPS_PREFIX_PATH}/ode"

echo ""

# Build
echo -e "${GREEN}Building server...${NC}"
cmake --build . --config Release -j${NUM_CORES}

echo ""
echo -e "${GREEN}Build complete!${NC}"

# Check for executable
if [ -f "${BUILD_DIR}/bin/Release/tux-target-srv.exe" ]; then
    SIZE=$(stat -c%s "${BUILD_DIR}/bin/Release/tux-target-srv.exe" 2>/dev/null || stat -f%z "${BUILD_DIR}/bin/Release/tux-target-srv.exe" 2>/dev/null)
    echo -e "${GREEN}Server executable: ${BUILD_DIR}/bin/Release/tux-target-srv.exe (${SIZE} bytes)${NC}"
else
    echo -e "${RED}Warning: Server executable not found${NC}"
fi

# Run post-build setup
if [ "$SKIP_POST_BUILD" = false ]; then
    echo ""
    echo -e "${BLUE}Running post-build setup...${NC}"
    "${SCRIPT_DIR}/post-build.sh" --server-only --build-dir "${BUILD_DIR}/bin/Release"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Server build finished!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "To run the server:"
echo "  cd ${BUILD_DIR}/bin/Release && ./tux-target-srv.exe"
echo ""
echo "Or use the run script with log rotation:"
echo "  ./scripts/run-server.sh"
