import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
const destination = resolve('vendor', 'DragonBonesJS');
if (!existsSync(destination)) {
  console.error('Upstream ausente. Execute npm run upstream:clone.');
  process.exit(1);
}
const result = spawnSync('git', ['-C', destination, 'rev-parse', 'HEAD'], { stdio: 'inherit' });
process.exit(result.status ?? 1);
