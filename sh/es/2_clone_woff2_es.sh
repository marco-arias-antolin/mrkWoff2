#!/bin/bash
# Script de clonación de woff2

INSTALL_DIR="$HOME/woff2"
LOG_FILE="$HOME/woff2_install.log"
INIT_DIR=$(pwd)
trap 'cd "$INIT_DIR"' EXIT INT TERM

# Colores
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
    echo "Log completo: $LOG_FILE"
    exit 1
}

log_message "${GREEN}=== Instalando woff2 ===${NC}"
"$(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"

# Verificar si git está instalado
log_message "${YELLOW}[1/2] Verificando dependencias...${NC}"
if ! command -v git &> /dev/null; then
    log_message "${YELLOW}Git no encontrado, instalando...${NC}"
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y git >> "$LOG_FILE" 2>&1 || error_exit "Fallo al instalar git"
fi

# Clonar o actualizar repositorio
log_message "${YELLOW}[2/2] Clonando woff2...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" && git pull >> "$LOG_FILE" 2>&1
    log_message "${YELLOW}Repositorio actualizado${NC}"
else
    git clone --recursive https://github.com/google/woff2.git "$INSTALL_DIR" >> "$LOG_FILE" 2>&1 || error_exit "Fallo al clonar"
    log_message "${YELLOW}Repositorio clonado${NC}"
fi

log_message "${GREEN}=== ¡Completado! ===${NC}"
log_message "Ir al directorio: cd $INSTALL_DIR"
log_message "Ver el log: cat $LOG_FILE"

exit 0