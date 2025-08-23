#!/bin/bash
# woff2 cloning script

INSTALL_DIR="$HOME/woff2"
LOG_FILE="$HOME/woff2_install.log"
INIT_DIR=$(pwd)
trap 'cd "$INIT_DIR"' EXIT INT TERM

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_message() {
    echo -e "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")" >> "$LOG_FILE"
}

error_exit() {
    log_message "${RED}[ERROR] $1${NC}" >&2
    echo "Full log: $LOG_FILE"
    exit 1
}

log_message "${GREEN}=== Installing woff2 ===${NC}"
"$(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"

# Check if git is installed
log_message "${YELLOW}[1/2] Checking dependencies...${NC}"
if ! command -v git &> /dev/null; then
    log_message "${YELLOW}Git not found, installing...${NC}"
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y git >> "$LOG_FILE" 2>&1 || error_exit "Failed to install git"
fi

# Clone or update repository
log_message "${YELLOW}[2/2] Cloning woff2...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" && git pull >> "$LOG_FILE" 2>&1
    log_message "${YELLOW}Repository updated${NC}"
else
    git clone --recursive https://github.com/google/woff2.git "$INSTALL_DIR" >> "$LOG_FILE" 2>&1 || error_exit "Failed to clone"
    log_message "${YELLOW}Repository cloned${NC}"
fi

log_message "${GREEN}=== Completed! ===${NC}"
log_message "Go to directory: cd $INSTALL_DIR"
log_message "View log: cat $LOG_FILE"

exit 0