#!/bin/bash
#
# Run Tux Target Server with Log Rotation
#
# This script starts the game server and rotates log files on startup
# to prevent infinite log growth.
#
# Usage: ./scripts/run-server.sh
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
SERVER_DIR="${PROJECT_DIR}/build-server/bin/Release"

# Check if server directory exists, fall back to legacy location
if [ ! -d "${SERVER_DIR}" ]; then
    SERVER_DIR="${PROJECT_DIR}/build/bin/Release"
fi

LOG_DIR="${SERVER_DIR}/logs"

# Check if server exists
if [ ! -f "${SERVER_DIR}/tux-target-srv.exe" ]; then
    echo -e "${RED}Error: Server not found at ${SERVER_DIR}/tux-target-srv.exe${NC}"
    echo "Please build the server first with: ./scripts/build-server.sh"
    exit 1
fi

# Create logs directory
mkdir -p "${LOG_DIR}"

# Function to rotate log files
rotate_logs() {
    local log_name="$1"
    local log_file="${LOG_DIR}/${log_name}"

    # Also check for log in main directory (NeL writes there by default)
    local main_log="${SERVER_DIR}/${log_name}"

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
echo -e "${BLUE}  Tux Target Server${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Server directory: ${SERVER_DIR}"
echo "Log directory: ${LOG_DIR}"
echo ""

# Rotate existing logs
echo "Rotating logs..."
rotate_logs "mtp_target_service.log"
rotate_logs "log.log"
rotate_logs "nel_debug.dmp"
echo ""

# Show server configuration summary
if [ -f "${SERVER_DIR}/mtp_target_service.cfg" ]; then
    echo "Server configuration:"
    grep -E "^(TcpPort|NbMaxClients|NbBot|SessionTimeout)" "${SERVER_DIR}/mtp_target_service.cfg" 2>/dev/null | head -5
    echo ""
fi

# Start server
echo -e "${GREEN}Starting server...${NC}"
echo ""
echo "Server commands (in-game chat):"
echo "  /help       - Show available commands"
echo "  /v <level>  - Vote for a level"
echo "  /forcemap   - Force next level (admin)"
echo "  /forceend   - End current session (admin)"
echo ""

cd "${SERVER_DIR}"

# Run server and tee output to log file
./tux-target-srv.exe 2>&1 | tee "${LOG_DIR}/mtp_target_service.log"

echo ""
echo -e "${BLUE}Server exited.${NC}"

# Move any remaining logs to logs directory
if [ -f "${SERVER_DIR}/log.log" ]; then
    mv "${SERVER_DIR}/log.log" "${LOG_DIR}/"
fi

echo "Logs saved to: ${LOG_DIR}"
