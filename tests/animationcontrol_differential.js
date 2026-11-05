'use strict';
// Compare animation-control timelines and real partial AnimationState setters/lifecycle.
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
const names=['AnimationProgressTimelineState','AnimationWeightTimelineState','AnimationParametersTimelineState'];
const fields=['_boneMask','_boneTimelines','_boneBlendTimelines','_slotTimelines','_slotBlendTimelines','_constraintTimelines','_animationTimelines','_poseTimelines'];
const keys=['dirty','playState','currentPlayTimes','currentTime','_frameIndex','_isTween','_valueScale','_current','_difference','_result','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB'];
const cases=[];for(let cls=0;cls<3;cls++)for(let pose=0;pose<2;pose++)for(let attached=0;attached<2;attached++)for(const tween of [0,1,2,3,5])for(const duration of [.5,1,2])for(const play of [0,2])for(let reverse=0;reverse<2;reverse++)cases.push([cls,pose,attached,tween,duration,play,reverse,'normal']);
for(let cls=0;cls<3;cls++)for(const op of ['seekNegative','seekBeyond','seekEnd','seekSame','weightSame','readonly','detach','foreignParent','negativeZero'])cases.push([cls,0,1,1,1,2,0,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[7]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
const fixture=fs.readFileSync(path.join(root,'examples/animationcontrol_ske.json'),'utf8');
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function execute(c){const [cls,pose,attached,tween,duration,play,reverse,op]=c;ctx.__json=fixture;const gd=new d.ObjectDataParser().parseDragonBonesData(vm.runInContext('JSON.parse(__json)',ctx)),ad=gd.getArmature('demo'),anim=ad.getAnimation('controller'),childData=ad.getAnimation('child'),td=B.borrowObject(d.TimelineData),arm=B.borrowObject(d.Armature),parent=B.borrowObject(d.AnimationState),child=B.borrowObject(d.AnimationState),grand=B.borrowObject(d.AnimationState),p=B.borrowObject(d[names[cls]]);arm._armatureData=ad;
 function setup(s,data,dur,plays){s._animationData=data;s._armature=arm;s._position=0;s._duration=dur;s.playTimes=plays;s._playheadState=3;s._actionTimeline=B.borrowObject(d.ActionTimelineState);s._actionTimeline.init(arm,s,null);}
 setup(parent,anim,1,play);setup(child,childData,duration,2);child._parent=op==='foreignParent'?grand:attached?parent:null;child._time=.2;child._actionTimeline.setCurrentTime(.2);child.parameterX=7;child.parameterY=9;
 const classes=[d.BoneTranslateTimelineState,d.AlphaTimelineState,d.SlotDisplayTimelineState,d.SlotZIndexTimelineState,d.IKConstraintTimelineState,d.AnimationWeightTimelineState];
 const probes=classes.map(k=>B.borrowObject(k));for(let i=0;i<6;i++)child[fields[i+1]].push(probes[i]);probes[5].target=grand;grand._parent=op==='foreignParent'?parent:child;child._poseTimelines.push(probes[0]);child._boneMask.push('root');child._zOrderTimeline=B.borrowObject(d.ZOrderTimelineState);const childAction=child._actionTimeline,childOrder=child._zOrderTimeline,parentAction=parent._actionTimeline,arrays=fields.map(k=>child[k]);
 anim.frameOffset=2;anim.frameIntOffset=2;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2;gd.frameArray=new Int16Array([99,99,0,tween,tween===2?2:50,2500,7500,1,tween,tween===2?2:75,2500,7500,3,tween,tween===2?2:100,2500,7500]);gd.timelineArray=new Uint16Array([99,99,99,100,0,3,cls===2?2:1,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];gd.frameIntArray=new Int16Array([99,99,99,-5000,12500,2500,-7500,15000,0]);p.target=child;p.init(arm,parent,pose?null:td);parent._animationTimelines.push(p);const out=[];
 const read=fn=>{try{return scalar(fn());}catch(e){return'getter-error';}};
 function snap(status){out.push(status,...keys.map(k=>scalar(p[k])),...['_time','_weight','parameterX','parameterY','_fadeState','_subFadeState'].map(k=>scalar(child[k])),read(()=>child.currentTime),read(()=>child.currentPlayTimes),read(()=>child.totalTime),read(()=>child.weight),String(child.animationData===childData),String(child._parent===parent),...probes.flatMap(t=>[scalar(t.playState),scalar(t.dirty),String(t._isInPool)]),scalar(childOrder.playState),scalar(childAction.currentTime),scalar(childAction.currentPlayTimes),scalar(childAction._frameIndex),String(childAction._isInPool),String(childOrder._isInPool),String(p._isInPool),...fields.map(k=>String(child[k].length)),...arrays.map((a,i)=>String(a===child[fields[i]])),scalar(grand._fadeState),scalar(grand._subFadeState),String(grand._parent===null));}
 for(let i=0;i<8;i++){for(const t of probes){t.playState=7;t.dirty=false;}childOrder.playState=7;let status='ok';try{if(op==='detach'&&i===2)child._parent=null;if(op==='negativeZero'&&i===0)child.weight=-0;parentAction._setCurrentTime((reverse?-1:1)*[0,.125,.5,.5,.75,1,1.25,-.25][i]);p.update((reverse?-1:1)*[0,.125,.5,.5,.75,1,1.25,-.25][i]);if(op==='seekNegative')child.currentTime=-.25;if(op==='seekBeyond')child.currentTime=3.25;if(op==='seekEnd'){child._parent=null;child.playTimes=1;childAction.currentPlayTimes=1;childAction.playState=1;child.currentTime=child.totalTime;}if(op==='seekSame')child.currentTime=child._time;if(op==='weightSame')child.weight=child.weight;if(op==='readonly')child.animationData=null;}catch(e){status='error';}snap(status);}
 parent.returnToPool();snap('parentClear');child.returnToPool();snap('childClear');out.push(String(parent._isInPool),String(child._isInPool),String(parentAction._isInPool),String(child._poseTimelines.length),String(grand._parent===parent));grand.returnToPool();td.returnToPool();arm.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'animationcontrol-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'animationcontrol-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/animationcontrol_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'animationcontrol-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,errors=0,getterErrors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')errors++;if(expected[i][j]==='getter-error')getterErrors++;if(rows[i][j]!==expected[i][j])throw Error('Animation control mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,getterErrors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'animationcontrol-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
