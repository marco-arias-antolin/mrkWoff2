/**
 * Downloads a Uint8Array as a file in the browser
 * @param {Uint8Array} uint8Array - Binary data to download
 * @param {string} fileName - Name for the downloaded file (with extension)
*/
export async function download(uint8Array, fileName) {
	const extension = fileName.split('.').pop().toLowerCase();
	const mime = { "ttf": "font/ttf", "woff2": "font/woff2" }
	const mimeType = mime[extension] || 'application/octet-stream';

	const blob = new Blob([uint8Array], { type: mimeType });
	const url = URL.createObjectURL(blob);

	const link = document.createElement('a');
	link.href = url;
	link.download = fileName;
	link.style.display = 'none';

	document.body.appendChild(link);
	link.click();
	document.body.removeChild(link);

	URL.revokeObjectURL(url);
}