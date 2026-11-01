import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';

const context = vm.createContext({});
for (const file of ['web/demo/rig-editor.js','web/demo/visual-inspector.js']) {
  vm.runInContext(readFileSync(file,'utf8'), context, { filename:file });
}
const inspector = context.BonoVisualInspector;

test('slots vinculam osso, ordem e displays por skin', () => {
  const raw = {
    armature:[{
      name:'Personagem',
      bone:[{name:'root'}, {name:'arm',parent:'root'}],
      slot:[{name:'hand',parent:'arm',displayIndex:1}, {name:'face',parent:'root'}],
      skin:[{name:'default',slot:[
        {name:'hand',display:[{name:'open',type:'image'},{name:'closed',type:'mesh'}]},
        {name:'face',display:[{name:'smile'}]}
      ]}]
    }]
  };
  const slots = inspector.slotList(raw,'Personagem');
  assert.equal(slots.length,2);
  assert.equal(slots[0].parent,'arm');
  assert.equal(slots[0].displayIndex,1);
  assert.equal(slots[0].zOrder,0);
  assert.equal(slots[0].displays.length,2);
  assert.equal(slots[0].displays[1].type,'mesh');
  assert.equal(slots[1].displays[0].name,'smile');
});

test('calcular ponto da articulação usando matriz do DragonBones e Pixi', () => {
  const display = { toGlobal({x,y}) { return {x:x*0.7+480,y:y*0.7+310}; } };
  const point = inspector.screenPoint(display, {globalTransformMatrix:{tx:100,ty:-80}});
  assert.equal(point.x,550);
  assert.equal(point.y,254);
  assert.equal(inspector.screenPoint(display, {globalTransformMatrix:{tx:NaN,ty:3}}),null);
});

test('posições de todos ossos incluem nome original para seleção visual', () => {
  const raw = {armature:[{name:'Mecha',bone:[{name:'root'},{name:'hand',parent:'root'}]}]};
  const bones = new Map([
    ['root',{globalTransformMatrix:{tx:0,ty:0}}],
    ['hand',{globalTransformMatrix:{tx:10,ty:-5}}]
  ]);
  const model = {
    spec:{armature:'Mecha'}, document:raw,
    display:{toGlobal(point){return {x:point.x+500,y:point.y+200};},armature:{getBone(name){return bones.get(name);}}}
  };
  const positions = inspector.bonePositions(model);
  assert.equal(positions.length,2);
  assert.equal(positions[1].name,'hand');
  assert.equal(positions[1].x,510);
  assert.equal(positions[1].y,195);
});
