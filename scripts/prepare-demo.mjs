import { copyFileSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { spawnSync } from 'node:child_process';
import { UPSTREAM } from '../upstream.lock.mjs';

const vendor = resolve('vendor/DragonBonesJS');
const output = resolve('web/demo');
const revision = spawnSync('git', ['-C', vendor, 'rev-parse', 'HEAD'], { encoding: 'utf8' });
if (revision.status !== 0 || revision.stdout.trim() !== UPSTREAM.commit) {
  console.error('O upstream não está instalado na revisão esperada. Execute npm run upstream:clone.');
  process.exit(1);
}

// The ORIGINAL PixiJS 8 adapter is built by DragonBones upstream.
// Keep it byte-for-byte, rather than replacing its runtime with a mock renderer.
const files = new Map([
  ['Pixi/Demos/8.x/libs/pixi/8.9.2/pixi.js', 'vendor/pixi.js'],
  ['Pixi/8.x/out/dragonBones.js', 'vendor/dragonBones-pixi8.js'],
  ['LICENSE', 'vendor/DRAGONBONES-LICENSE'],
  ['Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.json', 'assets/mecha_ske.json'],
  ['Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.json', 'assets/mecha_tex.json'],
  ['Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.png', 'assets/mecha_tex.png'],
  ['Cocos/Demos/assets/resources/mecha_1406/mecha_1406_ske.json', 'assets/mecha1406_ske.json'],
  ['Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.json', 'assets/mecha1406_tex.json'],
  ['Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.png', 'assets/mecha1406_tex.png']
]);
for (const [source, target] of files) {
  const from = resolve(vendor, source);
  const to = resolve(output, target);
  if (!existsSync(from)) throw new Error('Arquivo oficial ausente: ' + source);
  mkdirSync(dirname(to), { recursive: true });
  copyFileSync(from, to);
}
writeFileSync(resolve(output, 'vendor/source.json'), JSON.stringify({
  upstream: UPSTREAM.repository, commit: UPSTREAM.commit, renderer: 'PixiJS 8.9.2',
  source: Object.fromEntries(files)
}, null, 2) + '\n');
console.log('Demonstração pronta em web/demo/ — arquivos originais copiados sem alteração.');
