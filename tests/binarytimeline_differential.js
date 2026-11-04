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

const cases=[];
function add(frameCount, starts, options={}){cases.push({frameCount,starts,...options});}
for(const frameCount of [0,1,2,7,16,60])for(const starts of [[],[0],[0,1],[0,2,5],[2,2,2],[-2,0,4],[7,3,1]])for(const supplied of [0,1,2])add(frameCount,starts,{supplied});
for(const mode of ['missingTimeline','missingFrame','missingAnimation','missingData','badLength','outsideTimeline','outsideFrame','fractionOffset','nanOffset','nullArg','undefinedArg','reuse','append','mutate','negativeTotal','zeroTotal','lengthOverflow','maxKeys','duplicateOffsets'])for(const starts of [[],[0],[0,2,5]])add(7,starts,{mode});
let seed=0x54494d45;function next(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;}
for(let i=0;i<256;i++){const n=next()%9,starts=[];for(let j=0;j<n;j++)starts.push(next()%40-4);add(next()%35,starts,{supplied:next()%3,type:next()%80,prefix:next()%7,frameOffset:next()%5});}
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
function execute(c){
 const p=new d.BinaryDataParser(),data=B.borrowObject(d.DragonBonesData),anim=B.borrowObject(d.AnimationData);
 p._data=data;p._animation=anim;anim.frameCount=c.frameCount;anim.frameOffset=c.frameOffset===undefined?2:c.frameOffset;
 data.frameIndices.length=c.prefix===undefined?3:c.prefix;if(data.frameIndices.length>0)data.frameIndices[0]=99;
 const offset=3, frames=[-77,-88,...c.starts],timeline=[17,18,19,100,0,c.starts.length,0,0,...c.starts.map((_,i)=>i)];
 const buffer=new ArrayBuffer(4+frames.length*2+timeline.length*2),f=new Int16Array(buffer,4,frames.length),t=new Uint16Array(buffer,4+frames.length*2,timeline.length);f.set(frames);t.set(timeline);p._frameArrayBuffer=f;p._timelineArrayBuffer=t;
 let supplied=c.supplied===1?B.borrowObject(d.TimelineData):c.supplied===2?B.borrowObject(d.AnimationTimelineData):null;
 if(supplied){supplied.frameIndicesOffset=123;if(c.supplied===2){supplied.x=12;supplied.y=-9;}}
 const before=Buffer.from(new Uint8Array(buffer)).toString('hex');let argOffset=offset;
 if(c.mode==='missingTimeline')p._timelineArrayBuffer=null;if(c.mode==='missingFrame')p._frameArrayBuffer=null;if(c.mode==='missingAnimation')p._animation=null;if(c.mode==='missingData')p._data=null;
 if(c.mode==='negativeTotal')anim.frameCount=-2;if(c.mode==='zeroTotal')anim.frameCount=-1;if(c.mode==='lengthOverflow')data.frameIndices.length=4294967295;if(c.mode==='maxKeys')t[offset+2]=65535;if(c.mode==='duplicateOffsets')for(let i=0;i<c.starts.length;i++)t[offset+5+i]=0;if(c.mode==='badLength')anim.frameCount=0.5;if(c.mode==='outsideTimeline')argOffset=10000;if(c.mode==='outsideFrame')t[offset+5]=65535;if(c.mode==='fractionOffset')argOffset=0.5;if(c.mode==='nanOffset')argOffset=NaN;
 if(c.mode==='nullArg')supplied=null;if(c.mode==='undefinedArg')supplied=undefined;
 let result,tag='ok',reuse=false;
 try{result=p._parseBinaryTimeline(c.type===undefined?11:c.type,argOffset,supplied);
 if(c.mode==='append')result=p._parseBinaryTimeline(22,offset,result);
 if(c.mode==='mutate'){t[offset+2]=0;result=p._parseBinaryTimeline(23,offset,result);}
 if(c.mode==='reuse'){result.returnToPool();const again=B.borrowObject(d.TimelineData);reuse=again===result;result=p._parseBinaryTimeline(24,offset,again);}
 }catch(e){tag='error';}
 const active=result||p._timeline;const scalar=v=>v===undefined?'undefined':v===null?'null':Number.isNaN(v)?'NaN':String(v);
 return [tag,active?scalar(active.type):'nil',active?scalar(active.offset):'nil',active?scalar(active.frameIndicesOffset):'nil',p._timeline===null?'clear':p._timeline===active?'retained':'other',data.frameIndices.length,Array.from({length:Math.min(data.frameIndices.length,100)},(_,i)=>Object.prototype.hasOwnProperty.call(data.frameIndices,i)?scalar(data.frameIndices[i]):'hole').join(','),result?result===supplied:false,active?scalar(active.x):'nil',active?scalar(active.y):'nil',reuse,Buffer.from(new Uint8Array(buffer)).toString('hex'),before,p._frameArrayBuffer===f,p._timelineArrayBuffer===t].map(String);
}
const fields=['frameCount','starts','supplied','type','prefix','frameOffset','mode'];const rows=cases.map(c=>fields.map(k=>k==='starts'?c.starts.join(','):c[k]===undefined?'':String(c[k])));
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'binarytimeline-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'binarytimeline-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/binarytimeline_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'binarytimeline-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0;for(let i=0;i<lines.length;i++)for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j])throw Error('Binary timeline mismatch case '+i+' '+JSON.stringify(cases[i])+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}
const result={upstream:PIN,scenarios:cases.length,calls:cases.length+cases.filter(c=>['reuse','append','mutate'].includes(c.mode)).length,comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'binarytimeline-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
