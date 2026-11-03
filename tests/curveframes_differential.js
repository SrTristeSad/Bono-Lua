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
const arr=(id,values=[])=>{add('array',id);values.forEach((v,i)=>{if(v==='hole')add('put',id,'length','n:'+(i+1));else add('append',id,v);});};
const curves=[[],[.25,.1,.25,1],[0,0,1,1],[0,0,.2,.1,.8,.9,1,1],[.1,.2,.2,.1,.3,.4,.5,.7,.8,.9],[.05,.1,.1,.2,.3,.4,.4,.5,.6,.65,.7,.8,.8,.9,.9,1],[0,-2,.25,-1,.75,2,1,3],['n:NaN',0,1,1],['hole',0,1,1],['null',0,1,1],['b:false',0,1,1],[.1,.2,.2,.1,'b:false',.5,.6,.7,.8,.9]];
const tokens=values=>values.map(v=>typeof v==='string'?v:'n:'+v);
for(let c=0;c<curves.length;c++)for(const length of [0,1,2,7,31]){begin('sampling-'+c+'-'+length);arr('curve',tokens(curves[c]));add('helpLength',length);add('sample','o:curve');add('helpLength',2);add('sample','o:curve');}
for(const value of ['null','undefined','b:false','n:3',s('1234')]){begin('curve-primitive-'+value);add('helpLength',3);add('sample',value);}
begin('curve-arraylike');obj('curve',{length:'n:4','0':'n:0.2','1':'n:0.3','2':'n:0.8','3':'n:0.9'});add('helpLength',4);add('sample','o:curve');
for(const t of ['n:0','n:1','n:0.125','n:-1','n:2','n:NaN','n:Infinity','n:-0']){begin('bezier-point-'+t);arr('coords',['n:0','n:0','n:0.25','n:-1','n:0.75','n:2','n:1','n:1',t]);add('point','coords');}
begin('bezier-partial-y-failure');obj('blocked',{toString:s('blocked')});arr('coords',['n:0','o:blocked','n:0.25','n:1','n:0.75','n:2','n:1','n:3','n:0.5']);add('point','coords');
const easings=['absent','n:-2','n:0','n:-0','n:-0.125','n:-0.005','n:0.005','n:0.5','n:1','n:1.005','n:1.5','n:2','n:3','n:Infinity','n:-Infinity','n:NaN','null','undefined',s('NaN'),s('bad'),s('0x1'),s('-0.005')];
for(const easing of easings)for(const count of [0,1,4]){begin('tween-'+easing+'-'+count);obj('raw',easing==='absent'?{}:{tweenEasing:easing});add('frame','tween','o:raw',3,count);add('modify');}
for(let c=0;c<curves.length;c++){begin('curve-tween-'+c);arr('curve',tokens(curves[c]));obj('raw',{curve:'o:curve',tweenEasing:'n:0.5'});add('frame','tween','o:raw',0,6);add('modify');}
for(const value of ['null','undefined','b:false','n:9']){begin('invalid-curve-'+value);obj('raw',{curve:value});add('frame','tween','o:raw',2,3);add('frame','tween','o:raw',3,0);add('modify');}
for(const count of [.5,-1,NaN]){begin('frame-count-'+count);arr('curve',['n:0','n:0','n:1','n:1']);obj('raw',{curve:'o:curve'});add('frame','tween','o:raw',2,count);}
const values=['absent','n:-0','n:0.5','n:-0.5','n:-0.5000000000000001','n:1.5','n:-1.5','n:4503599627370495','n:4503599627370496','n:NaN','n:Infinity','n:-Infinity','null','undefined','b:true',s('-0.5'),s('NaN')];
for(const kind of ['single','double'])for(const type of [0,1,2,7])for(const value of values){begin(kind+'-'+type+'-'+value);add('config',type,'n:0.25','n:1');obj('raw',value==='absent'?{}:kind==='single'?{value}:{x:value,y:'n:-0.5'});add('frame',kind,'o:raw',5,2);add('modify');}
for(const type of [0,1,2])for(const kind of ['single','double']){begin('partial-value-failure-'+type+'-'+kind);add('config',type,'n:4','n:10');obj('blocked',{toString:s('blocked')});obj('raw',kind==='single'?{value:'o:blocked',tweenEasing:'n:0'}:{x:'n:3',y:'o:blocked',tweenEasing:'n:0'});add('frame',kind,'o:raw',7,2);add('modify');}
for(const scale of ['n:0','n:-1','n:0.01','n:100','n:Infinity','n:NaN']){begin('value-scale-'+scale);add('config',1,'n:-0.5',scale);obj('raw',{x:'n:-0.5',y:'n:0.005',value:'n:-0.005'});add('frame','single','o:raw',0,0);add('frame','double','o:raw',1,1);add('modify');}
for(const method of ['base','tween','single','double']){begin('raw-null-'+method);add('config',1,'n:2','n:1');add('frame',method,'null',0,2);}
for(const target of ['_frameArray','_frameIntArray','_frameFloatArray','_helpArray']){begin('length-overflow-'+target);add('workLength',target,4294967295);add('config',target==='_frameFloatArray'?2:1,'n:1','n:1');arr('overflowCurve');obj('raw',target==='_helpArray'?{curve:'o:overflowCurve'}:{});add('frame',target==='_helpArray'?'tween':'double','o:raw',0,target==='_helpArray'?4294967295:0);add('resetArrays');add('helpLength',0);}
// Action parsing is real: merge order, refs, payloads and pool ownership.
begin('action-frame-merge-and-serialization');add('bone','bone','root','none');add('addBone','bone');obj('slotraw',{name:s('slot'),parent:s('root')});add('slot','slot','slotraw',0);add('addSlot','slot');obj('raw',{event:s('event'),sound:s('sound'),action:s('play'),events:s('events'),actions:s('actions')});for(const start of [10,0,5,10,-1,3])add('actionsIn','o:raw',start,'bone','slot');add('serializeActions');add('modify');add('linkGlobal');add('returnGlobal');
begin('empty-actions-still-insert-initial-frame');obj('raw',{event:'null',sound:'undefined',action:'b:false'});add('actionsIn','o:raw',5,'none','none');add('actionsIn','o:raw',-1,'none','none');add('serializeActions');add('modify');
begin('action-frame-payload-and-partial-error');arr('ints',['n:1','hole','n:-0']);obj('entry',{name:s('entry'),ints:'o:ints'});arr('actions',['o:entry']);obj('bad',{toString:s('blocked')});obj('raw',{event:'o:actions',sound:s('sound'),actions:'o:bad'});add('actionsIn','o:raw',4,'none','none');add('serializeActions');add('modify');add('returnArm');
begin('actions-mid-sequence-error');arr('bad',['null']);obj('raw',{event:s('kept'),sound:'o:bad',action:s('unreached')});add('actionsIn','o:raw',2,'none','none');add('serializeActions');add('modify');
begin('merge-order-nan-and-infinity');for(const start of [NaN,3,NaN,Infinity,-Infinity,3])add('merge',s('action'),start,0);add('serializeActions');add('modify');
begin('manual-action-frame-holes');arr('offsets',['n:2','hole','n:-0','undefined','n:65536']);add('manualActions','offsets',9);add('modify');
begin('action-add-failure-keeps-orphans');add('failAddAction',2);obj('entry',{name:s('a')});arr('actions',['o:entry','o:entry','o:entry']);add('merge','o:actions',4,0);add('allowAddAction');add('merge',s('ok'),4,0);add('serializeActions');add('modify');
let seed=0x4652414d;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<5;run++){begin('deterministic-frames-'+run);for(let j=0;j<30;j++){add('config',rand(3),'n:0','n:'+((rand(21)-10)/10));obj('raw',{x:'n:'+((rand(2001)-1000)/8),y:'n:'+((rand(2001)-1000)/8),value:'n:'+((rand(2001)-1000)/8),tweenEasing:'n:'+((rand(501)-250)/100)});add('frame',rand(2)?'single':'double','o:raw',j,rand(5));}add('modify');}
const methodCalls=Object.fromEntries(['_getCurvePoint','_samplingEasingCurve','_parseFrame','_parseTweenFrame','_parseSingleValueFrame','_parseDoubleValueFrame','_parseActionFrame','_parseActionDataInFrame','_mergeActionFrame'].map(k=>[k,0]));
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn,failAddAction;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;failAddAction=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();for(const k of Object.keys(methodCalls)){const original=p[k];if(typeof original!=='function')throw Error('Missing original '+k);p[k]=function(...args){methodCalls[k]++;return original.apply(this,args);};}const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='helpLength')p._helpArray.length=num(a);
 else if(op==='sample')return scalar(p._samplingEasingCurve(decode(a),p._helpArray));
 else if(op==='point'){const args=Array.from({length:9},(_,i)=>raws[a][i]);p._getCurvePoint(...args,p._helpPoint);}
 else if(op==='config'){p._frameValueType=num(a);p._frameDefaultValue=decode(b);p._frameValueScale=decode(c);}
 else if(op==='frame'){const method={base:'_parseFrame',tween:'_parseTweenFrame',single:'_parseSingleValueFrame',double:'_parseDoubleValueFrame'}[a];return scalar(p[method](decode(b),num(c),num(e)));}
 else if(op==='modify')p._modifyArray();
 else if(op==='actionsIn')p._parseActionDataInFrame(decode(a),num(b),objects[c]||null,objects[e]||null);
 else if(op==='merge')p._mergeActionFrame(decode(a),num(b),num(c),null,null);
 else if(op==='serializeActions'){for(const f of p._actionFrames)p._parseActionFrame(f,f.frameStart,0);}
 else if(op==='manualActions'){const f=new d.ActionFrame();f.actions.push(...raws[a]);return scalar(p._parseActionFrame(f,num(b),123));}
 else if(op==='failAddAction'){failAddAction=Number(a);const original=p._armature.addAction;p._armature.addAction=function(...args){if(--failAddAction===0)throw Error('add action failure');return original.apply(this,args);};}
 else if(op==='allowAddAction')failAddAction=0;
 else if(op==='object')raws[a]={};else if(op==='array')raws[a]=new RealmArray();else if(op==='put')raws[a][b]=decode(c);else if(op==='append')raws[a].push(decode(b));
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
function frameSnapshot(){return [array(p._helpArray,'value'),['_frameValueType','_frameDefaultValue','_frameValueScale'].map(k=>scalar(p[k])).join(','),id(p._actionFrames)+':'+p._actionFrames.length+':'+p._actionFrames.map(f=>id(f)+':'+scalar(f.frameStart)+':'+array(f.actions,'value')).join('|'),array(p._armature.actions),array(p._armature.defaultActions),p._data.binary==null?'nil':Buffer.from(new Uint8Array(p._data.binary)).toString('hex')];}
const knownOps=new Set([...String(execute).matchAll(/op==='([^']+)'/g)].map(m=>m[1]));for(const r of rows)if(r[0]!=='begin'&&!knownOps.has(r[0]))throw Error('Unknown fixture operation '+r[0]);
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot(),...frameSnapshot()]);}
const sourceErrors=expected.filter(r=>['range','error'].includes(r[1])).length;if(sourceErrors!==21||Object.values(methodCalls).some(n=>n===0))throw Error('Unexpected source errors or missing method coverage');
if(!modelCoverage.ActionData||!modelCoverage.UserData||!expected.some(r=>r[1]==='true')||!expected.some(r=>r[1]==='false')||!expected.some(r=>r[1]==='range'))throw Error('Missing source coverage');
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'curveframes-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'curveframes-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/curveframes_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'curveframes-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'curveframes-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('CurveFrames mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,sourceErrors,methodCalls,tolerance:0,integration:'nine curve/frame/action methods with real models, working arrays, typed finalization and pool',lua,result:'passed'};fs.writeFileSync(path.join(dir,'curveframes-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
