#!/bin/bash
# WASM compile

INSTALL_DIR="$HOME/woff2"
SRC_FILE="$HOME/mrkWoff2/cpp/mrk_woff2.cpp"
SRC_FILES=$(find "$INSTALL_DIR/src" -name "*.cc" | grep -v -E 'convert_woff2ttf_fuzzer|convert_woff2ttf_fuzzer_new_entry|woff2_compress|woff2_decompress|woff2_info' | tr '\n' ' ')
INIT_DIR=$(pwd)
trap 'cd "$INIT_DIR"' EXIT INT TERM

# Fix "transform.c"
FILE_TRANSFORM="$INSTALL_DIR/brotli/c/common/transform.c"
SEARCH_PATTERN="static const char kPrefixSuffix\[217\]"
if grep -q "$SEARCH_PATTERN" "$FILE_TRANSFORM" 2>/dev/null; then
	cp "$FILE_TRANSFORM" "$FILE_TRANSFORM.old" &&
	sed -i 's/static const char kPrefixSuffix\[217\] =/static const char kPrefixSuffix[218] =/' "$FILE_TRANSFORM"
	if [ $? -eq 0 ]; then
		echo -e "Fix applied to transform.c\nBackup created: $FILE_TRANSFORM.old"
	else
		echo "Error modifying \"$FILE_TRANSFORM\""
	fi
fi

# Compile
em++ -Os \
	-Iinclude \
	-I$INSTALL_DIR/include \
	-I$INSTALL_DIR/brotli/c/include \
	-x c $INSTALL_DIR/brotli/c/common/*.c $INSTALL_DIR/brotli/c/dec/*.c $INSTALL_DIR/brotli/c/enc/*.c \
	-x c++ $SRC_FILES $SRC_FILE \
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

if [ $? -ne 0 ]; then
	echo "Compilation error"
	exit 1
fi
echo "Compilation completed successfully"
ls -la mrkWoff2_ems*

exit 0