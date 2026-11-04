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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');
const rows=[],add=(...r)=>rows.push(r.map(String)),begin=name=>add('begin',name),s=v=>'s:'+Buffer.from(v).toString('hex');
function emit(id,v){if(v!==null&&typeof v==='object'){if(Array.isArray(v)){add('array',id);for(let i=0;i<v.length;i++){if(!Object.hasOwn(v,i)){add('put',id,'length','n:'+(i+1));continue;}add('append',id,emit(id+'_'+i,v[i]));}}else{add('object',id);for(const [k,x] of Object.entries(v))add('put',id,k,emit(id+'_'+k,x));}return 'o:'+id;}if(v===null)return 'null';if(v===undefined)return 'undefined';if(typeof v==='string')return s(v);if(typeof v==='boolean')return 'b:'+v;return 'n:'+(Object.is(v,-0)?'-0':String(v));}
function start(name,rate=30){begin(name);add('cleanContext');add('setData','frameRate','n:'+rate);}
function parse(raw,scale=1,label='a'){add('parseArmature',label,emit('raw'+rows.length,raw),'n:'+scale);}
function finish(label='a'){add('registerArmature',label);add('modify');add('returnGlobal');}
const basic=()=>({name:'arm',bone:[{name:'root'},{name:'child',parent:'root'}],slot:[{name:'slot',parent:'root'}]});
const mesh=(name='mesh',weight=false)=>({name,type:'mesh',vertices:[1,2,3,4],uvs:[0,0,1,1],triangles:[0,1,0],...(weight?{weights:[1,0,.5,1,0,.75],slotPose:[1,0,0,1,10,20],bonePose:[0,1,0,0,1,3,4]}:{})});
function skin(displays,slot='slot',name='default'){return {name,slot:[{name:slot,display:displays}]};}
const anim=(name='walk')=>({name,duration:4,bone:[{name:'child',translateFrame:[{x:1,y:2,duration:2},{x:3,y:4}]}],slot:[{name:'slot',displayFrame:[{value:0},{value:1}],colorFrame:[{color:{aM:50}}]}],frame:[{event:'frame',duration:2},{sound:'sound'}]});
for(const type of [undefined,'armature','movieclip','stage',0,1,2,99])for(const rate of [0,12]){start('meta-'+type+'-'+rate);parse({name:'arm',frameRate:rate,...(type===undefined?{}:{type})},.5);finish();}
for(const scale of [0,-1,.5,2,Infinity,NaN]){start('canvas-scale-'+scale);parse({...basic(),canvas:{color:0x123456,x:1,y:-2,width:10,height:20},aabb:{x:-3,y:4,width:7,height:8}},scale);finish();}
for(const color of [undefined,null,0,Infinity]){start('canvas-color-'+color);parse({canvas:{color}});finish();}
for(const field of ['canvas','aabb','bone','ik','slot','skin','path','animation','defaultActions','actions'])for(const value of [null,undefined]){start('invalid-'+field+'-'+value);parse({[field]:value});}
start('canvas-partial');add('object','bad');add('put','bad','toString',s('bad'));add('object','canvas');add('put','canvas','x','n:2');add('put','canvas','height','o:bad');add('object','raw');add('put','raw','canvas','o:canvas');add('parseArmature','a','o:raw','n:2');
start('aabb-partial');add('object','bad');add('put','bad','toString',s('bad'));add('object','bounds');add('put','bounds','x','n:2');add('put','bounds','height','o:bad');add('object','raw');add('put','raw','aabb','o:bounds');add('parseArmature','a','o:raw','n:2');
for(const bones of [[{name:'child',parent:'root'},{name:'root'}],[{name:'leaf',parent:'mid'},{name:'mid',parent:'root'},{name:'root'}],[{name:'orphan',parent:'missing'}],[{name:'root'},{name:'root'}]]){start('parents-'+JSON.stringify(bones));parse({bone:bones});finish();}
start('ik-sorting');parse({...basic(),bone:[{name:'child',parent:'root'},{name:'target'},{name:'root'}],ik:[{name:'ik',bone:'child',target:'target',chain:0},{name:'missing',bone:'absent',target:'root'}]});finish();
start('slots-order-and-duplicates');parse({...basic(),slot:[{name:'one',parent:'root',zIndex:9},{name:'two',parent:'child',zIndex:-1},{name:'one',parent:'root'}]});finish();
start('skins-displays-actions');parse({...basic(),slot:[{name:'slot',parent:'root',displayIndex:1,actions:'walk'}],skin:[skin([null,{type:'armature',name:'child'},mesh(),{type:'boundingbox',name:'box',subType:'rectangle',width:5,height:6}])],animation:[anim()],defaultActions:'walk',actions:'walk'});finish();
for(const slot of ['','slot'])for(const weight of [false,true]){start('shared-'+slot+'-'+weight);parse({name:'shared',bone:[{name:'root'}],slot:[{name:slot,parent:'root'}],skin:[skin([{name:'copy',type:'mesh',share:'base'},mesh('base',weight),{name:'blank',type:'mesh',share:''},{name:'missing',type:'mesh',share:'absent'}],slot)]});finish();}
start('shared-link-before-animation');parse({bone:[{name:'root'},{name:'surface',type:'surface',vertices:[1,2]}],slot:[{name:'',parent:'root'}],skin:[skin([{name:'copy',type:'mesh',share:'base'},mesh('base')],'')],animation:[{name:'deform',duration:2,timeline:[{name:'copy',type:22,frame:[{vertices:[1,2,3,4]}]}]}]});finish();
start('path-after-skins');parse({...basic(),skin:[skin([{name:'path',type:'path',vertices:[0,0,1,1],lengths:[1,2]}])],path:[{name:'p',target:'slot',targetDisplay:'path',bones:['child']}]});finish();
for(const order of [['walk','run'],['run','walk']]){start('default-animation-'+order.join('-'));parse({...basic(),animation:[{name:'walk',duration:2},{name:'run',duration:3}],defaultActions:order.map(name=>({gotoAndPlay:name})),actions:[{type:'frame',name:'event'}]});finish();}
start('full-animated-armature');const a=basic();a.bone=[{name:'child',parent:'root'},{name:'root'},{name:'surface',type:'surface',vertices:[1,2,3,4],segmentX:1,segmentY:1}];a.canvas={color:0,x:1,width:20};a.aabb={x:-1,y:-2,width:20,height:30};a.ik=[{name:'ik',bone:'child',target:'root'}];a.skin=[skin([mesh('mesh',true),{name:'path',type:'path',vertices:[1,2,3,4],lengths:[2,4]}])];a.path=[{name:'path',target:'slot',targetDisplay:'path',bones:['child']}];a.animation=[{...anim(),ffd:[{slot:'slot',name:'mesh',frame:[{vertices:[1,2,3,4]}]}],ik:[{name:'ik',frame:[{weight:.5}]}],timeline:[{name:'surface',type:50,frame:[{vertices:[1,2,3,4]}]},{name:'childAnim',type:40,frame:[{value:.5}]}],blendType:'1d'}];a.defaultActions=[{gotoAndPlay:'walk'}];parse(a,2);finish();
for(const field of ['bone','slot','skin','animation']){start('failure-late-'+field);const raw=basic();raw.skin=[skin([mesh('mesh',true)])];raw[field]=field==='bone'?[{name:'child',parent:'future'},null]:field==='slot'?[{name:'slot',parent:'root',actions:'keep'},null]:field==='skin'?[skin([mesh('mesh',true)]),null]:[{name:'walk',duration:2,bone:undefined}];parse(raw);}
start('retry-preserves-then-clears-caches');parse({bone:[{name:'child',parent:'future'}],slot:null},1,'failed');parse({name:'next',bone:[{name:'other'}]},1,'a');finish();
for(const scale of [1,.25,-2]){start('two-armatures-shared-data-'+scale);parse({...basic(),name:'one',skin:[skin([mesh()])],animation:[anim()]},scale,'a');add('registerArmature','a');parse({...basic(),name:'two',skin:[skin([mesh()])],animation:[anim('run')]},scale,'b');add('registerArmature','b');add('modify');add('returnGlobal');}
start('array-like-bones');const token=emit('raw',{bone:{length:2,'0':{name:'child',parent:'root'},'1':{name:'root'}}});add('parseArmature','a',token,'n:1');finish();
start('fractional-weight-reservation');parse({...basic(),skin:[skin([{name:'bad',type:'mesh',vertices:[1,2],weights:[1,0]}])]});
let seed=0x41524d41;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<5;run++){start('deterministic-armature-'+run);const bones=Array.from({length:8},(_,i)=>({name:'b'+i,...(i?{parent:'b'+rand(i)}:{}),length:rand(50),transform:{x:rand(21)-10,y:rand(21)-10}})).reverse();const slots=Array.from({length:5},(_,i)=>({name:'s'+i,parent:'b'+rand(8),displayIndex:0,zIndex:rand(11)-5}));const raw={name:'random'+run,bone:bones,slot:slots,skin:[{name:'default',slot:slots.map(x=>({name:x.name,display:[{type:'image',name:'image'},null]}))}],animation:[{name:'anim',duration:12,bone:[{name:'b0',translateFrame:[{x:run,y:run,duration:4},{x:2,y:3}]}]}],defaultActions:'anim'};parse(raw,(run+1)/2);finish();}
const methodCalls=Object.fromEntries(['_parseArmature'].map(k=>[k,0]));
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn,failAddAction,callbackTrace,callbackFail;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;failAddAction=0;callbackTrace=[];callbackFail=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();for(const k of Object.keys(methodCalls)){const original=p[k];if(typeof original!=='function')throw Error('Missing original '+k);p[k]=function(...args){methodCalls[k]++;return original.apply(this,args);};}const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={G:d.CanvasData,O:d.AnimationTimelineData,N:d.AnimationData,T:d.TimelineData,Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='parseArmature'){objects[a]=p._parseArmature(decode(b),decode(c));return ref(objects[a]);}
 else if(op==='registerArmature')p._data.addArmature(objects[a]);
 else if(op==='setData')p._data[a]=decode(b);
 else if(op==='parseAnimation'){objects[a]=p._parseAnimation(raws[b]);return ref(objects[a]);}
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
function frameSnapshot(){return [array(p._helpArray,'value'),['_frameValueType','_frameDefaultValue','_frameValueScale','_prevClockwise','_prevRotation','_defaultColorOffset'].map(k=>scalar(p[k])).join(','),id(p._actionFrames)+':'+p._actionFrames.length+':'+p._actionFrames.map(f=>id(f)+':'+scalar(f.frameStart)+':'+array(f.actions,'value')).join('|'),p._armature==null?'nil':array(p._armature.actions),p._armature==null?'nil':array(p._armature.defaultActions),p._data==null||p._data.binary==null?'nil':observedBytes(),ref(p._bone),[p._geometry==null?'nil':geometry(p._geometry),ref(p._mesh),p._animation==null?'nil':primitive(p._animation,['frameFloatOffset','frameIntOffset']),p._timeline==null?'nil':primitive(p._timeline,['offset'])].join('|')];}
function timelineSnapshot(){const anim=p._animation;const maps=anim==null?'nil':['boneTimelines','slotTimelines'].map(k=>Object.keys(anim[k]).sort().map(n=>n+'='+array(anim[k][n])).join(',')).join('|');return [p._data==null?'nil':array(p._data.frameIndices,'value'),allocated.filter(o=>o.constructor===d.TimelineData||o.constructor===d.AnimationTimelineData).map(o=>ref(o)+':'+['type','offset','frameIndicesOffset','x','y'].map(k=>scalar(o[k])).join(',')).join('|'),anim==null?'nil':primitive(anim,['frameCount','frameOffset','frameIntOffset','frameFloatOffset']),maps,callbackTrace.join('|')];}
function animationSnapshot(){return [allocated.filter(o=>o.constructor===d.AnimationData).map(o=>ref(o)+':'+['blendType','frameCount','playTimes','duration','fadeInTime','scale','name','frameIntOffset','frameFloatOffset','frameOffset'].map(k=>scalar(o[k])).join(',')+':'+ref(o.actionTimeline)+':'+ref(o.zOrderTimeline)+':'+['boneTimelines','slotTimelines','constraintTimelines','animationTimelines'].map(k=>Object.keys(o[k]).sort().map(n=>n+'='+array(o[k][n])).join(',')).join('|')).join('~')];}
function armatureSnapshot(){return [allocated.filter(o=>o.constructor===d.ArmatureData).map(o=>ref(o)+':'+['name','frameRate','type','scale'].map(k=>scalar(o[k])).join(',')+':'+primitive(o.aabb,['x','y','width','height'])+':'+ref(o.parent)+':'+ref(o.canvas)+':'+ref(o.defaultAnimation)+':'+array(o.sortedBones)+':'+array(o.sortedSlots)+':'+array(o.animationNames,'value')+':'+['constraints','skins','animations'].map(k=>Object.keys(o[k]).sort().map(n=>n+'='+ref(o[k][n])).join(',')).join('|')+':'+array(o.defaultActions)+':'+array(o.actions)).join('~'),allocated.filter(o=>o.constructor===d.CanvasData).map(o=>ref(o)+':'+['hasBackground','color','x','y','width','height'].map(k=>scalar(o[k])).join(',')).join('|'),Object.keys(p._cacheBones).sort().map(k=>k+'='+array(p._cacheBones[k])).join('|')];}
const knownOps=new Set([...String(execute).matchAll(/op==='([^']+)'/g)].map(m=>m[1]));for(const r of rows)if(r[0]!=='begin'&&!knownOps.has(r[0]))throw Error('Unknown fixture operation '+r[0]);
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot(),...frameSnapshot(),...timelineSnapshot(),...animationSnapshot(),...armatureSnapshot()]);}
const sourceErrors=expected.filter(r=>['range','error'].includes(r[1])).length;if(sourceErrors!==24||Object.values(methodCalls).some(n=>n===0))throw Error('Unexpected source errors or missing method coverage');
if(!modelCoverage.CanvasData||!modelCoverage.WeightData||!modelCoverage.AnimationData||!modelCoverage.AnimationTimelineData||!modelCoverage.TimelineData||!expected.some(r=>r[1]==='range'))throw Error('Missing source coverage '+JSON.stringify(modelCoverage)+' range='+expected.some(r=>r[1]==='range'));
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'armatureparser-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'armatureparser-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/armatureparser_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:128*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'armatureparser-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'armatureparser-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('ArmatureParser mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,sourceErrors,methodCalls,tolerance:0,floatNaNBytes:'canonicalized payload/sign only',integration:'real _parseArmature with forward parents, canvas, constraints, skins, mesh shares, animations, actions, caches and pool',lua,result:'passed'};fs.writeFileSync(path.join(dir,'armatureparser-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
