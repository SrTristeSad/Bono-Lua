import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import vm from 'node:vm';

const built = resolve('dist/original/dragonBones.js');
const fixture = resolve('tests/fixtures/personagem-minimo.json');

function runtimeOrSkip(t) {
  if (!existsSync(built)) {
    t.skip('Compilação original ausente: npm run original:build');
    return null;
  }
  const context = vm.createContext({ console });
  vm.runInContext(readFileSync(built, 'utf8'), context, {
    filename: 'dragonBones.js', timeout: 5000
  });
  assert.ok(context.dragonBones, 'namespace global dragonBones');
  return context.dragonBones;
}

test('runtime compilado publica as classes originais fundamentais', t => {
  const db = runtimeOrSkip(t);
  if (!db) return;
  for (const cls of [
    'Matrix', 'Point', 'Transform', 'Bone', 'Armature',
    'Animation', 'AnimationState', 'ObjectDataParser', 'WorldClock'
  ]) assert.equal(typeof db[cls], 'function', cls);
});

test('matrizes DragonBones transformam e restauram um ponto', t => {
  const db = runtimeOrSkip(t);
  if (!db) return;
  const matrix = new db.Matrix(2, 0, 0, 3, 10, -5);
  const output = new db.Point();
  matrix.transformPoint(3, 4, output);
  assert.equal(output.x, 16);
  assert.equal(output.y, 7);
  matrix.invert();
  matrix.transformPoint(output.x, output.y, output);
  assert.ok(Math.abs(output.x - 3) < 1e-9);
  assert.ok(Math.abs(output.y - 4) < 1e-9);
});

test('parser original importa armadura hierárquica e animações', t => {
  const db = runtimeOrSkip(t);
  if (!db) return;
  const raw = JSON.parse(readFileSync(fixture, 'utf8'));
  const parsed = db.ObjectDataParser.getInstance().parseDragonBonesData(raw);
  assert.ok(parsed, 'parser retornou dados');
  const armature = parsed.getArmature('PersonagemA');
  assert.ok(armature, 'armadura existente');
  assert.equal(armature.getBone('forearm').parent.name, 'upperArm');
  assert.equal(armature.getBone('upperArm').parent.name, 'root');
  assert.ok(armature.getSlot('forearm'), 'slot carregado');
  const idle = armature.getAnimation('idle');
  const walk = armature.getAnimation('walk');
  assert.ok(idle);
  assert.ok(walk);
  assert.equal(idle.frameCount, 24);
  assert.equal(walk.frameCount, 48);
  assert.equal(walk.duration, 2);
});

test('WorldClock avança animações registradas com duração explícita', t => {
  const db = runtimeOrSkip(t);
  if (!db) return;
  const clock = new db.WorldClock(0);
  let elapsed = 0;
  const animated = { advanceTime(dt) { elapsed += dt; } };
  clock.add(animated);
  clock.advanceTime(0.25);
  clock.advanceTime(0.75);
  assert.equal(elapsed, 1);
  clock.remove(animated);
  clock.advanceTime(1);
  assert.equal(elapsed, 1);
});
