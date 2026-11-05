'use strict';
// Compare the real Animation public API against the pinned TypeScript.
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



let warnings=0;const ctx=vm.createContext({console:{warn(){warnings++;},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const fixture=fs.readFileSync(path.join(root,'examples/playback_ske.json'),'utf8');
const cases=[];for(let mode=0;mode<6;mode++)for(const layer of [-1,0,2])for(const position of [-1.25,0,.25,1,2.25])for(const duration of [-1,0,.5])for(const rate of [-100,-1,1])cases.push([mode,layer,position,duration,rate,'normal']);
for(const op of ['controller','childReuse','missingChild','time','frame','progress','stopTime','stopFrame','stopProgress','missing','emptyName','emptyModel','noDefault','mapIdentity','numericNames','readonly','singleFaded','zeroScale','configReset','sameName','complete','negativeProgress','nanProgress','childArm','childNoInherit','childHasState','childMissing','defaultStart','noDefaultStart'])cases.push([op==='sameName'?0:5,0,.25,.5,1,op]);
if(process.argv[4]!==undefined){const n=+process.argv[4];cases.splice(0,cases.length,cases[n]);}
function scalar(v){if(v===null||v===undefined)return'u';if(typeof v==='boolean')return String(v);if(typeof v==='string')return's'+Buffer.from(v).toString('hex');if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const sk=['name','group','layer','playTimes','timeScale','_position','_duration','_time','_weight','_weightResult','_fadeState','_subFadeState','_fadeTime','_fadeProgress','fadeTotalTime','_playheadState','actionEnabled','resetToPose','_isInPool'];
const ck=['animation','name','group','layer','playTimes','position','duration','timeScale','fadeInTime','fadeOutTime','fadeOutMode','pauseFadeIn','resetToPose'];
function execute(c){const[mode,layer,position,duration,rate,op]=c;const cache=4;warnings=0;ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx),gd=new d.ObjectDataParser().parseDragonBonesData(raw),ad=gd.getArmature('playback');if(cache)ad.cacheFrames(cache);
const arm=B.borrowObject(d.Armature);arm._armatureData=ad;for(const bd of ad.sortedBones)B.borrowObject(bd.type===1?d.Surface:d.Bone).init(bd,arm);
const hooks=[];class Observer extends d.Slot{static toString(){return'[test.PlaybackSlot]';}}
for(const hook of ['_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'])Observer.prototype[hook]=function(){hooks.push(this.name+':'+hook);};
B.clearPool(Observer);for(const sd of ad.sortedSlots){const slot=B.borrowObject(Observer);slot.init(sd,arm,{},{});const displays=ad.defaultSkin.getDisplays(sd.name);slot.displayFrameCount=displays.length;displays.forEach((v,i)=>{slot.replaceRawDisplayData(v,i);slot.replaceDisplay(v.type===2?slot.meshDisplay:slot.rawDisplay,i);});slot._setDisplayIndex(0);slot._updateDisplayData();}
for(const name in ad.constraints){const ik=B.borrowObject(d.IKConstraint);ik.init(ad.constraints[name],arm);arm._addConstraint(ik);}
const dispatch=[],proxy={hasDBEventListener(){return true;},dispatchDBEvent(type,e){dispatch.push(type+'~'+e.name+'~'+scalar(e.time));},dbClear(){}};
const core=new d.DragonBones({dispatchDBEvent(type,e){dispatch.push('sound~'+e.name+'~'+scalar(e.time));}});arm._proxy=proxy;arm._dragonBones=core;

const manager=B.borrowObject(d.Animation);manager.init(arm);arm._animation=manager;manager.animations=ad.animations;
let childArm=null,childManager=null;
if(op.startsWith('child')&&op!=='childReuse'){childArm=B.borrowObject(d.Armature);childArm._armatureData=ad;childArm._proxy=proxy;childArm._dragonBones=core;childArm.inheritAnimation=op!=='childNoInherit';childManager=B.borrowObject(d.Animation);childManager.init(childArm);childArm._animation=childManager;if(op!=='childMissing')childManager.animations=ad.animations;arm.getSlot('meshSlot')._childArmature=childArm;if(op==='childHasState')childManager.play('move',0);}
const config=B.borrowObject(d.AnimationConfig),held=[],out=[];const names=manager.animationNames,map=manager.animations,list=manager.getStates();
function id(v){if(v===null||v===undefined)return'-';let i=held.indexOf(v);if(i<0){i=held.length;held.push(v);}return String(i);}
let returned=null;function push(...v){out.push(...v.map(String));}function fields(o,keys){push(...keys.map(k=>scalar(o[k])));}
function snap(status){push(status,id(returned),manager.isPlaying,manager.isCompleted,manager.lastAnimationName,id(manager.lastAnimationState),manager._animationDirty,scalar(arm._cacheFrameIndex),manager.animationNames===names,manager.animations===map,manager.getStates()===list,manager.animationNames.join(','),manager.hasAnimation('move'),manager.hasAnimation('absent'),warnings);push(childManager?childManager.getStates().map(s=>s.name+'~'+s._playheadState).join('|'):'-');fields(config,ck);fields(manager._animationConfig,ck);push(manager.getStates().length);for(const s of manager.getStates()){push(id(s),id(s._parent));fields(s,sk);push(s._actionTimeline.playState,scalar(s.currentTime),s._animationTimelines.length,s._poseTimelines.length);}for(const n of ['move','alt','custom','controller','absent'])for(const l of [-1,0,2])push(id(manager.getState(n,l)));for(const b of arm.getBones()){push(b.name,...['x','y','rotation','skew','scaleX','scaleY'].map(k=>scalar(b.animationPose[k])));}push(hooks.join('|'),dispatch.join('|'));push(core._events.map(e=>e.type+'~'+e.name+'~'+scalar(e.time)).join('|'),core._objects.length);}
function stage(fn){let status='ok';try{fn();}catch(e){status='error';}snap(status);}
function tick(delta){hooks.length=0;dispatch.length=0;manager.advanceTime(delta);for(const b of arm.getBones()){b.update(arm._cacheFrameIndex);b._updateAlpha();}for(const s of arm.getSlots()){s._updateAlpha();s.update(arm._cacheFrameIndex);}core.advanceTime(0);}
stage(()=>{if(op==='noDefaultStart')ad.defaultAnimation=null;if(op==='defaultStart'||op==='noDefaultStart')returned=manager.play();});stage(()=>{returned=manager.fadeIn('move',.25,0,0,'A',0);});stage(()=>{returned=manager.fadeIn('alt',.25,0,1,'B',0);});stage(()=>tick(.125));
stage(()=>{config.animation=op==='controller'||op==='childReuse'||op==='missingChild'?'controller':op==='missing'?'absent':'move';config.name=op==='sameName'?'move':'custom';config.group='A';config.layer=layer;config.position=position;config.duration=duration;config.timeScale=rate;config.fadeInTime=-1;config.fadeOutTime=-1;config.fadeOutMode=mode;config.playTimes=-1;if(op==='singleFaded')manager.getState('move').fadeOut(.25);if(op==='emptyModel')ad.getAnimation('move').frameCount=0;if(op==='zeroScale')ad.getAnimation('move').scale=0;if(op==='missingChild')delete manager._animations.alt;if(op==='childReuse')manager.fadeIn('move',0,1,layer,'',0);returned=manager.playConfig(config);});
stage(()=>tick(.125));stage(()=>manager.stop());stage(()=>{returned=manager.play();});
stage(()=>{const n=op==='missing'?'absent':'move';switch(op){case'time':returned=manager.gotoAndPlayByTime(n,-.25,2);break;case'frame':returned=manager.gotoAndPlayByFrame(n,12,2);break;case'progress':returned=manager.gotoAndPlayByProgress(n,1.5,2);break;case'stopTime':returned=manager.gotoAndStopByTime(n,.5);break;case'stopFrame':returned=manager.gotoAndStopByFrame(n,12);break;case'stopProgress':returned=manager.gotoAndStopByProgress(n,.5);break;case'negativeProgress':returned=manager.gotoAndPlayByProgress(n,-.5);break;case'nanProgress':returned=manager.gotoAndPlayByProgress(n,NaN);break;case'emptyName':returned=manager.play('');break;default:returned=manager.play(n,1);}});
stage(()=>tick(op==='complete'?2:.25));stage(()=>manager.stop('move'));stage(()=>{returned=manager.play();});
if(op==='readonly')for(const key of ['isPlaying','isCompleted','lastAnimationName','animationNames','animationConfig','lastAnimationState'])stage(()=>{manager[key]=false;});
stage(()=>{const ref=manager._animationConfig;ref.position=9;const cfg=manager.animationConfig;push(cfg===ref);});
stage(()=>{manager.animations=manager.animations;});
stage(()=>{const replacement=vm.runInContext('({})',ctx);replacement['10']=ad.getAnimation('alt');replacement['2']=ad.getAnimation('move');replacement['a']=ad.getAnimation('empty');manager.animations=replacement;});
stage(()=>manager.reset());stage(()=>{if(op==='noDefault')ad.defaultAnimation=null;returned=manager.play();});stage(()=>tick(0));
core.advanceTime(0);core.advanceTime(0);if(childArm){arm.getSlot('meshSlot')._childArmature=null;childArm.returnToPool();}arm.returnToPool();push(manager._isInPool,names.length,list.length,Object.keys(map).length,...held.map(s=>s._isInPool));config.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'animationfacade-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'animationfacade-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/animationfacade_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'animationfacade-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/, '').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,sourceErrors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i+' '+rows[i].length+' '+expected[i].length);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')sourceErrors++;if(rows[i][j]!==expected[i][j])throw Error('Facade mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'animationfacade-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
