'use strict';
// Compare Surface and mesh deformation timelines with real parsed geometry.
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
const names=['SurfaceTimelineState','DeformTimelineState'];const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenProgress','_valueScale','_valueCount','_deformCount','_deformOffset','_sameValueOffset'];
const cases=[];for(let cls=0;cls<2;cls++)for(let pose=0;pose<2;pose++)for(const tween of [0,1,2,5])for(const scale of [.5,1,2])for(const weight of [-.5,0,.5,1.5])for(let region=0;region<4;region++)for(let variant=0;variant<2;variant++)cases.push([cls,pose,tween,scale,weight,region,variant,'normal']);
for(let cls=0;cls<2;cls++)for(const op of ['negativeOffset','cleanBlend','reset','clear','single','lastLoop','stopped','reinit','missingFrame'])cases.push([cls,0,1,1,.5,2,0,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[7]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
const fixture=fs.readFileSync(path.join(root,'examples/deformation_ske.json'),'utf8');
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function array(a){return a.length+':'+Array.from({length:a.length},(_,i)=>i in a?scalar(a[i]):'hole').join(',');}
function execute(c){const [cls,pose,tween,scale,weight,region,variant,op]=c;
 ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx);if(cls&&variant){const mesh=raw.armature[0].skin[0].slot[0].display[0];mesh.weights=[1,0,1,1,0,1,1,0,1];mesh.slotPose=[1,0,0,1,0,0];mesh.bonePose=[0,1,0,0,1,0,0];}
 const gd=new d.ObjectDataParser().parseDragonBonesData(raw,scale),ad=gd.getArmature('surface-demo'),anim=ad.getAnimation('deform'),td=B.borrowObject(d.TimelineData),arm=B.borrowObject(d.Armature),blend=B.borrowObject(d.BlendState),p=B.borrowObject(d[names[cls]]);arm._armatureData=ad;for(const bd of ad.sortedBones)B.borrowObject(bd.type===1?d.Surface:d.Bone).init(bd,arm);const surface=arm.getBone('grid');
 class Observer extends d.Slot{static toString(){return'[test.DeformationSlotObserver]';}_initDisplay(){}_disposeDisplay(){}_onUpdateDisplay(){}_addDisplay(){}}B.clearPool(Observer);const slot=B.borrowObject(Observer);slot.init(ad.getSlot('slot'),arm,null,null);slot.displayFrameCount=1;slot.replaceRawDisplayData(ad.defaultSkin.getDisplay('slot','mesh'),0);slot._setDisplayIndex(0);slot._updateDisplayData();const frame=slot.getDisplayFrameAt(0);frame.updateDeformVertices();if(variant)slot._geometryData=ad.defaultSkin.getDisplay('slot','other').geometry;
 const count=cls?frame.deformVertices.length:surface._deformVertices.length;const [off,n]=[[0,0],[0,2],[2,2],[0,6]][region];anim.frameOffset=2;anim.frameIntOffset=2;anim.frameFloatOffset=2;anim.duration=1;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2;
 gd.frameArray=new Int16Array([99,99,0,tween,tween===2?2:50,2500,7500,1,tween,tween===2?2:75,2500,7500,3,tween,tween===2?2:100,2500,7500]);gd.timelineArray=new Uint16Array([99,99,99,100,0,op==='single'?1:3,1,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];gd.frameIntArray=new Int16Array([99,99,99,0,count,n,off,op==='negativeOffset'?-8:32]);gd.frameFloatArray=new Float32Array(op==='negativeOffset'?65560:100);for(let i=0;i<3*n;i++)gd.frameFloatArray[3+i]=(i+1)*1.25;for(let i=0;i<count-n;i++)gd.frameFloatArray[(op==='negativeOffset'?65530:34)+i]=100+i;
 const state={animationData:anim,_actionTimeline:null,_position:0,_duration:1,playTimes:op==='lastLoop'?1:0,currentPlayTimes:0,_playheadState:op==='stopped'?0:3,layer:2,_weightResult:weight};blend.target=cls?slot:surface;p.target=blend;if(cls)p.displayFrame=op==='missingFrame'?null:frame;const rd=p._rd,out=[];
 function snap(status,result){out.push(status,...keys.map(k=>scalar(p[k])),array(p._rd),array(surface._deformVertices),array(frame.deformVertices),...['dirty','layer','leftWeight','layerWeight','blendWeight'].map(k=>scalar(blend[k])),scalar(surface._transformDirty),scalar(slot._verticesDirty),String(p.target===blend),String(p.displayFrame===frame),String(slot._geometryData===frame.getGeometryData()),String(result));}
 let init='ok';try{p.init(arm,state,pose?null:td);}catch(e){init='error';}snap(init,'init');
 for(const time of [0,.125,.5,.75,1,1.25,-.25]){let status='ok';try{p.update(time);}catch(e){status='error';}snap(status,'update');surface._transformDirty=false;slot._verticesDirty=false;blend.reset();state.layer=2;state._weightResult=weight;if(op==='cleanBlend')p.dirty=false;let accepted=blend.update(state),ok='blend';try{if(accepted)p.blend(op!=='cleanBlend');}catch(e){ok='error';}snap(ok,accepted);state.layer=variant?2:1;state._weightResult=.75;accepted=blend.update(state);ok='blend2';try{if(accepted)p.blend(false);}catch(e){ok='error';}snap(ok,accepted);if(op==='reinit')p.init(arm,state,null);if(op==='reset')blend.reset();}
 p.fadeOut();snap('fade','none');p.returnToPool();blend.returnToPool();snap('clear','none');out.push(String(p._isInPool),String(blend._isInPool),String(p._rd===rd));td.returnToPool();arm.returnToPool();gd.returnToPool();return out;
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'deformationtimeline-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'deformationtimeline-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/deformationtimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'deformationtimeline-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,errors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')errors++;if(rows[i][j]!==expected[i][j])throw Error('Deformation timeline mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'deformationtimeline-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
