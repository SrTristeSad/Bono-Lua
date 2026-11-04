'use strict';
// Execute pinned DisplayFrame with real display/geometry/weight models.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const cases=[];for(let raw=0;raw<6;raw++)for(let replacement=0;replacement<6;replacement++)for(let texture=0;texture<4;texture++)for(let weighted=0;weighted<2;weighted++)for(const op of ['normal','prefilled','holes','badCount','badOffset','missingData','zero','repeat'])cases.push([raw,replacement,texture,weighted,op]);
function execute(c){const [r,v,t,w,op]=c,owned=[],ids=new Map();function borrow(C,id){const x=B.borrowObject(C);owned.push(x);ids.set(x,id);return x;}function texture(id){const x=new d.TextureData();x._onClear();ids.set(x,id);return x;}const tex=[texture('rawTexture'),texture('replacementTexture'),texture('overrideTexture')];
function display(kind,id,texture){if(!kind)return null;const x=borrow([null,d.ImageDisplayData,d.MeshDisplayData,d.PathDisplayData,d.BoundingBoxDisplayData,d.ArmatureDisplayData][kind],id);if(kind===1||kind===2)x.texture=t===3?null:texture;if(kind===2||kind===3){ids.set(x.geometry,id+'Geometry');const data=borrow(d.DragonBonesData,id+'Data');data.intArray=new Int16Array([99,3]);x.geometry.data=data;x.geometry.offset=1;if(w){x.geometry.weight=B.borrowObject(d.WeightData);x.geometry.weight.count=4;}if(op==='badCount'){if(w)x.geometry.weight.count=-1;else data.intArray[1]=-1;}if(op==='zero'){if(w)x.geometry.weight.count=0;else data.intArray[1]=0;}if(op==='badOffset')x.geometry.offset=100;if(op==='missingData')x.geometry.data=null;}if(kind===4){x.boundingBox=B.borrowObject(d.RectangleBoundingBoxData);ids.set(x.boundingBox,id+'Box');}return x;}
const f=B.borrowObject(d.DisplayFrame),a=f.deformVertices;f.rawDisplayData=display(r,'raw',tex[0]);f.displayData=display(v,'replacement',tex[1]);f.textureData=t===1||t===3?tex[2]:null;f.display=tex[0];if(op==='prefilled')a.push(7,-0);if(op==='holes')a.length=3;let status='ok';try{f.updateDeformVertices();if(op==='repeat'){if(a.length)a[0]=9;f.updateDeformVertices();}}catch(e){status='error';}const id=x=>x==null?'nil':ids.get(x);const out=[status,id(f.getGeometryData()),id(f.getBoundingBox()),id(f.getTextureData()),a.length,Array.from({length:a.length},(_,i)=>i in a?(Object.is(a[i],-0)?'-0':String(a[i])):'hole').join(',')];f.returnToPool();out.push(f.deformVertices===a,a.length,f.rawDisplayData===null,f.displayData===null,f.textureData===null,f.display===null);const again=B.borrowObject(d.DisplayFrame);out.push(again===f,again.deformVertices===a);again.returnToPool();for(const x of owned.reverse())x.returnToPool();return out.join('|');}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'displayframe-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute).join('\n')+'\n';const actual=cp.execFileSync(lua,['tests/displayframe_differential.lua',input],{cwd:root,encoding:'utf8',timeout:120000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'displayframe-'+tag+'-original.tsv'),expected);fs.writeFileSync(path.join(dir,'displayframe-'+tag+'-actual.tsv'),actual);if(actual!==expected){const a=actual.trimEnd().split('\n'),b=expected.trimEnd().split('\n');const i=b.findIndex((x,i)=>a[i]!==x);throw Error('DisplayFrame '+i+' '+cases[i]+' expected '+b[i]+' actual '+a[i]);}const result={upstream:PIN,scenarios:cases.length,comparedColumns:cases.length*14,sourceErrors:expected.split('\n').filter(x=>x.startsWith('error|')).length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'displayframe-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
