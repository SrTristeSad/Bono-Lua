'use strict';
// Execute the eight genuine DisplayData declarations and their real
// pool/math/action/texture dependencies. Unported references are test records.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','model/UserData','model/TextureAtlasData','model/DisplayData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={G:'GeometryData',D:'DisplayData',I:'ImageDisplayData',A:'ArmatureDisplayData',M:'MeshDisplayData',B:'BoundingBoxDisplayData',P:'PathDisplayData',W:'WeightData',Q:'ActionData',U:'UserData',X:'TextureData'};
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
for(const kind of ['I','A','M','B','P','W'])scenario('construct-clear-and-pool-'+kind,[
 ['new','raw',kind],['borrow','clean',kind],['string',kind],['set','raw','extra','s:persist'],['clear','raw'],['clear','raw'],['return','raw'],['borrow','again',kind],['return','again'],['return','again'],['borrow','last',kind]]);
scenario('abstract-base-preserves-type-and-refuses-pool-key',[
 ['new','raw','D'],['set','raw','type',99],['transform','raw',1,2,3,4,5,6],['set','raw','name','s:raw'],['clear','raw'],['string','D'],['return','raw'],['borrow','bad','D']]);
scenario('geometry-construct-clear-getters-and-sharing',[
 ['new','g','G'],['get','g','vertexCount'],['clear','g'],['data','d',11,22,33,44,55],['data','other',101,202,303,404],
 ['link','g','data','d'],['get','g','vertexCount'],['get','g','triangleCount'],['set','g','offset',2],['get','g','vertexCount'],['get','g','triangleCount'],
 ['new','dest','G'],['set','dest','inheritDeform','true'],['link','dest','data','other'],['share','dest','g'],['get','dest','vertexCount'],['get','dest','triangleCount'],['share','g','g'],['clear','dest'],['clear','g']]);
scenario('geometry-raw-undefined-and-fractional-offsets',[
 ['new','g','G'],['data','d',11,22,33,44],['link','g','data','d'],['get','g','vertexCount'],['get','g','triangleCount'],
 ...['0','-0','-1','-0.5','0.5','5e-324','0.9999999999999999','1.0000000000000002','4','NaN','Infinity','-Infinity'].flatMap(n=>[['set','g','offset',n],['get','g','vertexCount'],['get','g','triangleCount']]),
 ['set','g','offset',0],['readonly','g','vertexCount'],['readonly','g','triangleCount'],['get','g','vertexCount'],['record','empty'],['link','g','data','empty'],['get','g','vertexCount']]);
scenario('geometry-owned-and-shared-weight',[
 ['new','owner','G'],['new','shared','G'],['borrow','w','W'],['record','bone'],['bone','w','bone'],['bone','w','bone'],['set','w','count',12],['set','w','offset',88],
 ['link','owner','weight','w'],['set','owner','offset',5],['set','shared','inheritDeform','true'],['share','shared','owner'],['clear','shared'],['clear','owner'],['borrow','reuse','W'],['clear','shared']]);
scenario('share-overwrites-without-recycling-old-weight',[
 ['new','src','G'],['new','dest','G'],['borrow','old','W'],['borrow','new','W'],['link','dest','weight','old'],['link','src','weight','new'],['set','src','offset',9],
 ['share','dest','src'],['clear','dest'],['clear','src'],['return','old'],['borrow','reuse','W']]);
scenario('geometry-clear-failure-retains-fields',[
 ['new','g','G'],['borrow','w','W'],['data','d',7,8],['link','g','data','d'],['link','g','weight','w'],['set','g','offset',99],['set','g','inheritDeform','true'],
 ['hook','return:w','throw'],['clear','g'],['clear','g'],['borrow','reuse','W']]);
scenario('image-references-and-independent-transform-pivot',[
 ['borrow','i','I'],['borrow','j','I'],['new','texture','X'],['record','skin'],['link','i','texture','texture'],['link','i','parent','skin'],
 ['transform','i','-0',0.25,1,2,3,4],['pivot','i',0.5,0.75],['set','i','name','s:imagem'],['set','i','path','s:ação.png'],['return','i'],['borrow','reuse','I']]);
scenario('armature-display-owns-actions-not-armature',[
 ['borrow','a','A'],['borrow','q','Q'],['borrow','u','U'],['record','armature'],['link','q','data','u'],['link','a','armature','armature'],['set','a','inheritAnimation','true'],
 ['action','a','q'],['action','a','q'],['clear','a'],['borrow','reuseQ','Q'],['borrow','reuseU','U']]);
scenario('armature-actions-growing-and-shortening-during-clear',[
 ['borrow','a','A'],['borrow','first','Q'],['borrow','late','Q'],['action','a','first'],['hook','return:first','action','a','late'],['clear','a'],
 ['borrow','f','Q'],['borrow','s','Q'],['action','a','f'],['action','a','s'],['hook','return:f','length','a','actions',0],['clear','a']]);
scenario('armature-actions-failure-before-subtype-resets',[
 ['borrow','a','A'],['borrow','first','Q'],['borrow','bad','Q'],['record','armature'],['link','a','armature','armature'],['set','a','type',999],['set','a','inheritAnimation','true'],
 ['transform','a',1,2,3,4,5,6],['set','a','name','s:before'],['action','a','first'],['action','a','bad'],['hook','return:bad','throw'],['return','a'],['return','a'],['borrow','reuse','A']]);
scenario('armature-sparse-actions-error',[
 ['borrow','a','A'],['borrow','q','Q'],['set','a','type',999],['action','a','q'],['length','a','actions',3],['clear','a'],['length','a','actions',1],['clear','a']]);
for(const kind of ['M','P'])scenario('geometry-owner-failure-order-'+kind,[
 ['borrow','display',kind],['geometry','g','display'],['borrow','w','W'],['link','g','weight','w'],['set','g','offset',21],['set','w','count',42],
 ['set','display','type',999],['set','display','closed','true'],['set','display','constantSpeed','true'],['transform','display',1,2,3,4,5,6],
 ...(kind==='M'?[['new','texture','X'],['link','display','texture','texture']]:[['curve','display',0.5],['curve','display','-0'],['length','display','curveLengths',5]]),
 ['hook','return:w','throw'],['return','display'],['return','display'],['borrow','reuse',kind],['borrow','reuseW','W']]);
scenario('mesh-shared-geometry-does-not-own-weight-or-texture',[
 ['borrow','m','M'],['geometry','g','m'],['new','src','G'],['borrow','w','W'],['new','texture','X'],['link','src','weight','w'],['share','g','src'],['link','m','texture','texture'],
 ['return','m'],['clear','src'],['borrow','reuse','W']]);
scenario('bounding-box-return-contract-and-failure-order',[
 ['borrow','b','B'],['record','box'],['link','b','boundingBox','box'],['set','b','type',999],['set','b','name','s:before'],['transform','b',1,2,3,4,5,6],
 ['hook','return:box','throw'],['return','b'],['return','b'],['borrow','reuse','B']]);
scenario('weight-bones-are-non-owning-duplicates-and-sparse-length',[
 ['borrow','w','W'],['record','first'],['record','last'],['bone','w','first'],['bone','w','first'],['length','w','bones',5],['bone','w','last'],
 ['arrayExtra','w','bones','s:persist'],['set','w','count',7],['set','w','offset',12],['return','w'],['borrow','reuse','W']]);
scenario('path-large-logical-array-and-extra-properties',[
 ['borrow','p','P'],['curve','p',0.5],['curve','p','NaN'],['arrayExtra','p','curveLengths','s:keep'],['length','p','curveLengths',4294967295],['clear','p'],
 ['length','p','curveLengths',-1],['length','p','curveLengths','NaN'],['length','p','curveLengths',0.5],['clear','p']]);
scenario('numeric-preservation-before-clear',[
 ['borrow','p','P'],['borrow','i','I'],['borrow','w','W'],
 ...['-0','5e-324','-5e-324','1.7976931348623157e308','NaN','Infinity','-Infinity'].flatMap(v=>[
  ['transform','p',v,v,v,v,v,v],['pivot','i',v,v],['set','w','count',v],['set','w','offset',v],['curve','p',v]]),['clear','p'],['clear','i'],['clear','w']]);
for(const limit of [0,1,2,0.5])scenario('pool-capacity-'+limit,[
 ['borrow','m','M'],['geometry','g','m'],['borrow','w','W'],['link','g','weight','w'],['limit','M',limit],['limit','W',limit],['return','m'],['return','m'],['borrow','reuseM','M'],['borrow','reuseW','W']]);
let seed=0x44495350;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','i','I'],['borrow','a','A'],['borrow','m','M'],['borrow','p','P'],['borrow','w','W'],['geometry','g','m'],['geometry','pg','p'],['borrow','q','Q'],['record','bone'],['data','d',4,5,6,7],['link','g','data','d']];
 for(let n=0;n<100;n++){
  const id=['i','a','m','p'][rand(4)];
  switch(rand(9)){
   case 0:steps.push(['transform',id,rand(16)/8,rand(16)/8,rand(16)/8,rand(16)/8,rand(16)/8,rand(16)/8]);break;
   case 1:steps.push(['set',id,'name','s:n'+rand(6)]);break;
   case 2:steps.push(['clear',id]);break;
   case 3:steps.push(['action','a','q']);break;
   case 4:steps.push(['bone','w','bone']);break;
   case 5:steps.push(['curve','p',rand(16)/8]);break;
   case 6:steps.push(['share','pg','g']);break;
   case 7:steps.push(['set','g','offset',rand(8)-2],['get','g','vertexCount']);break;
   case 8:steps.push(['link','g','weight','w'],['set','g','isShared',rand(2)?'true':'false']);break;
  }
 }
 steps.push(['return','i'],['return','a'],['return','m'],['return','p'],['return','w']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='undefined'?undefined:s==='true'?true:s==='false'?false:s.startsWith('s:')?s.slice(2):Number(s);
let d,B,classes,objects,labels,log,hooks,warnings,ids,nextId;
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
const ref=o=>o==null?'nil':o.hashCode!==undefined?'#'+o.hashCode:o.id;
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
function wrap(o,id){if(o._wrapped)return;o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+id);fire('return:'+id);return original.call(this);};}
function begin(){objects={};labels=new Set();log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];}
function execute(row){const [op,a,b,c]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);if(o.returnToPool)wrap(o,a);return 'object:'+(o.hashCode===undefined?'geometry:'+identity(o):ref(o));}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='clear'){if(objects[a] instanceof classes.G)objects[a].clear();else objects[a]._onClear();}
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes[a].toString();
 else if(op==='link')objects[a][b]=c==='none'?null:objects[c];
 else if(op==='geometry'){objects[a]=objects[b].geometry;labels.add(a);return 'object:geometry:'+identity(objects[a]);}
 else if(op==='share')objects[a].shareFrom(objects[b]);
 else if(op==='get')return scalar(objects[a][b]);
 else if(op==='readonly')objects[a][b]=123;
 else if(op==='transform')for(const [i,k] of ['x','y','rotation','skew','scaleX','scaleY'].entries())objects[a].transform[k]=Number(row[i+2]);
 else if(op==='pivot'){objects[a].pivot.x=Number(b);objects[a].pivot.y=Number(c);}
 else if(op==='bone')objects[a].addBone(objects[b]);
 else if(op==='action')objects[a].addAction(objects[b]);
 else if(op==='curve')objects[a].curveLengths.push(Number(b));
 else if(op==='length')objects[a][b].length=Number(c);
 else if(op==='arrayExtra')objects[a][b].extra=decode(c);
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='record'){objects[a]={id:a,returns:0,returnToPool(){this.returns++;log.push('return:'+a);fire('return:'+a);}};labels.add(a);}
 else if(op==='data'){objects[a]={id:a,intArray:new Int16Array(row.slice(2).map(Number))};labels.add(a);}
 else throw Error('Unknown command '+op);
 return 'void';
}
function array(a,kind){return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+(kind==='ref'?ref(a[k]):scalar(a[k]))).join(',')+':'+scalar(a.extra);}
function geometry(g){return [identity(g),scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight),scalar(g.extra)].join(':');}
function primitive(o,fields){return identity(o)+':'+fields.map(k=>scalar(o[k])).join(',');}
function describe(o){
 if(o instanceof classes.G)return 'G:'+geometry(o);
 if(o.hashCode===undefined)return o.intArray?'data:'+o.id+':'+array(o.intArray):'record:'+o.id+':'+o.returns;
 const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(o instanceof classes.D){out.push(scalar(o.type),scalar(o.name),scalar(o.path),primitive(o.transform,['x','y','rotation','skew','scaleX','scaleY']),ref(o.parent),scalar(o.extra));
  if(kind==='I')out.push(primitive(o.pivot,['x','y']),ref(o.texture));
  if(kind==='A')out.push(scalar(o.inheritAnimation),array(o.actions,'ref'),ref(o.armature));
  if(kind==='M')out.push(geometry(o.geometry),ref(o.texture));
  if(kind==='B')out.push(ref(o.boundingBox));
  if(kind==='P')out.push(scalar(o.closed),scalar(o.constantSpeed),geometry(o.geometry),array(o.curveLengths));
 }else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones,'ref'));
 else if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.bone),ref(o.slot),ref(o.data));
 else if(kind==='U')for(const k of ['ints','floats','strings'])out.push(identity(o[k])+':'+o[k].map(scalar).join(','));
 else if(kind==='X')out.push(scalar(o.rotated),scalar(o.name),primitive(o.region,['x','y','width','height']),ref(o.parent),o.frame==null?'nil':primitive(o.frame,['x','y','width','height']));
 return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'displaydata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'displaydata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/displaydata_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'displaydata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('DisplayData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('DisplayData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',normalization:'object null/undefined to nil; array holes/undefined by value and length',lua,result:'passed'};fs.writeFileSync(path.join(dir,'displaydata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
