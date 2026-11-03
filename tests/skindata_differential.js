'use strict';
// Execute genuine SkinData and real display/armature dependencies; no skin probe.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/SkinData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={S:'SkinData',A:'ArmatureData',I:'ImageDisplayData',M:'MeshDisplayData',P:'PathDisplayData',C:'ArmatureDisplayData',W:'WeightData',Q:'ActionData',U:'UserData'};
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
const display=(id,name,kind='I')=>[['borrow',id,kind],['set',id,'name','s:'+name]];
scenario('raw-constructor-pool-and-empty-map',[
 ['new','raw','S'],['borrow','clean','S'],['string'],['list','missing','raw','slot'],['lookup','absent','raw','slot','name'],['set','raw','name','s:raw'],['set','raw','extra','s:keep'],['clear','raw'],['clear','raw'],['return','raw'],['borrow','again','S'],['return','again'],['return','again'],['borrow','reuse','S']]);
scenario('null-displays-first-match-and-parent',[
 ['borrow','s','S'],...display('i','same'),...display('m','same','M'),['add','s','slot','null'],['add','s','slot','i'],['add','s','slot','NULL'],['add','s','slot','m'],
 ['list','list','s','slot'],['lookup','found','s','slot','same'],['set','i','name','s:changed'],['lookup','second','s','slot','same'],['lookup','missing','s','slot','absent'],['return','s'],['borrow','reuseI','I'],['borrow','reuseM','M'],['borrow','reuseS','S']]);
scenario('duplicate-reference-is-returned-repeatedly',[
 ['borrow','s','S'],...display('i','image'),['add','s','a','i'],['add','s','a','i'],['add','s','b','i'],['list','old','s','a'],['return','s'],['borrow','reuse','I']]);
scenario('sharing-between-skins-does-not-detach-old-list',[
 ['borrow','a','S'],['borrow','b','S'],...display('i','image'),['add','a','slot','i'],['add','b','slot','i'],['list','aList','a','slot'],['list','bList','b','slot'],['clear','a'],['lookup','clearedDisplay','b','slot',''],['clear','b']]);
scenario('explicit-null-versus-hole-and-undefined',[
 ['borrow','s','S'],...display('i','image'),['add','s','slot','null'],['add','s','slot','i'],['length','s','slot',4],['lookup','foundBeforeHole','s','slot','image'],['lookup','holeError','s','slot','absent'],['clear','s'],
 ['write','s','slot',2,'null'],['write','s','slot',3,'NULL'],['clear','s'],['add','s','new','null'],['write','s','new',1,'undefined'],['lookup','undefinedError','s','new','absent'],['clear','s'],['length','s','new',0],['clear','s']]);
scenario('omitted-display-keeps-created-empty-list',[
 ['borrow','s','S'],['add','s','omitted','omit'],['list','created','s','omitted'],['add','s','explicitUndefined','undefined'],['list','created2','s','explicitUndefined'],['add','s','null','null'],['clear','s']]);
scenario('strict-marker-identity-with-lua-equality',[
 ['borrow','s','S'],...display('i','image'),['equal','i'],['add','s','slot','i'],['add','s','slot','null'],['lookup','found','s','slot','image'],['return','s']]);
scenario('ordered-map-return-and-reinserted-key',[
 ['borrow','s','S'],...['z','a','10','2','-0','01'].flatMap((name,i)=>[...display('d'+i,'n'+i),['add','s',name,'d'+i]]),['deleteKey','s','z'],['put','s','z','d0'],['return','s'],...Array.from({length:6},(_,i)=>['borrow','r'+i,'I'])]);
scenario('growing-list-and-deleted-future-key',[
 ['borrow','s','S'],...display('first','first'),...display('late','late'),...display('deleted','deleted'),['add','s','z','first'],['add','s','a','deleted'],
 ['hook','return:first','add','s','z','late'],['hook','return:late','deleteKey','s','a'],['clear','s']]);
scenario('new-map-key-from-callback-survives-current-enumeration',[
 ['borrow','s','S'],...display('first','first'),...display('late','late'),['add','s','old','first'],['hook','return:first','add','s','late','late'],['return','s'],['borrow','reuse','S'],['lookup','survivor','reuse','late','late'],['clear','reuse']]);
scenario('return-failure-keeps-partial-map-and-state',[
 ['borrow','s','S'],['set','s','name','s:before'],...display('first','first'),...display('bad','bad','M'),...display('last','last'),['add','s','first','first'],['add','s','bad','bad'],['add','s','last','last'],
 ['hook','return:bad','throw'],['return','s'],['return','s'],['borrow','reuse','S']]);
scenario('parent-setter-failure-before-append',[
 ['borrow','s','S'],...display('i','image'),['parentHook','i'],['hook','parent:i','throw'],['add','s','slot','i'],['list','empty','s','slot'],['add','s','slot','i'],['clear','s']]);
scenario('parent-setter-replaces-list-before-push',[
 ['borrow','s','S'],...display('i','image'),...display('other','other'),['parentHook','i'],['hook','parent:i','put','s','slot','other'],['add','s','slot','i'],['list','replaced','s','slot'],['clear','s']]);
scenario('parent-setter-deletes-list-before-push',[
 ['borrow','s','S'],...display('i','image'),['parentHook','i'],['hook','parent:i','deleteKey','s','slot'],['add','s','slot','i'],['list','missing','s','slot'],['add','s','slot','i'],['clear','s']]);
scenario('overflow-parent-assignment-and-non-index-write',[
 ['borrow','s','S'],...display('i','image'),['add','s','slot','null'],['list','saved','s','slot'],['length','s','slot',4294967295],['add','s','slot','i'],['length','s','slot',0],['clear','s']]);
scenario('array-aliases-and-extra-properties',[
 ['borrow','a','S'],['borrow','b','S'],...display('i','image'),['add','a','slot','i'],['add','a','slot','null'],['alias','b','other','a','slot'],['extra','a','slot','s:keep'],['list','old','a','slot'],['clear','a'],['clear','b']]);
scenario('real-armature-getmesh-does-not-filter-display-type',[
 ['borrow','a','A'],['borrow','s','S'],['set','s','name','s:default'],...display('i','same'),...display('m','same','M'),['add','s','slot','null'],['add','s','slot','i'],['add','s','slot','m'],['addSkin','a','s'],
 ['mesh','first','a','default','slot','same'],['set','i','name','s:other'],['mesh','second','a','default','slot','same'],['mesh','missing','a','absent','slot','same'],['return','a']]);
scenario('real-armature-skin-display-weight-failure-chain',[
 ['borrow','a','A'],['borrow','s','S'],['set','s','name','s:skin'],...display('m','mesh','M'),...display('p','path','P'),['borrow','w','W'],['geom','g','m'],['geom','shared','p'],['link','g','weight','w'],['share','shared','g'],
 ['add','s','slot','m'],['add','s','slot','p'],['addSkin','a','s'],['hook','return:w','throw'],['return','a'],['return','a'],['borrow','reuseW','W'],['borrow','reuseS','S']]);
scenario('real-armature-display-owns-action-userdata',[
 ['borrow','s','S'],['borrow','c','C'],['borrow','q','Q'],['borrow','u','U'],['link','q','data','u'],['action','c','q'],['add','s','slot','c'],['return','s'],['borrow','reuseQ','Q'],['borrow','reuseU','U']]);
for(const limit of [0,1,2,0.5,1.5])scenario('pool-capacity-'+limit,[
 ['borrow','s','S'],...display('i','image'),...display('m','mesh','M'),['add','s','slot','i'],['add','s','slot','m'],['limit','S',limit],['limit','I',limit],['limit','M',limit],['return','s'],['borrow','rs','S'],['borrow','ri','I'],['borrow','rm','M']]);
let seed=0x534b494e;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','s','S'],...Array.from({length:6},(_,i)=>display('d'+i,'n'+i,i%2?'M':'I')).flat()];
 for(let i=0;i<80;i++){
  const slot=['z','a','2','10','-0'][rand(5)],id='d'+rand(6);
  switch(rand(6)){
   case 0:steps.push(['add','s',slot,id]);break;
   case 1:steps.push(['add','s',slot,'null']);break;
   case 2:steps.push(['lookup','lookup','s',slot,'n'+rand(6)]);break;
   case 3:steps.push(['set',id,'name','s:n'+rand(6)]);break;
   case 4:steps.push(['list','list','s',slot]);break;
   case 5:steps.push(['clear','s']);break;
  }
 }
 steps.push(['return','s']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s.startsWith('s:')?s.slice(2):s==='true'?true:s==='false'?false:Number(s);
let d,B,classes,objects,labels,lists,log,hooks,warnings,ids,nextId,parents;
const ref=o=>o==null?'nil':'#'+o.hashCode;
const entry=o=>o===null?'null':o===undefined?'undefined':ref(o);
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
const value=id=>id==='null'||id==='NULL'?null:id==='undefined'?undefined:objects[id];
function begin(){objects={};labels=new Set();lists={};log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;parents=new WeakMap();const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];}
function execute(row){const [op,a,b,c,e,f]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);if(!o._wrapped){o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+a);fire('return:'+a);return original.call(this);};}return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='add'){if(c==='omit')objects[a].addDisplay(b);else objects[a].addDisplay(b,value(c));}
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes.S.toString();
 else if(op==='list'){const v=objects[b].getDisplays(c);lists[a]=v;return v===null?'nil':'list:'+identity(v);}
 else if(op==='lookup'){const v=objects[b].getDisplay(c,e);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='mesh'){const v=objects[b].getMesh(c,e,f);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='addSkin')objects[a].addSkin(objects[b]);
 else if(op==='link')objects[a][b]=objects[c];
 else if(op==='geom'){objects[a]=objects[b].geometry;labels.add(a);return 'geometry:'+identity(objects[a]);}
 else if(op==='share')objects[a].shareFrom(objects[b]);
 else if(op==='action')objects[a].addAction(objects[b]);
 else if(op==='length')objects[a].displays[b].length=Number(c);
 else if(op==='write')objects[a].displays[b][Number(c)]=value(e);
 else if(op==='deleteKey')delete objects[a].displays[b];
 else if(op==='put')objects[a].displays[b]=[value(c)];
 else if(op==='alias')objects[a].displays[b]=objects[c].displays[e];
 else if(op==='extra')objects[a].displays[b].extra=decode(c);
 else if(op==='parentHook'){
  const o=objects[a],state={value:o.parent};parents.set(o,state);Object.defineProperty(o,'parent',{configurable:true,get(){return state.value;},set(v){state.value=v;log.push('parent:'+a+':'+ref(v));fire('parent:'+a);}});
 }
 else if(op==='equal'){/* Lua __eq must not turn a display into the null marker. */}
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else throw Error('Unknown test command '+op);
 return 'void';
}
function array(a){if(a==null)return 'nil';return identity(a)+':'+scalar(a.length)+':prefix='+Array.from({length:Math.min(a.length,12)},(_,i)=>entry(a[i])).join(',')+':defined='+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+entry(a[k])).join(',')+':extra='+scalar(a.extra)+':nonIndex='+entry(a[4294967295]);}
function primitive(o,ks){return identity(o)+':'+ks.map(k=>scalar(o[k])).join(',');}
function geometry(g){return identity(g)+':'+[scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)].join(':');}
function describe(o){if(o==null)return 'nil';if(o instanceof d.GeometryData)return 'G:'+geometry(o);const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(kind==='S')out.push(scalar(o.name),ref(o.parent),scalar(o.extra),identity(o.displays)+':'+Object.keys(o.displays).sort().map(k=>k+'='+array(o.displays[k])).join(';'));
 else if(kind==='A')out.push(scalar(o.name),ref(o.defaultSkin),identity(o.skins)+':'+Object.keys(o.skins).sort().map(k=>k+'='+ref(o.skins[k])).join(';'));
 else if(['I','M','P','C'].includes(kind)){out.push(scalar(o.type),scalar(o.name),scalar(o.path),ref(o.parent),primitive(o.transform,['x','y','rotation','skew','scaleX','scaleY']));if(kind==='I')out.push(primitive(o.pivot,['x','y']),ref(o.texture));if(kind==='M'||kind==='P')out.push(geometry(o.geometry));if(kind==='P')out.push(scalar(o.closed),scalar(o.constantSpeed));if(kind==='C')out.push(scalar(o.inheritAnimation),array(o.actions),ref(o.armature));}
 else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones));
 else if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.data));
 else if(kind==='U')for(const k of ['ints','floats','strings'])out.push(identity(o[k])+':'+o[k].map(scalar).join(','));return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(lists).sort().map(k=>k+'='+array(lists[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'skindata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'skindata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/skindata_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'skindata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('SkinData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('SkinData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',integration:'real ArmatureData, SkinData, displays, geometry, weights and action payloads',normalization:'object null/undefined to nil; list null distinct from undefined/hole; hole/undefined property descriptors normalized',lua,result:'passed'};fs.writeFileSync(path.join(dir,'skindata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
