import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { UPSTREAM } from '../upstream.lock.mjs';
const destination = resolve('vendor', 'DragonBonesJS');
if (!existsSync(destination)) {
  console.error('Upstream ausente. Execute npm run upstream:clone.');
  process.exit(1);
}
const p = spawnSync('git', ['-C', destination, 'rev-parse', 'HEAD'], { encoding: 'utf8' });
if (p.status !== 0) { console.error(p.stderr); process.exit(1); }
const revision = p.stdout.trim();
console.log('Obtido:', revision, 'Esperado:', UPSTREAM.commit);
if (revision !== UPSTREAM.commit) process.exit(1);
