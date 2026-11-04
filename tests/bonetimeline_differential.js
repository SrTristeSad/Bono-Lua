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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint','animation/BaseTimelineState','animation/TimelineState','animation/AnimationState'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');


const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const names=['BoneAllTimelineState','BoneTranslateTimelineState','BoneRotateTimelineState','BoneScaleTimelineState'];
const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_timeScale','_timeOffset','_tweenType','_framePosition','_frameDurationR','_tweenProgress','_valueScale','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB','_valueCount'];
const cases=[];for(let cls=0;cls<4;cls++)for(const pose of [0,1])for(const tween of [0,1,2,3,5])for(const scale of [.5,1,2])for(const weight of [-.5,0,.5,1,1.5])for(const layer of [1,2,3])cases.push([cls,pose,tween,scale,weight,layer,'normal']);
for(let cls=0;cls<4;cls++)for(const op of ['fadeOut','cleanBlend','reset','clear','single','lastLoop','stopped'])cases.push([cls,0,1,1,.5,1,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[6]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function array(a){return a.length+':'+Array.from({length:a.length},(_,i)=>i in a?scalar(a[i]):'hole').join(',');}
function execute(c){const [cls,pose,tween,scale,weight,layer,op]=c;
 const gd=B.borrowObject(d.DragonBonesData),ad=B.borrowObject(d.ArmatureData),anim=B.borrowObject(d.AnimationData),td=B.borrowObject(d.TimelineData),bd=B.borrowObject(d.BoneData),arm=B.borrowObject(d.Armature),bone=B.borrowObject(d.Bone),blend=B.borrowObject(d.BlendState),p=B.borrowObject(d[names[cls]]);
 ad.name='arm';gd.addArmature(ad);anim.name='anim';ad.addAnimation(anim);ad.scale=scale;ad.frameRate=4;anim.duration=1;anim.frameOffset=2;anim.frameFloatOffset=2;td.offset=3;td.frameIndicesOffset=2;bd.name='bone';ad.addBone(bd);arm._armatureData=ad;bone.init(bd,arm);
 gd.frameArray=new Int16Array([99,99,0,tween,tween===2?2:50,2500,7500,1,tween,tween===2?2:75,2500,7500,3,tween,tween===2?2:100,2500,7500]);gd.timelineArray=new Uint16Array([99,99,99,100,0,op==='single'?1:3,6,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];
 gd.frameFloatArray=new Float32Array([99,99,99,1,3,7,-5,2,.5,11,13,-8,9,.25,2,23,29,10,-12,3,-1]);
 const state={animationData:anim,_actionTimeline:null,_position:0,_duration:1,playTimes:op==='lastLoop'?1:0,currentPlayTimes:0,_playheadState:op==='stopped'?0:3,layer:2,_weightResult:weight};
 p.init(arm,state,pose?null:td);p.target=blend;blend.target=bone;const out=[];const rd=p._rd;
 function snap(status,result){out.push(status,...keys.map(k=>scalar(p[k])),p._rd?array(p._rd):'u',...['dirty','layer','leftWeight','layerWeight','blendWeight'].map(k=>scalar(blend[k])),...['x','y','rotation','skew','scaleX','scaleY'].map(k=>scalar(bone.animationPose[k])),scalar(bone._transformDirty),String(p.target===blend),String(blend.target===bone),String(result));}
 for(const time of [0,.125,.5,.75,1,1.25,-.25]){let status='ok';try{p.update(time);}catch(e){status='error';}snap(status,'update');bone.animationPose.x=5;bone.animationPose.y=7;bone.animationPose.rotation=.1;bone.animationPose.skew=.2;bone.animationPose.scaleX=2;bone.animationPose.scaleY=3;bone._transformDirty=false;blend.reset();state.layer=2;state._weightResult=weight;if(op==='cleanBlend')p.dirty=false;let ok=blend.update(state);if(ok)p.blend(op!=='cleanBlend');snap('blend',ok);state.layer=layer;state._weightResult=.75;ok=blend.update(state);if(ok)p.blend(false);snap('blend2',ok);state.layer=-1;state._weightResult=.25;ok=blend.update(state);if(ok)p.blend(false);snap('blend3',ok);if(op==='fadeOut')p.fadeOut();if(op==='reset')blend.reset();}
 p.fadeOut();snap('fade','none');blend.reset();snap('reset','none');p.returnToPool();blend.returnToPool();snap('clear','none');out.push(String(p._isInPool),String(blend._isInPool),String(p._rd===rd),...['BONE_TRANSFORM','BONE_ALPHA','SURFACE','SLOT_DEFORM','SLOT_ALPHA','SLOT_Z_INDEX'].map(k=>d.BlendState[k]));td.returnToPool();arm.returnToPool();gd.returnToPool();return out;
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'bonetimeline-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'bonetimeline-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/bonetimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'bonetimeline-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns');for(let j=0;j<rows[i].length;j++){columns++;if(rows[i][j]!==expected[i][j])throw Error('Bone timeline mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'bonetimeline-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
