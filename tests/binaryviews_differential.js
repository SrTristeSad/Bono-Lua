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

const cases=[['normal',0,'0'],['overlap',0,'0'],['mutate',0,'0'],['empty',0,'0'],['short',0,'0'],['colorMissing',0,'0'],['colorZero',0,'0'],['nullRaw',0,'0'],['nullOffsets',0,'0'],['missingData',0,'0']];
for(const i of [0,2,4,6,8,10,12])for(const v of ['-2','-0.5','0.5','1','2','4','200','NaN','Infinity','undefined','null'])cases.push(['start',i,v]);
for(const i of [1,3,5,7,9,11,13])for(const v of ['-4','-0.5','0','1','2','3','5.9','200','NaN','Infinity','undefined','null'])cases.push(['length',i,v]);
for(const v of ['-4','-0.5','0.5','1','2','4','200','NaN','Infinity','undefined'])cases.push(['base',0,v]);
for(const k of ['binary','intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'])cases.push(['setter',0,k]);
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const fields=['intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'],ctors=[Int16Array,Float32Array,Int16Array,Float32Array,Int16Array,Uint16Array,Int16Array];
const val=s=>s==='undefined'?undefined:s==='null'?null:Number(s);
function scalar(v){if(v===undefined)return'u';if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return b.toString('hex');}
function execute(c){const[mode,index,token]=c,p=new d.BinaryDataParser(),data=B.borrowObject(d.DragonBonesData),buf=new ArrayBuffer(128),old=new ArrayBuffer(16);new Uint8Array(buf).set(Array.from({length:128},(_,i)=>(i*13+7)%256));data.binary=old;for(let i=0;i<fields.length;i++)data[fields[i]]=new ctors[i](old,0,2);p._intArrayBuffer=data.intArray;p._frameArrayBuffer=data.frameArray;p._timelineArrayBuffer=data.timelineArray;p._data=data;p._binary=buf;p._binaryOffset=8;
 let offsets=[0,8,8,8,16,4,20,8,28,4,32,4,36,4],raw={offset:offsets};
 if(mode==='start'||mode==='length')offsets[index]=val(token);if(mode==='base')p._binaryOffset=val(token);if(mode==='overlap'||mode==='mutate')offsets=[0,8,0,8,0,8,0,8,0,8,0,8,0,8];if(mode==='empty')offsets=Array(14).fill(0);if(mode==='short')offsets=[];if(mode==='colorMissing')offsets.length=13;if(mode==='colorZero'){offsets[12]=999;offsets[13]=0;}raw.offset=offsets;if(mode==='nullRaw')raw=null;if(mode==='nullOffsets')raw.offset=null;if(mode==='missingData')p._data=null;
 if(mode==='setter'){const previous=data[token];Object.defineProperty(data,token,{configurable:true,get(){return previous;},set(){throw Error('injected setter');}});}
 let tag='ok';try{p._parseArray(raw);}catch(e){tag='error';}
 const before=Buffer.from(new Uint8Array(buf)).toString('hex');if(mode==='mutate'&&tag==='ok'){data.intArray[0]=0x1234;data.floatArray[1]=1.25;data.timelineArray[2]=65535;}
 const meta=v=>v?[v.buffer===buf?'new':v.buffer===old?'old':'other',v.length,v.byteOffset,v.byteLength,v.BYTES_PER_ELEMENT,Array.from(v).slice(0,12).map(scalar).join(',')].join(':'):'nil';
 return [tag,data.binary===buf?'new':data.binary===old?'old':'other',...fields.map(k=>meta(data[k])),meta(p._intArrayBuffer),meta(p._frameArrayBuffer),meta(p._timelineArrayBuffer),p._intArrayBuffer===data.intArray,p._frameArrayBuffer===data.frameArray,p._timelineArrayBuffer===data.timelineArray,data.colorArray===data.intArray,Buffer.from(new Uint8Array(buf)).toString('hex'),before].map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'binaryviews-cases.tsv');fs.writeFileSync(input,cases.map(r=>r.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'binaryviews-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/binaryviews_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'binaryviews-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0;for(let i=0;i<lines.length;i++)for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j])throw Error('Binary views mismatch case '+i+' '+JSON.stringify(cases[i])+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'binaryviews-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
