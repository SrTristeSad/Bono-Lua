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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const cases=[];
for(const values of ['1,0,0,1,0,0','0,1,-1,0,40,20','2,1,-3,4,5,6','-2,-1,3,-4,-5,-6','0,0,0,0,-0,0','NaN,1,2,3,4,5','Infinity,0,0,1,0,0'])for(const mode of ['new','borrow','clean','dirty','clear','reuse','failFromMatrix','failMatrixClear','failGlobalClear','failOffsetClear','readonly','replace'])cases.push([mode,values]);
let seed=0x5452414e;for(let i=0;i<128;i++){const a=[];for(let j=0;j<6;j++){seed=(Math.imul(seed,1664525)+1013904223)>>>0;a.push((seed%2001-1000)/37);}cases.push(['dirty',a.join(',')]);}
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject,T=d.TransformObject;vm.runInContext('class RuntimeProbe extends dragonBones.TransformObject {static toString(){return "[test.RuntimeTransform]";}};this.RuntimeProbe=RuntimeProbe;',ctx);const C=ctx.RuntimeProbe;
function num(s){return s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-0'?-0:Number(s);}
function scalar(n){if(n===undefined)return'u';if(typeof n==='boolean')return String(n);if(Number.isNaN(n))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(n);return'n'+b.toString('hex');}
const keys=['x','y','skew','rotation','scaleX','scaleY'];
function execute(row){const [mode,text]=row;B.clearPool(C);const p=mode==='new'?new C():B.borrowObject(C),q=new C(),matrix=p.globalTransformMatrix,global=p.global,offset=p.offset,origin=new d.Transform(),user={},armature={};
 const initial=[p._globalDirty,p._alpha,p._globalAlpha].map(scalar).join(',');p.origin=origin;p.userData=user;p._armature=armature;const values=text.split(',').map(num);['a','b','c','d','tx','ty'].forEach((k,i)=>matrix[k]=values[i]);p.offset.x=9;p._alpha=.25;p._globalAlpha=.5;
 let calls=0,tag='ok',returned;const original=global.fromMatrix;global.fromMatrix=function(m){calls++;if(mode==='failFromMatrix')throw Error('injected');return original.call(this,m);};
 if(mode==='failMatrixClear')matrix.identity=function(){throw Error('injected');};if(mode==='failGlobalClear')global.identity=function(){throw Error('injected');};if(mode==='failOffsetClear')offset.identity=function(){throw Error('injected');};
 p._globalDirty=mode!=='clean';try{if(mode==='new'){}else if(mode==='readonly'){p.armature={};}else if(mode==='clear'||mode.startsWith('fail')&&mode!=='failFromMatrix'){p._onClear();}else if(mode==='reuse'){p.returnToPool();returned=B.borrowObject(C);}else if(mode==='replace'){p.globalTransformMatrix=new d.Matrix(...values);p.updateGlobalTransform();p.updateGlobalTransform();}else{p.updateGlobalTransform();p.updateGlobalTransform();}}catch(e){tag='error';}
 let abstract='ok';try{B.borrowObject(T);}catch(e){abstract='error';}
 const result=[tag,initial,p._globalDirty,p._alpha,p._globalAlpha,...['a','b','c','d','tx','ty'].map(k=>p.globalTransformMatrix[k]),...keys.map(k=>p.global[k]),...keys.map(k=>p.offset[k])].map((v,i)=>i<2?String(v):scalar(v));
 return [...result,String(calls),p.globalTransformMatrix===matrix,p.global===global,p.offset===offset,p.origin===origin,p.userData===user,p.armature===armature,returned===p,p._isInPool,T._helpMatrix===C._helpMatrix,T._helpMatrix!==matrix,T._helpTransform===C._helpTransform,T._helpPoint===C._helpPoint,q.global!==p.global,abstract].map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'transformobject-'+path.basename(lua)+'-cases.tsv');fs.writeFileSync(input,cases.map(r=>r.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'transformobject-'+path.basename(lua)+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/transformobject_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'transformobject-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0,approximate=0;const decode=s=>s.startsWith('n')?Buffer.from(s.slice(1),'hex').readDoubleLE():NaN;
for(let i=0;i<lines.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns '+i);for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j]){const a=decode(lines[i][j]),b=decode(expected[i][j]);if(['dirty','borrow','replace'].includes(cases[i][0])&&j>=13&&j<=16&&Number.isFinite(a)&&Number.isFinite(b)&&a!==0&&b!==0&&Math.abs(a-b)<=8*Number.EPSILON*Math.max(1,Math.abs(b))){approximate++;continue;}throw Error('TransformObject mismatch '+i+' '+cases[i].join(' ')+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,approximateComparisons:approximate,tolerance:'exact except nonzero trig decomposition: 8*epsilon*max(1,abs(expected))',lua,result:'passed'};fs.writeFileSync(path.join(dir,'transformobject-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
