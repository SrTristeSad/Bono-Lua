import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import vm from 'node:vm';

const context=vm.createContext({});
vm.runInContext(readFileSync(resolve('web/demo/rig-editor.js'),'utf8'),context);
const rig=context.BonoRigEditor;
const source=JSON.parse(readFileSync('tests/fixtures/personagem-minimo.json','utf8'));

test('hierarquia de ossos preserva pais e filhos',()=>{
  const nodes=rig.hierarchy(source,'PersonagemA');
  assert.equal(nodes.length,3);
  assert.equal(nodes[0].name,'root');
  assert.equal(nodes[1].parent,'root');
  assert.equal(nodes[2].parent,'upperArm');
  assert.equal(nodes[2].depth,2);
});

test('alterar transform do osso sem modificar o JSON original',()=>{
  const draft=rig.clone(source);
  const pose=rig.pose(draft,'PersonagemA','upperArm');
  rig.setPose(draft,'PersonagemA','upperArm',{x:pose.x+12,y:pose.y-7,rotation:25});
  assert.equal(rig.pose(draft,'PersonagemA','upperArm').x,pose.x+12);
  assert.equal(rig.pose(draft,'PersonagemA','upperArm').rotation,25);
  assert.equal(rig.pose(source,'PersonagemA','upperArm').x,pose.x);
  assert.equal(JSON.parse(rig.serialize(draft)).armature[0].bone[1].transform.rotate,25);
});

test('rotação legacy skX/skY preserva skew, sem destruir escala e outras propriedades',()=>{
  const raw={armature:[{name:'Legacy',bone:[{name:'arm',transform:{x:2,y:8,skY:20,skX:35,scX:1.5,scY:0.8}}]}]};
  const draft=rig.clone(raw);
  const next=rig.setPose(draft,'Legacy','arm',{x:4,y:12,rotation:30});
  assert.equal(next.rotation,30);
  const t=rig.rawBone(draft,'Legacy','arm').transform;
  assert.equal(t.skX,45);
  assert.equal(t.skY,30);
  assert.equal(t.scX,1.5);
  assert.equal(t.scY,0.8);
});

test('offset no runtime DragonBones equivale a diferença entre pose original e editada',()=>{
  let invalidated=false;
  const runtimeBone={
    offset:{x:0,y:0,rotation:0,skew:0},
    invalidUpdate(){invalidated=true;}
  };
  rig.applyRuntimeOffset(runtimeBone,{x:10,y:1,rotation:30},{x:17,y:4,rotation:45},2);
  assert.equal(runtimeBone.offset.x,14);
  assert.equal(runtimeBone.offset.y,6);
  assert.ok(Math.abs(runtimeBone.offset.rotation-Math.PI/12)<1e-9);
  assert.equal(runtimeBone.offset.skew,0);
  assert.ok(invalidated);
});

test('recusar valores não finitos e restaurar sem perda',()=>{
  const raw=rig.clone(source);
  assert.throws(()=>rig.setPose(raw,'PersonagemA','forearm',{x:Infinity,y:0,rotation:0}),/finitos/);
  const base=rig.pose(source,'PersonagemA','forearm');
  rig.setPose(raw,'PersonagemA','forearm',{x:12,y:4,rotation:90});
  rig.setPose(raw,'PersonagemA','forearm',base);
  const restored=rig.pose(raw,'PersonagemA','forearm');
  assert.equal(restored.x,base.x);
  assert.equal(restored.y,base.y);
  assert.equal(restored.rotation,base.rotation);
});
