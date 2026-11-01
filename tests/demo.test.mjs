import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { resolve } from 'node:path';
import { UPSTREAM } from '../upstream.lock.mjs';

const root=resolve('web/demo');
test('viewer contains an actual original-runtime integration', () => {
  const html=readFileSync(resolve(root,'index.html'),'utf8');
  const js=readFileSync(resolve(root,'app.js'),'utf8');
  assert.match(html,/vendor\/pixi\.js/);
  assert.match(html,/vendor\/dragonBones-pixi8\.js/);
  assert.match(js,/factory\.parseDragonBonesData\(skeleton\)/);
  assert.match(js,/factory\.parseTextureAtlasData\(atlas, texture\.source\)/);
  assert.match(js,/factory\.buildArmatureDisplay\(/);
  assert.match(js,/PixiFactory\.advanceTime\(/);
});
test('demo built from pinned upstream has original assets', t => {
  const manifest=resolve(root,'vendor/source.json');
  if (!existsSync(manifest)) {
    t.skip('Execute npm run upstream:clone && npm run demo:prepare');
    return;
  }
  const source=JSON.parse(readFileSync(manifest,'utf8'));
  assert.equal(source.commit,UPSTREAM.commit);
  for(const path of [
    'vendor/pixi.js','vendor/dragonBones-pixi8.js','vendor/DRAGONBONES-LICENSE',
    'assets/mecha_ske.json','assets/mecha_tex.json','assets/mecha_tex.png'
  ]) assert.ok(statSync(resolve(root,path)).size>100,'Missing: '+path);
  const skeleton=JSON.parse(readFileSync(resolve(root,'assets/mecha_ske.json'),'utf8'));
  assert.equal(skeleton.armature[0].bone.length,20);
  assert.equal(skeleton.armature[0].slot.length,19);
  assert.ok(skeleton.armature[0].animation.some(a=>a.name==='idle'));
});
