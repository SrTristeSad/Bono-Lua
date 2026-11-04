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

function init(weight=false){context();add('addSkin','skin');if(weight)weighted('geo');else verts('geo');add('display','mesh','M','mesh');add('mesh','mesh','geo');add('addDisplay','skin','slot','mesh');verts('surface');add('put','surface','type','n:1');add('put','surface','name',s('surface'));add('parseBone','surface','surface');add('addBone','surface');obj('sameSlot',{name:s('b0'),parent:s('b0')});add('slot','sameSlot','sameSlot',1);add('addSlot','sameSlot');add('newConstraint');add('setArm','frameRate','n:24');add('cleanContext');for(const [name,v] of [['_frameArray',11],['_frameIntArray',13],['_frameFloatArray',17],['_timelineArray',19]])add('workPut',name,0,'n:'+v);add('indicesPrefix',1);}
const parse=(id='a',raw='raw')=>add('parseAnimation',id,raw);
const makeFrames=(count=2,color=false)=>{arr('dv',['n:1','n:2','n:3','n:4']);obj('color',{aM:'n:50',rO:'n:-0.5'});for(let i=0;i<count;i++)obj('f'+i,{duration:'n:'+(i+1),x:'n:'+(i+.5),y:'n:'+(-i-.5),...(color?{color:'o:color'}:{value:'n:'+(i+.25)}),rotate:'n:'+(i*90),skew:'n:15',clockwise:'n:1',tweenRotate:'n:-1',vertices:'o:dv'});arr('frames',Array.from({length:count},(_,i)=>'o:f'+i));};
for(const props of [{},{name:s('')},{name:'null',duration:'n:4',playTimes:'n:0',fadeInTime:'n:0.5',scale:'n:2',blendType:s('1d')},{duration:'undefined',playTimes:'null',scale:'n:-0'},{duration:'n:-1',fadeInTime:'n:Infinity'},{duration:s('NaN'),blendType:s('unknown')}]){begin('metadata-'+JSON.stringify(props));init();obj('raw',props);parse();add('registerAnimation','a');add('modify');add('returnArm');}
for(const rate of ['n:0','n:-0','n:12','n:-24','n:Infinity']){begin('frame-rate-'+rate);init();add('setArm','frameRate',rate);obj('raw',{duration:'n:4'});parse();}
const kinds=[0,1,10,11,12,13,20,21,22,23,24,30,40,41,42,50,60,999];
const nameFor=k=>k===50?'surface':k===22?'mesh':[10,11,12,13,60].includes(k)?'b0':[20,21,23,24].includes(k)?'slot':k===30?'ik':'child';
for(const kind of kinds)for(const blend of ['none','1d'])for(const count of [0,1,3]){begin('generic-'+kind+'-'+blend+'-'+count);init(kind===22);makeFrames(count,kind===21);obj('tl',{type:'n:'+kind,name:s(nameFor(kind)),frame:'o:frames',x:'n:0.25',y:'n:-0.5'});arr('tls',['o:tl']);obj('raw',{duration:'n:7',blendType:s(blend),timeline:'o:tls'});parse();add('registerAnimation','a');add('modify');add('returnArm');}
begin('legacy-all-and-modern-order');init(true);makeFrames();add('put','f0','event',s('event'));add('put','f1','sound',s('sound'));obj('bt',{name:s('b0'),translateFrame:'o:frames',rotateFrame:'o:frames',scaleFrame:'o:frames',frame:'o:frames'});obj('st',{name:s('slot'),frame:'o:frames'});obj('ffd',{skin:s(''),slot:s('slot'),name:s('mesh'),frame:'o:frames'});obj('ik',{name:s('ik'),frame:'o:frames'});obj('z',{frame:'o:frames'});for(const [id,entry] of [['bones','bt'],['slots','st'],['ffds','ffd'],['iks','ik']])arr(id,['o:'+entry]);obj('mt',{type:'n:60',name:s('b0'),frame:'o:frames'});arr('tls',['o:mt']);obj('raw',{duration:'n:8',frame:'o:frames',zOrder:'o:z',bone:'o:bones',slot:'o:slots',ffd:'o:ffds',ik:'o:iks',timeline:'o:tls'});parse();add('registerAnimation','a');add('modify');add('linkGlobal');add('returnGlobal');
for(const field of ['frame','zOrder','bone','slot','ffd','ik','timeline'])for(const value of ['null','undefined','b:false','n:3']){begin('invalid-'+field+'-'+value);init();obj('raw',{duration:'n:4',[field]:value});parse();}
for(const field of ['blendType','duration','name']){begin('metadata-error-'+field);init();obj('bad',{toString:s('bad')});obj('raw',{[field]:'o:bad'});parse();}
for(const missing of ['slot','mesh','skin']){begin('ffd-missing-'+missing);init();makeFrames();obj('ffd',{slot:s(missing==='slot'?'missing':'slot'),skin:s(missing==='skin'?'missing':'default'),name:s(missing==='mesh'?'missing':'mesh'),frame:'o:frames'});arr('ffds',['o:ffd']);obj('raw',{duration:'n:5',ffd:'o:ffds'});parse();}
for(const kind of [50,22])for(const name of ['missing','b0']){begin('generic-geometry-'+kind+'-'+name);init();makeFrames();obj('tl',{type:'n:'+kind,name:s(name),frame:'o:frames'});arr('tls',['o:tl']);obj('raw',{duration:'n:5',timeline:'o:tls'});parse();}
begin('mesh-scan-last-match-and-key-order');init();for(const skinName of ['2','1']){add('skin','s'+skinName,skinName);add('addSkin','s'+skinName);verts('g'+skinName,['n:1','n:2','n:3','n:4','n:5','n:6']);add('display','m'+skinName,'M','mesh');add('geo','m'+skinName,'g'+skinName);add('addDisplay','s'+skinName,'slot','m'+skinName);}add('nullDisplay','skin','slot');verts('last',['n:1','n:2','n:3','n:4','n:5','n:6','n:7','n:8']);add('display','last','M','mesh');add('geo','last','last');add('addDisplay','skin','b0','last');makeFrames();obj('tl',{type:'n:22',name:s('mesh'),frame:'o:frames'});arr('tls',['o:tl']);obj('raw',{duration:'n:6',timeline:'o:tls'});parse();add('modify');
begin('undefined-display-error');init();add('undefinedDisplay','skin','slot');makeFrames();obj('tl',{type:'n:22',name:s('missing'),frame:'o:frames'});arr('tls',['o:tl']);obj('raw',{duration:'n:4',timeline:'o:tls'});parse();
begin('blend-timeline-partial-error');init();obj('bad',{toString:s('bad')});makeFrames(1);obj('tl',{type:'n:40',name:s('child'),x:'n:2',y:'o:bad',frame:'o:frames'});arr('tls',['o:tl']);obj('raw',{duration:'n:4',blendType:s('1d'),timeline:'o:tls'});parse();
begin('action-clear-before-modern-failure');init();makeFrames();add('put','f0','event',s('event'));obj('raw',{duration:'n:4',frame:'o:frames',timeline:'undefined'});parse();obj('raw',{duration:'n:3'});parse('b');add('modify');
begin('actions-retained-after-legacy-failure');init();makeFrames();add('put','f0','event',s('event'));obj('raw',{duration:'n:4',frame:'o:frames',bone:'undefined'});parse();obj('raw',{duration:'n:3'});parse('b');add('modify');
for(const target of ['_timelineArray','_frameArray','_frameIntArray','_frameFloatArray','indices']){begin('overflow-'+target);init();makeFrames();obj('tl',{type:'n:'+ (target==='_frameIntArray'?60:11),name:s('b0'),frame:'o:frames'});arr('tls',['o:tl']);obj('raw',{duration:'n:4',timeline:'o:tls'});if(target==='indices')add('indicesLength',4294967295);else add('workLength',target,4294967295);parse();add('resetArrays');add('indicesLength',0);}
let seed=0x414e494d;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<4;run++){begin('deterministic-animation-'+run);init();for(let j=0;j<6;j++){const n=1+rand(4);makeFrames(n);const types=[11,12,13,20,21,22,23,24,30,40,41,42,50,60];arr('tls');for(let k=0;k<8;k++){const type=types[rand(types.length)];obj('tl'+k,{type:'n:'+type,name:s(nameFor(type)),frame:'o:frames'});add('append','tls','o:tl'+k);}obj('raw',{name:s('anim'+j),duration:'n:12',blendType:s(j%2?'1d':'none'),timeline:'o:tls'});parse('a'+j);add('registerAnimation','a'+j);}add('modify');add('returnArm');}
const methodCalls=Object.fromEntries(['_parseAnimation'].map(k=>[k,0]));
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn,failAddAction,callbackTrace,callbackFail;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;failAddAction=0;callbackTrace=[];callbackFail=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();for(const k of Object.keys(methodCalls)){const original=p[k];if(typeof original!=='function')throw Error('Missing original '+k);p[k]=function(...args){methodCalls[k]++;return original.apply(this,args);};}const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={O:d.AnimationTimelineData,N:d.AnimationData,T:d.TimelineData,Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='parseAnimation'){objects[a]=p._parseAnimation(raws[b]);return ref(objects[a]);}
 else if(op==='registerAnimation')p._armature.addAnimation(objects[a]);
 else if(op==='newConstraint'){const o=B.borrowObject(d.IKConstraintData);o.name='ik';p._armature.addConstraint(o);}
 else if(op==='cleanContext'){for(const k of ['_animation','_timeline','_slot','_skin','_mesh','_geometry'])p[k]=null;}
 else if(op==='nullDisplay')objects[a].addDisplay(b,null);
 else if(op==='undefinedDisplay')objects[a].displays[b].push(undefined);
 else if(op==='animationSpec'){p._animation.frameCount=num(a);p._animation.frameOffset=num(b);}
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
function timelineSnapshot(){const anim=p._animation;const maps=anim==null?'nil':['boneTimelines','slotTimelines'].map(k=>Object.keys(anim[k]).sort().map(n=>n+'='+array(anim[k][n])).join(',')).join('|');return [p._data==null?'nil':array(p._data.frameIndices,'value'),allocated.filter(o=>o.constructor===d.TimelineData||o.constructor===d.AnimationTimelineData).map(o=>ref(o)+':'+['type','offset','frameIndicesOffset','x','y'].map(k=>scalar(o[k])).join(',')).join('|'),anim==null?'nil':primitive(anim,['frameCount','frameOffset','frameIntOffset','frameFloatOffset']),maps,callbackTrace.join('|')];}
function animationSnapshot(){return [allocated.filter(o=>o.constructor===d.AnimationData).map(o=>ref(o)+':'+['blendType','frameCount','playTimes','duration','fadeInTime','scale','name','frameIntOffset','frameFloatOffset','frameOffset'].map(k=>scalar(o[k])).join(',')+':'+ref(o.actionTimeline)+':'+ref(o.zOrderTimeline)+':'+['boneTimelines','slotTimelines','constraintTimelines','animationTimelines'].map(k=>Object.keys(o[k]).sort().map(n=>n+'='+array(o[k][n])).join(',')).join('|')).join('~')];}
const knownOps=new Set([...String(execute).matchAll(/op==='([^']+)'/g)].map(m=>m[1]));for(const r of rows)if(r[0]!=='begin'&&!knownOps.has(r[0]))throw Error('Unknown fixture operation '+r[0]);
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot(),...frameSnapshot(),...timelineSnapshot(),...animationSnapshot()]);}
const sourceErrors=expected.filter(r=>['range','error'].includes(r[1])).length;if(sourceErrors!==28||Object.values(methodCalls).some(n=>n===0))throw Error('Unexpected source errors or missing method coverage');
if(!modelCoverage.WeightData||!modelCoverage.AnimationData||!modelCoverage.AnimationTimelineData||!modelCoverage.TimelineData||!expected.some(r=>r[1]==='range'))throw Error('Missing source coverage');
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'animationparser-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'animationparser-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/animationparser_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:128*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'animationparser-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'animationparser-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('AnimationParser mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,sourceErrors,methodCalls,tolerance:0,floatNaNBytes:'canonicalized payload/sign only',integration:'real _parseAnimation with all legacy/modern timeline branches, models, frames, maps, pool and typed finalization',lua,result:'passed'};fs.writeFileSync(path.join(dir,'animationparser-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
