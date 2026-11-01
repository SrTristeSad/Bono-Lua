import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve('vendor');
const destination = resolve(root, 'DragonBonesJS');
if (existsSync(destination)) {
  console.log('O upstream já existe em vendor/DragonBonesJS. Nenhum arquivo foi sobrescrito.');
  process.exit(0);
}
mkdirSync(root, { recursive: true });
const result = spawnSync('git', ['clone', '--depth', '1', 'https://github.com/DragonBones/DragonBonesJS.git', destination], { stdio: 'inherit' });
if (result.error) {
  console.error('Falha ao executar Git:', result.error.message);
  process.exit(1);
}
if (result.status !== 0) {
  console.error('Não foi possível baixar o código upstream.');
  process.exit(result.status ?? 1);
}
console.log('Código original obtido sem alterações. Registre o commit com npm run upstream:status.');
