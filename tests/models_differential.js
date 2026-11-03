'use strict';
// The oracle executes original model + pool + rectangle code. The two small
// abstract-backend test classes only supply keys and createTexture().
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
const code=['core/BaseObject','geom/Rectangle','model/CanvasData','model/TextureAtlasData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const rows=[];
function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
scenario('canvas-constructor-and-pool',[
 ['new','raw','C'],['borrow','clean','C'],['string','C'],
 ['set','raw','hasBackground','true'],['set','raw','color',16777215],['set','raw','x','-0'],['set','raw','y','NaN'],
 ['set','raw','width','Infinity'],['set','raw','height',-14],['set','raw','extra',77],
 ['return','raw'],['borrow','again','C'],['onClear','again'],['limit','C',2],['return','again'],['return','again'],
 ['return','clean'],['borrow','first','C'],['borrow','second','C'],['clearPool','C'],['return','raw']]);
scenario('texture-region-frame-copy',[
 ['new','raw','T'],['borrow','src','T'],['borrow','dest','T'],['borrow','atlas','A'],
 ['set','src','name','s:sample'],['set','src','rotated','true'],['region','src','-0',0.25,-5,12],['parent','src','atlas'],
 ['rect','f1',1,2,3,4],['rect','f2',9,8,7,6],['frame','src','f1'],['copy','dest','src'],
 ['frame','dest','f2'],['copy','dest','src'],['copy','src','src'],['frame','src','none'],['copy','dest','src'],
 ['onClear','dest'],['return','src'],['borrow','again','T'],['string','AbstractT'],['string','AbstractA'],['abstractCreate','atlas']]);
scenario('atlas-copy-parent-and-order',[
 ['borrow','src','A'],['borrow','dest','A'],['set','src','autoSearch','true'],['set','src','width',1024],
 ['set','src','height',512],['set','src','scale',0.5],['set','src','name','s:atlas'],['set','src','imagePath','s:texture.png'],
 ...['beta','alpha','2','10'].flatMap((name,i)=>[
   ['borrow','s'+i,'T'],['set','s'+i,'name','s:'+name],['region','s'+i,i,i+1,i+2,i+3],['add','src','s'+i]]),
 ...['old-z','old-a'].flatMap((name,i)=>[
   ['borrow','d'+i,'T'],['set','d'+i,'name','s:'+name],['add','dest','d'+i]]),
 ['borrow','duplicate','T'],['set','duplicate','name','s:beta'],['parent','duplicate','dest'],['add','src','duplicate'],
 ['get','found','src','beta'],['get','missing','src','absent'],['copy','dest','src'],['get','copied','dest','beta'],
 ['copy','src','src'],['return','dest'],['borrow','reused','A']]);
scenario('direct-map-delete-reinsert',[
 ['new','atlas','A'],['borrow','a','T'],['borrow','b','T'],['borrow','c','T'],['borrow','d','T'],
 ['put','atlas','x','a'],['put','atlas','-0','b'],['put','atlas','10','c'],['put','atlas','2','d'],
 ['delete','atlas','x'],['put','atlas','x','a'],['onClear','atlas'],['borrow','last','T'],['borrow','next','T']]);
scenario('factory-error-keeps-original-partial-state',[
 ['borrow','src','A'],['borrow','dest','A'],['borrow','a','T'],['borrow','b','T'],['borrow','old','T'],
 ['set','a','name','s:one'],['set','b','name','s:two'],['set','old','name','s:old'],
 ['add','src','a'],['add','src','b'],['add','dest','old'],['set','dest','failAt',2],
 ['copy','dest','src'],['set','dest','failAt','undefined'],['copy','dest','src'],['return','dest']]);
scenario('scalar-binary64-preservation',[
 ['borrow','canvas','C'],['borrow','tex','T'],
 ...['0.1','-0.1','1.2345678901234567','5e-324','-5e-324','1.7976931348623157e308','-0','NaN','Infinity','-Infinity'].flatMap(n=>[
  ['set','canvas','x',n],['set','canvas','height',n],['region','tex',n,n,n,n]]),
 ['return','canvas'],['return','tex']]);
for(const limit of ['0','1','2','0.5','1.5','NaN','-1','Infinity'])scenario('canvas-limit-'+limit,[
 ['borrow','a','C'],['borrow','b','C'],['limit','C',limit],['return','a'],['return','b'],
 ['limit','C',limit],['borrow','c','C'],['return','c'],['clearPool','*'],['return','a']]);
let seed=0x4d4f444c;
const random=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<4;s++) {
 const steps=[['borrow','a','A'],['borrow','b','A'],...Array.from({length:6},(_,i)=>['borrow','t'+i,'T'])];
 for(let i=0;i<80;i++) {
  const id='t'+random(6),atlas=random(2)?'a':'b';
  switch(random(7)){
   case 0:steps.push(['set',id,'name','s:name'+random(4)],['add',atlas,id]);break;
   case 1:steps.push(['region',id,random(20)-10,random(20)-10,random(20),random(20)]);break;
   case 2:steps.push(['copy',id,'t'+random(6)]);break;
   case 3:steps.push(['get','lookup',atlas,'name'+random(4)]);break;
   case 4:steps.push(['copy',atlas,atlas==='a'?'b':'a']);break;
   case 5:steps.push(['onClear',id]);break;
   case 6:steps.push(['limit',random(2)?'C':'T',random(4)]);break;
  }
 }
 scenario('deterministic-'+s,steps);
}
function scalar(v){
 if(v===undefined)return 'undefined';
 if(typeof v==='boolean')return v?'b:true':'b:false';
 if(typeof v!=='number')return 's:'+v;
 if(Number.isNaN(v))return 'NaN';
 const bytes=Buffer.alloc(8);bytes.writeDoubleLE(v);return 'n:'+bytes.toString('hex');
}
const decode=v=>v.startsWith('s:')?v.slice(2):v==='true'?true:v==='false'?false:v==='undefined'?undefined:Number(v);
let B,C,A,T,AbstractA,AbstractT,classes,objects,labels,rectangles,warnings,rectIds,mapIds,nextRect,nextMap;
function begin(){
 warnings=[];const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);
 const d=ctx.dragonBones;B=d.BaseObject;C=d.CanvasData;AbstractA=d.TextureAtlasData;AbstractT=d.TextureData;
 T=class extends AbstractT {static toString(){return '[test.Models.Texture]';}};
 A=class extends AbstractA {
  static toString(){return '[test.Models.Atlas]';}
  createTexture(){this.createCalls=(this.createCalls||0)+1;if(this.failAt===this.createCalls)throw Error('factory failure');return B.borrowObject(T);}
 };
 classes={C,A,T,AbstractA,AbstractT};objects={};labels=new Set();rectangles={};rectIds=new WeakMap();mapIds=new WeakMap();nextRect=0;nextMap=0;
}
function rect(r){if(r==null)return 'nil';if(!rectIds.has(r))rectIds.set(r,++nextRect);return rectIds.get(r)+':'+['x','y','width','height'].map(k=>scalar(r[k])).join(',');}
function ref(o){return o==null?'nil':scalar(o.hashCode);}
function describe(o){
 if(o==null)return 'nil';
 const base=[scalar(o.hashCode),o._isInPool?'1':'0'];
 if(o instanceof C)return ['C',...base,...['hasBackground','color','x','y','width','height','extra'].map(k=>scalar(o[k]))].join(':');
 if(o instanceof AbstractT)return ['T',...base,scalar(o.rotated),scalar(o.name),rect(o.region),ref(o.parent),rect(o.frame)].join(':');
 if(!mapIds.has(o.textures))mapIds.set(o.textures,++nextMap);
 return ['A',...base,...['autoSearch','width','height','scale','name','imagePath','createCalls','failAt'].map(k=>scalar(o[k])),mapIds.get(o.textures),
   Object.keys(o.textures).sort().map(k=>k+'='+describe(o.textures[k])).join(';')].join(':');
}
function snapshot(){return [scalar(B._hashCode),scalar(B._defaultMaxCount),
 Object.keys(rectangles).sort().map(k=>k+'='+rect(rectangles[k])).join('|'),
 [...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),
 Object.keys(B._poolsMap).sort().map(k=>k+':'+B._poolsMap[k].map(ref).join(',')).join('|'),
 Object.keys(B._maxCountMap).sort().map(k=>k+':'+scalar(B._maxCountMap[k])).join('|'),warnings.join('|')];}
const expected=[];
for(let i=0;i<rows.length;i++){
 const [op,a,b,c,...rest]=rows[i];let tag='void';
 if(op==='begin')begin();else{
  warnings=[];
  try{
   let value;
   if(op==='new'||op==='borrow'){value=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=value;labels.add(a);}
   else if(op==='set')objects[a][b]=decode(c);
   else if(op==='region')for(const [j,k] of ['x','y','width','height'].entries())objects[a].region[k]=Number([b,c,...rest][j]);
   else if(op==='rect'){const r=AbstractT.createRectangle();for(const [j,k] of ['x','y','width','height'].entries())r[k]=Number([b,c,...rest][j]);rectangles[a]=r;value=r;}
   else if(op==='frame')objects[a].frame=b==='none'?null:rectangles[b];
   else if(op==='parent')objects[a].parent=b==='none'?null:objects[b];
   else if(op==='add')value=objects[a].addTexture(objects[b]);
   else if(op==='get'){value=objects[b].getTexture(c);objects[a]=value;labels.add(a);}
   else if(op==='copy')value=objects[a].copyFrom(objects[b]);
   else if(op==='onClear')value=objects[a]._onClear();
   else if(op==='return')value=objects[a].returnToPool();
   else if(op==='limit')value=B.setMaxCount(a==='*'?null:classes[a],Number(b));
   else if(op==='clearPool')value=B.clearPool(a==='*'?null:classes[a]);
   else if(op==='string')value=classes[a].toString();
   else if(op==='put')objects[a].textures[b]=objects[c];
   else if(op==='delete')delete objects[a].textures[b];
   else if(op==='abstractCreate')value=AbstractA.prototype.createTexture.call(objects[a]);
   else throw Error('Unknown test command');
   tag=op==='get'?(value===null?'nil':'object:'+ref(value)):op==='rect'?'rectangle':
     op==='string'?'string:'+value:value===undefined?'void':'object:'+ref(value);
  }catch(e){tag=e.name==='RangeError'?'range':'error';}
 }
 expected.push([String(i),tag,...snapshot()]);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});
const input=path.join(dir,'models-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');
fs.writeFileSync(path.join(dir,'models-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/models_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:32*1024*1024});
fs.writeFileSync(path.join(dir,'models-'+path.basename(lua)+'-actual.tsv'),actual);
const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));
if(lines.length!==expected.length)throw Error('Model transcript length differs');
let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){
 comparisons++;if(lines[i][j]!==expected[i][j])throw Error('Model mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);
}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,
 tolerance:0,numericComparison:'exact binary64 bytes; NaN canonicalized',referenceNormalization:'null/undefined parent or missing-object references map to nil',lua,result:'passed'};
fs.writeFileSync(path.join(dir,'models-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
