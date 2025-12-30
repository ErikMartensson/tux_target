#!/bin/bash
#
# Run Tux Target Client with Log Rotation
#
# This script starts the game client and rotates log files on startup
# to prevent infinite log growth.
#
# Usage: ./scripts/run-client.sh
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAX_LOGS=5  # Keep this many old log files

# Determine directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CLIENT_DIR="${PROJECT_DIR}/build-client/bin/Release"

# Check if client directory exists, fall back to legacy location
if [ ! -d "${CLIENT_DIR}" ]; then
    CLIENT_DIR="${PROJECT_DIR}/build/bin/Release"
fi

LOG_DIR="${CLIENT_DIR}/logs"

# Check if client exists
if [ ! -f "${CLIENT_DIR}/tux-target.exe" ]; then
    echo -e "${RED}Error: Client not found at ${CLIENT_DIR}/tux-target.exe${NC}"
    echo "Please build the client first with: ./scripts/build-client.sh"
    exit 1
fi

# Create logs directory
mkdir -p "${LOG_DIR}"

# Function to rotate log files
rotate_logs() {
    local log_name="$1"
    local log_file="${LOG_DIR}/${log_name}"

    # Also check for log in main directory (NeL writes there by default)
    local main_log="${CLIENT_DIR}/${log_name}"

    # Move main log to logs directory if it exists
    if [ -f "${main_log}" ]; then
        # Remove oldest
        rm -f "${log_file}.${MAX_LOGS}"

        # Shift existing logs
        for i in $(seq $((MAX_LOGS-1)) -1 1); do
            [ -f "${log_file}.${i}" ] && mv "${log_file}.${i}" "${log_file}.$((i+1))"
        done

        # Current becomes .1
        [ -f "${log_file}" ] && mv "${log_file}" "${log_file}.1"

        # Move main log to logs directory
        mv "${main_log}" "${log_file}"
        echo -e "${GREEN}Rotated: ${log_name}${NC}"
    fi
}

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Tux Target Client${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Client directory: ${CLIENT_DIR}"
echo "Log directory: ${LOG_DIR}"
echo ""

# Rotate existing logs
echo "Rotating logs..."
rotate_logs "log.log"
rotate_logs "chat.log"
rotate_logs "nel_debug.dmp"
echo ""

# Check for login service
echo "Checking services..."
if command -v nc &> /dev/null; then
    if nc -z localhost 49997 2>/dev/null; then
        echo -e "${GREEN}Login service running on port 49997${NC}"
    else
        echo -e "${YELLOW}Login service not detected (port 49997)${NC}"
        echo "  For online play, start: cd login-service-deno && deno task login"
        echo "  For LAN play, select 'Play on LAN' in game menu"
    fi
fi
echo ""

# Start client
echo -e "${GREEN}Starting client...${NC}"
echo ""
echo "Controls:"
echo "  - Arrow keys: Steer penguin"
echo "  - CTRL: Toggle ball/gliding modes"
echo "  - Enter: Open chat"
echo ""

cd "${CLIENT_DIR}"
./tux-target.exe

echo ""
echo -e "${BLUE}Client exited.${NC}"

# Move any new logs to logs directory
if [ -f "${CLIENT_DIR}/log.log" ]; then
    mv "${CLIENT_DIR}/log.log" "${LOG_DIR}/"
fi
if [ -f "${CLIENT_DIR}/chat.log" ]; then
    mv "${CLIENT_DIR}/chat.log" "${LOG_DIR}/"
fi

echo "Logs saved to: ${LOG_DIR}"
