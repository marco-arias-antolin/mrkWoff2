#!/bin/bash
# Emscripten SDK installation script (emsdk)

set -e
INSTALL_DIR="$HOME/emsdk"
LOG_FILE="$HOME/emsdk_install.log"
SDK_VERSION="latest"
INIT_DIR=$(pwd)
trap 'cd "$INIT_DIR"' EXIT INT TERM

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log_message() {
    echo -e "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")" >> "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_message "${YELLOW}[INFO] Installing $1${NC}"
        sudo apt-get install -y "$1" >> "$LOG_FILE" 2>&1 || error_exit "Failed to install $1"
    fi
}

error_exit() {
    log_message "${RED}[ERROR] $1${NC}" >&2
    echo "Check log: $LOG_FILE"
    exit 1
}

# Start installation
> "$LOG_FILE"
log_message "${GREEN}=== Emscripten SDK Installation ===${NC}"
log_message "${YELLOW}Version: $SDK_VERSION${NC}"
echo "Installation log: $LOG_FILE"

# Install dependencies
log_message "${YELLOW}[1/4] Checking dependencies${NC}"
sudo apt-get update >> "$LOG_FILE" 2>&1
check_command git
check_command python3
check_command cmake
# check_command nodejs

# Clone repository
log_message "${YELLOW}[2/4] Clone emsdk${NC}"
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR"
    git pull >> "$LOG_FILE" 2>&1 || error_exit "Failed to update repository"
else
    git clone https://github.com/emscripten-core/emsdk.git "$INSTALL_DIR" >> "$LOG_FILE" 2>&1 || error_exit "Failed to clone repository"
    cd "$INSTALL_DIR"
fi

# Install SDK
log_message "${YELLOW}[3/4] Installing version $SDK_VERSION${NC}"
./emsdk install $SDK_VERSION >> "$LOG_FILE" 2>&1 || error_exit "Failed to install emsdk"

# Activate SDK
log_message "${YELLOW}[4/4] Activating SDK${NC}"
./emsdk activate $SDK_VERSION >> "$LOG_FILE" 2>&1 || error_exit "Failed to activate emsdk"

# Configure environment variables
log_message "${GREEN}=== Installation completed ===${NC}"
env_line="source \"$INSTALL_DIR/emsdk_env.sh\" >/dev/null 2>&1"
log_message "${YELLOW}Add configuration to .bashrc? [Y/N]${NC}"
read -r -n 1 response
echo "$(date '+%Y-%m-%d %H:%M:%S') - $response" >> "$LOG_FILE"
echo ""
if [[ "$response" =~ ^[Yy]$ ]]; then
    if ! grep -q "emsdk_env.sh" ~/.bashrc; then
        echo -e "\n# Emscripten SDK\n$env_line" >> ~/.bashrc
        log_message "${GREEN}✓ Configuration added to .bashrc${NC}"
    else
        log_message "${YELLOW}Configuration already exists in .bashrc${NC}"
    fi
fi

# Display usage information
echo ""
log_message "To verify installation:"
log_message "  ${GREEN}emcc --version${NC}"
log_message "To use Emscripten in this session:"
log_message "  ${GREEN}source \"$INSTALL_DIR/emsdk_env.sh\"\n${NC}"

exit 0