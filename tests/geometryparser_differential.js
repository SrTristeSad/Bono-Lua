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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');
const rows=[],add=(...r)=>rows.push(r.map(String)),begin=name=>add('begin',name),s=v=>'s:'+Buffer.from(v).toString('hex');
const obj=(id,props={})=>{add('object',id);for(const [k,v] of Object.entries(props))add('put',id,k,v);};
const arr=(id,values=[])=>{add('array',id);for(const v of values)add('append',id,v);};
const verts=(id,values=['n:1','n:2','n:3','n:4'])=>{arr(id+'v',values);obj(id,{vertices:'o:'+id+'v'});};
function bones(){add('bone','b1','b1','none');add('bone','b0','b0','none');add('addBone','b1');add('addBone','b0');add('rawBoneAdd','b0');add('rawBoneAdd','b1');}
function context(){bones();obj('slotRaw',{name:s('slot'),parent:s('b0')});add('slot','slot','slotRaw',0);add('addSlot','slot');add('skin','skin','default');add('context','slot','skin');}
function weighted(id,pose=true){verts(id);arr(id+'w',['n:1','n:0','n:0.25','n:1','n:1','n:0.75']);add('put',id,'weights','o:'+id+'w');if(pose){arr(id+'sp',['n:1','n:0','n:0','n:1','n:10','n:20']);arr(id+'bp',['n:0','n:1','n:0','n:0','n:1','n:2','n:3','n:1','n:2','n:0','n:0','n:2','n:4','n:6']);add('put',id,'slotPose','o:'+id+'sp');add('put',id,'bonePose','o:'+id+'bp');}else{arr(id+'b',['n:0','n:1']);add('put',id,'bones','o:'+id+'b');}}
if(Buffer.from(s('ellipse😀').slice(2),'hex').toString()!=='ellipse😀')throw Error('Fixture encoding');
begin('unweighted-layout-offsets-and-reset');add('display','m','M','mesh');verts('raw',['n:1','n:2','n:3','n:4','n:5','n:6','n:99']);arr('tri',['n:0','n:1','n:2','n:99']);arr('uv',['n:0','n:0','n:1','n:0','n:0','n:1']);add('put','raw','triangles','o:tri');add('put','raw','uvs','o:uv');add('geo','m','raw');add('bind');add('counts','m');add('geo','m','raw');add('counts','m');add('workExtra','_intArray',s('keep'));add('workPut','_frameArray',2,'n:123');add('resetArrays');add('counts','m');add('geo','m','raw');
for(const values of [[],['n:1'],['n:1','undefined','null','n:4'],['n:-0','n:NaN','n:Infinity','n:-Infinity']]){begin('vertex-values-'+values.join(','));add('display','m','M','mesh');verts('raw',values);add('geo','m','raw');}
for(const field of ['vertices','triangles','uvs','weights'])for(const value of ['null','undefined']){begin('invalid-field-'+field+'-'+value);add('display','m','M','mesh');verts('raw');add('put','raw',field,value);add('geo','m','raw');}
for(const target of ['_intArray','_floatArray']){begin('length-overflow-'+target);add('display','m','M','mesh');verts('raw');add('workLength',target,4294967295);add('geo','m','raw');add('resetArrays');}
begin('weighted-poses-two-bones-and-reparse');context();weighted('raw');add('display','m','M','mesh');add('geo','m','raw');add('bind');add('counts','m');verts('plain');add('geo','m','plain');add('return','m');
begin('weighted-without-poses-original-weightCount-loop');context();weighted('raw',false);add('display','m','M','mesh');add('geo','m','raw');add('bind');add('counts','m');add('return','m');
begin('weightCount-differs-from-vertexCount');context();weighted('raw',false);arr('extra',['n:1','n:0','n:0.5','n:1','n:1','n:0.5','n:0','n:0','n:0','n:0']);add('put','raw','weights','o:extra');add('display','m','M','mesh');add('geo','m','raw');
for(const pose of [
 ['n:0','n:1','n:2','n:3','n:5','n:2','n:3','n:1','n:2','n:1','n:-1','n:3','n:4','n:6'],
 ['n:0','n:1','n:2','n:2','n:4','n:0','n:0','n:1','n:0','n:0','n:0','n:0','n:0','n:0']]){begin('bone-matrix-general-and-singular-'+pose.join(','));context();weighted('raw');arr('pose',pose);add('put','raw','bonePose','o:pose');add('display','m','M','mesh');add('geo','m','raw');}
for(const pose of [[],['n:1','n:0','n:0','n:1'],['n:0','n:0','n:0','n:0','n:0','n:0'],['n:1','n:2','n:2','n:4','n:0','n:0']]){begin('slot-pose-degenerate-'+pose.join(','));context();weighted('raw');arr('pose',pose);add('put','raw','slotPose','o:pose');add('display','m','M','mesh');add('geo','m','raw');}
for(const field of ['slotPose','bonePose','bones']){begin('missing-pose-field-'+field);context();weighted('raw',field!=='bones');add('put','raw',field,'null');add('display','m','M','mesh');add('geo','m','raw');}
begin('fractional-weight-count-range-error');context();verts('raw',['n:1','n:2']);arr('w',['n:1','n:0']);add('put','raw','weights','o:w');add('display','m','M','mesh');add('geo','m','raw');
begin('weight-index-not-in-pose-and-raw-bones');context();weighted('raw');add('putIndex','rawbp',0,'n:99');add('display','m','M','mesh');add('geo','m','raw');
begin('mesh-wrapper-pose-caches');context();weighted('raw');add('display','m','M','mesh');add('mesh','m','raw');add('return','m');
for(const type of [s('bone'),s('surface'),'n:8']){begin('parse-bone-'+type);verts('raw');obj('transform',{x:'n:3',y:'n:4',rotate:'n:45'});add('put','raw','type',type);add('put','raw','name',s('bone'));add('put','raw','length','n:10');add('put','raw','alpha','n:0.5');add('put','raw','segmentX','n:2');add('put','raw','segmentY','n:3');add('put','raw','transform','o:transform');add('setArm','scale','n:0.5');add('parseBone','bone','raw');add('addBone','bone');add('returnArm');}
for(const type of [s('image'),s('armature'),s('mesh'),s('boundingbox'),s('path'),'n:99']){begin('parse-display-'+type);context();verts('raw');add('put','raw','name',s('display'));add('put','raw','type',type);arr('lengths',['n:2','undefined','n:6']);add('put','raw','lengths','o:lengths');add('put','raw','width','n:10');add('put','raw','height','n:20');add('put','raw','actions',s('walk'));obj('transform',{x:'n:2',y:'n:-3',rotate:'n:30'});add('put','raw','transform','o:transform');add('setArm','scale','n:2');add('parseDisplay','display','raw');add('return','display');}
begin('armature-display-without-slot-context');obj('raw',{type:s('armature'),name:s('child')});add('parseDisplay','display','raw');
for(const share of ['undefined','null','b:false',s('other')]){begin('deferred-share-'+share);context();obj('raw',{name:s('shared'),type:s('mesh'),share});add('parseDisplay','display','raw');add('return','display');}
begin('skin-null-slots-default-name-and-action-index');context();obj('slotraw',{name:s('slot'),actions:s('walk'),displayIndex:'n:2'});add('slot','slot2','slotraw',1);add('set','slot','displayIndex','n:2');add('context','slot','skin');verts('mesh');add('put','mesh','type',s('mesh'));add('put','mesh','name',s('mesh'));obj('nested',{type:s('armature'),name:s('child')});obj('image',{type:s('image'),name:s('image')});arr('displays',['null','b:false','o:nested','o:image','o:mesh','undefined','n:0',s('')]);obj('slotEntry',{name:s('slot'),display:'o:displays'});obj('ignored',{name:s('missing'),display:'null'});arr('slots',['o:ignored','o:slotEntry']);obj('rawSkin',{name:s(''),slot:'o:slots'});add('parseSkin','parsed','rawSkin');add('addSkin','parsed');add('linkGlobal');add('returnGlobal');
begin('skin-action-transfer-empty-first-slot');context();obj('slotraw',{name:s('slot'),actions:s('play')});add('slot','newSlot','slotraw',0);add('context','newSlot','skin');obj('child',{type:s('armature'),name:s('child')});arr('displays',['o:child','o:child']);obj('slotEntry',{name:s('slot'),display:'o:displays'});arr('slots',['o:slotEntry']);obj('rawSkin',{slot:'o:slots'});add('parseSkin','parsed','rawSkin');add('return','parsed');
for(const value of ['null','undefined']){begin('skin-display-failure-'+value);context();obj('entry',{name:s('slot'),display:value});arr('slots',['o:entry']);obj('rawSkin',{slot:'o:slots'});add('parseSkin','parsed','rawSkin');}
begin('weighted-skin-failure-chain');context();weighted('mesh');add('put','mesh','name',s('mesh'));add('put','mesh','type',s('mesh'));arr('displays',['o:mesh']);obj('entry',{name:s('slot'),display:'o:displays'});arr('slots',['o:entry']);obj('rawSkin',{slot:'o:slots'});add('parseSkin','parsed','rawSkin');add('addSkin','parsed');add('linkGlobal');add('failReturn','W');add('returnGlobal');add('returnGlobal');
let seed=0x47454f4d;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<4;run++){begin('deterministic-geometry-'+run);context();for(let i=0;i<12;i++){const values=Array.from({length:2*(1+rand(5))},()=> 'n:'+((rand(2001)-1000)/13));verts('raw',values);arr('tri',['n:0','n:0','n:0']);if(i%2)add('put','raw','triangles','o:tri');add('put','raw','type',s(i%2?'mesh':'surface'));add('put','raw','name',s('data'+i));if(i%2)add('parseDisplay','item','raw');else add('parseBone','item','raw');add('return','item');}}
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='object')raws[a]={};else if(op==='array')raws[a]=new RealmArray();else if(op==='put')raws[a][b]=decode(c);else if(op==='append')raws[a].push(decode(b));
 else if(op==='bone'||op==='rawBone'){const o=op==='rawBone'?register(new d.BoneData()):B.borrowObject(d.BoneData);o.name=b;if(op==='bone')o.parent=objects[c]||null;objects[a]=o;}
 else if(op==='set')objects[a][b]=decode(c);
 else if(op==='putIndex')raws[a][Number(b)]=decode(c);
 else if(op==='rawBoneAdd')p._rawBones.push(objects[a]);
 else if(op==='context'){p._slot=objects[a]||null;p._skin=objects[b]||null;}
 else if(op==='geo')p._parseGeometry(raws[b],objects[a].geometry);
 else if(op==='mesh')p._parseMesh(raws[b],objects[a]);
 else if(op==='parseBone'||op==='parseDisplay'||op==='parseSkin'){objects[a]=p[op==='parseBone'?'_parseBone':op==='parseDisplay'?'_parseDisplay':'_parseSkin'](raws[b]);return ref(objects[a]);}
 else if(op==='workPut')p[a][Number(b)]=decode(c);
 else if(op==='workLength')p[a].length=Number(b);
 else if(op==='workExtra')p[a].extra=decode(b);
 else if(op==='resetArrays')p._parseArray(null);
 else if(op==='bind'){p._data.intArray=p._intArray;p._data.floatArray=p._floatArray;}
 else if(op==='counts')return scalar(objects[a].geometry.vertexCount)+'|'+scalar(objects[a].geometry.triangleCount);
 else if(op==='linkGlobal')p._data.addArmature(p._armature);
 else if(op==='returnGlobal')p._data.returnToPool();
 else if(op==='returnArm')p._armature.returnToPool();
 else if(op==='failReturn')failReturn=a;
 else if(op==='parent')objects[a].parent=objects[b]||null;
 else if(op==='addBone')p._armature.addBone(objects[a]);else if(op==='addSlot')p._armature.addSlot(objects[a]);else if(op==='addSkin')p._armature.addSkin(objects[a]);
 else if(op==='skin'){const o=B.borrowObject(d.SkinData);o.name=b;objects[a]=o;}
 else if(op==='display'){const o=B.borrowObject(classes[b]);o.name=c;objects[a]=o;}
 else if(op==='addDisplay')objects[a].addDisplay(b,objects[c]);
 else if(op==='slot'){objects[a]=p._parseSlot(raws[b],Number(c));return ref(objects[a]);}
 else if(op==='ik'||op==='path'||op==='box'){objects[a]=p[op==='ik'?'_parseIKConstraint':op==='path'?'_parsePathConstraint':'_parseBoundingBox'](raws[b]);return ref(objects[a]);}
 else if(op==='actions'){lists[a]=p._parseActionData(decode(b),Number(c),objects[e]||null,objects[f]||null);return 'list:'+id(lists[a]);}
 else if(op==='payloadRead'){const u=lists[a][Number(b)].data;return [u.getInt(Number(c)),u.getFloat(Number(c)),u.getString(Number(c))].map(scalar).join('|');}
 else if(op==='returnActions'){for(const o of lists[a])o.returnToPool();}
 else if(op==='return'){if(objects[a]!=null)objects[a].returnToPool();}
 else if(op==='transform')p._parseTransform(raws[a],p._helpTransform,decode(b));
 else if(op==='transformSet')p._helpTransform[a]=decode(b);
 else if(op==='color')p._parseColorTransform(raws[a],p._helpColorTransform);
 else if(op==='pivot')p._parsePivot(raws[b],objects[a]);
 else if(op==='setArm')p._armature[a]=decode(b);
 else if(op==='newArm')p._armature=register(new d.ArmatureData());
 else if(op==='clearArm')p._armature._onClear();
 else throw Error(op);return 'void';
}
function array(a,mode='ref'){return id(a)+':'+a.length+':'+Object.keys(a).filter(k=>a[k]!==undefined).sort().map(k=>k+'='+(mode==='value'?scalar(a[k]):ref(a[k]))).join(',');}
function geometry(g){return id(g)+':'+[scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)].join(',');}
const primitive=(o,keys)=>id(o)+':'+keys.map(k=>scalar(o[k])).join(',');
const transformKeys=['x','y','rotation','skew','scaleX','scaleY'],colorKeys=['alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'];
function describe(o){const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(kind==='A')out.push(scalar(o.scale),ref(o.defaultSkin),...['bones','slots','skins'].map(k=>id(o[k])+':'+Object.keys(o[k]).sort().map(n=>n+'='+ref(o[k][n])).join(',')));
 if(kind==='Z')out.push(scalar(o.name),id(o.armatures)+':'+Object.keys(o.armatures).sort().map(k=>k+'='+ref(o.armatures[k])).join(','));
 if(kind==='F')out.push(scalar(o.type),scalar(o.name),ref(o.parent),scalar(o.alpha),scalar(o.segmentX),scalar(o.segmentY),primitive(o.transform,transformKeys),geometry(o.geometry));
 if(kind==='B')out.push(scalar(o.type),scalar(o.name),ref(o.parent),scalar(o.length),scalar(o.alpha),...['inheritTranslation','inheritRotation','inheritScale','inheritReflection'].map(k=>scalar(o[k])),primitive(o.transform,transformKeys));
 if(kind==='S')out.push(...['name','displayIndex','zOrder','zIndex','alpha','blendMode'].map(k=>scalar(o[k])),ref(o.parent),o.color==null?'nil':primitive(o.color,colorKeys));
 if(kind==='K')out.push(scalar(o.name),ref(o.parent),id(o.displays)+':'+Object.keys(o.displays).sort().map(k=>k+'='+array(o.displays[k])).join(','));
 if(['I','P','Y','M','H','J'].includes(kind)){out.push(scalar(o.type),scalar(o.name),scalar(o.path),ref(o.parent),primitive(o.transform,transformKeys));if(kind==='I')out.push(primitive(o.pivot,['x','y']));if(['P','Y','M'].includes(kind))out.push(geometry(o.geometry));if(kind==='P'||kind==='Y')out.push(scalar(o.closed),scalar(o.constantSpeed),array(o.curveLengths,'value'));if(kind==='H')out.push(scalar(o.inheritAnimation),array(o.actions));if(kind==='J')out.push(ref(o.boundingBox));}
 if(['R','E','V'].includes(kind)){out.push(...['type','color','width','height'].map(k=>scalar(o[k])));if(kind==='V')out.push(scalar(o.x),scalar(o.y),array(o.vertices,'value'));}
 if(['C','D'].includes(kind)){out.push(...['type','name','order'].map(k=>scalar(o[k])),ref(o.root),ref(o.target),ref(o.bone));if(kind==='C')out.push(scalar(o.scaleEnabled),scalar(o.bendPositive),scalar(o.weight));else out.push(ref(o.pathSlot),ref(o.pathDisplayData),array(o.bones),...['positionMode','spacingMode','rotateMode','position','spacing','rotateOffset','rotateMix','translateMix'].map(k=>scalar(o[k])));}
 if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones));
 if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.bone),ref(o.slot),ref(o.data));
 if(kind==='U')out.push(...['ints','floats','strings'].map(k=>array(o[k],'value')));
 return out.join(':');}
function snapshot(){return [scalar(B._hashCode),allocated.map(describe).join('|'),Object.keys(objects).sort().map(k=>k+'='+ref(objects[k])).join('|'),Object.keys(lists).sort().map(k=>k+'='+array(lists[k])).join('|'),primitive(p._helpTransform,transformKeys),primitive(p._helpColorTransform,colorKeys),Object.keys(p._slotChildActions).sort().map(k=>k+'='+array(p._slotChildActions[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),warnings.map(w=>Buffer.from(w).toString('hex')).join('|'),['_intArray','_floatArray','_frameIntArray','_frameFloatArray','_frameArray','_timelineArray','_colorArray'].map(k=>k+'='+array(p[k],'value')).join('|'),[ref(p._armature),ref(p._data),ref(p._skin),ref(p._slot),array(p._rawBones),array(p._cacheMeshes),id(p._cacheRawMeshes)+':'+p._cacheRawMeshes.length+':'+p._cacheRawMeshes.map(o=>id(o)).join(','),...['_weightSlotPose','_weightBonePoses'].map(k=>id(p[k])+':'+Object.keys(p[k]).sort().map(n=>n+'='+(p[k][n]==null?'nil':id(p[k][n]))).join(','))].join('|'),primitive(p._helpMatrixA,['a','b','c','d','tx','ty'])+'|'+primitive(p._helpMatrixB,['a','b','c','d','tx','ty'])+'|'+primitive(p._helpPoint,['x','y'])];}
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot()]);}
for(const name of ['SurfaceData','BoneData','MeshDisplayData','PathDisplayData','ArmatureDisplayData','BoundingBoxDisplayData','SkinData','WeightData','DragonBonesData'])if(!modelCoverage[name])throw Error('Missing positive source coverage '+name);
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'geometryparser-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'geometryparser-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/geometryparser_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'geometryparser-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'geometryparser-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('GeometryParser mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,integration:'seven parser methods: geometry/array/bone/path/mesh/display/skin with real models, weights, matrices and pool; untyped working arrays',lua,result:'passed'};fs.writeFileSync(path.join(dir,'geometryparser-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
