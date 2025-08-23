#!/bin/bash
# Compilación a WASM

INSTALL_DIR="$HOME/woff2"

FILE_TRANSFORM="$INSTALL_DIR/brotli/c/common/transform.c"
SEARCH_PATTERN="static const char kPrefixSuffix\[217\]"
if grep -q "$SEARCH_PATTERN" "$FILE_TRANSFORM" 2>/dev/null; then
	cp "$FILE_TRANSFORM" "$FILE_TRANSFORM.old" &&
	sed -i 's/static const char kPrefixSuffix\[217\] =/static const char kPrefixSuffix[218] =/' "$FILE_TRANSFORM"
	if [ $? -eq 0 ]; then
		echo -e "Corrección aplicada en transform.c\nBackup creado: $FILE_TRANSFORM.old"
	else
		echo "Error modificando \"$FILE_TRANSFORM\""
	fi
fi

SRC_FILES=$(find "$INSTALL_DIR/src" -name "*.cc" | grep -v -E 'convert_woff2ttf_fuzzer|convert_woff2ttf_fuzzer_new_entry|woff2_compress|woff2_decompress|woff2_info' | tr '\n' ' ')
echo "1 ) Comprimido"
echo "* ) Muy comprimido"
read -r response
if [ "$response" = "1" ]; then
	echo "Comprimido"
	em++ -O3 \
		-Iinclude \
		-I$INSTALL_DIR/include \
		-I$INSTALL_DIR/brotli/c/include \
		-x c $INSTALL_DIR/brotli/c/common/*.c $INSTALL_DIR/brotli/c/dec/*.c $INSTALL_DIR/brotli/c/enc/*.c \
		-x c++ $SRC_FILES mrk_woff2.cpp \
		-s MODULARIZE=1 \
		-s 'EXPORT_NAME="createWoff2Module"' \
		-s EXPORT_ES6=1 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s ASSERTIONS=2 \
		-s EXPORTED_FUNCTIONS='["_malloc","_free","_compress_woff2","_decompress_woff2","_info_woff2"]' \
		-s EXPORTED_RUNTIME_METHODS='["getValue","UTF8ToString","cwrap","HEAPU8","HEAPU32"]' \
		-o mrkWoff2_ems.js
else
	echo "Muy comprimido"
	em++ -Os \
		-Iinclude \
		-I$INSTALL_DIR/include \
		-I$INSTALL_DIR/brotli/c/include \
		-x c $INSTALL_DIR/brotli/c/common/*.c $INSTALL_DIR/brotli/c/dec/*.c $INSTALL_DIR/brotli/c/enc/*.c \
		-x c++ $SRC_FILES mrk_woff2.cpp \
		-s MODULARIZE=1 \
		-s 'EXPORT_NAME="createWoff2Module"' \
		-s EXPORT_ES6=1 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s ASSERTIONS=0 \
		-s DISABLE_EXCEPTION_CATCHING=1 \
		-s FILESYSTEM=0 \
		-g0 \
		-s EXPORTED_FUNCTIONS='["_malloc","_free","_compress_woff2","_decompress_woff2","_info_woff2"]' \
		-s EXPORTED_RUNTIME_METHODS='["getValue","UTF8ToString","cwrap","HEAPU8","HEAPU32"]' \
		-o mrkWoff2_ems.js
fi

if [ $? -ne 0 ]; then
	echo "Error en la compilación"
	exit 1
fi
echo "Compilación completada exitosamente"
ls -la mrkWoff2_ems*

exit 0