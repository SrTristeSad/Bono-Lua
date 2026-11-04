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

const cases=[];for(const offset of [0,12,32767,32768,65534,65535])for(const vertices of [0,1,3])for(const bones of [0,1,3])for(const mode of ['normal','oldWeight','clear','shared'])cases.push([offset,vertices,bones,mode]);
for(const mode of ['missingBuffer','missingData','missingOffset','nullRaw','negativeOffset','fractionOffset','nanOffset','outsideOffset','shortBuffer','outsideWeight','missingBones','holes','badBoneIndex','duplicateBones','negativeBones','negativeVertices','negativeInfluence','truncatedInfluence','repeat','mutate','returnFailure','addFailure'])cases.push([12,3,3,mode]);
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
function scalar(v){if(v===undefined)return'u';if(v===null)return'null';if(typeof v==='number'){if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}return String(v);}
function execute(c){const [w,vertices,bones,mode]=c,p=new d.BinaryDataParser(),data=B.borrowObject(d.DragonBonesData),g=new d.GeometryData();g.clear();p._data=data;
 for(let i=0;i<3;i++){const b=B.borrowObject(d.BoneData);b.name='b'+i;p._rawBones.push(b);}
 const size=mode==='shortBuffer'?8:Math.max(40,w+20),buf=new ArrayBuffer(4+size*2),view=new Int16Array(buf,4,size);p._intArrayBuffer=view;data.intArray=view;data.binary=buf;
 view[3]=vertices;view[4]=2;view[6]=w;
 if(w!==65535&&w<size){view[w]=bones;for(let i=0;i<bones;i++)view[w+2+i]=i;let at=w+2+bones;for(let i=0;i<vertices;i++){view[at++]=i%3;for(let j=0;j<i%3;j++)view[at++]=j;}}
 let old;if(['oldWeight','clear','shared','repeat','returnFailure','addFailure'].includes(mode)){old=B.borrowObject(d.WeightData);old.count=91;old.offset=71;old.addBone(p._rawBones[0]);g.weight=old;}
 if(mode==='shared')g.isShared=true;
 let raw={offset:3};if(mode==='missingBuffer')p._intArrayBuffer=null;if(mode==='missingData')p._data=null;if(mode==='missingOffset')raw={};if(mode==='nullRaw')raw=null;if(mode==='negativeOffset')raw.offset=-2;if(mode==='fractionOffset')raw.offset=0.5;if(mode==='nanOffset')raw.offset=NaN;if(mode==='outsideOffset')raw.offset=size+10;if(mode==='outsideWeight')view[6]=size+10;if(mode==='missingBones')p._rawBones.length=0;if(mode==='holes')delete p._rawBones[1];if(mode==='badBoneIndex')view[w+2]=-1;if(mode==='duplicateBones')for(let i=0;i<bones;i++)view[w+2+i]=0;if(mode==='negativeBones')view[w]=-1;if(mode==='negativeVertices')view[3]=-1;if(mode==='negativeInfluence')view[w+2+bones]=-1;if(mode==='truncatedInfluence')view[w+2+bones]=32767;
 const before=Buffer.from(new Uint8Array(buf)).toString('hex'),allocated=[];const original=B.borrowObject;B.borrowObject=function(C){const o=original.call(B,C);allocated.push(o);return o;};const originalAdd=d.WeightData.prototype.addBone;let added=0;if(mode==='addFailure')d.WeightData.prototype.addBone=function(b){if(++added===2)throw Error('injected add');return originalAdd.call(this,b);};let tag='ok';try{p._parseGeometry(raw,g);if(mode==='repeat')p._parseGeometry(raw,g);if(mode==='mutate'){view[6]=-1;p._parseGeometry(raw,g);}}catch(e){tag='error';}finally{B.borrowObject=original;d.WeightData.prototype.addBone=originalAdd;}
 const weight=o=>o?[scalar(o.offset),scalar(o.count),o.bones.length,Array.from({length:Math.min(o.bones.length,20)},(_,i)=>o.bones[i]===undefined?'u':o.bones[i]===null?'null':o.bones[i].name).join(',')].join(':'):'nil';
 const first=[tag,scalar(g.offset),g.data===data?'data':g.data===null?'null':'other',weight(g.weight),weight(old),allocated.map(weight).join('|'),g.weight===old,allocated.length,g.isShared];
 if(mode==='returnFailure'&&g.weight)g.weight.returnToPool=function(){throw Error('injected');};let clear='skip';if(['clear','shared','returnFailure'].includes(mode)){try{g.clear();clear='ok';}catch(e){clear='error';}}
 return [...first,clear,weight(g.weight),old?old._isInPool:false,allocated.map(o=>o._isInPool?'1':'0').join(''),g.data===null?'null':g.data===data?'data':'other',scalar(g.offset),g.isShared,mode==='mutate'?view[6]===-1:Buffer.from(new Uint8Array(buf)).toString('hex')===before,view.buffer===buf].map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'binarygeometry-cases.tsv');fs.writeFileSync(input,cases.map(r=>r.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'binarygeometry-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/binarygeometry_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'binarygeometry-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0;for(let i=0;i<lines.length;i++)for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j])throw Error('Binary geometry mismatch case '+i+' '+JSON.stringify(cases[i])+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'binarygeometry-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
