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

const rows=[];const add=(op,text,scale='1')=>rows.push([op,Buffer.from(text).toString('hex'),scale]);
for(const text of ['null','true','false','0','-0','-0.0','1e999','-1e999','-1e-999','9007199254740993','9223372036854775807','0.1','1.7976931348623157e308','5e-324','[]','{}','[null,false,0,"x"]','{"2":0,"a":1,"1":2,"a":3,"__proto__":null}', '"\\uD800"','"\\uDC00"','"\\uD83D\\uDE00"','"😀"','"\\u0000"','"\\uD800x"','"\\uD800\\u0041"','', '01','-01','1.','1.e2','1e','+1','NaN','Infinity','[1,]','{"x":1,}','{"x" 1}','"\\x00"','"\\uZZZZ"','true false','[','{','"x','\v0'])add('json',text);
for(let i=0;i<128;i++)add('json',JSON.stringify({name:'item'+i,a:[null,i/7,i%2===0,'α😀'],nested:{'10':i,'2':-i,x:'\n'}}));
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
function build(header,mode='valid'){
 let h=Buffer.from(typeof header==='string'?header:JSON.stringify(header));while(h.length%4)h=Buffer.concat([h,Buffer.from(' ')]);
 const body=Buffer.alloc(104);const i=new Int16Array(body.buffer,body.byteOffset,16);i.set([2,1,0,mode==='weighted'?8:-1,0,1,1]);if(mode==='weighted')i.set([1,0,0,1,0,1,0],8);
 new Int16Array(body.buffer,body.byteOffset+64,8).set([0,0,2,0]);new Uint16Array(body.buffer,body.byteOffset+80,8).set([100,0,2,1,0,0,2]);
 const prefix=Buffer.alloc(12);prefix.write('DBDT');prefix.writeUInt32LE(h.length,8);return Buffer.concat([prefix,h,body]);
}
const base={version:'5.6',name:'binary',frameRate:24,offset:[0,32,32,16,48,8,56,8,64,16,80,16,96,8],armature:[{name:'arm',bone:[{name:'root'}],slot:[{name:'slot',parent:'root'}],skin:[{name:'default',slot:[{name:'slot',display:[{name:'mesh',type:'mesh',offset:0}]}]}],animation:[{name:'walk',duration:4,offset:[0,0,0],action:0,bone:{root:[11,0]},slot:{slot:[20,0]},timeline:[{type:40,offset:0,name:'child'}]}]}]};
for(const mode of ['valid','weighted','noColor','noArmature','emptyArms','unsupported','compatible','nullArms','badOffset','badAnimation','blend','cleanup','mutate']){
 const h=JSON.parse(JSON.stringify(base));if(mode==='noColor')h.offset.length=12;if(mode==='noArmature')delete h.armature;if(mode==='emptyArms')h.armature=[];if(mode==='unsupported')h.version='x';if(mode==='compatible'){h.version='x';h.compatibleVersion='5.6';}if(mode==='nullArms')h.armature=null;if(mode==='badOffset')h.offset[2]=1;if(mode==='badAnimation')h.armature[0].animation[0].offset=null;if(mode==='blend')h.armature[0].animation[0].blendType='1D';add(mode,build(h,mode),mode==='valid'?'2':'1');
}
for(let n=0;n<13;n++)add('truncated',build(base).subarray(0,n));
const wrong=build(base);wrong[0]=0;add('badtag',wrong);const huge=build(base);huge.writeUInt32LE(0xffffffff,8);add('hugeHeader',huge);
for(const text of ['{','null','[]','true','{"version":"5.6"}','{"version":"5.6","offset":[],"armature":[]}','{"version":"5.6","name":"\\uD800"}'])add('header',build(text));
for(const byte of [0,255]){const blob=build('{"version":"5.6","name":"a~b"}');blob[blob.indexOf(126)]=byte;add('customDecoder',blob);}
add('json','['.repeat(64)+'null'+']'.repeat(64));
for(const size of [256,65536]){const prefix=Buffer.alloc(12);prefix.write('DBDT');prefix.writeUInt32LE(size,8);const h=Buffer.alloc(size,32);h.write('{"version":"5.6","name":"large"}');add('largeHeader',Buffer.concat([prefix,h]));}
for(const text of ['"\\uD800\\uD800"','"\\uDC00\\uD800"','"\\uD83D\\uDE00\\u0000"','{"😀":1,"\\uD83D\\uDE00":2}','[true,false,null,-0,1e400]','\u00a00','\f0','[01]','1e+','-','"\\u123"'])add('json',text);
function scalar(v){if(v===undefined)return'u';if(v===null)return'null';if(typeof v==='string')return's'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='number'){if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}return String(v);}
function tree(v){if(v===null||typeof v!=='object')return scalar(v);if(Array.isArray(v))return'['+v.map(tree).join('|')+']';return'{'+Object.keys(v).map(k=>scalar(k)+':'+tree(v[k])).join('|')+'}';}
function execute(r){const [op,h,scale]=r;if(op==='json'){try{return ['ok',tree(JSON.parse(Buffer.from(h,'hex').toString()))];}catch(e){return['error',''];}}
 const p=new d.BinaryDataParser(),bytes=Buffer.from(h,'hex'),buf=new ArrayBuffer(bytes.length);new Uint8Array(buf).set(bytes);const old=new ArrayBuffer(1);p._binary=old;p._binaryOffset=99;const allocated=[],borrow=B.borrowObject;B.borrowObject=function(C){const o=borrow.call(B,C);allocated.push(o);return o;};let result,tag='ok';try{result=p.parseDragonBonesData(buf,Number(scale));}catch(e){tag='error';}finally{B.borrowObject=borrow;}
 const data=result||p._data,tl=t=>t?[t.type,t.offset,t.frameIndicesOffset,t.x,t.y].map(scalar).join(','):'nil';
 function snapshot(){if(!data)return'nil';const arms=data.armatureNames.map(n=>{const a=data.getArmature(n);const skins=Object.keys(a.skins).map(k=>Object.keys(a.skins[k].displays).map(s=>a.skins[k].displays[s].map(x=>{if(!x)return'null';const g=x.geometry;return scalar(x.name)+':'+(g?[scalar(g.offset),g.vertexCount,g.weight?g.weight.count:'none',g.weight?g.weight.bones.map(b=>b?scalar(b.name):'u').join(','):''].join(','):'');}).join(';')).join('|')).join('/');const anim=Object.keys(a.animations).map(k=>{const z=a.animations[k];return[scalar(z.name),scalar(z.duration),tl(z.actionTimeline),...['boneTimelines','slotTimelines','constraintTimelines','animationTimelines'].map(m=>Object.keys(z[m]).map(n=>scalar(n)+'='+z[m][n].map(tl).join(';')).join('|'))].join('/');}).join('|');return[scalar(a.name),scalar(a.scale),a.sortedBones.map(b=>scalar(b.name)).join(','),skins,anim].join('~');}).join('!');const views=['intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'].map(k=>{const v=data[k];return v?[v.byteOffset,v.byteLength,v.buffer===buf].join(','):'nil';}).join('|');return[scalar(data.name),scalar(data.version),scalar(data.frameRate),data.stage?scalar(data.stage.name):'nil',arms,data.frameIndices.map(scalar).join(','),views,data.binary===buf,data.colorArray===data.intArray].join('#');}
 const before=snapshot();if(op==='mutate'&&data){data.intArray[0]=7;data.timelineArray[0]=250;}let cleanup='skip';if(op==='cleanup'&&result){try{result.returnToPool();cleanup='ok';}catch(e){cleanup='error';}}
 return[tag,result===null?'null':result?'data':'undefined',scalar(p._binaryOffset),p._binary===buf?'new':p._binary===old?'old':'other',p._data===null?'clear':'retained',p._animation===null?'clear':'retained',before,op==='mutate'?snapshot():'',cleanup,allocated.map(o=>o._isInPool?'1':'0').join(''),Buffer.from(new Uint8Array(buf)).toString('hex')];
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'dbdt-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');const expected=rows.map(execute);fs.writeFileSync(path.join(dir,'dbdt-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/dbdt_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:16*1024*1024});fs.writeFileSync(path.join(dir,'dbdt-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let columns=0;for(let i=0;i<lines.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns '+i);for(let j=0;j<expected[i].length;j++){columns++;if(lines[i][j]!==expected[i][j])throw Error('DBDT mismatch '+i+' '+rows[i][0]+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.length,comparedColumns:columns,sourceErrors:expected.filter(r=>r[0]==='error').length,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'dbdt-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
