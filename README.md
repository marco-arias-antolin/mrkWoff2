# [Woff2-Wasm](https://marco-arias-antolin.github.io/Woff2-Wasm/web/Woff2-Wasm.html)

TTF ↔ WOFF2 compression/decompression in your browser using WebAssembly.  
All processing happens locally.

**Built with**:
- [WOFF2](https://github.com/google/woff2)
- [Emscripten](https://github.com/emscripten-core/emsdk)
- [WebAssembly](https://www.w3.org/community/webassembly/)

## Key Features

| Feature | Description |
|---------|-------------|
| **Compression** | Convert TTF to WOFF2 (60%+ size reduction) for web optimization |
| **Decompression** | Convert WOFF2 back to TTF format to restore original fonts |
| **Font Information** | Extract metadata and technical details from WOFF2 font files |
| **Browser-based** | No server uploads - all processing happens locally in your browser |
| **WASM-powered** | Native performance via WebAssembly for fast conversion |
| **Cross-Platform** | Works in any modern browser supporting WebAssembly |
| **Privacy-focused** | No font data leaves your device - complete client-side processing |

## Technology Stack

- **[WOFF2](https://github.com/google/woff2)** - Compression algorithms
- **[Emscripten](https://github.com/emscripten-core/emsdk)** - C++ to WebAssembly compilation
- **[Vanilla JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)** - Frontend implementation

*No font data leaves your browser - all processing happens client-side*

## Project Structure

```
Woff2-Wasm/
├── cpp/
│   └── Woff2_Wasm.cpp            # Core C++ module with WOFF2 operations
├── sh/
│   ├── 1_install_emsdk.sh
│   ├── 2_clone_woff2.sh
│   └── 3_wasm_compile.sh        # Compile WebAssembly module
├── web/
│   ├── css/                     # Styles
│   │   ├── Woff2-Wasm.css         # JavaScript wrapper for WASM module
│   │   └── style.css            # Emscripten-generated JavaScript
│   ├── js/
│   │   ├── Woff2-Wasm.js          # JavaScript wrapper for WASM module
│   │   ├── Woff2-Wasm_ems.js      # Emscripten-generated JavaScript
│   │   ├── Woff2-Wasm_ems.wasm    # Compiled WebAssembly module
│   │   └── util/
│   │       └── download.js      # File download utility
│   └── Woff2-Wasm.html
├── agpl.txt                     # GNU Affero General Public License
├── gpl.txt                      # GNU General Public License
└── README.md                    # This file
```

## Core Functions

The C++ module (`Woff2_Wasm.cpp`) exports three main functions:
- `compress_woff2`: Converts TTF font data to WOFF2 format
- `decompress_woff2`: Converts WOFF2 font data back to TTF format  
- `info_woff2`: Extracts metadata information from WOFF2 files

## Installation & Building
### Prerequisites
- Git

### Automated Build
Run the provided build script:

```bash
cd "$HOME/Woff2-Wasm/sh" # Update path if different
chmod +x *.sh
./1_install_emsdk.sh
source "$HOME/emsdk/emsdk_env.sh"
./2_clone_woff2.sh
./3_wasm_compile.sh
```

### Manual Build

1. Install Emscripten:
```bash
# Dependencies: git, python3, cmake

# INSTRUCTIONS - Copy and paste these commands one by one into your terminal
# Note: If you make this into a script file, you MUST run it with: source scriptname.sh because the 'source' command needs to affect the current shell environment
INSTALL_DIR=$HOME/emsdk
SDK_VERSION="latest"
git clone https://github.com/emscripten-core/emsdk.git "$INSTALL_DIR"
cd "$INSTALL_DIR"
git pull
./emsdk install $SDK_VERSION
./emsdk activate $SDK_VERSION
# This command sets up the environment variables for the current shell
# If making a script, this is why you need to run it with 'source'
source ./emsdk_env.sh
```

2. Clone Google's WOFF2 repository:
```bash
# Clone the woff2 repository with submodules (--recursive is needed for brotli dependency)
git clone --recursive https://github.com/google/woff2.git
```

3. Compile the C++ module:
```bash
INSTALL_DIR="$HOME/woff2"
# Fix transform.c - Brotli compilation issue with array size
FILE_TRANSFORM="$INSTALL_DIR/brotli/c/common/transform.c"
SEARCH_PATTERN="static const char kPrefixSuffix\[217\]"
# First check if the pattern exists in the file
grep "$SEARCH_PATTERN" "$FILE_TRANSFORM"
# Create backup of original file before modifying
cp "$FILE_TRANSFORM" "$FILE_TRANSFORM.old" &&
# Fix the array size from 217 to 218 to resolve compilation error
sed -i 's/static const char kPrefixSuffix\[217\] =/static const char kPrefixSuffix[218] =/' "$FILE_TRANSFORM"

SRC_FILES=$(find "$INSTALL_DIR/src" -name "*.cc" | grep -v -E 'convert_woff2ttf_fuzzer|convert_woff2ttf_fuzzer_new_entry|woff2_compress|woff2_decompress|woff2_info' | tr '\n' ' ')
CPP_FILE=$HOME/Woff2-Wasm/cpp/Woff2_Wasm.cpp

# Compilation
em++ -Os \
  -Iinclude \
  -I$INSTALL_DIR/include \
  -I$INSTALL_DIR/brotli/c/include \
  -x c $INSTALL_DIR/brotli/c/common/*.c $INSTALL_DIR/brotli/c/dec/*.c $INSTALL_DIR/brotli/c/enc/*.c \
  -x c++ $SRC_FILES $CPP_FILE \
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
  -o Woff2-Wasm_ems.js
```

## Usage

### Web Interface
1. Open [Woff2-Wasm.html](https://marco-arias-antolin.github.io/Woff2-Wasm/web/Woff2-Wasm.html) in a web browser

   NOTE: Requires a local web server due to CORS restrictions

   Linux:
   - ``python3 -m http.server 8000``
   - ``npx serve``
   - ``php -S localhost:8000``
   
   Then navigate to: http://localhost:8000/Woff2-Wasm.html

   Windows:
   - [laragon](https://laragon.org/download)
   - [XAMPP](https://www.apachefriends.org/download.html)

2. Select a TTF or WOFF2 file
3. Choose an operation (Compress/Decompress/Info)
4. Download the converted file

### Programmatic Usage
```javascript
// WOFF2 Functions Usage:
import { compressWoff2, decompressWoff2, infoWoff2 } from './js/Woff2-Wasm.js';

// Compress TTF → WOFF2
// Input: Uint8Array (TTF font data)
// Output: Promise<Uint8Array> (Compressed WOFF2 data)
woff2Data = await compressWoff2(ttfData);

// Decompress WOFF2 → TTF
// Input: Uint8Array (WOFF2 font data)
// Output: Promise<Uint8Array> (Restored TTF data)
ttfData = await decompressWoff2(woff2Data);

// WOFF2 Font Information
// Input: Uint8Array (WOFF2 font data)
// Output: Promise<string> (Font metadata as string)
fontInfo = await infoWoff2(woff2Data);
```

## API Reference
#### ``compressWoff2(input: Uint8Array): Promise<Uint8Array>``
#### ``decompressWoff2(input: Uint8Array): Promise<Uint8Array>``  
#### ``infoWoff2(input: Uint8Array): Promise<string>``

## Browser Support
This project requires a modern browser with WebAssembly support:
- Chrome 57+
- Firefox 52+ 
- Safari 11+
- Edge 16+

## License
This project is licensed under:
- **GNU General Public License v3.0** - See [gpl.txt](gpl-3.0.txt)

### Third-party Licenses
The **[WOFF2](https://github.com/google/woff2)** library is licensed under the MIT License.  
**[Emscripten](https://github.com/emscripten-core/emsdk)** is available under 2 licenses, the MIT license and the University of Illinois/NCSA Open Source License

## Acknowledgments
- Google [WOFF2](https://github.com/google/woff2) team for the excellent compression library
- [Emscripten](https://github.com/emscripten-core/emsdk) team for making C++ to WebAssembly compilation possible
- [WebAssembly community](https://www.w3.org/community/webassembly/) for continuous improvements

---
### ⚠️ **LEGAL NOTICE** ⚠️
This project is intended for legal font conversion.  
Ensure you have appropriate rights and licenses to convert and use any fonts.  
The authors are not responsible for Copyright infringement.