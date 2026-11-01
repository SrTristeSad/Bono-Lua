import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFileSync} from 'node:fs';
const ctx=vm.createContext({});
for(const file of ['web/demo/rig-editor.js','web/demo/timeline-editor.js'])
  vm.runInContext(readFileSync(file,'utf8'),ctx,{filename:file});
const editor=ctx.BonoTimelineEditor;
const sample=JSON.parse(readFileSync('tests/fixtures/personagem-minimo.json','utf8'));

test('localizar keyframes de translação existentes e quadros acumulados',()=>{
  const keys=editor.frames(sample,'PersonagemA','walk','upperArm','translate');
  assert.equal(keys.length,2);
  assert.equal(keys[0].start,0);assert.equal(keys[0].duration,24);
  assert.equal(keys[1].start,24);assert.equal(keys[1].x,12);
});
test('alterar apenas valor X/Y sem mudar duração ou outros canais',()=>{
  const draft=ctx.BonoRigEditor.clone(sample);
  const backup=ctx.BonoRigEditor.clone(sample);
  const changed=editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','translate',1,{x:88,y:-14});
  assert.equal(changed.x,88);
  assert.equal(changed.y,-14);
  assert.equal(draft.armature[0].animation[1].bone[0].translateFrame[1].duration,24);
  assert.equal(JSON.stringify(draft.armature[0].bone),JSON.stringify(backup.armature[0].bone));
  assert.equal(JSON.stringify(draft.armature[0].skin),JSON.stringify(backup.armature[0].skin));
  assert.equal(JSON.stringify(draft.armature[0].slot),JSON.stringify(backup.armature[0].slot));
  assert.equal(JSON.stringify(draft.armature[0].animation[0]),JSON.stringify(backup.armature[0].animation[0]));
  assert.equal(backup.armature[0].animation[1].bone[0].translateFrame[1].x,12);
});
test('rotação preserva interpolação e frames existentes',()=>{
  const draft=ctx.BonoRigEditor.clone(sample);
  draft.armature[0].animation[1].bone[0].rotateFrame=[
    {duration:12,tweenEasing:0,rotate:15},{duration:36,tweenEasing:0,rotate:35}
  ];
  editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','rotate',0,{rotate:-20});
  assert.equal(draft.armature[0].animation[1].bone[0].rotateFrame[0].rotate,-20);
  assert.equal(draft.armature[0].animation[1].bone[0].rotateFrame[0].tweenEasing,0);
  assert.equal(draft.armature[0].animation[1].bone[0].rotateFrame[0].duration,12);
});
test('suporta durações implícitas sem alterar o comprimento da timeline',()=>{
  const draft=ctx.BonoRigEditor.clone(sample);
  draft.armature[0].animation[1].bone[0].translateFrame=[{x:1},{duration:3,x:2},{duration:44,x:4}];
  const keys=editor.frames(draft,'PersonagemA','walk','upperArm','translate');
  assert.equal(keys[1].start,1);
  assert.equal(keys[2].start,4);
});
test('recusa índices, canais e valores inválidos sem mutação',()=>{
  const draft=ctx.BonoRigEditor.clone(sample);
  const before=JSON.stringify(draft);
  assert.throws(()=>editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','translate',99,{x:5,y:1}),/Keyframe/);
  assert.throws(()=>editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','translate',0,{x:NaN,y:1}),/inválido/);
  assert.throws(()=>editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','rotate',0,{rotate:1}),/Keyframe/);
  assert.throws(()=>editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','scale',0,{x:1,y:1}),/Canal/);
  assert.equal(JSON.stringify(draft),before);
});
test('não editar marcador terminal fora da duração',()=>{
  const draft=ctx.BonoRigEditor.clone(sample);
  draft.armature[0].animation[1].bone[0].translateFrame=[{duration:48,x:0,y:0},{duration:0,x:1,y:2}];
  assert.throws(()=>editor.editExistingFrame(draft,'PersonagemA','walk','upperArm','translate',1,{x:2,y:3}),/encerramento/);
});
