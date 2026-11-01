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


test('inserir no meio do intervalo sem mudar a duracao do clipe',()=>{
  const d=ctx.BonoRigEditor.clone(sample),clip=d.armature[0].animation[1];
  const prior=JSON.stringify(clip.bone[0]);
  const inserted=editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',10);
  assert.equal(inserted.start,10);
  assert.equal(inserted.duration,14);
  assert.deepEqual(JSON.parse(JSON.stringify(editor.frames(d,'PersonagemA','walk','upperArm','translate').map(k=>[k.start,k.duration]))),[[0,10],[10,14],[24,24]]);
  assert.equal(clip.duration,48);
  assert.equal(clip.bone[0].translateFrame[1].x,0);
  assert.equal(clip.bone[0].translateFrame[2].x,12);
  assert.notEqual(JSON.stringify(clip.bone[0]),prior);
});
test('apagar frame intermediario redistribui seus quadros e preserva outros canais',()=>{
  const d=ctx.BonoRigEditor.clone(sample);
  editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',10,{x:5,y:2});
  const arm=d.armature[0];
  const savedAnimations=JSON.stringify(arm.animation[0]);
  const updated=editor.removeFrame(d,'PersonagemA','walk','upperArm','translate',1);
  assert.equal(updated.index,0);
  assert.deepEqual(JSON.parse(JSON.stringify(editor.frames(d,'PersonagemA','walk','upperArm','translate').map(k=>[k.start,k.duration]))),[[0,24],[24,24]]);
  assert.equal(JSON.stringify(arm.animation[0]),savedAnimations);
});
test('ajustar a duracao redistribui somente dois intervalos vizinhos',()=>{
  const d=ctx.BonoRigEditor.clone(sample);
  editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',8);
  const edited=editor.setFrameDuration(d,'PersonagemA','walk','upperArm','translate',0,5);
  assert.equal(edited.duration,5);
  assert.deepEqual(JSON.parse(JSON.stringify(editor.frames(d,'PersonagemA','walk','upperArm','translate').map(k=>[k.start,k.duration]))),[[0,5],[5,19],[24,24]]);
  assert.equal(d.armature[0].animation[1].duration,48);
});
test('preservar marcador final (duration 0) e nao o editar',()=>{
  const d=ctx.BonoRigEditor.clone(sample);
  d.armature[0].animation[1].bone[0].translateFrame=[
    {duration:24,x:0,y:0},{duration:24,x:9,y:7},{duration:0,x:0,y:0}
  ];
  const inserted=editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',30);
  assert.equal(inserted.start,30);
  const entries=editor.frames(d,'PersonagemA','walk','upperArm','translate');
  assert.deepEqual(entries.map(k=>[k.start,k.duration]),[[0,24],[24,6],[30,18],[48,0]]);
  assert.equal(editor.removeFrame(d,'PersonagemA','walk','upperArm','translate',2).index,1);
  assert.deepEqual(JSON.parse(JSON.stringify(editor.frames(d,'PersonagemA','walk','upperArm','translate').map(k=>[k.start,k.duration]))),[[0,24],[24,24],[48,0]]);
  assert.throws(()=>editor.removeFrame(d,'PersonagemA','walk','upperArm','translate',2),/primeiro quadro/);
});
test('inserir frame com valores explicitos e sem duplicar eventos',()=>{
  const d=ctx.BonoRigEditor.clone(sample), raw=d.armature[0].animation[1].bone[0].translateFrame[0];
  raw.actions=[{gotoAndPlay:'next'}];
  raw.tweenEasing=0.5;
  editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',6,{x:22,y:-12});
  const frames=d.armature[0].animation[1].bone[0].translateFrame;
  assert.equal(frames[1].x,22);assert.equal(frames[1].y,-12);
  assert.equal(frames[1].tweenEasing,0.5);
  assert.equal(frames[1].actions,undefined);
  assert.equal(frames[0].actions[0].gotoAndPlay,'next');
});
test('recusar operacoes fora de alcance sem alterar o JSON',()=>{
  const d=ctx.BonoRigEditor.clone(sample);
  const before=JSON.stringify(d);
  for(const at of [-1,0,24,48,49,3.2]) {
    assert.throws(()=>editor.insertFrame(d,'PersonagemA','walk','upperArm','translate',at),/quadro|existe/);
    assert.equal(JSON.stringify(d),before);
  }
  assert.throws(()=>editor.removeFrame(d,'PersonagemA','walk','upperArm','translate',0),/primeiro quadro/);
  assert.throws(()=>editor.setFrameDuration(d,'PersonagemA','walk','upperArm','translate',0,0),/inteira/);
  assert.throws(()=>editor.setFrameDuration(d,'PersonagemA','walk','upperArm','translate',0,48),/ao menos um/);
  assert.throws(()=>editor.setFrameDuration(d,'PersonagemA','walk','upperArm','translate',1,6),/dois keyframes/);
  assert.equal(JSON.stringify(d),before);
});
test('operacoes na rotacao preservam skew de outros canais e duracao',()=>{
  const d=ctx.BonoRigEditor.clone(sample);
  const bone=d.armature[0].animation[1].bone[0];
  bone.rotateFrame=[{duration:48,tweenEasing:0,rotate:10},{duration:0,rotate:10}];
  const inserted=editor.insertFrame(d,'PersonagemA','walk','upperArm','rotate',8,{rotate:45});
  assert.equal(inserted.rotate,45);
  assert.equal(bone.rotateFrame[1].duration,40);
  assert.deepEqual(Array.from(editor.frames(d,'PersonagemA','walk','upperArm','rotate'),k=>k.start),[0,8,48]);
  assert.equal(d.armature[0].animation[1].duration,48);
});
