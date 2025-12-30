#!/bin/bash
#
# Build Both Tux Target Client and Server
#
# This script builds both the game client and server to separate directories.
# Usage: ./scripts/build-all.sh [--clean] [--skip-post-build]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Pass through all arguments
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Building Client and Server${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Build client first
echo -e "${BLUE}--- Building Client ---${NC}"
"${SCRIPT_DIR}/build-client.sh" "$@"

echo ""
echo ""

# Then build server
echo -e "${BLUE}--- Building Server ---${NC}"
"${SCRIPT_DIR}/build-server.sh" "$@"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Both builds complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Client: build-client/bin/Release/tux-target.exe"
echo "Server: build-server/bin/Release/tux-target-srv.exe"
echo ""
echo "Run scripts:"
echo "  ./scripts/run-client.sh"
echo "  ./scripts/run-server.sh"
