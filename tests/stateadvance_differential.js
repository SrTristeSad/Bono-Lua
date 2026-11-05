'use strict';
// Compare AnimationState initialization, fades, masks and child wiring against the pin.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationConfig','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint','animation/BaseTimelineState','animation/TimelineState','animation/AnimationState','animation/Animation'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');



const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const fixture=fs.readFileSync(path.join(root,'examples/playback_ske.json'),'utf8');
const cases=[];for(let kind=0;kind<4;kind++)for(let reset=0;reset<2;reset++)for(const fade of [0,.25])for(const cache of [0,4])for(const rate of [1,-1])for(const weight of [0,.5,1.5])cases.push([kind,reset,fade,cache,rate,weight,'normal']);
for(const op of ['mask','stop','fadeOut','controllerGate','noDisplayControl','reuseBlend','noData','resetCache'])cases.push([0,1,.25,4,1,1,op]);
if(process.argv[4]){const n=+process.argv[4];cases.splice(0,cases.length,cases[n]);}
function scalar(v){if(v===null||v===undefined)return'u';if(typeof v==='boolean')return String(v);if(typeof v==='string')return's'+Buffer.from(v).toString('hex');if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const stateKeys=['_time','_weight','_weightResult','_fadeProgress','_fadeTime','_fadeState','_subFadeState','_timelineDirty','_playheadState','positionX','parameterX','_isInPool'];
const groups=['_boneTimelines','_boneBlendTimelines','_slotTimelines','_slotBlendTimelines','_constraintTimelines','_animationTimelines','_poseTimelines'];
function execute(c){const[kind,reset,fade,cache,rate,weight,op]=c;ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx),gd=new d.ObjectDataParser().parseDragonBonesData(raw),ad=gd.getArmature('playback');if(cache)ad.cacheFrames(cache);
const arm=B.borrowObject(d.Armature);arm._armatureData=ad;for(const bd of ad.sortedBones)B.borrowObject(bd.type===1?d.Surface:d.Bone).init(bd,arm);
const hooks=[];class Observer extends d.Slot{static toString(){return'[test.PlaybackSlot]';}}
for(const hook of ['_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'])Observer.prototype[hook]=function(){hooks.push(this.name+':'+hook);};
B.clearPool(Observer);for(const sd of ad.sortedSlots){const slot=B.borrowObject(Observer);slot.init(sd,arm,{},{});const displays=ad.defaultSkin.getDisplays(sd.name);slot.displayFrameCount=displays.length;displays.forEach((v,i)=>{slot.replaceRawDisplayData(v,i);slot.replaceDisplay(v.type===2?slot.meshDisplay:slot.rawDisplay,i);});slot._setDisplayIndex(0);slot._updateDisplayData();}
for(const name in ad.constraints){const ik=B.borrowObject(d.IKConstraint);ik.init(ad.constraints[name],arm);arm._addConstraint(ik);}
const dispatch=[],proxy={hasDBEventListener(){return true;},dispatchDBEvent(type,e){dispatch.push(type+'~'+e.name+'~'+scalar(e.time));},dbClear(){}};
const core=new d.DragonBones({dispatchDBEvent(type,e){dispatch.push('sound~'+e.name+'~'+scalar(e.time));}});arm._proxy=proxy;arm._dragonBones=core;
const manager=B.borrowObject(d.Animation);manager.init(arm);arm._animation=manager;const states=[],configs=[];
function add(name,layer){const cfg=B.borrowObject(d.AnimationConfig);cfg.animation=name;cfg.timeScale=rate;cfg.playTimes=kind===2?0:1;cfg.fadeInTime=fade;cfg.pauseFadeIn=false;cfg.weight=weight;cfg.layer=layer;cfg.group='group';cfg.autoFadeOutTime=.125;cfg.resetToPose=!!reset;cfg.displayControl=op!=='noDisplayControl';const s=B.borrowObject(d.AnimationState);s.init(arm,ad.getAnimation(name),cfg);manager._animationStates.push(s);states.push(s);configs.push(cfg);return s;}
if(kind===0)add(op==='noData'?'empty':'move',0);if(kind===1){add('move',2);add('alt',1);}if(kind===2){const parent=add('controller',0),a=add('move',0),b=add('alt',0);a.timeScale=b.timeScale=0;parent.addState(a,parent.animationData.getAnimationTimelines('move'));parent.addState(b,parent.animationData.getAnimationTimelines('alt'));}
manager._lastAnimationState=states[states.length-1]||null;manager._animationDirty=true;
const out=[];function push(...v){out.push(...v.map(String));}function nums(a){return Array.from(a,scalar).join(',');}
const deltas=[0,.125,.125,.25,.5,.125,.5,1,.25,.25];
for(let step=0;step<deltas.length;step++){
if(states[0]){const s=states[0];if(kind===2)s.parameterX=[-.2,0,.25,.75,1.2,-.2,.5,0,1,.25][step];if(op==='mask'&&step===2)s.addBoneMask('root');if(op==='mask'&&step===5)s.removeAllBoneMask();if(op==='stop'&&step===2)s.stop();if(op==='stop'&&step===4)s.play();if(op==='fadeOut'&&step===2)s.fadeOut(.25,false);if(op==='reuseBlend'&&step===2)manager.getBlendState('boneTransform','root',arm.getBone('child'));}
if(op==='controllerGate')arm.getSlot('meshSlot').displayController=step<4?'blocked':'group';if(op==='resetCache'&&step===1)arm._cacheFrameIndex=-1;
manager.advanceTime(deltas[step]);
push(step,scalar(arm._cacheFrameIndex),manager._animationDirty,manager._animationStates.length,states.indexOf(manager._lastAnimationState),core._objects.length,core._events.map(e=>e.type+'~'+e.name+'~'+scalar(e.time)).join('|'));
for(const s of states){push(...stateKeys.map(k=>scalar(s[k])));for(const group of groups){push(s[group].map(t=>[t.constructor.toString(),scalar(t.currentTime),scalar(t.playState),scalar(t._isInPool)].join('~')).join('|'));}push(s._boneMask.join(','));}
for(const b of arm.getBones()){push(b.name,...['x','y','rotation','skew','scaleX','scaleY'].map(k=>scalar(b.animationPose[k])),scalar(b._alpha),b._transformDirty,nums(b._cachedFrameIndices||[]));if(b._boneData.type===1)push(nums(b._deformVertices));}
for(const s of arm.getSlots()){push(s.name,scalar(s.displayIndex),scalar(s._alpha),scalar(s._zIndex),...['alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'].map(k=>scalar(s._colorTransform[k])),s._colorDirty,s._verticesDirty,nums(s._cachedFrameIndices||[]));for(const f of s._displayFrames)push(nums(f.deformVertices));}
for(const k of Object.keys(manager._blendStates)){push(k);for(const n of Object.keys(manager._blendStates[k])){const b=manager._blendStates[k][n];push(n,b.target.name,scalar(b.blendWeight),scalar(b.leftWeight),scalar(b.layerWeight),scalar(b.layer),scalar(b.dirty));}}
for(const b of arm.getBones()){b.update(arm._cacheFrameIndex);b._updateAlpha();}for(const s of arm.getSlots()){s._updateAlpha();s.update(arm._cacheFrameIndex);}push(hooks.join('|'));hooks.length=0;core.advanceTime(0);push(dispatch.join('|'));dispatch.length=0;
}
core.advanceTime(0);core.advanceTime(0);arm.returnToPool();for(const cfg of configs)cfg.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'stateadvance-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'stateadvance-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/stateadvance_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'stateadvance-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/, '').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i+' '+rows[i].length+' '+expected[i].length);for(let j=0;j<rows[i].length;j++){columns++;if(rows[i][j]!==expected[i][j])throw Error('Playback mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'stateadvance-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
