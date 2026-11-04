'use strict';
// Execute the five pinned abstract timeline bases; callbacks and AnimationState input are test contracts only.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint','animation/BaseTimelineState'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');


const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const names=['TimelineState','TweenTimelineState','SingleValueTimelineState','DoubleValueTimelineState','MutilpleValueTimelineState'];
const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_valueOffset','_frameValueOffset','_frameOffset','_frameRate','_frameCount','_frameIndex','_frameRateR','_position','_duration','_timeScale','_timeOffset','_tweenType','_curveCount','_framePosition','_frameDurationR','_tweenEasing','_tweenProgress','_valueScale','_current','_difference','_result','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB','_valueCount'];
const times=[-1,-.25,0,.125,.5,.75,1,1.25,2];
const cases=[];for(let cls=0;cls<5;cls++)for(const frames of [0,1,3])for(let tween=0;tween<6;tween++)for(const play of [0,1,2])for(let action=0;action<2;action++)for(const scale of [50,100])for(const offset of [0,25])cases.push([cls,frames,tween,play,action,scale,offset,[1,.5,-1][cases.length%3],3,'normal']);
for(let cls=0;cls<5;cls++)for(const op of ['paused','stopped','fadeOut','reinit','clear','noAction','zeroSpan','curveZero','curveNegative','blend'])cases.push([cls,3,2,2,0,100,0,1,op==='paused'?1:op==='stopped'?0:3,op]);
for(const kind of [0,1])for(let tween=0;tween<7;tween++)for(const p of [-.25,0,.125,.5,.875,1,1.25])for(const easing of [-1,0,.5,1,2])cases.push([kind,0,tween,0,0,p,easing,1,3,'helper']);
const selection=process.argv[4];if(selection!==undefined){const a=/^\d+$/.test(selection)?[cases[+selection]]:cases.filter(c=>c[9]===selection);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function array(a){return a.length+':'+Array.from({length:a.length},(_,i)=>i in a?scalar(a[i]):'hole').join(',');}
function execute(c){const [cls,frames,tween,play,action,scale,offset,valueScale,head,op]=c;
 if(op==='helper'){return[scalar(cls===0?d.TweenTimelineState._getEasingValue(tween,scale,offset):d.TweenTimelineState._getEasingCurveValue(scale,[999,2500,7500,999],tween-1,1))];}
 const parent=names[cls],Parent=d[parent];class Probe extends Parent{static toString(){return'[test.BaseTimelineProbe]';}_onArriveAtFrame(){this.arrives++;if(cls)super._onArriveAtFrame();else this.dirty=true;}_onUpdateFrame(){this.updates++;if(cls)super._onUpdateFrame();}}
 B.clearPool(Probe);const p=B.borrowObject(Probe);p.arrives=p.updates=0;
 const gd=B.borrowObject(d.DragonBonesData),ad=B.borrowObject(d.ArmatureData),anim=B.borrowObject(d.AnimationData),td=B.borrowObject(d.TimelineData),arm=B.borrowObject(d.Armature);ad.name='arm';gd.addArmature(ad);anim.name='anim';ad.addAnimation(anim);arm._armatureData=ad;ad.frameRate=op==='zeroRate'?0:4;anim.duration=1;anim.frameOffset=2;td.offset=3;td.frameIndicesOffset=2;
 const curveCount=op==='curveZero'?0:op==='curveNegative'?-2:2;
 gd.frameArray=new Int16Array([99,99,0,tween,tween===2?curveCount:50,2500,7500,1,tween,tween===2?curveCount:75,2500,7500,op==='zeroSpan'?1:3,tween,tween===2?curveCount:100,2500,7500]);
 gd.timelineArray=new Uint16Array([99,99,99,op==='zeroScale'?0:scale,offset,frames,4,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];
 const values=new Float32Array([99,1,3,5,7,11,13,17,19,23,29,31,37]);
 // AnimationState is deliberately a field contract until its real port exists.
 const state={animationData:anim,_actionTimeline:action?p:null,_position:0,_duration:op==='zeroDuration'?0:1,playTimes:play,currentPlayTimes:0,_playheadState:head};
 const driver=B.borrowObject(Probe);driver.arrives=driver.updates=0;const ds={...state,_actionTimeline:null};driver.init(arm,ds,null);if(!action)state._actionTimeline=driver;if(op==='noAction')state._actionTimeline=null;
 p.init(arm,state,frames===0?null:td);p._valueArray=values;p._valueScale=valueScale;if(cls===4)p._valueCount=4;
 const rd=p._rd,out=[];function snap(status){out.push(status,...keys.map(k=>scalar(p[k])),p._rd?array(p._rd):'u',String(p.arrives),String(p.updates),String(p._armature===arm),String(p._animationState===state),String(p._timelineData===(frames===0?null:td)),String(p._actionTimeline===driver),String(p._frameArray===gd.frameArray),String(p._timelineArray===gd.timelineArray),String(p._frameIndices===gd.frameIndices));}
 for(let i=0;i<times.length;i++){let status='ok';try{driver._setCurrentTime(times[i]);state.currentPlayTimes=driver.currentPlayTimes;if(op==='fadeOut'&&i===4)p.fadeOut();if(op==='reinit'&&i===4)p.init(arm,state,null);if(op==='blend')p.blend(true);p.update(times[i]);}catch(e){status='error';}snap(status);}
 if(op==='clear')p._onClear();p.fadeOut();snap('final');p.returnToPool();out.push(...keys.map(k=>scalar(p[k])),p._rd?array(p._rd):'u',String(p._rd===rd),String(p._isInPool));driver.returnToPool();td.returnToPool();arm.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'basetimeline-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');
const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'basetimeline-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/basetimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'basetimeline-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,approximate=0,errors=0;
for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i+' '+rows[i].length+' '+expected[i].length);for(let j=0;j<rows[i].length;j++){columns++;const a=rows[i][j],b=expected[i][j];if(b==='error')errors++;if(a===b)continue;throw Error('Timeline mismatch '+i+' '+cases[i]+' col '+j+' expected '+b+' actual '+a);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,approximateComparisons:approximate,lua,result:'passed'};fs.writeFileSync(path.join(dir,'basetimeline-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
