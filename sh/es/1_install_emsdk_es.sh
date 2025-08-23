#!/bin/bash
# Script de instalación de Emscripten SDK (emsdk)

set -e
INSTALL_DIR="$HOME/emsdk"
LOG_FILE="$HOME/emsdk_install.log"
SDK_VERSION="latest"
INIT_DIR=$(pwd)
trap 'cd "$INIT_DIR"' EXIT INT TERM

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funciones
log_message() {
    echo -e "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $(echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")" >> "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_message "${YELLOW}[INFO] Instalando $1${NC}"
        sudo apt-get install -y "$1" >> "$LOG_FILE" 2>&1 || error_exit "Fallo al instalar $1"
    fi
}

error_exit() {
    log_message "${RED}[ERROR] $1${NC}" >&2
    echo "Consulta el log: $LOG_FILE"
    exit 1
}

# Inicio de instalación
> "$LOG_FILE"
log_message "${GREEN}=== Instalación de Emscripten SDK ===${NC}"
log_message "${YELLOW}Versión: $SDK_VERSION${NC}"
echo "Registro de instalación: $LOG_FILE"

# Instalar dependencias
log_message "${YELLOW}[1/4] Verificando dependencias${NC}"
sudo apt-get update >> "$LOG_FILE" 2>&1
check_command git
check_command python3
check_command cmake
# check_command nodejs

# Clonar repositorio
log_message "${YELLOW}[2/4] Obteniendo emsdk${NC}"
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR"
    git pull >> "$LOG_FILE" 2>&1 || error_exit "Error al actualizar repositorio"
else
    git clone https://github.com/emscripten-core/emsdk.git "$INSTALL_DIR" >> "$LOG_FILE" 2>&1 || error_exit "Error al clonar repositorio"
    cd "$INSTALL_DIR"
fi

# Instalar SDK
log_message "${YELLOW}[3/4] Instalando versión $SDK_VERSION${NC}"
./emsdk install $SDK_VERSION >> "$LOG_FILE" 2>&1 || error_exit "Fallo al instalar emsdk"

# Activar SDK
log_message "${YELLOW}[4/4] Activando SDK${NC}"
./emsdk activate $SDK_VERSION >> "$LOG_FILE" 2>&1 || error_exit "Fallo al activar emsdk"

# Configurar variables de entorno
log_message "${GREEN}=== Instalación completada ===${NC}"
env_line="source \"$INSTALL_DIR/emsdk_env.sh\" >/dev/null 2>&1"
log_message "${YELLOW}¿Desea añadir la configuración a .bashrc? [S/N]${NC}"
read -r -n 1 response
echo "$(date '+%Y-%m-%d %H:%M:%S') - $response" >> "$LOG_FILE"
echo ""
if [[ "$response" =~ ^[Ss]$ ]]; then
    if ! grep -q "emsdk_env.sh" ~/.bashrc; then
        echo -e "\n# Emscripten SDK\n$env_line" >> ~/.bashrc
        log_message "${GREEN}✓ Configuración añadida a .bashrc${NC}"
    else
        log_message "${YELLOW}La configuración ya existe en .bashrc${NC}"
    fi
fi

# Mostrar información de uso
echo ""
log_message "Para comprobar la instalación:"
log_message "  ${GREEN}emcc --version${NC}"
log_message "Para usar Emscripten en esta sesión:"
log_message "  ${GREEN}source \"$INSTALL_DIR/emsdk_env.sh\"\n${NC}"

exit 0