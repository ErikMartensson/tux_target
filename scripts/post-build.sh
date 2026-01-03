#!/bin/bash
#
# Post-Build Setup Script for Tux Target
#
# This script copies all required runtime files to the build directory
# after compiling the client and server.
#
# Usage:
#   ./scripts/post-build.sh                              # Setup both (legacy build/)
#   ./scripts/post-build.sh --client-only                # Setup client only
#   ./scripts/post-build.sh --server-only                # Setup server only
#   ./scripts/post-build.sh --build-dir /path/to/dir     # Custom build directory
#
# Options:
#   --client-only    Only copy files needed for the client
#   --server-only    Only copy files needed for the server
#   --build-dir DIR  Specify custom release directory
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
RYZOMCORE_DIR="/c/ryzomcore"
PROJECT_DIR="/c/Users/User/Repos/tux_target"
RELEASE_DIR=""
CLIENT_ONLY=false
SERVER_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --client-only)
            CLIENT_ONLY=true
            shift
            ;;
        --server-only)
            SERVER_ONLY=true
            shift
            ;;
        --build-dir)
            RELEASE_DIR="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Set default release directory if not specified
if [ -z "${RELEASE_DIR}" ]; then
    if [ "$CLIENT_ONLY" = true ]; then
        RELEASE_DIR="${PROJECT_DIR}/build-client/bin/Release"
    elif [ "$SERVER_ONLY" = true ]; then
        RELEASE_DIR="${PROJECT_DIR}/build-server/bin/Release"
    else
        RELEASE_DIR="${PROJECT_DIR}/build/bin/Release"
    fi
fi

# Determine mode string for display
if [ "$CLIENT_ONLY" = true ]; then
    MODE="Client"
elif [ "$SERVER_ONLY" = true ]; then
    MODE="Server"
else
    MODE="Client + Server"
fi

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Tux Target Post-Build Setup (${MODE})${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if build directory exists
if [ ! -d "${RELEASE_DIR}" ]; then
    echo -e "${RED}Error: Build directory not found: ${RELEASE_DIR}${NC}"
    echo "Please build the project first."
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

# Function to copy directory
copy_dir() {
    local src="$1"
    local dst="$2"
    local pattern="$3"

    if [ ! -d "${src}" ]; then
        echo -e "${YELLOW}⚠ Directory not found: ${src}${NC}"
        return 1
    fi

    mkdir -p "${dst}"
    if [ -n "${pattern}" ]; then
        cp -r "${src}"/${pattern} "${dst}/" 2>/dev/null || true
    else
        cp -r "${src}"/* "${dst}/" 2>/dev/null || true
    fi
    return 0
}

STEP=1

# ============================================
# CLIENT-ONLY SETUP
# ============================================
if [ "$SERVER_ONLY" = false ]; then

    # 1. Copy NeL Driver DLLs (Client needs graphics + audio drivers)
    echo "${STEP}. Copying NeL driver DLLs..."
    copy_file "${RYZOMCORE_DIR}/build/bin/Release/nel_drv_opengl_win_r.dll" \
              "${RELEASE_DIR}/nel_drv_opengl_win_r.dll" || true
    copy_file "${RYZOMCORE_DIR}/build/bin/Release/nel_drv_openal_win_r.dll" \
              "${RELEASE_DIR}/nel_drv_openal_win_r.dll" || true
    echo ""
    STEP=$((STEP + 1))

    # 2. Copy Font Files (Client-specific)
    echo "${STEP}. Copying font files..."
    mkdir -p "${RELEASE_DIR}/data/font"
    copy_file "${RYZOMCORE_DIR}/nel/samples/3d/cegui/datafiles/n019003l.pfb" \
              "${RELEASE_DIR}/data/font/n019003l.pfb" || true
    copy_file "${RYZOMCORE_DIR}/nel/samples/3d/font/beteckna.ttf" \
              "${RELEASE_DIR}/data/font/bigfont.ttf" || true
    echo ""
    STEP=$((STEP + 1))

    # 3. Copy GUI data (Client-specific)
    echo "${STEP}. Copying GUI data..."
    mkdir -p "${RELEASE_DIR}/data/gui"

    # Copy v1.2.2a GUI files first (from client/data/gui)
    if [ -d "${PROJECT_DIR}/client/data/gui" ]; then
        copy_dir "${PROJECT_DIR}/client/data/gui" "${RELEASE_DIR}/data/gui"
        echo -e "${GREEN}✓ Copied v1.2.2a GUI files${NC}"
    else
        echo -e "${YELLOW}⚠ v1.2.2a GUI data not found${NC}"
    fi

    # Copy any additional GUI files from data/gui (if they don't conflict)
    if [ -d "${PROJECT_DIR}/data/gui" ]; then
        for file in "${PROJECT_DIR}/data/gui"/*.{xml,tga}; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                if [ ! -f "${RELEASE_DIR}/data/gui/$filename" ]; then
                    cp "$file" "${RELEASE_DIR}/data/gui/" 2>/dev/null || true
                fi
            fi
        done
        echo -e "${GREEN}✓ Merged additional v1.5.19 GUI files${NC}"
    fi

    GUI_COUNT=$(find "${RELEASE_DIR}/data/gui" -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Total GUI files: ${GUI_COUNT}${NC}"
    echo ""
    STEP=$((STEP + 1))

    # 4. Copy client config
    echo "${STEP}. Copying client config..."
    if [ -f "${PROJECT_DIR}/data/config/mtp_target_default.cfg" ]; then
        copy_file "${PROJECT_DIR}/data/config/mtp_target_default.cfg" \
                  "${RELEASE_DIR}/mtp_target_default.cfg"
    elif [ -f "${PROJECT_DIR}/client/mtp_target_default.cfg" ]; then
        copy_file "${PROJECT_DIR}/client/mtp_target_default.cfg" \
                  "${RELEASE_DIR}/mtp_target_default.cfg"
        echo -e "${YELLOW}⚠ Using original config (may need water fix)${NC}"
    fi

    # Create tux-target.cfg wrapper (client looks for this file, not mtp_target_default.cfg)
    if [ ! -f "${RELEASE_DIR}/tux-target.cfg" ]; then
        cat > "${RELEASE_DIR}/tux-target.cfg" << 'EOF'
// This file tells the client where to find the main config
RootConfigFilename = "mtp_target_default.cfg";
EOF
        echo -e "${GREEN}✓ Created: tux-target.cfg${NC}"
    else
        echo -e "${GREEN}✓ tux-target.cfg already exists${NC}"
    fi
    echo ""
    STEP=$((STEP + 1))

    # 5. Create client directories
    echo "${STEP}. Creating client directory structure..."
    mkdir -p "${RELEASE_DIR}/data/font"
    mkdir -p "${RELEASE_DIR}/data/gui"
    mkdir -p "${RELEASE_DIR}/data/shape"
    mkdir -p "${RELEASE_DIR}/data/sound"
    mkdir -p "${RELEASE_DIR}/data/misc"
    mkdir -p "${RELEASE_DIR}/data/particle"
    mkdir -p "${RELEASE_DIR}/data/smiley"
    mkdir -p "${RELEASE_DIR}/data/texture"
    mkdir -p "${RELEASE_DIR}/cache"
    mkdir -p "${RELEASE_DIR}/replay"
    mkdir -p "${RELEASE_DIR}/logs"
    echo -e "${GREEN}✓ Client directory structure created${NC}"
    echo ""
    STEP=$((STEP + 1))

fi

# ============================================
# SERVER-ONLY SETUP
# ============================================
if [ "$CLIENT_ONLY" = false ]; then

    # Server config
    echo "${STEP}. Copying server config..."
    if [ ! -f "${RELEASE_DIR}/mtp_target_service.cfg" ]; then
        if [ -f "${PROJECT_DIR}/server/mtp_target_service_default.cfg" ]; then
            copy_file "${PROJECT_DIR}/server/mtp_target_service_default.cfg" \
                      "${RELEASE_DIR}/mtp_target_service.cfg"
        fi
    else
        echo -e "${GREEN}✓ Server config already exists${NC}"
    fi
    echo ""
    STEP=$((STEP + 1))

    # Lua server scripts (Server-specific)
    echo "${STEP}. Copying Lua server scripts..."
    mkdir -p "${RELEASE_DIR}/data/lua"
    if [ -d "${PROJECT_DIR}/data/lua" ]; then
        cp -r "${PROJECT_DIR}/data/lua"/*.lua "${RELEASE_DIR}/data/lua/" 2>/dev/null || true
        LUA_COUNT=$(ls "${RELEASE_DIR}/data/lua"/*_server.lua 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Copied ${LUA_COUNT} Lua server scripts${NC}"
    else
        echo -e "${YELLOW}⚠ Lua server scripts not found in ${PROJECT_DIR}/data/lua${NC}"
    fi
    echo ""
    STEP=$((STEP + 1))

    # Module Lua scripts (Server-specific - for paint, team, etc.)
    echo "${STEP}. Copying module Lua scripts..."
    mkdir -p "${RELEASE_DIR}/data/module"
    if [ -d "${PROJECT_DIR}/data/module" ]; then
        cp -r "${PROJECT_DIR}/data/module"/*.lua "${RELEASE_DIR}/data/module/" 2>/dev/null || true
        MODULE_COUNT=$(ls "${RELEASE_DIR}/data/module"/*.lua 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Copied ${MODULE_COUNT} module Lua scripts${NC}"
    else
        echo -e "${YELLOW}⚠ Module Lua scripts not found in ${PROJECT_DIR}/data/module${NC}"
    fi
    echo ""
    STEP=$((STEP + 1))

    # Create server directories
    echo "${STEP}. Creating server directory structure..."
    mkdir -p "${RELEASE_DIR}/data/level"
    mkdir -p "${RELEASE_DIR}/data/lua"
    mkdir -p "${RELEASE_DIR}/data/module"
    mkdir -p "${RELEASE_DIR}/data/shape"
    mkdir -p "${RELEASE_DIR}/data/texture"
    mkdir -p "${RELEASE_DIR}/data/particle"
    mkdir -p "${RELEASE_DIR}/data/misc"
    mkdir -p "${RELEASE_DIR}/data/smiley"
    mkdir -p "${RELEASE_DIR}/data/sound"
    mkdir -p "${RELEASE_DIR}/logs"
    echo -e "${GREEN}✓ Server directory structure created${NC}"
    echo ""
    STEP=$((STEP + 1))

    # Copy game data files for server to serve to clients
    echo "${STEP}. Copying game data files (shapes, textures, etc.)..."

    # Shape files - server serves these to clients
    if [ -d "${PROJECT_DIR}/data/shape" ]; then
        cp -r "${PROJECT_DIR}/data/shape"/* "${RELEASE_DIR}/data/shape/" 2>/dev/null || true
        SHAPE_COUNT=$(ls "${RELEASE_DIR}/data/shape"/*.shape 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Copied ${SHAPE_COUNT} shape files${NC}"
    fi

    # Texture files
    if [ -d "${PROJECT_DIR}/data/texture" ]; then
        cp -r "${PROJECT_DIR}/data/texture"/* "${RELEASE_DIR}/data/texture/" 2>/dev/null || true
        TEXTURE_COUNT=$(ls "${RELEASE_DIR}/data/texture"/* 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Copied ${TEXTURE_COUNT} texture files${NC}"
    fi

    # Particle files
    if [ -d "${PROJECT_DIR}/data/particle" ]; then
        cp -r "${PROJECT_DIR}/data/particle"/* "${RELEASE_DIR}/data/particle/" 2>/dev/null || true
        PARTICLE_COUNT=$(ls "${RELEASE_DIR}/data/particle"/* 2>/dev/null | wc -l)
        echo -e "${GREEN}✓ Copied ${PARTICLE_COUNT} particle files${NC}"
    fi

    # Misc files (helper shapes, etc.)
    if [ -d "${PROJECT_DIR}/data/misc" ]; then
        cp -r "${PROJECT_DIR}/data/misc"/* "${RELEASE_DIR}/data/misc/" 2>/dev/null || true
        echo -e "${GREEN}✓ Copied misc files${NC}"
    fi

    # Smiley files
    if [ -d "${PROJECT_DIR}/data/smiley" ]; then
        cp -r "${PROJECT_DIR}/data/smiley"/* "${RELEASE_DIR}/data/smiley/" 2>/dev/null || true
        echo -e "${GREEN}✓ Copied smiley files${NC}"
    fi

    # Sound files
    if [ -d "${PROJECT_DIR}/data/sound" ]; then
        cp -r "${PROJECT_DIR}/data/sound"/* "${RELEASE_DIR}/data/sound/" 2>/dev/null || true
        echo -e "${GREEN}✓ Copied sound files${NC}"
    fi

    # Font files
    if [ -d "${PROJECT_DIR}/data/font" ]; then
        mkdir -p "${RELEASE_DIR}/data/font"
        cp -r "${PROJECT_DIR}/data/font"/* "${RELEASE_DIR}/data/font/" 2>/dev/null || true
        echo -e "${GREEN}✓ Copied font files${NC}"
    fi

    echo ""
    STEP=$((STEP + 1))

fi

# ============================================
# SHARED SETUP (Both client and server need these)
# ============================================

# Copy dependency DLLs (Required for both client and server)
echo "${STEP}. Copying dependency DLLs..."

# Determine source directory for dependency DLLs
DEPS_DIR=""
if [ -n "${TUXDEPS_PREFIX_PATH}" ] && [ -d "${TUXDEPS_PREFIX_PATH}/bin" ]; then
    DEPS_DIR="${TUXDEPS_PREFIX_PATH}/bin"
elif [ -d "/c/tux_target_deps/bin" ]; then
    DEPS_DIR="/c/tux_target_deps/bin"
elif [ -d "${PROJECT_DIR}/build/bin/Release" ]; then
    DEPS_DIR="${PROJECT_DIR}/build/bin/Release"
else
    echo -e "${YELLOW}⚠ Dependency DLL directory not found${NC}"
    echo ""
    STEP=$((STEP + 1))
fi

if [ -n "${DEPS_DIR}" ]; then
    echo "   Using DLL source: ${DEPS_DIR}"

    # Core dependencies (needed by both client and server)
    for dll in lua.dll zlib.dll freetype.dll libpng16.dll jpeg62.dll; do
        copy_file "${DEPS_DIR}/${dll}" "${RELEASE_DIR}/${dll}" || true
    done

    # Client-specific dependencies (graphics and audio libraries)
    if [ "$SERVER_ONLY" = false ]; then
        for dll in libxml2.dll libcurl.dll vorbisfile.dll vorbis.dll ogg.dll OpenAL32.dll libcrypto-1_1-x64.dll libssl-1_1-x64.dll; do
            copy_file "${DEPS_DIR}/${dll}" "${RELEASE_DIR}/${dll}" || true
        done
    fi

    # Visual C++ Runtime DLLs (if available)
    for dll in msvcp140.dll vcruntime140.dll vcruntime140_1.dll concrt140.dll; do
        copy_file "${DEPS_DIR}/${dll}" "${RELEASE_DIR}/${dll}" || true
    done

    echo ""
    STEP=$((STEP + 1))
fi

# Level files (Shared)
echo "${STEP}. Copying level files..."
mkdir -p "${RELEASE_DIR}/data/level"
if [ -d "${PROJECT_DIR}/data/level" ]; then
    cp -r "${PROJECT_DIR}/data/level"/*.lua "${RELEASE_DIR}/data/level/" 2>/dev/null || true
    LEVEL_COUNT=$(find "${RELEASE_DIR}/data/level" -name "*.lua" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Copied ${LEVEL_COUNT} level files${NC}"
else
    echo -e "${YELLOW}⚠ Level files not found in ${PROJECT_DIR}/data/level${NC}"
fi
echo ""
STEP=$((STEP + 1))

# Skybox (Shared)
echo "${STEP}. Copying skybox..."
mkdir -p "${RELEASE_DIR}/data/shape"
if [ -f "${PROJECT_DIR}/data/shape/sky.shape" ]; then
    copy_file "${PROJECT_DIR}/data/shape/sky.shape" \
              "${RELEASE_DIR}/data/shape/sky.shape"
else
    echo -e "${YELLOW}⚠ Corrected skybox not found (may show wrong theme)${NC}"
fi
echo ""
STEP=$((STEP + 1))

# ============================================
# VERIFICATION
# ============================================
echo "${STEP}. Verifying executables..."
if [ "$SERVER_ONLY" = false ] && [ -f "${RELEASE_DIR}/tux-target.exe" ]; then
    CLIENT_SIZE=$(stat -c%s "${RELEASE_DIR}/tux-target.exe" 2>/dev/null || stat -f%z "${RELEASE_DIR}/tux-target.exe" 2>/dev/null || echo "?")
    echo -e "${GREEN}✓ Client: tux-target.exe (${CLIENT_SIZE} bytes)${NC}"
elif [ "$SERVER_ONLY" = false ]; then
    echo -e "${YELLOW}⚠ Client executable not found${NC}"
fi

if [ "$CLIENT_ONLY" = false ] && [ -f "${RELEASE_DIR}/tux-target-srv.exe" ]; then
    SERVER_SIZE=$(stat -c%s "${RELEASE_DIR}/tux-target-srv.exe" 2>/dev/null || stat -f%z "${RELEASE_DIR}/tux-target-srv.exe" 2>/dev/null || echo "?")
    echo -e "${GREEN}✓ Server: tux-target-srv.exe (${SERVER_SIZE} bytes)${NC}"
elif [ "$CLIENT_ONLY" = false ]; then
    echo -e "${YELLOW}⚠ Server executable not found${NC}"
fi
echo ""

# ============================================
# SUMMARY
# ============================================
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Post-Build Setup Complete! (${MODE})${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Build directory: ${RELEASE_DIR}"
echo ""

if [ "$SERVER_ONLY" = false ]; then
    echo "To run the client:"
    echo "  cd ${RELEASE_DIR} && ./tux-target.exe"
    echo "  Or: ./scripts/run-client.sh"
    echo ""
fi

if [ "$CLIENT_ONLY" = false ]; then
    echo "To run the server:"
    echo "  cd ${RELEASE_DIR} && ./tux-target-srv.exe"
    echo "  Or: ./scripts/run-server.sh"
    echo ""
fi

echo "For troubleshooting, see: docs/RUNTIME_FIXES.md"
