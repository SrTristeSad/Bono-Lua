import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import vm from 'node:vm';

// Sample ORIGINAL do proprio repositorio DragonBonesJS, nao copiado aqui.
// A validação nao depende de imagens nem redistribui recursos do demo.
const upstreamSample = resolve('vendor/DragonBonesJS/Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.json');
const compiled = resolve('dist/original/dragonBones.js');

test('parser original importa exemplo real DragonBonesJS (20 ossos e animacao idle)', t => {
  if (!existsSync(compiled) || !existsSync(upstreamSample)) {
    t.skip('Execute npm run upstream:clone && npm run original:build');
    return;
  }
  const context = vm.createContext({ console });
  vm.runInContext(readFileSync(compiled, 'utf8'), context, { timeout: 5000 });
  const db = context.dragonBones;
  const raw = JSON.parse(readFileSync(upstreamSample, 'utf8'));
  const parsed = db.ObjectDataParser.getInstance().parseDragonBonesData(raw);
  assert.ok(parsed);
  assert.equal(parsed.name, 'mecha_1002_101d_show');
  const armature = parsed.getArmature('mecha_1002_101d');
  assert.ok(armature);
  assert.equal(armature.sortedBones.length, 20);
  assert.equal(armature.sortedSlots.length, 19);
  assert.equal(armature.getAnimation('idle').frameCount, 80);
});
