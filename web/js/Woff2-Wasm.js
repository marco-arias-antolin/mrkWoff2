import createWoff2Module from './Woff2-Wasm_ems.js';

const ModulePromise = createWoff2Module();

let _readyDone = false;
let ModuleRef = null;

function readUint32FromPtr(Module, ptr) {
	return Module.HEAPU32[ptr >> 2];
}

function readNullTerminatedString(Module, ptr) {
	const heap = Module.HEAPU8;
	let end = ptr;
	while (heap[end] !== 0) end++;
	const bytes = heap.subarray(ptr, end);
	return new TextDecoder().decode(bytes);
}

async function _ready() {
	if (_readyDone) return ModuleRef;
	ModuleRef = await ModulePromise;
	if (typeof ModuleRef._compress_woff2 !== 'function') {
		throw new Error('WASM function _compress_woff2 not found in Module.');
	}
	if (typeof ModuleRef._decompress_woff2 !== 'function') {
		throw new Error('WASM function _decompress_woff2 not found in Module.');
	}
	if (typeof ModuleRef._info_woff2 !== 'function') {
		throw new Error('WASM function _info_woff2 not found in Module.');
	}
	_readyDone = true;
	return ModuleRef;
}

/**
 * Compresses TTF font data to WOFF2 format
 * @param {Uint8Array} inputUint8 - Input TTF font as Uint8Array
 * @returns {Promise<Uint8Array>} Compressed WOFF2 data as Uint8Array
 * @throws {Error} If compression fails or input is invalid
 */
export async function compressWoff2(inputUint8) {
	const Module = await _ready();

	const inputLen = inputUint8.byteLength;
	const inPtr = Module._malloc(inputLen);
	if (!inPtr) throw new Error('malloc failed');

	try {
		Module.HEAPU8.set(inputUint8, inPtr);

		const outLenPtr = Module._malloc(4);
		if (!outLenPtr) throw new Error('malloc failed for outLenPtr');

		try {
			const outPtr = Module._compress_woff2(inPtr, inputLen, outLenPtr);
			if (outPtr === 0) throw new Error('compress_woff2 failed (returned NULL)');

			const outLen = readUint32FromPtr(Module, outLenPtr);
			const result = Module.HEAPU8.subarray(outPtr, outPtr + outLen);
			const copy = new Uint8Array(result);
			Module._free(outPtr);
			return copy;
		} finally {
			Module._free(outLenPtr);
		}
	} finally {
		Module._free(inPtr);
	}
}

/**
 * Decompresses WOFF2 font data back to TTF format
 * @param {Uint8Array} inputUint8 - Input WOFF2 font data as Uint8Array
 * @returns {Promise<Uint8Array>} Decompressed TTF data as Uint8Array
 * @throws {Error} If decompression fails or input is invalid
 */
export async function decompressWoff2(inputUint8) {
	const Module = await _ready();

	const inputLen = inputUint8.byteLength;
	const inPtr = Module._malloc(inputLen);
	if (!inPtr) throw new Error('malloc failed');

	try {
		Module.HEAPU8.set(inputUint8, inPtr);

		const outLenPtr = Module._malloc(4);
		if (!outLenPtr) throw new Error('malloc failed for outLenPtr');

		try {
			const outPtr = Module._decompress_woff2(inPtr, inputLen, outLenPtr);
			if (outPtr === 0) throw new Error('decompress_woff2 failed (returned NULL)');

			const outLen = readUint32FromPtr(Module, outLenPtr);
			const result = Module.HEAPU8.subarray(outPtr, outPtr + outLen);
			const copy = new Uint8Array(result);
			Module._free(outPtr);
			return copy;
		} finally {
			Module._free(outLenPtr);
		}
	} finally {
		Module._free(inPtr);
	}
}

/**
 * Extracts metadata and information from WOFF2 font file
 * @param {Uint8Array} inputUint8 - Input WOFF2 font data as Uint8Array
 * @returns {Promise<Object>} Font metadata object containing information
 * @throws {Error} If info extraction fails or input is invalid
 */
export async function infoWoff2(inputUint8) {
	const Module = await _ready();

	const inputLen = inputUint8.byteLength;
	const inPtr = Module._malloc(inputLen);
	if (!inPtr) throw new Error('malloc failed');

	try {
		Module.HEAPU8.set(inputUint8, inPtr);

		const strPtr = Module._info_woff2(inPtr, inputLen);
		if (strPtr === 0) throw new Error('info_woff2 failed (returned NULL)');
		try {
			const info = readNullTerminatedString(Module, strPtr);
			return info;
		} finally {
			Module._free(strPtr);
		}
	} finally {
		Module._free(inPtr);
	}
}