import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { UPSTREAM } from '../upstream.lock.mjs';

const base = resolve('vendor', 'DragonBonesJS');
const required = [
  'LICENSE',
  'DragonBones/src/dragonBones/geom/Matrix.ts',
  'DragonBones/src/dragonBones/geom/Transform.ts',
  'DragonBones/src/dragonBones/armature/Armature.ts',
  'DragonBones/src/dragonBones/armature/Bone.ts',
  'DragonBones/src/dragonBones/armature/Slot.ts',
  'DragonBones/src/dragonBones/animation/Animation.ts',
  'DragonBones/src/dragonBones/animation/AnimationState.ts',
  'DragonBones/src/dragonBones/parser/ObjectDataParser.ts',
  'DragonBones/src/dragonBones/parser/BinaryDataParser.ts'
];

test('revisão do upstream é SHA completo e imutável', () => {
  assert.match(UPSTREAM.commit, /^[0-9a-f]{40}$/);
  assert.equal(UPSTREAM.license, 'MIT');
});
test('módulos originais críticos estão presentes quando upstream instalado', (t) => {
  if (!existsSync(base)) { t.skip('Execute npm run upstream:clone para teste de integração'); return; }
  for (const path of required) assert.ok(existsSync(resolve(base, path)), 'Ausente: ' + path);
  const license = readFileSync(resolve(base, 'LICENSE'), 'utf8');
  assert.match(license, /MIT License/);
});
