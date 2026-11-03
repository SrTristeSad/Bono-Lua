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
const special=(name,raw='o:raw',start=0,count=1)=>add('special',name,raw,start,count);
function context(n=3){add('bone','root','root','none');add('addBone','root');for(let i=0;i<n;i++){obj('slotraw',{name:s('slot'+i),parent:s('root')});add('slot','slot'+i,'slotraw',i);add('addSlot','slot'+i);}add('frameContext','root',n?'slot0':'none');}
for(const name of ['BoneAll','BoneTranslate','BoneRotate','BoneScale','SlotDisplay','SlotColor','IKConstraint','ZOrder']){begin('defaults-'+name);context();obj('raw');special(name);special(name,'o:raw',1,0);add('serializeActions');add('modify');}
for(const name of ['BoneAll','BoneRotate'])for(const cw of [-3,-1,0,1,3,NaN,Infinity,-Infinity]){begin('rotation-sequence-'+name+'-'+cw);context();add('previous','n:'+cw,'n:1.25');for(const [j,angle] of [-720,-180,-179,0,179,180,181,720].entries()){obj('transform',{x:'n:2',y:'n:-3',rotate:'n:'+angle,skew:'n:-30',scX:'n:2',scY:'n:0.5'});obj('raw',{transform:'o:transform',rotate:'n:'+angle,skew:'n:15',clockwise:'n:'+cw,tweenRotate:'n:'+cw,tweenEasing:'n:0',event:s('event'+j)});special(name,'o:raw',j,j%3);}add('serializeActions');add('modify');add('linkGlobal');add('returnGlobal');}
for(const angle of ['n:-0','n:NaN','n:Infinity','n:-Infinity','n:0.5','n:180','n:-180']){begin('rotation-extremes-'+angle);context();obj('transform',{rotate:angle,skew:angle});obj('raw',{rotate:angle,skew:angle,transform:'o:transform'});special('BoneRotate','o:raw',0,1);special('BoneAll','o:raw',1,1);add('modify');}
for(const name of ['BoneTranslate','BoneScale'])for(const value of ['absent','null','undefined','n:-0','n:NaN','n:Infinity','n:-Infinity','b:false',s('-2.5')]){begin('values-'+name+'-'+value);obj('raw',value==='absent'?{}:{x:value,y:'n:-0.5',tweenEasing:'n:0.5'});special(name);add('modify');}
for(const name of ['BoneAll','BoneTranslate','BoneRotate','BoneScale','SlotDisplay','SlotColor','IKConstraint','ZOrder']){begin('null-raw-'+name);context();special(name,'null');}
for(const name of ['BoneTranslate','BoneScale','BoneRotate','BoneAll','IKConstraint']){begin('partial-value-'+name);context();obj('blocked',{toString:s('blocked')});obj('transform',{x:'n:2',scY:'o:blocked'});obj('raw',{x:'n:2',y:'o:blocked',rotate:'n:45',skew:'o:blocked',clockwise:'n:2',tweenRotate:'n:2',transform:'o:transform',weight:'o:blocked'});special(name,'o:raw',1,1);add('modify');}
for(const name of ['BoneAll','BoneRotate']){begin('rotation-state-before-tween-error-'+name);context();add('previous','n:3','n:0');obj('transform',{rotate:'n:90'});obj('raw',{transform:'o:transform',rotate:'n:90',clockwise:'n:-2',tweenRotate:'n:-2',curve:'null'});special(name,'o:raw',1,4);}
for(const value of ['absent','null','undefined','n:-1','n:3','n:-0',s('2')]){begin('display-precedence-'+value);context();obj('raw',value==='absent'?{displayIndex:'n:5',event:s('changed')}:{value,displayIndex:'n:5',event:s('changed')});special('SlotDisplay');add('serializeActions');add('modify');}
begin('display-missing-slot-keeps-frame');obj('raw',{value:'n:7',event:s('event')});special('SlotDisplay');add('modify');
begin('display-actions-partial-error');context();arr('bad',['null']);obj('raw',{value:'n:2',event:s('kept'),sound:'o:bad'});special('SlotDisplay');add('serializeActions');add('modify');
const colorCases=[{}, {aM:'n:50',rM:'n:25',gM:'n:75',bM:'n:100',aO:'n:-0.5',rO:'n:0.5',gO:'n:65536',bO:'n:-32769'}, {unknown:'n:1'}, {aM:'n:-0.5',rM:'n:Infinity',gM:'n:NaN',bM:'undefined',aO:'n:Infinity',rO:'n:-Infinity',gO:'null',bO:s('-0.5')}];
for(let i=0;i<colorCases.length;i++){begin('colors-'+i);obj('color',colorCases[i]);obj('raw',{color:'o:color'});special('SlotColor');special('SlotColor','o:raw',1,0);obj('empty');special('SlotColor','o:empty',2,1);special('SlotColor','o:empty',3,1);add('modify');special('SlotColor','o:empty',4,1);add('modify');}
for(const value of ['null','undefined','b:false','n:3',s(''),s('x')]){begin('color-primitive-'+value);obj('raw',{value,color:'null'});special('SlotColor');add('modify');}
for(const values of [[],['hole'],['undefined'],['n:1']]){begin('color-array-'+values.join(','));arr('color',values);obj('raw',{color:'o:color'});special('SlotColor');add('modify');}
begin('color-value-precedence-and-default-reuse');obj('color',{aM:'n:25'});obj('raw',{value:'null',color:'o:color'});special('SlotColor');obj('raw',{value:'o:color',color:'null'});special('SlotColor','o:raw',1,1);obj('raw',{value:'undefined',color:'o:color'});special('SlotColor','o:raw',2,1);add('modify');
begin('color-transform-partial-error');obj('blocked',{toString:s('blocked')});obj('color',{aM:'n:50',rM:'n:25',gO:'o:blocked'});obj('raw',{color:'o:color'});special('SlotColor');obj('raw');special('SlotColor','o:raw',1,1);add('modify');
for(const bend of ['absent','b:false','b:true','n:0','n:1','null','undefined',s('false'),s('0'),s('yes')])for(const weight of ['absent','n:-0.005','n:0.005','n:1.5','null','undefined','n:Infinity']){begin('ik-'+bend+'-'+weight);const props={};if(bend!=='absent')props.bendPositive=bend;if(weight!=='absent')props.weight=weight;obj('raw',props);special('IKConstraint');add('modify');}
const orders=[[],['n:0','n:2'],['n:2','n:-2'],['n:0','n:1','n:2','n:-1'],['n:1','n:0'],['n:0','n:9'],['n:0','n:-1'],['n:0','n:0.5'],['n:0','undefined'],['n:0','null'],['n:0',s('1')],['n:1',s('1')],['n:0'],['n:0','n:1','n:2']];
for(const order of orders){begin('zorder-'+order.join(','));context(3);arr('order',order);obj('raw',{zOrder:'o:order'});special('ZOrder');add('modify');}
for(const value of ['null','undefined','n:0','b:false']){begin('zorder-primitive-'+value);context(2);obj('raw',{zOrder:value});special('ZOrder');}
for(const n of [0,1,2,5]){begin('zorder-slot-count-'+n);context(n);arr('order',n?['n:0','n:0']:[]);obj('raw',{zOrder:'o:order'});special('ZOrder');add('modify');}
for(const name of ['BoneAll','BoneTranslate','BoneRotate','BoneScale','SlotDisplay','SlotColor','IKConstraint','ZOrder'])for(const target of ['_frameArray',name==='SlotColor'?'_colorArray':name==='IKConstraint'?'_frameIntArray':'_frameFloatArray']){begin('overflow-'+name+'-'+target);context();add('workLength',target,4294967295);obj('raw');special(name);add('resetArrays');}
begin('overflow-explicit-color-keeps-cache-unset');add('workLength','_colorArray',4294967295);obj('color',{aM:'n:50'});obj('raw',{color:'o:color'});special('SlotColor');add('resetArrays');
begin('bone-all-actions-after-floats');context();arr('payload',['n:1','hole']);obj('action',{name:s('event'),ints:'o:payload'});arr('actions',['o:action']);arr('bad',['null']);obj('raw',{events:'o:actions',actions:'o:bad'});special('BoneAll');add('serializeActions');add('modify');add('returnArm');
let seed=0x53504543;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<4;run++){begin('deterministic-specials-'+run);context(4);for(let j=0;j<32;j++){const name=['BoneAll','BoneTranslate','BoneRotate','BoneScale','SlotDisplay','SlotColor','IKConstraint'][rand(7)];obj('transform',{x:'n:'+((rand(1001)-500)/4),rotate:'n:'+(rand(1081)-540),scX:'n:'+(rand(30)/10)});obj('color',{aM:'n:'+rand(201),rO:'n:'+(rand(101)-50)});obj('raw',{transform:'o:transform',x:'n:'+rand(100),y:'n:'+(rand(100)-50),rotate:'n:'+(rand(1081)-540),clockwise:'n:'+(rand(5)-2),tweenRotate:'n:'+(rand(5)-2),color:'o:color',weight:'n:'+(rand(201)/100),displayIndex:'n:'+(rand(5)-1),tweenEasing:'n:'+((rand(301)-150)/100)});special(name,'o:raw',j,rand(4));}add('serializeActions');add('modify');}
const methodCalls=Object.fromEntries(['_parseZOrderFrame','_parseBoneAllFrame','_parseBoneTranslateFrame','_parseBoneRotateFrame','_parseBoneScaleFrame','_parseSlotDisplayFrame','_parseSlotColorFrame','_parseIKConstraintFrame'].map(k=>[k,0]));
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray,failReturn,failAddAction;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);const original=o.returnToPool;o.returnToPool=function(){if(failReturn&&this.constructor===classes[failReturn]){failReturn=null;throw Error('return failure');}return original.call(this);};}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;failReturn=null;failAddAction=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();for(const k of Object.keys(methodCalls)){const original=p[k];if(typeof original!=='function')throw Error('Missing original '+k);p[k]=function(...args){methodCalls[k]++;return original.apply(this,args);};}const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={Z:d.DragonBonesData,F:d.SurfaceData,M:d.MeshDisplayData,H:d.ArmatureDisplayData,J:d.BoundingBoxDisplayData,W:d.WeightData,A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);p._data=B.borrowObject(d.DragonBonesData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='special')return scalar(p['_parse'+a+'Frame'](decode(b),num(c),num(e)));
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
function frameSnapshot(){return [array(p._helpArray,'value'),['_frameValueType','_frameDefaultValue','_frameValueScale','_prevClockwise','_prevRotation','_defaultColorOffset'].map(k=>scalar(p[k])).join(','),id(p._actionFrames)+':'+p._actionFrames.length+':'+p._actionFrames.map(f=>id(f)+':'+scalar(f.frameStart)+':'+array(f.actions,'value')).join('|'),array(p._armature.actions),array(p._armature.defaultActions),p._data.binary==null?'nil':observedBytes(),ref(p._bone)];}
const knownOps=new Set([...String(execute).matchAll(/op==='([^']+)'/g)].map(m=>m[1]));for(const r of rows)if(r[0]!=='begin'&&!knownOps.has(r[0]))throw Error('Unknown fixture operation '+r[0]);
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot(),...frameSnapshot()]);}
const sourceErrors=expected.filter(r=>['range','error'].includes(r[1])).length;if(sourceErrors!==39||Object.values(methodCalls).some(n=>n===0))throw Error('Unexpected source errors or missing method coverage');
if(!modelCoverage.ActionData||!modelCoverage.UserData||!expected.some(r=>r[1]==='range'))throw Error('Missing source coverage');
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'specialframes-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'specialframes-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
let actual;try{actual=cp.execFileSync(lua,['tests/specialframes_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});}catch(e){if(typeof e.stdout==='string')fs.writeFileSync(path.join(dir,'specialframes-failed-partial.tsv'),e.stdout);throw Error('Lua execution failed: '+String(e.stderr||e.message).slice(-1600));}fs.writeFileSync(path.join(dir,'specialframes-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('SpecialFrames mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,sourceErrors,methodCalls,tolerance:0,floatNaNBytes:'canonicalized payload/sign only',integration:'eight specialized frame serializers with real models, transforms, actions, typed finalization and pool',lua,result:'passed'};fs.writeFileSync(path.join(dir,'specialframes-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
