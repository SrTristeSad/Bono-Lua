import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, sep, extname } from 'node:path';

const root = resolve('web/demo');
const contentTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml'
};
const port = Number(process.env.PORT || 4173);
if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('PORT inválida');
const server = createServer(async (request, response) => {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    response.writeHead(405); response.end('Method not allowed'); return;
  }
  try {
    const url = new URL(request.url ?? '/', 'http://localhost');
    let path = decodeURIComponent(url.pathname);
    if (path === '/') path = '/index.html';
    const full = resolve(root, '.' + path);
    if (full !== root && !full.startsWith(root + sep)) {
      response.writeHead(403); response.end('Forbidden'); return;
    }
    const info = await stat(full);
    if (!info.isFile()) { response.writeHead(404); response.end('Not found'); return; }
    const body = await readFile(full);
    response.writeHead(200, {
      'Content-Type': contentTypes[extname(full)] ?? 'application/octet-stream',
      'Content-Length': body.length,
      'Cache-Control': 'no-store',
      'X-Content-Type-Options': 'nosniff'
    });
    response.end(request.method === 'HEAD' ? undefined : body);
  } catch {
    response.writeHead(404); response.end('Not found');
  }
});
server.listen(port, '127.0.0.1', () => console.log('Bono-Lua demo: http://127.0.0.1:' + port));
