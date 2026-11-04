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
const verts=(id,values=['n:1','n:2','n:3','n:4'])=>{arr(id+'v',values);obj(id,{vertices:'o:'+id+'v'});};
function bones(){add('bone','b1','b1','none');add('bone','b0','b0','none');add('addBone','b1');add('addBone','b0');add('rawBoneAdd','b0');add('rawBoneAdd','b1');}
function context(){bones();obj('slotRaw',{name:s('slot'),parent:s('b0')});add('slot','slot','slotRaw',0);add('addSlot','slot');add('skin','skin','default');add('context','slot','skin');}
function weighted(id,pose=true){verts(id);arr(id+'w',['n:1','n:0','n:0.25','n:1','n:1','n:0.75']);add('put',id,'weights','o:'+id+'w');if(pose){arr(id+'sp',['n:1','n:0','n:0','n:1','n:10','n:20']);arr(id+'bp',['n:0','n:1','n:0','n:0','n:1','n:2','n:3','n:1','n:2','n:0','n:0','n:2','n:4','n:6']);add('put',id,'slotPose','o:'+id+'sp');add('put',id,'bonePose','o:'+id+'bp');}else{arr(id+'b',['n:0','n:1']);add('put',id,'bones','o:'+id+'b');}}

function setup(weight=false,pose=true){context();if(weight)weighted('geo',pose);else verts('geo');add('display','mesh','M','mesh');add('mesh','mesh','geo');add('addDisplay','skin','slot','mesh');add('deformContext','mesh');add('workPut','_frameFloatArray',0,'n:19');add('workPut','_frameIntArray',0,'n:23');}

function init(count=5,weighted=false){setup(weighted);obj('sameSlot',{name:s('b0'),parent:s('b0')});add('slot','sameSlot','sameSlot',3);add('addSlot','sameSlot');add('animationSpec',count,3);add('workPut','_frameArray',0,'n:29');add('indicesPrefix',2);}
const timeline=(id='t',raw='null',frames='o:frames',mode=2,parser='_parseDoubleValueFrame',provided='none',kind=11,values=2,key='frames')=>add('timeline',id,raw,frames,key,kind,mode,values,parser,provided);
const frame=(id,props={})=>obj(id,{x:'n:2',y:'n:3',value:'n:4',...props});
for(const n of [0,1,2,3,7])for(const count of [0,1,5,9])for(const mode of [0,1,2]){begin('layout-'+n+'-'+count+'-'+mode);init(count);for(let i=0;i<n;i++)frame('f'+i,{duration:'n:'+(i%3+1)});arr('frames',Array.from({length:n},(_,i)=>'o:f'+i));timeline('t','null','o:frames',mode,mode===0?'_parseSlotDisplayFrame':'_parseDoubleValueFrame');add('modify');}
for(const duration of ['absent','n:0','n:-1','n:0.5','n:2.5','n:NaN','n:Infinity','null','undefined',s('NaN')]){begin('duration-'+duration);init();frame('f',duration==='absent'?{}:{duration});arr('frames',['o:f','o:f','o:f']);timeline();add('modify');}
for(const scale of ['n:-1','n:0','n:0.5','n:Infinity','null','undefined']){begin('scale-offset-'+scale);init();frame('f');arr('frames',['o:f','o:f']);obj('raw',{scale,offset:'n:-0.005',frames:'o:frames'});timeline('t','o:raw','null');add('modify');}
for(const value of ['null','undefined','b:false','n:3']){begin('frames-property-'+value);init();frame('f');arr('frames',['o:f']);obj('raw',{frames:value});timeline('t','o:raw');}
begin('raw-frames-precedence-empty-and-reuse');init();frame('f');arr('frames',['o:f']);arr('empty');obj('raw',{frames:'o:empty'});add('newTimeline','existing');timeline('a','o:raw','o:frames',2,'_parseDoubleValueFrame','existing');timeline('b','null','o:frames',2,'_parseDoubleValueFrame','existing');add('modify');
for(const raw of ['null','undefined']){begin('raw-'+raw);init();frame('f');arr('frames',['o:f']);timeline('t',raw);}
for(const parser of ['_parseFrame','_parseSingleValueFrame','_parseDoubleValueFrame','_parseBoneAllFrame','_parseBoneTranslateFrame','_parseBoneRotateFrame','_parseBoneScaleFrame','_parseSlotDisplayFrame','_parseSlotColorFrame','_parseIKConstraintFrame','_parseZOrderFrame','_parseSlotDeformFrame','_parseDeformFrame']){begin('callback-'+parser);init(6,parser==='_parseSlotDeformFrame');frame('f',{duration:'n:2',rotate:'n:45',event:s('event')});arr('frames',['o:f','o:f','o:f']);timeline('t','null','o:frames',parser==='_parseSlotDisplayFrame'?0:parser==='_parseSlotColorFrame'||parser==='_parseIKConstraintFrame'?1:2,parser);add('modify');}
for(const target of ['animation','data']){begin('missing-'+target);init();frame('f');arr('frames',['o:f','o:f']);add('clearDeformContext',target);timeline('t','null','o:frames',target==='animation'?1:2);}
for(const fail of [1,2]){begin('callback-failure-'+fail);init();frame('f');arr('frames',['o:f','o:f','o:f']);add('failCallback',fail);timeline();add('failCallback',0);timeline('second');add('modify');}
for(const target of ['_timelineArray','_frameArray','indices']){begin('overflow-'+target);init();frame('f');arr('frames',['o:f','o:f']);if(target==='indices')add('indicesLength',4294967295);else add('workLength',target,4294967295);timeline();add('resetArrays');add('indicesLength',0);}
for(const count of [-1,-2,.5,NaN]){begin('animation-count-'+count);init(count);frame('f');arr('frames',['o:f','o:f']);timeline();}
for(const field of ['scale','offset']){begin('header-conversion-error-'+field);init();obj('bad',{toString:s('bad')});frame('f');arr('frames',['o:f']);obj('raw',{[field]:'o:bad'});add('newTimeline','existing');timeline('t','o:raw','o:frames',2,'_parseDoubleValueFrame','existing');}
begin('actions-real-timeline');init(7);for(const t of [0,3,6])add('merge',s('action'+t),t,10);timeline('t','null','actions',0,'_parseActionFrame','none',0,0,'');add('modify');
begin('actions-use-cache-next-time');init(8);for(const t of [0,5,7])add('merge',s('action'+t),t,10);add('actionCopy',1);timeline('t','null','o:copy',0,'_parseActionFrame','none',0,0,'');add('modify');
begin('actions-cache-missing-next');init();add('actionCopy',0);timeline('t','null','o:copy',0,'_parseActionFrame','none',0,0,'');
for(const kind of ['bone','slot'])for(const name of ['b0','slot','missing']){begin('dispatch-'+kind+'-'+name);init();frame('f',{duration:'n:2',event:s('event')});arr('frames',['o:f','o:f']);obj('raw',{name:s(name),translateFrame:'o:frames',rotateFrame:'o:frames',scaleFrame:'o:frames',frame:'o:frames'});add('dispatch',kind,'raw');add('modify');}
for(const kind of ['bone','slot'])for(const value of ['null','undefined','o:empty']){begin('dispatch-empty-'+kind+'-'+value);init();arr('empty');obj('raw',{name:s(kind==='bone'?'b0':'slot'),translateFrame:value,displayFrame:value,colorFrame:value,frame:value});add('dispatch',kind,'raw');}
begin('bone-partial-registration');init();frame('f');arr('frames',['o:f']);obj('raw',{name:s('b0'),translateFrame:'o:frames',rotateFrame:'undefined'});add('dispatch','bone','raw');add('modify');
begin('slot-deferred-registration');init();frame('f');arr('frames',['o:f']);obj('raw',{name:s('slot'),displayFrame:'o:frames',colorFrame:'undefined'});add('dispatch','slot','raw');add('modify');
begin('dispatch-return-pool');init();frame('f');arr('frames',['o:f','o:f']);obj('raw',{name:s('b0'),frame:'o:frames'});add('dispatch','bone','raw');obj('raw',{name:s('slot'),frame:'o:frames'});add('dispatch','slot','raw');add('returnAnimation');add('modify');
let seed=0x54494d45;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<5;run++){begin('deterministic-timelines-'+run);init(20);for(let j=0;j<12;j++){const n=1+rand(5);for(let k=0;k<n;k++)frame('f'+k,{duration:'n:'+rand(7),x:'n:'+((rand(2001)-1000)/8),y:'n:'+((rand(2001)-1000)/8),tweenEasing:'n:'+((rand(301)-150)/100)});arr('frames',Array.from({length:n},(_,i)=>'o:f'+i));timeline('t'+j,'null','o:frames',rand(3),'_parseDoubleValueFrame');}add('modify');}
const methodCalls=Object.fromEntries(['_parseTimeline','_parseBoneTimeline','_parseSlotTimeline'].map(k=>[k,0]));
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn,failAddAction,callbackTrace,callbackFail;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;failAddAction=0;callbackTrace=[];callbackFail=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();for(const k of Object.keys(methodCalls)){const original=p[k];if(typeof original!=='function')throw Error('Missing original '+k);p[k]=function(...args){methodCalls[k]++;return original.apply(this,args);};}const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={N:d.AnimationData,T:d.TimelineData,Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='animationSpec'){p._animation.frameCount=num(a);p._animation.frameOffset=num(b);}
 else if(op==='indicesPrefix'){for(let i=0;i<num(a);i++)p._data.frameIndices.push(41+i);}
 else if(op==='indicesLength')p._data.frameIndices.length=num(a);
 else if(op==='newTimeline'){objects[a]=B.borrowObject(d.TimelineData);objects[a].frameIndicesOffset=77;}
 else if(op==='failCallback')callbackFail=num(a);
 else if(op==='returnAnimation')p._animation.returnToPool();
 else if(op==='actionCopy'){raws.copy=new RealmArray();for(let i=0;i<2;i++){const f=new d.ActionFrame();f.frameStart=i*2;f.actions.push(i);raws.copy.push(f);}if(num(a))p._actionFrames[1].frameStart=5;}
 else if(op==='dispatch')p[a==='bone'?'_parseBoneTimeline':'_parseSlotTimeline'](raws[b]);
 else if(op==='timeline'){const [_,label,raw,frames,key,type,mode,values,parser,provided]=r;const original=p[parser];const cb=function(raw,start,count){callbackTrace.push([parser,scalar(start),scalar(count)].join(':'));const result=original.call(this,raw,start,count);if(callbackFail>0&&--callbackFail===0)throw Error('callback failure');return result;};objects[label]=p._parseTimeline(decode(raw),frames==='actions'?p._actionFrames:decode(frames),key,num(type),num(mode),num(values),cb,objects[provided]||null);return ref(objects[label]);}
 else if(op==='deformContext'){p._mesh=objects[a];p._geometry=p._mesh.geometry;p._animation=B.borrowObject(d.AnimationData);p._timeline=B.borrowObject(d.TimelineData);p._animation.frameFloatOffset=5;p._animation.frameIntOffset=7;p._timeline.offset=3;}
 else if(op==='deform')return scalar(p[a==='slot'?'_parseSlotDeformFrame':'_parseDeformFrame'](decode(b),num(c),num(e)));
 else if(op==='poseCache'){const key=p._mesh.parent.name+'_'+p._slot.name+'_'+p._mesh.name;p[a==='slot'?'_weightSlotPose':'_weightBonePoses'][key]=decode(b);}
 else if(op==='weightCount')p._mesh.geometry.weight.count=num(a);
 else if(op==='animationOffsets'){p._animation.frameFloatOffset=num(a);p._animation.frameIntOffset=num(b);}
 else if(op==='timelineOffset')p._timeline.offset=num(a);
 else if(op==='returnDeformContext'){p._animation.returnToPool();p._timeline.returnToPool();}
 else if(op==='clearDeformContext'){if(a==='parent')p._mesh.parent=null;else p['_'+a]=null;}
 else if(op==='special')return scalar(p['_parse'+a+'Frame'](decode(b),num(c),num(e)));
 else if(op==='previous'){p._prevClockwise=decode(a);p._prevRotation=decode(b);}
 else if(op==='frameContext'){p._bone=objects[a]||null;p._slot=objects[b]||null;}
 else if(op==='helpLength')p._helpArray.length=num(a);
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
// Float NaN payload/sign is outside the adapter contract. Normalize only
// those four-byte cells in a detached observation snapshot; never edit views.
function observedBytes(){const out=Buffer.from(new Uint8Array(p._data.binary));for(const name of ['floatArray','frameFloatArray']){const v=p._data[name];for(let i=0;i<v.length;i++)if(Number.isNaN(v[i]))out.writeUInt32LE(0x7fc00000,v.byteOffset+i*4);}return out.toString('hex');}
function frameSnapshot(){return [array(p._helpArray,'value'),['_frameValueType','_frameDefaultValue','_frameValueScale','_prevClockwise','_prevRotation','_defaultColorOffset'].map(k=>scalar(p[k])).join(','),id(p._actionFrames)+':'+p._actionFrames.length+':'+p._actionFrames.map(f=>id(f)+':'+scalar(f.frameStart)+':'+array(f.actions,'value')).join('|'),array(p._armature.actions),array(p._armature.defaultActions),p._data==null||p._data.binary==null?'nil':observedBytes(),ref(p._bone),[p._geometry==null?'nil':geometry(p._geometry),ref(p._mesh),p._animation==null?'nil':primitive(p._animation,['frameFloatOffset','frameIntOffset']),p._timeline==null?'nil':primitive(p._timeline,['offset'])].join('|')];}
function timelineSnapshot(){const anim=p._animation;const maps=anim==null?'nil':['boneTimelines','slotTimelines'].map(k=>Object.keys(anim[k]).sort().map(n=>n+'='+array(anim[k][n])).join(',')).join('|');return [p._data==null?'nil':array(p._data.frameIndices,'value'),allocated.filter(o=>o.constructor===d.TimelineData).map(o=>ref(o)+':'+['type','offset','frameIndicesOffset'].map(k=>scalar(o[k])).join(',')).join('|'),anim==null?'nil':primitive(anim,['frameCount','frameOffset','frameIntOffset','frameFloatOffset']),maps,callbackTrace.join('|')];}
const knownOps=new Set([...String(execute).matchAll(/op==='([^']+)'/g)].map(m=>m[1]));for(const r of rows)if(r[0]!=='begin'&&!knownOps.has(r[0]))throw Error('Unknown fixture operation '+r[0]);
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot(),...frameSnapshot(),...timelineSnapshot()]);}
const sourceErrors=expected.filter(r=>['range','error'].includes(r[1])).length;if(sourceErrors!==20||Object.values(methodCalls).some(n=>n===0))throw Error('Unexpected source errors or missing method coverage');
if(!modelCoverage.WeightData||!modelCoverage.AnimationData||!modelCoverage.TimelineData||!expected.some(r=>r[1]==='range'))throw Error('Missing source coverage');
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'timelines-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'timelines-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/timelines_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'timelines-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'timelines-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('Timelines mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,sourceErrors,methodCalls,tolerance:0,floatNaNBytes:'canonicalized payload/sign only',integration:'three timeline parsers with real frame callbacks, animation models, indices, dispatch, pool and typed finalization',lua,result:'passed'};fs.writeFileSync(path.join(dir,'timelines-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
