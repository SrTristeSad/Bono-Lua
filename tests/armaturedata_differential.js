'use strict';
// Execute genuine ArmatureData/BoneData/SurfaceData/SlotData and dependencies.
// Animation cache integration uses real models; remaining boundaries are probes.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/CanvasData','model/DisplayData','model/AnimationData','model/ArmatureData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={A:'ArmatureData',B:'BoneData',S:'SurfaceData',L:'SlotData',D:'AnimationData',U:'UserData',Q:'ActionData',C:'CanvasData',W:'WeightData',M:'MeshDisplayData'};
const arrays=['animationNames','sortedBones','sortedSlots','defaultActions','actions'];
const maps=['bones','slots','constraints','skins','animations'];
const bone=(id,name,kind='B')=>[['borrow',id,kind],['set',id,'name','s:'+name]];
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
for(const kind of ['A','B','S','L'])scenario('constructors-clear-and-pool-'+kind,[
 ['new','raw',kind],['borrow','clean',kind],['set','raw','extra','s:keep'],['string',kind],['clear','raw'],['clear','raw'],['return','raw'],['borrow','again',kind],['return','again'],['return','again'],['borrow','last',kind]]);
scenario('raw-default-references-differ-from-cleared-null',[
 ['new','raw','A'],['borrow','clean','A'],['skin','one','first'],['skin','two','second'],['skin','default','default'],['borrow','d','D'],['set','d','name','s:clip'],
 ['add','raw','Skin','one'],['add','raw','Animation','d'],['add','clean','Skin','two'],['add','raw','Skin','default'],
 ['link','raw','defaultSkin','none'],['skin','third','third'],['add','raw','Skin','third'],['link','raw','defaultAnimation','none'],
 ['borrow','d2','D'],['set','d2','name','s:other'],['add','raw','Animation','d2'],['clear','raw']]);
scenario('duplicates-lookups-and-defaults',[
 ['borrow','a','A'],...bone('b','same'),...bone('dup','same'),...bone('root','root'),['borrow','s','L'],['set','s','name','s:slot'],['set','s','zOrder',-8],
 ['borrow','s2','L'],['set','s2','name','s:slot'],['add','a','Bone','b'],['add','a','Bone','dup'],['add','a','Slot','s'],['add','a','Slot','s2'],
 ['constraint','c','ik','b','root'],['constraint','c2','ik','b','root'],['add','a','Constraint','c'],['add','a','Constraint','c2'],
 ['skin','skin','skin'],['skin','dupSkin','skin'],['skin','default','default'],['add','a','Skin','skin'],['add','a','Skin','dupSkin'],['add','a','Skin','default'],
 ['borrow','d','D'],['set','d','name','s:anim'],['borrow','dupD','D'],['set','dupD','name','s:anim'],['add','a','Animation','d'],['add','a','Animation','dupD'],
 ...['Bone','Slot','Constraint','Skin','Animation'].flatMap(k=>[['get','found'+k,'a',k,{Bone:'same',Slot:'slot',Constraint:'ik',Skin:'skin',Animation:'anim'}[k]],['get','missing'+k,'a',k,'absent']]),
 ['borrow','mesh','M'],['display','skin','slot','mesh','mesh'],['mesh','foundMesh','a','skin','slot','mesh'],['mesh','missingMesh','a','absent','slot','mesh'],
 ['hook','display:skin','throw'],['mesh','failedMesh','a','skin','slot','mesh'],['clear','a']]);
scenario('sort-parent-chain-in-place',[
 ['borrow','a','A'],...bone('root','root'),...bone('child','child'),...bone('tip','tip','S'),['link','child','parent','root'],['link','tip','parent','child'],
 ['add','a','Bone','tip'],['add','a','Bone','child'],['add','a','Bone','root'],['sort','a'],['sort','a']]);
scenario('sort-constraint-target-before-root-with-strict-identity',[
 ['borrow','a','A'],...bone('root','root'),...bone('target','target'),...bone('other','other'),['equal','root'],['equal','target'],['equal','other'],
 ['constraint','c','c','root','target'],['add','a','Constraint','c'],['add','a','Bone','root'],['add','a','Bone','other'],['add','a','Bone','target'],['sort','a']]);
scenario('sort-empty-and-sparse-failure-partial-state',[
 ['borrow','a','A'],['sort','a'],...bone('b','b'),['add','a','Bone','b'],['length','a','sortedBones',3],['sort','a'],['length','a','sortedBones',1],['sort','a']]);
scenario('ordered-map-release-numeric-and-reinserted-keys',[
 ['borrow','a','A'],...['z','a','10','2','-0','01'].flatMap((name,i)=>[...bone('b'+i,name),['add','a','Bone','b'+i]]),
 ['delete','a','bones','z'],['put','a','bones','z','b0'],['return','a'],...Array.from({length:6},(_,i)=>['borrow','reuse'+i,'B'])]);
scenario('clear-order-real-owned-models-and-boundaries',[
 ['borrow','a','A'],['borrow','q0','Q'],['borrow','q1','Q'],['action','a','q0','true'],['action','a','q1','false'],
 ...bone('b','bone'),['add','a','Bone','b'],['borrow','l','L'],['set','l','name','s:slot'],['add','a','Slot','l'],
 ['constraint','c','c','b','b'],['add','a','Constraint','c'],['skin','skin','skin'],['add','a','Skin','skin'],['borrow','d','D'],['set','d','name','s:anim'],['add','a','Animation','d'],
 ['borrow','canvas','C'],['borrow','u','U'],['link','a','canvas','canvas'],['link','a','userData','u'],['set','a','scale',9],['rect','a',1,2,3,4],['return','a'],['borrow','reuse','A']]);
scenario('actions-grow-and-sparse-error',[
 ['borrow','a','A'],['borrow','first','Q'],['borrow','late','Q'],['action','a','first','true'],['hook','return:first','action','a','late','true'],['clear','a'],
 ['action','a','first','false'],['length','a','actions',3],['clear','a'],['length','a','actions',1],['clear','a']]);
scenario('map-return-failure-and-dynamic-deletion',[
 ['borrow','a','A'],...bone('first','first'),...bone('second','second'),...bone('last','last'),['add','a','Bone','first'],['add','a','Bone','second'],['add','a','Bone','last'],
 ['hook','return:first','delete','a','bones','last'],['hook','return:second','throw'],['return','a'],['return','a'],['borrow','reused','A']]);
for(const kind of ['B','S','L'])scenario('user-data-failure-before-resets-'+kind,[
 ['borrow','o',kind],['borrow','u','U'],['link','o','userData','u'],['set','o','name','s:before'],['set','o','alpha',0.25],
 ...(kind==='L'?[['color','custom'],['colorSet','custom','redOffset',32],['colorLink','o','custom']]:[['pose','o',1,2,3,4,5,6]]),
 ['hook','return:u','throw'],['return','o'],['return','o'],['borrow','reuse',kind]]);
scenario('surface-real-geometry-weight-and-super-clear-order',[
 ['borrow','s','S'],['borrow','w','W'],['geom','g','s'],['link','g','weight','w'],['set','s','segmentX',7],['set','s','segmentY',9],['set','s','type',99],['pose','s',1,2,3,4,5,6],
 ['hook','return:w','throw'],['return','s'],['return','s'],['borrow','reuseS','S'],['borrow','reuseW','W']]);
scenario('slot-color-is-non-owning-and-default-shared',[
 ['borrow','a','L'],['borrow','b','L'],['color','custom'],['colorSet','custom','redOffset',255],['colorSet','default','alphaMultiplier',0.25],
 ['colorLink','a','default'],['colorLink','b','custom'],['return','a'],['return','b'],['borrow','reuse','L']]);
scenario('animation-cache-integrates-real-armature-bones-slots',[
 ['borrow','a','A'],...bone('b','root'),...bone('surface','surface','S'),['link','surface','parent','b'],['add','a','Bone','surface'],['add','a','Bone','b'],['sort','a'],
 ['borrow','slot','L'],['set','slot','name','s:slot'],['link','slot','parent','b'],['add','a','Slot','slot'],
 ['borrow','d','D'],['set','d','name','s:clip'],['set','d','duration',1.25],['set','d','scale',0.5],['add','a','Animation','d'],['cache','a',24],
 ['set','d','duration',4],['cache','a',60],['link','d','parent','none'],['cache','a',12],['clear','a']]);
scenario('animation-cache-failure-retains-order-and-rate',[
 ['borrow','a','A'],['borrow','one','D'],['borrow','bad','D'],['set','one','name','s:10'],['set','bad','name','s:2'],['set','bad','duration','NaN'],
 ['add','a','Animation','one'],['add','a','Animation','bad'],['cache','a',12],['cache','a',24],['set','a','cacheFrameRate',0],['set','bad','duration',1],['cache','a',8]]);
scenario('cache-iteration-mutation-and-raw-uninitialized-rate',[
 ['new','raw','A'],['cache','raw',24],['borrow','a','A'],['borrow','one','D'],['borrow','two','D'],['set','one','name','s:one'],['set','two','name','s:two'],
 ['add','a','Animation','one'],['add','a','Animation','two'],['hook','cache:one','delete','a','animations','two'],['cache','a',4],['set','a','cacheFrameRate',0],['cache','a','NaN']]);
scenario('cache-frame-storage-roundtrip-and-zero-based-offsets',[
 ['borrow','a','A'],['storage','global'],['link','a','parent','global'],['matrix','m',1,2,3,4,5,6],['transform','t',99,100,7,8,9,10],['matrix','out'],['transform','pose'],
 ['store','a','m','t'],['load','a','out','pose',0],['storageLength','global',15],['store','a','m','t'],['load','a','out','pose',15],
 ...['-1','0.5','5e-324','NaN','undefined','Infinity'].map(n=>['load','a','out','pose',n]),['storageLength','global',4294967290],['store','a','m','t']]);
scenario('cache-frame-source-read-failure-after-resize',[
 ['borrow','a','A'],['storage','global'],['link','a','parent','global'],['storageLength','global',3],['matrix','m',1,2,3,4,5,6],['transform','t'],
 ['readFailure','m','c'],['store','a','m','t'],['matrix','out'],['transform','pose'],['load','a','out','pose',3]]);
scenario('cache-frame-missing-parent-and-undefined-payload',[
 ['borrow','a','A'],['matrix','m'],['transform','t'],['store','a','m','t'],['load','a','m','t',0],['storage','global'],['link','a','parent','global'],
 ['matrixSet','m','c','undefined'],['store','a','m','t'],['matrix','out'],['transform','pose'],['load','a','out','pose',0]]);
for(const limit of [0,1,2,0.5])scenario('pool-limit-'+limit,[
 ['borrow','a','A'],...bone('b','b'),['borrow','s','S'],['set','s','name','s:surface'],['add','a','Bone','b'],['add','a','Bone','s'],
 ['limit','A',limit],['limit','B',limit],['limit','S',limit],['return','a'],['borrow','reuseA','A'],['borrow','reuseB','B'],['borrow','reuseS','S']]);
scenario('binary64-fields-and-cache-payload',[
 ['borrow','a','A'],['borrow','b','B'],['borrow','s','S'],['borrow','l','L'],['storage','global'],['link','a','parent','global'],['matrix','m'],['transform','t'],['matrix','out'],['transform','pose'],
 ...['-0','5e-324','-5e-324','1.7976931348623157e308','NaN','Infinity','-Infinity'].flatMap(v=>[
  ['set','a','frameRate',v],['set','b','length',v],['set','b','alpha',v],['set','s','segmentX',v],['set','l','zIndex',v],['matrixSet','m','a',v],['transformSet','t','rotation',v],['store','a','m','t']]),
 ['load','a','out','pose',60],['clear','b'],['clear','s'],['clear','l']]);
let seed=0x41524d44;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','a','A'],...Array.from({length:8},(_,i)=>bone('b'+i,'bone'+i,i%3?'B':'S')).flat(),['borrow','d','D'],['set','d','name','s:clip'],['set','d','duration',1]];
 // Strictly lower parents guarantee an acyclic graph. No cycle guards added.
 for(let i=1;i<8;i++)steps.push(['link','b'+i,'parent','b'+rand(i)]);
 const order=Array.from({length:8},(_,i)=>i);for(let i=7;i>0;i--){const j=rand(i+1);[order[i],order[j]]=[order[j],order[i]];}
 for(const i of order)steps.push(['add','a','Bone','b'+i]);steps.push(['sort','a'],['add','a','Animation','d']);
 for(let i=0;i<70;i++)switch(rand(5)){
  case 0:steps.push(['sort','a']);break;
  case 1:steps.push(['cache','a',rand(12)]);break;
  case 2:steps.push(['set','a','cacheFrameRate',0]);break;
  case 3:steps.push(['set','b'+rand(8),'alpha',rand(32)/16]);break;
  case 4:steps.push(['get','lookup','a','Bone','bone'+rand(8)]);break;
 }
 steps.push(['return','a']);scenario('acyclic-deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='undefined'?undefined:s==='true'?true:s==='false'?false:s.startsWith('s:')?s.slice(2):Number(s);
let d,B,classes,objects,labels,records,storages,matrices,transforms,colors,readers,log,hooks,warnings,ids,nextId;
const ref=o=>o==null?'nil':o.hashCode!==undefined?'#'+o.hashCode:o.id;
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
function wrap(o,id){if(o._wrapped)return;o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+id);fire('return:'+id);return original.call(this);};if(o instanceof classes.D){const cache=o.cacheFrames;o.cacheFrames=function(rate){log.push('cache:'+id+':'+scalar(rate));fire('cache:'+id);return cache.call(this,rate);};}}
function begin(){objects={};labels=new Set();records={};storages={};matrices={};transforms={};readers=new WeakMap();log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];colors={default:classes.L.DEFAULT_COLOR};}
function execute(row){const [op,a,b,c,e,f]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);wrap(o,a);return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes[a].toString();
 else if(op==='link')objects[a][b]=c==='none'?null:objects[c]||records[c]||storages[c];
 else if(op==='add')objects[a]['add'+b](objects[c]||records[c]);
 else if(op==='get'){const value=objects[b]['get'+c](e);objects[a]=value;labels.add(a);return value===null?'nil':'object:'+ref(value);}
 else if(op==='mesh'){const value=objects[b].getMesh(c,e,f);objects[a]=value;labels.add(a);return value===null?'nil':'object:'+ref(value);}
 else if(op==='action')objects[a].addAction(objects[b],decode(c));
 else if(op==='sort')objects[a].sortBones();
 else if(op==='cache')objects[a].cacheFrames(decode(b));
 else if(op==='length')objects[a][b].length=Number(c);
 else if(op==='delete')delete objects[a][b][c];
 else if(op==='put')objects[a][b][c]=objects[e]||records[e];
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='equal'){/* Lua metamethod probe only. */}
 else if(op==='skin'||op==='constraint'){
  const record={id:a,name:b,parent:null,root:op==='constraint'?objects[c]:null,target:op==='constraint'?objects[e]:null,returns:0,displays:{},returnToPool(){this.returns++;log.push('return:'+a);fire('return:'+a);},getDisplay(slot,mesh){log.push('display:'+a+':'+slot+':'+mesh);fire('display:'+a);return this.displays[slot+':'+mesh]||null;}};records[a]=record;
 }
 else if(op==='display')records[a].displays[b+':'+c]=objects[e];
 else if(op==='geom'){objects[a]=objects[b].geometry;labels.add(a);return 'geometry:'+identity(objects[a]);}
 else if(op==='pose')for(const [i,k] of ['x','y','rotation','skew','scaleX','scaleY'].entries())objects[a].transform[k]=Number(row[i+2]);
 else if(op==='rect')for(const [i,k] of ['x','y','width','height'].entries())objects[a].aabb[k]=Number(row[i+2]);
 else if(op==='color')colors[a]=classes.L.createColor();
 else if(op==='colorSet')colors[a][b]=Number(c);
 else if(op==='colorLink')objects[a].color=colors[b];
 else if(op==='storage')storages[a]={id:a,cachedFrames:[]};
 else if(op==='storageLength')storages[a].cachedFrames.length=Number(b);
 else if(op==='matrix'||op==='transform'){
  const table=op==='matrix'?matrices:transforms;table[a]=op==='matrix'?new d.Matrix():new d.Transform();const ks=op==='matrix'?['a','b','c','d','tx','ty']:['x','y','rotation','skew','scaleX','scaleY'];if(row.length>2)ks.forEach((k,i)=>table[a][k]=Number(row[i+2]));
 }
 else if(op==='matrixSet'||op==='transformSet')(op==='matrixSet'?matrices:transforms)[a][b]=decode(c);
 else if(op==='store')return scalar(objects[a].setCacheFrame(matrices[b],transforms[c]));
 else if(op==='load')objects[a].getCacheFrame(matrices[b],transforms[c],decode(e));
 else if(op==='readFailure'){const o=matrices[a],value=o[b];readers.set(o,{key:b,value});Object.defineProperty(o,b,{get(){log.push('read:'+a+':'+b);throw Error('read failure');}});}
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else throw Error('Unknown test command '+op);
 return 'void';
}
function array(a,kind){return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+(kind==='ref'?ref(a[k]):scalar(a[k]))).join(',');}
function primitive(o,ks){if(o==null)return 'nil';const reader=readers.get(o);return identity(o)+':'+ks.map(k=>scalar(reader&&reader.key===k?reader.value:o[k])).join(',');}
const tfields=['x','y','rotation','skew','scaleX','scaleY'];const cfields=['alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'];
function describe(o){if(o==null)return 'nil';if(o.hashCode===undefined)return o instanceof d.GeometryData?'G:'+identity(o)+':'+[scalar(o.isShared),scalar(o.inheritDeform),scalar(o.offset),ref(o.data),ref(o.weight)].join(':'):'record:'+o.id;
 const kind=Object.keys(classes).find(k=>classes[k]===o.constructor);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(kind==='A'){out.push(...['type','frameRate','cacheFrameRate','scale','name','extra'].map(k=>scalar(o[k])),primitive(o.aabb,['x','y','width','height']));for(const k of arrays)out.push(array(o[k],k==='animationNames'?'number':'ref'));for(const k of maps)out.push(identity(o[k])+':'+Object.keys(o[k]).sort().map(n=>n+'='+ref(o[k][n])).join(';'));out.push(...['defaultSkin','defaultAnimation','canvas','userData','parent'].map(k=>ref(o[k])));}
 else if(kind==='B'||kind==='S'){out.push(...['inheritTranslation','inheritRotation','inheritScale','inheritReflection','type','length','alpha','name','extra'].map(k=>scalar(o[k])),primitive(o.transform,tfields),ref(o.userData),ref(o.parent));if(kind==='S')out.push(scalar(o.segmentX),scalar(o.segmentY),describe(o.geometry));}
 else if(kind==='L')out.push(...['blendMode','displayIndex','zOrder','zIndex','alpha','name','extra'].map(k=>scalar(o[k])),primitive(o.color,cfields),ref(o.userData),ref(o.parent));
 else if(kind==='D'){out.push(...['frameIntOffset','frameFloatOffset','frameOffset','blendType','frameCount','playTimes','duration','scale','fadeInTime','cacheFrameRate','name'].map(k=>scalar(o[k])),ref(o.parent),array(o.cachedFrames));for(const k of ['boneCachedFrameIndices','slotCachedFrameIndices'])out.push(identity(o[k])+':'+Object.keys(o[k]).sort().map(n=>n+'='+array(o[k][n])).join(';'));}
 else if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.data));
 else if(kind==='U')for(const k of ['ints','floats','strings'])out.push(identity(o[k])+':'+o[k].map(scalar).join(','));
 else if(kind==='C')out.push(...['hasBackground','color','x','y','width','height'].map(k=>scalar(o[k])));
 else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones,'ref'));
 else if(kind==='M')out.push(scalar(o.type),scalar(o.name),scalar(o.path),primitive(o.transform,tfields),describe(o.geometry));
 return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(records).sort().map(k=>{const r=records[k];return k+'='+r.name+':'+ref(r.parent)+':'+ref(r.root)+':'+ref(r.target)+':'+r.returns+':'+Object.keys(r.displays).sort().map(n=>n+'='+ref(r.displays[n])).join(',');}).join('|'),
 Object.keys(storages).sort().map(k=>k+'='+array(storages[k].cachedFrames)).join('|'),Object.keys(matrices).sort().map(k=>k+'='+primitive(matrices[k],['a','b','c','d','tx','ty'])).join('|'),Object.keys(transforms).sort().map(k=>k+'='+primitive(transforms[k],tfields)).join('|'),Object.keys(colors).sort().map(k=>k+'='+primitive(colors[k],cfields)).join('|'),
 Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'armaturedata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'armaturedata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/armaturedata_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'armaturedata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('ArmatureData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('ArmatureData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',integration:'real ArmatureData/BoneData/SurfaceData/SlotData with AnimationData cache',normalization:'object null/undefined to nil externally, strict-null decisions retain private state; holes/undefined by value and length',lua,result:'passed'};fs.writeFileSync(path.join(dir,'armaturedata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
