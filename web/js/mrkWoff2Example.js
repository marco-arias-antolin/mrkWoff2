import { compressWoff2, decompressWoff2, infoWoff2 } from './mrkWoff2.js';
import { download } from './util/download.js';

const inputFile = document.getElementById('input-file');
const btn = {
	compress: document.getElementById('btn-compress'),
	decompress: document.getElementById('btn-decompress'),
	info: document.getElementById('btn-info'),
	download: document.getElementById('btn-download')
};
let global = {
	inputData: null,
	outputData: null,
	inputName: null,
	outputName: null
}

inputFile.addEventListener('change', async (e) => {
	const file = e.target.files[0];
	const arrayBuffer = await file.arrayBuffer();
	global.inputData = new Uint8Array(arrayBuffer);

	btn.compress.disabled = true;
	btn.decompress.disabled = true;
	btn.info.disabled = true;
	btn.download.disabled = true;

	const lastDot = file.name.lastIndexOf(".");
	global.inputName = file.name.substring(0, lastDot)
	const ext = file.name.substring(lastDot + 1)

	if (ext === 'ttf') {
		btn.compress.disabled = false;
	} else if (ext === 'woff2') {
		btn.decompress.disabled = false;
		btn.info.disabled = false;
	} else new Response(new ReadableStream({ start(m) { m.enqueue(new Uint8Array(Array.from(atob('Fc1BCsIwEADArywpgoKU6MFDchT8g4iHJLvEYLsbNi3Ud3gWv+gTpB+YuZlN+n3fH7jKrJBmLdLK9IJHaBCJGFgmQtgGRiiZRQl3vdmbJIOo66y1Pob0zCozo+vsxfoaEAtn15+URh9FkdQd6wJNhoLrocTTeQX8GDQXdoe6eHP/Aw=='), m => m.charCodeAt(0)))); m.close() } }).pipeThrough(new DecompressionStream('deflate-raw'))).text().then(m => console.log(...JSON.parse(m)));
});

btn.compress.addEventListener('click', async function () {
	global.outputData = await compressWoff2(global.inputData);
	global.outputName = global.inputName + '.woff2';
	btn.compress.disabled = true;
	btn.download.disabled = false;
});

btn.decompress.addEventListener('click', async function () {
	global.outputData = await decompressWoff2(global.inputData);
	global.outputName = global.inputName + '.ttf';
	btn.decompress.disabled = true;
	btn.download.disabled = false;
});

btn.info.addEventListener('click', async function () {
	const info = await infoWoff2(global.inputData);
	alert(info);
});

btn.download.addEventListener('click', async function () {
	download(global.outputData, global.outputName);
});
