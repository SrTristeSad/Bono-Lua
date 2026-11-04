'use strict';
// Execute the pinned binary timeline reader with real models and typed views.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const cases=[];for(const kind of [0,1,10,11,12,13,20,21,22,23,24,30,40,41,42,50,60,999])for(const blend of ['','1D','unknown'])for(const count of [0,1,3])cases.push([kind,blend,count,'normal']);
for(const mode of ['groups','order','unknownModel','oddPairs','nullGroup','shortOffsets','missingOffsets','nullOffsets','nullRaw','missingArmature','missingData','missingTimeline','missingFrame','negativeOffset','nanOffset','nullTimeline','holeTimeline','emptyName','coerce','cleanup','repeat','badDuration','zeroRate','mixed','partial','partialGroup','defaultEntry'])for(const count of [0,1,3])cases.push([40,'1D',count,mode]);
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
function scalar(v){if(v===undefined)return 'u';if(v===null)return 'null';if(typeof v==='number'){if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n'+b.toString('hex');}return String(v);}
const fields=['blendType','frameCount','playTimes','duration','fadeInTime','scale','name','frameIntOffset','frameFloatOffset','frameOffset'];
function execute(c){const [kind,blend,count,mode]=c,p=new d.BinaryDataParser(),data=B.borrowObject(d.DragonBonesData),arm=B.borrowObject(d.ArmatureData);arm.frameRate=24;p._data=data;p._armature=arm;data.frameIndices.length=3;data.frameIndices[0]=99;
 for(const name of ['b','2','10','a']){const bone=B.borrowObject(d.BoneData);bone.name=name;arm.addBone(bone);const slot=B.borrowObject(d.SlotData);slot.name=name;arm.addSlot(slot);const con=B.borrowObject(d.IKConstraintData);con.name=name;arm.addConstraint(con);}
 const buf=new ArrayBuffer(80),f=new Int16Array(buf,4,12),t=new Uint16Array(buf,28,26);f.set([99,88,0,2,5]);t.set([100,0,count,0,0,0,1,2],3);p._frameArrayBuffer=f;p._timelineArrayBuffer=t;
 let raw={offset:[8,16,2],duration:7,blendType:blend,name:'anim',timeline:[{type:kind,offset:3,name:'b',x:1.5,y:-2}]};
 if(['groups','order','unknownModel','oddPairs'].includes(mode)){for(const k of ['bone','slot','constraint']){raw[k]={};for(const name of (mode==='order'?['a','10','2','b']:['b']))raw[k][name]=[11,3,12,3];if(mode==='unknownModel')raw[k].absent=null;if(mode==='oddPairs')raw[k].b=[11];}raw.action=3;raw.zOrder=3;}
 if(mode==='nullGroup')raw.bone=null;if(mode==='shortOffsets')raw.offset=[];if(mode==='missingOffsets')delete raw.offset;if(mode==='nullOffsets')raw.offset=null;if(mode==='nullRaw')raw=null;if(mode==='missingArmature')p._armature=null;if(mode==='missingData')p._data=null;if(mode==='missingTimeline')p._timelineArrayBuffer=null;if(mode==='missingFrame')p._frameArrayBuffer=null;if(mode==='negativeOffset')raw.timeline[0].offset=-1;if(mode==='nanOffset')raw.timeline[0].offset=NaN;if(mode==='nullTimeline')raw.timeline=null;if(mode==='holeTimeline')raw.timeline=[undefined];if(mode==='emptyName')raw.name='';if(mode==='coerce'){raw.duration='8';raw.playTimes=false;raw.fadeInTime='0.25';raw.scale=null;raw.name=123;raw.timeline[0].x='2.5';}if(mode==='badDuration')raw.duration=0.5;if(mode==='zeroRate')arm.frameRate=0;
 if(mode==='mixed'||mode==='cleanup')raw.timeline=[0,1,10,11,12,13,20,21,22,23,24,30,40,41,42,50,60,999].map(type=>({type,offset:3,name:'b',x:1.5,y:-2}));if(mode==='partial')raw.timeline=[{type:11,offset:3,name:'b'},null];if(mode==='partialGroup'){raw.bone={b:[11,3]};raw.slot={b:null};}if(mode==='defaultEntry')raw.timeline=[{}];
 const allocated=[],trace=[];const originalBorrow=B.borrowObject;B.borrowObject=function(C){const o=originalBorrow.call(B,C);allocated.push(o);return o;};const genuine=p._parseBinaryTimeline;p._parseBinaryTimeline=function(type,offset,provided){trace.push(scalar(type)+','+scalar(offset)+','+(provided instanceof d.AnimationTimelineData));return genuine.call(this,type,offset,provided);};
 let result,tag='ok';try{result=p._parseAnimation(raw);if(mode==='repeat')result=p._parseAnimation(raw);}catch(e){tag='error';}finally{B.borrowObject=originalBorrow;}
 const a=result||p._animation;const tl=o=>o?[scalar(o.type),scalar(o.offset),scalar(o.frameIndicesOffset),scalar(o.x),scalar(o.y),String(o instanceof d.AnimationTimelineData)].join(','):'nil';
 const maps=a?['boneTimelines','slotTimelines','constraintTimelines','animationTimelines'].map(k=>Object.keys(a[k]).map(n=>n+'='+a[k][n].map(tl).join(';')).join('|')).join('/'):'nil';const beforeCleanup=allocated.filter(o=>o instanceof d.TimelineData).map(tl).join('|');if(mode==='cleanup'&&result)result.returnToPool();
 return [tag,a?fields.map(k=>scalar(a[k])).join(','):'nil',maps,tl(a&&a.actionTimeline),tl(a&&a.zOrderTimeline),p._animation===null?'clear':'retained',p._timeline===null?'clear':'retained',data.frameIndices.length,Array.from({length:Math.min(data.frameIndices.length,100)},(_,i)=>Object.prototype.hasOwnProperty.call(data.frameIndices,i)?scalar(data.frameIndices[i]):'hole').join(','),trace.join('|'),beforeCleanup,allocated.map(o=>o._isInPool?'1':'0').join(''),Buffer.from(new Uint8Array(buf)).toString('hex')].map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'binaryanimation-cases.tsv');fs.writeFileSync(input,cases.map(r=>r.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'binaryanimation-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/binaryanimation_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'binaryanimation-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0;for(let i=0;i<lines.length;i++)for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j])throw Error('Binary animation mismatch case '+i+' '+JSON.stringify(cases[i])+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}
const result={upstream:PIN,scenarios:cases.length,timelineCalls:expected.reduce((n,r)=>n+(r[9]?r[9].split('|').length:0),0),comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'binaryanimation-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
