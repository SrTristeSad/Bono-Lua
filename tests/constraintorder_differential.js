'use strict';
// Compare IK and z-order timelines against real constraints, slots and armature.
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
const names=['IKConstraintTimelineState','ZOrderTimelineState'];const keys=['dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenProgress','_valueScale','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB'];
const cases=[];for(let cls=0;cls<2;cls++)for(let pose=0;pose<2;pose++)for(const tween of [0,1,2,5])for(const play of [0,1,2])for(const head of [0,1,3])for(let variant=0;variant<4;variant++)cases.push([cls,pose,tween,play,head,variant,'normal']);
for(let cls=0;cls<2;cls++)for(const op of ['single','fadeOut','reinit','missingSlot','clear','sortOriginal','sortDuplicate','sortBounds','sortFractional','sortAbsent'])cases.push([cls,0,1,0,3,0,op]);
const sel=process.argv[4];if(sel!==undefined){const a=/^\d+$/.test(sel)?[cases[+sel]]:cases.filter(c=>c[6]===sel);if(!a.length||!a[0])throw Error('selection');cases.splice(0,cases.length,...a);}
const fixture=fs.readFileSync(path.join(root,'examples/constraintorder_ske.json'),'utf8');
function scalar(v){if(v===undefined||v===null)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
function execute(c){const [cls,pose,tween,play,head,variant,op]=c;ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx);raw.armature[0].ik[0].chain=variant%2;raw.armature[0].ik[0].bendPositive=variant<2;raw.armature[0].ik[0].weight=[-.5,0,1,1.5][variant];const gd=new d.ObjectDataParser().parseDragonBonesData(raw),ad=gd.getArmature('ik-demo'),anim=ad.getAnimation('change'),td=B.borrowObject(d.TimelineData),arm=B.borrowObject(d.Armature),ik=B.borrowObject(d.IKConstraint),p=B.borrowObject(d[names[cls]]);arm._armatureData=ad;for(const bd of ad.sortedBones)B.borrowObject(d.Bone).init(bd,arm);ik.init(ad.getConstraint('aim'),arm);arm._addConstraint(ik);
 class Observer extends d.Slot{static toString(){return'[test.ConstraintOrderSlot]';}_initDisplay(){}_disposeDisplay(){}_onUpdateDisplay(){}_addDisplay(){}}B.clearPool(Observer);const slots=[];for(const sd of ad.sortedSlots){const slot=B.borrowObject(Observer);slot.init(sd,arm,null,null);slots.push(slot);}let missing=null;if(op==='missingSlot'){missing=slots[1];arm._slots.splice(1,1);}
 anim.frameOffset=2;anim.frameIntOffset=2;anim.duration=1;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2;const order=[[2,0,1],[1,1,0],[-1,3,0],[1,0,2]][variant];gd.frameArray=new Int16Array(cls?[99,99,0,3,...order,1,3,0,2,1,3,0,99,99,99]:[99,99,0,tween,tween===2?2:50,2500,7500,1,tween,tween===2?2:75,2500,7500,3,tween,tween===2?2:100,2500,7500]);gd.timelineArray=new Uint16Array([99,99,99,100,0,op==='single'?1:3,2,1,0,5,10]);gd.frameIndices=[99,99,0,1,1,2,2,2];gd.frameIntArray=new Int16Array([99,99,99,100,100,0,25,-100,150]);
 const state={animationData:anim,_actionTimeline:null,_position:0,_duration:1,playTimes:play,currentPlayTimes:0,_playheadState:head};p.target=ik;p.init(arm,state,pose?null:td);const out=[];
 function snap(status){out.push(status,...keys.map(k=>scalar(p[k])),scalar(ik._bendPositive),scalar(ik._weight),...['upper','lower','target'].flatMap(n=>{const b=arm.getBone(n);return['_transformDirty','_childrenTransformDirty','_localDirty','_hasConstraint'].map(k=>scalar(b[k]));}),scalar(arm._slotsDirty),scalar(arm._zOrderDirty),...slots.flatMap(s=>[scalar(s._zOrder),scalar(s._zOrderDirty)]),String(p.target===ik),String(ik._constraintData===ad.getConstraint('aim')));}
 for(let i=0;i<7;i++){arm._slotsDirty=false;for(const s of slots)s._zOrderDirty=false;for(const n of ['upper','lower','target'])arm.getBone(n)._transformDirty=false;let status='ok';try{p.update([0,.125,.5,.75,1,1.25,-.25][i]);if(op.startsWith('sort')){const maps={sortOriginal:null,sortDuplicate:[99,1,1,0],sortBounds:[99,-1,3,0],sortFractional:[99,0,.5,2],sortAbsent:[99,0]};arm._sortZOrder(maps[op],1);}if(op==='fadeOut')p.fadeOut();if(op==='reinit'&&i===2)p.init(arm,state,null);}catch(e){status='error';}snap(status);}
 if(op==='clear')p._onClear();p.fadeOut();snap('final');p.returnToPool();snap('clear');out.push(String(p._isInPool));td.returnToPool();if(missing)missing.returnToPool();arm.returnToPool();gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'constraintorder-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'constraintorder-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/constraintorder_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'constraintorder-'+tag+'-actual.tsv'),actual);const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,errors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')errors++;if(rows[i][j]!==expected[i][j])throw Error('Constraint order mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:errors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'constraintorder-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
