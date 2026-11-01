import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';
const context=vm.createContext({});
for (const file of ['web/demo/rig-editor.js','web/demo/slot-editor.js'])
  vm.runInContext(readFileSync(file,'utf8'),context,{filename:file});
const editor=context.BonoSlotEditor;
function sample() {
  return {
    version:'5.5',armature:[{
      name:'Hero',
      bone:[{name:'root'}],
      slot:[{name:'body',parent:'root',displayIndex:0},{name:'hand',parent:'root',displayIndex:1},{name:'head',parent:'root'}],
      skin:[{name:'default',slot:[
        {name:'body',display:[{name:'shirt',type:'image'}]},
        {name:'hand',display:[{name:'open',type:'image'},{name:'closed',type:'image'}]},
        {name:'head',display:[{name:'face',type:'image'}]}
      ]}],
      animation:[{name:'idle',duration:24,bone:[{name:'root',translateFrame:[{duration:24,x:1,y:0}]}]}]
    }]
  };
}
test('editar somente displayIndex do slot e preservar animações/skins',()=>{
  const raw=sample();const backup=structuredClone(raw);
  assert.equal(editor.getDisplayIndex(raw,'Hero','hand'),1);
  assert.equal(editor.getDisplayOptions(raw,'Hero','hand').length,2);
  assert.equal(editor.setDisplayIndex(raw,'Hero','hand',0),0);
  assert.equal(editor.getDisplayIndex(raw,'Hero','hand'),0);
  assert.equal(editor.setDisplayIndex(raw,'Hero','hand',-1),-1);
  assert.deepEqual(raw.armature[0].animation,backup.armature[0].animation);
  assert.deepEqual(raw.armature[0].skin,backup.armature[0].skin);
  assert.deepEqual(raw.armature[0].bone,backup.armature[0].bone);
});
test('índice de display inválido não altera o projeto',()=>{
  const raw=sample();const before=JSON.stringify(raw);
  for (const index of [-2,9,0.5,Infinity,NaN]) {
    assert.throws(()=>editor.setDisplayIndex(raw,'Hero','hand',index),/inválido/);
    assert.equal(JSON.stringify(raw),before);
  }
});
test('reordenar somente os slots, mantendo todas as propriedades',()=>{
  const raw=sample();
  assert.equal(editor.canReorder(raw,'Hero'),true);
  assert.equal(editor.moveSlot(raw,'Hero','body',1),1);
  assert.deepEqual(raw.armature[0].slot.map(s=>s.name),['hand','body','head']);
  assert.equal(editor.moveSlot(raw,'Hero','body',1),2);
  assert.deepEqual(raw.armature[0].slot.map(s=>s.name),['hand','head','body']);
  assert.equal(editor.moveSlot(raw,'Hero','body',1),2);
  assert.deepEqual(raw.armature[0].slot.map(s=>s.name),['hand','head','body']);
});
test('timeline de ordem Z bloqueia reordenação destrutiva',()=>{
  const raw=sample();
  raw.armature[0].animation[0].zOrder=[{duration:24,zOrder:[0,1]}];
  assert.equal(editor.canReorder(raw,'Hero'),false);
  const before=JSON.stringify(raw);
  assert.throws(()=>editor.moveSlot(raw,'Hero','body',1),/Z/);
  assert.equal(JSON.stringify(raw),before);
});
test('aplicar sequência original de slots na armadura runtime',()=>{
  const original=sample();
  const edited=structuredClone(original);
  editor.moveSlot(edited,'Hero','body',1);
  let observed=null, advanced=null;
  const runtime={
    _sortZOrder(values,offset){observed={values:[...values],offset};},
    advanceTime(dt){advanced=dt;}
  };
  editor.applyRuntimeOrder(runtime,original,edited,'Hero');
  assert.deepEqual(observed,{values:[1,0,2],offset:0});
  assert.equal(advanced,0);
});
test('atualizar display da API original em tempo zero',()=>{
  let actual=null, invalidated=false, dt=null;
  const slot={set displayIndex(v){actual=v},invalidUpdate(){invalidated=true;}};
  const runtime={getSlot(n){return n==='hand'?slot:null},advanceTime(v){dt=v;}};
  editor.applyRuntimeDisplay(runtime,'hand',-1);
  assert.equal(actual,-1);assert.ok(invalidated);assert.equal(dt,0);
});
