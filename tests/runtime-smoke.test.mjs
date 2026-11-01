import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import vm from 'node:vm';

const output=resolve('dist/original/dragonBones.js');
test('compiled upstream exposes essential runtime classes', t=>{
  if(!existsSync(output)) {t.skip('run npm run original:build first');return;}
  const context=vm.createContext({console});
  vm.runInContext(readFileSync(output,'utf8'),context,{filename:'dragonBones.js',timeout:5000});
  const db=context.dragonBones;
  assert.ok(db,'dragonBones namespace');
  for(const cls of ['Matrix','Transform','Bone','Armature','Animation','AnimationState','ObjectDataParser','WorldClock']) {
    assert.equal(typeof db[cls],'function',cls);
  }
  const matrix=new db.Matrix();
  assert.equal(matrix.a,1);assert.equal(matrix.d,1);
  assert.equal(matrix.tx,0);assert.equal(matrix.ty,0);
  const point=matrix.transformPoint(5,9, new db.Point());
  assert.equal(point.x,5);assert.equal(point.y,9);
});
