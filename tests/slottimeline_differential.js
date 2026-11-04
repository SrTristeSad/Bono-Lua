'use strict';
// Compare four concrete alpha/slot timelines using real runtime targets.
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
const names=['AlphaTimelineState','SlotDisplayTimelineState','SlotColorTimelineState','SlotZIndexTimelineState'];
const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenType','_framePosition','_frameDurationR','_tweenProgress','_valueScale'];
const colors=['alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'];
const cases=[];for(let cls=0;cls<4;cls++)for(const pose of [0,1])for(const tween of [0,1,2,3,5])for(const fade of [0,1,2])for(const weight of [-.5,0,.5,1.5])for(const variant of [0,1])cases.push([cls,pose,tween,fade,weight,variant,'normal']);
for(let cls=0;cls<4;cls++)for(const op of ['fadeOut','cleanBlend','reset','clear','single','lastLoop','stopped','negativeColorOffset'])cases.push([cls,0,1,1,.5,0,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[6]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function array(a){return a.length+':'+Array.from({length:a.length},(_,i)=>i in a?scalar(a[i]):'hole').join(',');}
function execute(c){const [cls,pose,tween,fade,weight,variant,op]=c;
 const gd=B.borrowObject(d.DragonBonesData),ad=B.borrowObject(d.ArmatureData),anim=B.borrowObject(d.AnimationData),td=B.borrowObject(d.TimelineData),bd=B.borrowObject(d.BoneData),sd=B.borrowObject(d.SlotData),arm=B.borrowObject(d.Armature),bone=B.borrowObject(d.Bone),blend=B.borrowObject(d.BlendState),p=B.borrowObject(d[names[cls]]);
 class Observer extends d.Slot{static toString(){return'[test.SlotTimelineObserver]';}_initDisplay(){}_disposeDisplay(){}_onUpdateDisplay(){}_addDisplay(){}}B.clearPool(Observer);const slot=B.borrowObject(Observer);
 ad.name='arm';gd.addArmature(ad);anim.name='anim';ad.addAnimation(anim);ad.frameRate=4;anim.duration=1;anim.frameOffset=2;anim.frameIntOffset=2;td.offset=3;td.frameIndicesOffset=2;bd.name='bone';ad.addBone(bd);sd.name='slot';sd.parent=bd;sd.displayIndex=1;sd.zIndex=3;sd.color=new d.ColorTransform(.8,.7,.6,.5,1,2,3,4);ad.addSlot(sd);arm._armatureData=ad;bone.init(bd,arm);slot.init(sd,arm,null,null);slot.displayFrameCount=3;slot._setDisplayIndex(1);slot._updateDisplayData();
 gd.frameArray=new Int16Array([99,99,0,cls===1?0:tween,tween===2?2:50,2500,7500,1,cls===1?2:tween,tween===2?2:75,2500,7500,3,cls===1?-1:tween,tween===2?2:100,2500,7500]);gd.timelineArray=new Uint16Array([99,99,99,100,0,op==='single'?1:3,1,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];
 gd.frameIntArray=new Int16Array([99,99,99,...(cls===2?[op==='negativeColorOffset'?-8:0,8,16]:cls===0?[150,20,-50]:[2,-3,7])]);gd.colorArray=new Int16Array(op==='negativeColorOffset'?65536:24);const rows=[[100,80,60,40,1,2,3,4],[20,40,60,80,-10,20,-30,40],[150,125,75,50,100,-100,50,-50]];rows.forEach((row,i)=>row.forEach((v,j)=>gd.colorArray[(op==='negativeColorOffset'&&i===0?65528:i*8)+j]=v));
 // AnimationState is a test input contract until its real controller is ported.
 const state={animationData:anim,_actionTimeline:null,_position:0,_duration:1,playTimes:op==='lastLoop'?1:0,currentPlayTimes:0,_playheadState:op==='stopped'?0:3,layer:2,_weightResult:weight,_fadeState:fade===1?-1:0,_subFadeState:fade===2?1:0,_fadeProgress:variant?.75:.5};
 p.target=cls===1||cls===2?slot:blend;blend.target=cls===0&&variant?bone:slot;p.init(arm,state,pose?null:td);const buffers=[p._current,p._difference,p._result],out=[];
 function snap(status,result){out.push(status,...keys.map(k=>scalar(p[k])),...['_current','_difference','_result'].map(k=>Array.isArray(p[k])?array(p[k]):scalar(p[k])),...['dirty','layer','leftWeight','layerWeight','blendWeight'].map(k=>scalar(blend[k])),scalar(slot._alpha),scalar(bone._alpha),scalar(slot._zIndex),scalar(slot.displayIndex),scalar(slot._animationDisplayIndex),scalar(slot._displayDirty),scalar(slot._colorDirty),...colors.map(k=>scalar(slot._colorTransform[k])),scalar(arm._alphaDirty),scalar(arm._zIndexDirty),String(p.target===(cls===1||cls===2?slot:blend)),String(result));}
 for(const time of [0,.125,.5,.75,1,1.25,-.25]){slot._colorDirty=false;slot._displayDirty=false;arm._alphaDirty=false;arm._zIndexDirty=false;let status='ok';try{p.update(time);}catch(e){status='error';}snap(status,'update');if(cls===0||cls===3){blend.reset();state.layer=2;state._weightResult=weight;if(op==='cleanBlend')p.dirty=false;let ok=blend.update(state);if(ok)p.blend(op!=='cleanBlend');snap('blend',ok);state.layer=variant?2:1;state._weightResult=.75;ok=blend.update(state);if(ok)p.blend(false);snap('blend2',ok);}if(op==='fadeOut')p.fadeOut();if(op==='reset')blend.reset();}
 p.fadeOut();snap('fade','none');p.returnToPool();blend.returnToPool();snap('clear','none');out.push(String(p._isInPool),String(blend._isInPool),...buffers.map((v,i)=>String(v===[p._current,p._difference,p._result][i])));td.returnToPool();arm.returnToPool();gd.returnToPool();return out;
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'slottimeline-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'slottimeline-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/slottimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'slottimeline-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,errors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')errors++;if(rows[i][j]!==expected[i][j])throw Error('Slot timeline mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'slottimeline-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
