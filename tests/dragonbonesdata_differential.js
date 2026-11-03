'use strict';
// Execute genuine DragonBonesData with real ownership/cache dependencies.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/SkinData','model/DragonBonesData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={D:'DragonBonesData',N:'AnimationData',S:'SkinData',A:'ArmatureData',I:'ImageDisplayData',M:'MeshDisplayData',P:'PathDisplayData',C:'ArmatureDisplayData',W:'WeightData',Q:'ActionData',U:'UserData'};
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
const display=(id,name,kind='I')=>[['borrow',id,kind],['set',id,'name','s:'+name]];
scenario('constructor-defaults-and-reuse',[
 ['new','raw','D'],['borrow','d','D'],['string'],['getArmature','missing','raw','missing'],['set','raw','name','s:before'],['set','raw','extra','s:kept'],['clear','raw'],['clear','raw'],['return','raw'],['borrow','reuse','D'],['return','reuse'],['return','reuse']]);
scenario('armature-order-duplicates-parent-sharing',[
 ['borrow','d','D'],['borrow','other','D'],...['z','a','10','2','01',''].flatMap((name,i)=>[['borrow','a'+i,'A'],['set','a'+i,'name','s:'+name],['addArmature','d','a'+i]]),
 ['borrow','dup','A'],['set','dup','name','s:a'],['addArmature','d','dup'],['getArmature','found','d','a'],['addArmature','other','a0'],['getArmature','shared','d','z'],['return','d'],['return','other']]);
scenario('stage-is-non-owning-userdata-is-owned',[
 ['borrow','d','D'],['borrow','stage','A'],['borrow','u','U'],['link','d','stage','stage'],['link','d','userData','u'],['clear','d'],['return','stage'],['return','d']]);
scenario('sparse-arrays-aliases-extra-properties-and-huge-length',[
 ['borrow','d','D'],...['frameIndices','cachedFrames','armatureNames'].flatMap(k=>[['arrayWrite','d',k,0,'1'],['arrayWrite','d',k,3,'s:tail'],['arrayLength','d',k,4294967295],['arrayExtra','d',k,'s:kept'],['arrayAlias',k,'d',k]]),['clear','d'],['borrow','a','A'],['set','a','name','s:later'],['addArmature','d','a'],['clear','d']]);
scenario('all-binary-references-reset-without-mutating-payload',[
 ['new','d','D'],...['binary','intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'].flatMap((k,i)=>[['buffer','v'+i,k],['bufferLink','d',k,'v'+i]]),
 ['bufferLink','d','frameFloatArray','v2'],['return','d'],['borrow','reuse','D']]);
scenario('parent-setter-fails-before-map-and-names',[
 ['borrow','d','D'],['borrow','a','A'],['set','a','name','s:before'],['parentHook','a'],['hook','parent:a','throw'],['addArmature','d','a'],['addArmature','d','a'],['clear','d']]);
scenario('parent-setter-changes-name-before-map-and-push',[
 ['borrow','d','D'],['borrow','a','A'],['set','a','name','s:old'],['parentHook','a'],['hook','parent:a','set','a','name','s:new'],['addArmature','d','a'],['getArmature','old','d','old'],['getArmature','new','d','new'],['return','d']]);
scenario('duplicate-name-must-not-run-parent-setter',[
 ['borrow','d','D'],['borrow','a','A'],['borrow','b','A'],['set','a','name','s:same'],['set','b','name','s:same'],['parentHook','b'],['hook','parent:b','throw'],['addArmature','d','a'],['addArmature','d','b'],['return','d']]);
scenario('name-push-overflow-after-map-and-parent',[
 ['borrow','d','D'],['borrow','a','A'],['set','a','name','s:a'],['arrayLength','d','armatureNames',4294967295],['addArmature','d','a'],['getArmature','found','d','a'],['clear','d']]);
scenario('deleted-future-map-key-and-added-key-survives-clear',[
 ['borrow','d','D'],...['first','deleted','late'].flatMap(id=>[['borrow',id,'A'],['set',id,'name','s:'+id]]),['addArmature','d','first'],['addArmature','d','deleted'],['hook','return:first','mapDelete','d','deleted'],['clear','d'],['addArmature','d','first'],['hook','return:first','addArmature','d','late'],['return','d'],['borrow','reuse','D'],['getArmature','found','reuse','late'],['clear','reuse']]);
scenario('numeric-map-order-reinsertion-and-multiple-alias-returns',[
 ['borrow','d','D'],...['z','2','10','a'].flatMap((id,i)=>[['borrow','a'+i,'A'],['set','a'+i,'name','s:'+id],['addArmature','d','a'+i]]),['mapDelete','d','z'],['mapPut','d','z','a0'],['mapPut','d','alias','a0'],['return','d']]);
scenario('armature-failure-retains-data-and-remaining-map',[
 ['borrow','d','D'],['set','d','name','s:keep'],['borrow','a','A'],['borrow','b','A'],['set','a','name','s:a'],['set','b','name','s:b'],['addArmature','d','a'],['addArmature','d','b'],['hook','return:b','throw'],['return','d'],['return','d'],['borrow','reuse','D']]);
scenario('userdata-failure-after-armatures-before-resets',[
 ['borrow','d','D'],['borrow','a','A'],['borrow','u','U'],['link','d','userData','u'],['link','d','stage','a'],['set','d','name','s:keep'],['addArmature','d','a'],['arrayWrite','d','frameIndices',3,9],['hook','return:u','throw'],['return','d'],['return','d']]);
scenario('real-global-armature-skin-mesh-weight-failure-chain',[
 ['borrow','d','D'],['borrow','a','A'],['borrow','s','S'],['set','s','name','s:default'],...display('m','mesh','M'),['borrow','w','W'],['geom','g','m'],['link','g','weight','w'],['link','g','data','d'],['buffer','ints','intArray'],['bufferLink','d','intArray','ints'],['counts','g'],['add','s','slot','m'],['addSkin','a','s'],['addArmature','d','a'],['mesh','found','a','default','slot','mesh'],['hook','return:w','throw'],['return','d'],['return','d'],['borrow','reuseD','D'],['borrow','reuseA','A'],['borrow','reuseS','S'],['borrow','reuseM','M'],['borrow','reuseW','W']]);
scenario('real-cache-storage-offsets-holes-and-clear-alias',[
 ['borrow','d','D'],['borrow','a','A'],['addArmature','d','a'],['arrayLength','d','cachedFrames',3],['arrayAlias','cache','d','cachedFrames'],['matrix','m',1,2,3,4,5,6],['transform','t',90,91,7,8,9,10],['matrix','out'],['transform','pose'],['store','a','m','t'],['load','a','out','pose',3],['store','a','m','t'],['load','a','out','pose',13],['load','a','out','pose',-1],['load','a','out','pose',0.5],['clear','d']]);
scenario('real-animation-cache-uses-global-owner',[
 ['borrow','d','D'],['borrow','a','A'],['addArmature','d','a'],['borrow','n','N'],['set','n','name','s:clip'],['set','n','duration',1.25],['set','n','scale',0.5],['addAnimation','a','n'],['cache','a',24],['return','d']]);
for(const v of ['-0','NaN','Infinity','-Infinity','5e-324','1.23456789012345'])scenario('numeric-payload-'+v,[
 ['borrow','d','D'],['set','d','frameRate',v],['arrayWrite','d','frameIndices',0,v],['arrayWrite','d','cachedFrames',2,v],['borrow','a','A'],['addArmature','d','a'],['matrix','m',v,2,3,4,5,6],['transform','t'],['matrix','out'],['transform','pose'],['store','a','m','t'],['load','a','out','pose',3],['clear','d']]);
for(const limit of [0,1,2,0.5,1.5])scenario('pool-limit-'+limit,[
 ['borrow','d','D'],['borrow','a','A'],['addArmature','d','a'],['limit','D',limit],['limit','A',limit],['return','d'],['borrow','reuseD','D'],['borrow','reuseA','A']]);
let seed=0x44424441;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','d','D'],...Array.from({length:6},(_,i)=>[['borrow','a'+i,'A'],['set','a'+i,'name','s:n'+i]]).flat()];
 for(let i=0;i<80;i++){const id='a'+rand(6);switch(rand(6)){
 case 0:steps.push(['addArmature','d',id]);break;
 case 1:steps.push(['getArmature','found','d','n'+rand(6)]);break;
 case 2:steps.push(['set',id,'name','s:n'+rand(6)]);break;
 case 3:steps.push(['arrayWrite','d','frameIndices',rand(8),rand(100)]);break;
 case 4:steps.push(['set','d','frameRate',rand(60)]);break;
 case 5:steps.push(['clear','d']);break;}}
 steps.push(['return','d']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s.startsWith('s:')?s.slice(2):s==='true'?true:s==='false'?false:Number(s);
let d,B,classes,objects,labels,lists,log,hooks,warnings,ids,nextId,parents,buffers,matrices,transforms;
const ref=o=>o==null?'nil':'#'+o.hashCode;
const entry=o=>o===null?'null':o===undefined?'undefined':ref(o);
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
const value=id=>id==='null'||id==='NULL'?null:id==='undefined'?undefined:objects[id];
function begin(){buffers={};matrices={};transforms={};objects={};labels=new Set();lists={};log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;parents=new WeakMap();const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];}
function execute(row){const [op,a,b,c,e,f]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);if(!o._wrapped){o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+a);fire('return:'+a);return original.call(this);};}return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='add'){if(c==='omit')objects[a].addDisplay(b);else objects[a].addDisplay(b,value(c));}
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes.D.toString();
 else if(op==='list'){const v=objects[b].getDisplays(c);lists[a]=v;return v===null?'nil':'list:'+identity(v);}
 else if(op==='lookup'){const v=objects[b].getDisplay(c,e);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='mesh'){const v=objects[b].getMesh(c,e,f);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='counts')return 'counts:'+scalar(objects[a].vertexCount)+':'+scalar(objects[a].triangleCount);
 else if(op==='getArmature'){const v=objects[b].getArmature(c);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='addArmature')objects[a].addArmature(objects[b]);
 else if(op==='mapDelete')delete objects[a].armatures[b];
 else if(op==='mapPut')objects[a].armatures[b]=objects[c];
 else if(op==='arrayLength')objects[a][b].length=Number(c);
 else if(op==='arrayWrite')objects[a][b][Number(c)]=decode(e);
 else if(op==='arrayExtra')objects[a][b].extra=decode(c);
 else if(op==='arrayAlias')lists[a]=objects[b][c];
 else if(op==='buffer')buffers[a]=b==='binary'?new Uint8Array([1,2,3,255]).buffer:b.toLowerCase().includes('float')?new Float32Array([1.25,-2.5,3.75]):b==='timelineArray'?new Uint16Array([1,2,65535]):new Int16Array([1,2,-3]);
 else if(op==='bufferLink')objects[a][b]=buffers[c];
 else if(op==='matrix'||op==='transform'){
  const record=op==='matrix'?new d.Matrix():new d.Transform();const ks=op==='matrix'?['a','b','c','d','tx','ty']:['x','y','rotation','skew','scaleX','scaleY'];if(row.length>2)ks.forEach((k,i)=>record[k]=Number(row[i+2]));(op==='matrix'?matrices:transforms)[a]=record;
 }
 else if(op==='store')return 'offset:'+scalar(objects[a].setCacheFrame(matrices[b],transforms[c]));
 else if(op==='load')objects[a].getCacheFrame(matrices[b],transforms[c],Number(e));
 else if(op==='addAnimation')objects[a].addAnimation(objects[b]);
 else if(op==='cache')objects[a].cacheFrames(Number(b));
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
function numericArray(a){if(a==null)return 'nil';return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).sort().map(k=>k+'='+scalar(a[k])).join(',');}
function buffer(a){if(a==null)return 'nil';return identity(a)+':'+Array.from(a instanceof ArrayBuffer?new Uint8Array(a):a).map(scalar).join(',');}
function array(a){if(a==null)return 'nil';return identity(a)+':'+scalar(a.length)+':prefix='+Array.from({length:Math.min(a.length,12)},(_,i)=>entry(a[i])).join(',')+':defined='+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+entry(a[k])).join(',')+':extra='+scalar(a.extra)+':nonIndex='+entry(a[4294967295]);}
function primitive(o,ks){return identity(o)+':'+ks.map(k=>scalar(o[k])).join(',');}
function geometry(g){return identity(g)+':'+[scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)].join(':');}
function describe(o){if(o==null)return 'nil';if(o instanceof d.GeometryData)return 'G:'+geometry(o);const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(kind==='D'){out.push(...['autoSearch','frameRate','version','name','extra'].map(k=>scalar(o[k])),ref(o.stage),ref(o.userData),...['frameIndices','cachedFrames','armatureNames'].map(k=>numericArray(o[k])),identity(o.armatures)+':'+Object.keys(o.armatures).sort().map(k=>k+'='+ref(o.armatures[k])).join(';'),...['binary','intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'].map(k=>buffer(o[k])));}
 else if(kind==='N')out.push(scalar(o.name),ref(o.parent),scalar(o.cacheFrameRate),numericArray(o.cachedFrames));
 else if(kind==='S')out.push(scalar(o.name),ref(o.parent),scalar(o.extra),identity(o.displays)+':'+Object.keys(o.displays).sort().map(k=>k+'='+array(o.displays[k])).join(';'));
 else if(kind==='A')out.push(scalar(o.name),ref(o.parent),scalar(o.cacheFrameRate),ref(o.defaultSkin),identity(o.skins)+':'+Object.keys(o.skins).sort().map(k=>k+'='+ref(o.skins[k])).join(';'));
 else if(['I','M','P','C'].includes(kind)){out.push(scalar(o.type),scalar(o.name),scalar(o.path),ref(o.parent),primitive(o.transform,['x','y','rotation','skew','scaleX','scaleY']));if(kind==='I')out.push(primitive(o.pivot,['x','y']),ref(o.texture));if(kind==='M'||kind==='P')out.push(geometry(o.geometry));if(kind==='P')out.push(scalar(o.closed),scalar(o.constantSpeed));if(kind==='C')out.push(scalar(o.inheritAnimation),array(o.actions),ref(o.armature));}
 else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones));
 else if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.data));
 else if(kind==='U')for(const k of ['ints','floats','strings'])out.push(identity(o[k])+':'+o[k].map(scalar).join(','));return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(lists).sort().map(k=>k+'='+numericArray(lists[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|'),Object.keys(buffers).sort().map(k=>k+'='+buffer(buffers[k])).join('|'),Object.keys(matrices).sort().map(k=>k+'='+primitive(matrices[k],['a','b','c','d','tx','ty'])).join('|'),Object.keys(transforms).sort().map(k=>k+'='+primitive(transforms[k],['x','y','rotation','skew','scaleX','scaleY'])).join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'dragonbonesdata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'dragonbonesdata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/dragonbonesdata_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'dragonbonesdata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('DragonBonesData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('DragonBonesData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',integration:'real DragonBonesData, ArmatureData, SkinData, displays, geometry, weights, AnimationData and cache frames',normalization:'object null/undefined to nil; logical numeric arrays base 1; already-decoded buffers supplied by test boundary, no Lua typed view implementation',lua,result:'passed'};fs.writeFileSync(path.join(dir,'dragonbonesdata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
