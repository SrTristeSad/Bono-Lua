'use strict';
// Compare ActionTimelineState, real event/action queues and interface observers.
const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const ts=require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2]||'../DragonBonesJS'),lua=process.argv[3]||'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...a)=>cp.execFileSync('git',['-C',upstream,...a],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN)throw Error('Wrong upstream HEAD');
// Compile the common namespace together: transpileModule(file-by-file) cannot
// resolve cross-file namespace references such as CanvasData extends BaseObject.
const prefix='/pinned/';
const files=git('ls-tree','-r','--name-only',PIN,'DragonBones/src').trim().split('\n').filter(p=>p.endsWith('.ts'));
const texts=new Map(files.map(p=>[prefix+p,git('show',PIN+':'+p)]));
const config=ts.parseConfigFileTextToJson('tsconfig.json',git('show',PIN+':DragonBones/tsconfig.json')).config;
const converted=ts.convertCompilerOptionsFromJson(config.compilerOptions,prefix+'DragonBones');
const options={...converted.options,declaration:false,watch:false};delete options.outFile;
const host=ts.createCompilerHost(options),read=host.readFile.bind(host),exists=host.fileExists.bind(host);
host.getCurrentDirectory=()=>prefix;
host.readFile=p=>p.startsWith(prefix)?texts.get(p):read(p);
host.fileExists=p=>p.startsWith(prefix)?texts.has(p):exists(p);
host.getSourceFile=(p,version)=>{const text=host.readFile(p);return text===undefined?undefined:ts.createSourceFile(p,text,version,true);};
const emitted=new Map();host.writeFile=(p,text)=>emitted.set(p,text);
const program=ts.createProgram([...texts.keys()],options,host);
const diagnostics=program.getSyntacticDiagnostics();
if(diagnostics.length)throw Error('Cannot parse pinned core');
const emitResult=program.emit();if(emitResult.emitSkipped)throw Error('Original emit skipped');
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint','animation/BaseTimelineState','animation/TimelineState','animation/AnimationState'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');


const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_frameCount','_position','_duration'];
const cases=[];for(let frames=0;frames<3;frames++)for(let enabled=0;enabled<2;enabled++)for(let parent=0;parent<2;parent++)for(let reverse=0;reverse<2;reverse++)for(const play of [0,1,2])for(let listeners=0;listeners<4;listeners++)for(let reset=0;reset<2;reset++)cases.push([frames,enabled,parent,reverse,play,listeners,reset,'normal']);
for(const op of ['reinit','seek','interval','readonly','missingProxy','foreign','clear','displayControlOff','precision'])cases.push([2,1,0,0,2,1,1,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[7]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
const fixture=fs.readFileSync(path.join(root,'examples/actiontimeline_ske.json'),'utf8');
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function execute(c){const [frames,enabled,parent,reverse,play,listeners,reset,op]=c;ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx);if(op==='precision'){raw.armature[0].animation[0].frame[0].duration=5;raw.armature[0].animation[0].frame[1].duration=6;raw.armature[0].animation[0].frame[2].duration=13;}if(frames===1){raw.armature[0].animation[0].frame.length=1;raw.armature[0].animation[0].frame[0].duration=24;}
 const gd=new d.ObjectDataParser().parseDragonBonesData(raw),ad=gd.getArmature('ik-demo'),arm=B.borrowObject(d.Armature),p=B.borrowObject(d.ActionTimelineState);arm._armatureData=ad;for(const bd of ad.sortedBones)B.borrowObject(d.Bone).init(bd,arm);
 class SlotObserver extends d.Slot{static toString(){return'[test.ActionSlot]';}_initDisplay(){}_disposeDisplay(){}_onUpdateDisplay(){}_addDisplay(){}}B.clearPool(SlotObserver);for(const sd of ad.sortedSlots)B.borrowObject(SlotObserver).init(sd,arm,null,null);
 let foreign=null,anim=ad.getAnimation('events');if(op==='foreign'){ctx.__json=fixture;const r=vm.runInContext('JSON.parse(__json)',ctx);r.armature[0].animation[0].frame[1].event='foreign-step';foreign=new d.ObjectDataParser().parseDragonBonesData(r);anim=foreign.getArmature('ik-demo').getAnimation('events');}
 const actions=anim.parent.actions,checks=[],localEvents=[],globalEvents=[];let clears=0;
 const state={animationData:anim,_actionTimeline:p,_position:op==='interval'?.25:0,_duration:op==='interval'?.5:1,playTimes:play,currentPlayTimes:0,_playheadState:3,_parent:parent?{}:null,actionEnabled:!!enabled,displayControl:op!=='displayControlOff',resetToPose:!!reset,timeScale:reverse?-1:1};
 function event(e){return[e.type,e.name,scalar(e.time),e.armature===arm,e.animationState===state,actions.indexOf(e.actionData),e.bone?e.bone.name:'nil',e.slot?e.slot.name:'nil',e.actionData?e.data===e.actionData.data:e.data===null,e._isInPool].join('~');}
 const proxy={hasDBEventListener(type){checks.push(type);return listeners===1||listeners===2&&type==='frameEvent'||listeners===3&&type!=='frameEvent';},dispatchDBEvent(type,e){localEvents.push(event(e));},dbClear(){clears++;}};
 const manager={dispatchDBEvent(type,e){globalEvents.push(event(e));}};const core=new d.DragonBones(manager);arm._dragonBones=core;arm._proxy=op==='missingProxy'?null:proxy;arm._sortZOrder([2,0,1],0);p.init(arm,state,frames===0?null:anim.actionTimeline);const out=[];
 function snap(status){out.push(status,...keys.map(k=>scalar(p[k])),String(arm.eventDispatcher===proxy),String(arm._zOrderDirty),String(arm._slotsDirty),arm.getSlots().map(s=>scalar(s._zOrder)).join(','),String(core._events.length),core._events.map(event).join('|'),String(arm._actions.length),arm._actions.map(event).join('|'),String(core._objects.length),core._objects.map(event).join('|'),checks.join(','),localEvents.join('|'),globalEvents.join('|'));}
 for(let i=0;i<8;i++){checks.length=localEvents.length=globalEvents.length=0;arm._slotsDirty=false;let status='ok';try{if(op==='readonly'&&i===0)arm.eventDispatcher={};if(op==='seek'&&i===2)p.setCurrentTime(.4);if(op==='reinit'&&i===2)p.init(arm,state,null);p.update((reverse?-1:1)*[0,.125,.3,.6,1.1,2.1,2.1,.4][i]);}catch(e){status='error';}snap(status);status='dispatch';try{core.advanceTime(0);}catch(e){status='error';}snap(status);}
 if(op==='clear')p._onClear();p.returnToPool();snap('clear');arm._proxy=proxy;core.advanceTime(0);arm.returnToPool();out.push(String(p._isInPool),String(clears),String(core._events.length),String(core._objects.length),String(arm._actions.length),String(p._armature===null));if(foreign)foreign.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'actiontimeline-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'actiontimeline-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/actiontimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'actiontimeline-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,errors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')errors++;if(rows[i][j]!==expected[i][j])throw Error('Action timeline mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'actiontimeline-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
