#!/bin/bash
#
# Post-Build Setup Script for Tux Target
#
# This script copies all required runtime files to the build directory
# after compiling the client and server.
#
# Usage: ./scripts/post_build.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Tux Target Post-Build Setup"
echo "========================================="
echo ""

# Configuration
RYZOMCORE_DIR="/c/ryzomcore"
PROJECT_DIR="/c/Users/User/Repos/tux_target"
RELEASE_DIR="${PROJECT_DIR}/build/bin/Release"

# Check if build directory exists
if [ ! -d "${RELEASE_DIR}" ]; then
    echo -e "${RED}Error: Build directory not found: ${RELEASE_DIR}${NC}"
    echo "Please build the project first with: cd build && cmake --build . --config Release"
    exit 1
fi

echo "Build directory: ${RELEASE_DIR}"
echo ""

# Function to copy file with verification
copy_file() {
    local src="$1"
    local dst="$2"

    if [ ! -f "${src}" ]; then
        echo -e "${RED}✗ Missing: ${src}${NC}"
        return 1
    fi

    # Create destination directory if needed
    mkdir -p "$(dirname "${dst}")"

    cp "${src}" "${dst}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Copied: $(basename "${dst}")${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to copy: ${src}${NC}"
        return 1
    fi
}

# 1. Copy NeL Driver DLLs
echo "1. Copying NeL driver DLLs..."
copy_file "${RYZOMCORE_DIR}/build/bin/Release/nel_drv_opengl_win_r.dll" \
          "${RELEASE_DIR}/nel_drv_opengl_win_r.dll"
copy_file "${RYZOMCORE_DIR}/build/bin/Release/nel_drv_openal_win_r.dll" \
          "${RELEASE_DIR}/nel_drv_openal_win_r.dll"
echo ""

# 2. Copy Font Files
echo "2. Copying font files..."
copy_file "${RYZOMCORE_DIR}/nel/samples/3d/cegui/datafiles/n019003l.pfb" \
          "${RELEASE_DIR}/data/font/n019003l.pfb"
copy_file "${RYZOMCORE_DIR}/nel/samples/3d/font/beteckna.ttf" \
          "${RELEASE_DIR}/data/font/bigfont.ttf"
echo ""

# 3. Create required directories
echo "3. Creating directory structure..."
mkdir -p "${RELEASE_DIR}/data/font"
mkdir -p "${RELEASE_DIR}/data/level"
mkdir -p "${RELEASE_DIR}/data/lua"
mkdir -p "${RELEASE_DIR}/data/shape"
mkdir -p "${RELEASE_DIR}/data/sound"
mkdir -p "${RELEASE_DIR}/data/misc"
mkdir -p "${RELEASE_DIR}/data/particle"
mkdir -p "${RELEASE_DIR}/data/smiley"
echo -e "${GREEN}✓ Directory structure created${NC}"
echo ""

# 4. Copy corrected data files (config, levels, shapes)
echo "4. Copying corrected data files..."

# Copy corrected config file (with water rendering disabled)
if [ -f "${PROJECT_DIR}/data/config/mtp_target_default.cfg" ]; then
    copy_file "${PROJECT_DIR}/data/config/mtp_target_default.cfg" \
              "${RELEASE_DIR}/mtp_target_default.cfg"
elif [ -f "${PROJECT_DIR}/client/mtp_target_default.cfg" ]; then
    copy_file "${PROJECT_DIR}/client/mtp_target_default.cfg" \
              "${RELEASE_DIR}/mtp_target_default.cfg"
    echo -e "${YELLOW}⚠ Using original config (may need water fix)${NC}"
fi

# Copy server config if not exists
if [ ! -f "${RELEASE_DIR}/mtp_target_service.cfg" ]; then
    if [ -f "${PROJECT_DIR}/server/mtp_target_service_default.cfg" ]; then
        copy_file "${PROJECT_DIR}/server/mtp_target_service_default.cfg" \
                  "${RELEASE_DIR}/mtp_target_service.cfg"
    fi
fi
echo ""

# 5. Copy corrected level files (with fixed ServerLua paths)
echo "5. Copying corrected level files..."
if [ -d "${PROJECT_DIR}/data/level" ]; then
    cp -r "${PROJECT_DIR}/data/level"/*.lua "${RELEASE_DIR}/data/level/" 2>/dev/null
    LEVEL_COUNT=$(find "${RELEASE_DIR}/data/level" -name "*.lua" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Copied ${LEVEL_COUNT} level files (with fixed ServerLua paths)${NC}"
else
    echo -e "${YELLOW}⚠ Corrected level files not found in ${PROJECT_DIR}/data/level${NC}"
    LEVEL_COUNT=$(find "${RELEASE_DIR}/data/level" -name "*.lua" 2>/dev/null | wc -l)
    if [ "${LEVEL_COUNT}" -gt 0 ]; then
        echo -e "${YELLOW}  Using existing ${LEVEL_COUNT} level files${NC}"
    else
        echo -e "${RED}  No level files found - server will crash!${NC}"
    fi
fi
echo ""

# 6. Copy Lua server scripts (converted to v1.2.2a API)
# These scripts have been fixed for v1.2.2a compatibility:
# - Removed nlinfo() calls (not registered in v1.2.2a)
# - Use global entitySceneCollideEvent() instead of CEntity:collideWithModule()
# - Use v1.2.2a method names (getName, getScore, getIsOpen, etc.)
echo "6. Copying Lua server scripts..."
if [ -d "${PROJECT_DIR}/mtp-target-src/data/lua" ]; then
    cp -r "${PROJECT_DIR}/mtp-target-src/data/lua"/*.lua "${RELEASE_DIR}/data/lua/" 2>/dev/null
    LUA_COUNT=$(find "${RELEASE_DIR}/data/lua" -name "*_server.lua" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Copied ${LUA_COUNT} Lua server scripts (v1.2.2a API)${NC}"
else
    echo -e "${YELLOW}⚠ Lua server scripts not found in ${PROJECT_DIR}/mtp-target-src/data/lua${NC}"
fi
echo ""

# 7. Copy corrected skybox (snow variant)
echo "7. Copying corrected skybox..."
if [ -f "${PROJECT_DIR}/data/shape/sky.shape" ]; then
    copy_file "${PROJECT_DIR}/data/shape/sky.shape" \
              "${RELEASE_DIR}/data/shape/sky.shape"
else
    echo -e "${YELLOW}⚠ Corrected skybox not found (may show wrong theme)${NC}"
fi
echo ""

# 8. Verify executables
echo "8. Verifying executables..."
if [ -f "${RELEASE_DIR}/tux-target.exe" ]; then
    CLIENT_SIZE=$(stat -f%z "${RELEASE_DIR}/tux-target.exe" 2>/dev/null || stat -c%s "${RELEASE_DIR}/tux-target.exe" 2>/dev/null)
    echo -e "${GREEN}✓ Client: tux-target.exe ($(numfmt --to=iec ${CLIENT_SIZE} 2>/dev/null || echo ${CLIENT_SIZE} bytes))${NC}"
else
    echo -e "${RED}✗ Client executable not found${NC}"
fi

if [ -f "${RELEASE_DIR}/tux-target-srv.exe" ]; then
    SERVER_SIZE=$(stat -f%z "${RELEASE_DIR}/tux-target-srv.exe" 2>/dev/null || stat -c%s "${RELEASE_DIR}/tux-target-srv.exe" 2>/dev/null)
    echo -e "${GREEN}✓ Server: tux-target-srv.exe ($(numfmt --to=iec ${SERVER_SIZE} 2>/dev/null || echo ${SERVER_SIZE} bytes))${NC}"
else
    echo -e "${YELLOW}⚠ Server executable not found (build with -DBUILD_SERVER=ON)${NC}"
fi
echo ""

# 9. Summary
echo "========================================="
echo "Post-Build Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Check user config: C:\\Users\\User\\AppData\\Roaming\\tux-target.cfg"
echo "  2. Start login service: cd login-service-deno && deno task login"
echo "  3. Start server: cd ${RELEASE_DIR} && ./tux-target-srv.exe"
echo "  4. Start client: cd ${RELEASE_DIR} && ./tux-target.exe"
echo ""
echo "Controls:"
echo "  - Arrow keys: Steer penguin (requires speed in ball mode)"
echo "  - CTRL: Toggle ball/gliding modes"
echo "  - Enter: Open chat (press again to send)"
echo ""
echo "For troubleshooting, see: docs/RUNTIME_FIXES.md"
