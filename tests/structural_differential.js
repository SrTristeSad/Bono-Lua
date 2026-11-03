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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');
const rows=[],add=(...r)=>rows.push(r.map(String)),begin=name=>add('begin',name),s=v=>'s:'+Buffer.from(v).toString('hex');
const obj=(id,props={})=>{add('object',id);for(const [k,v] of Object.entries(props))add('put',id,k,v);};
const arr=(id,values=[])=>{add('array',id);for(const v of values)add('append',id,v);};
if(Buffer.from(s('ellipse😀').slice(2),'hex').toString()!=='ellipse😀')throw Error('Fixture UTF-8 transport');
function bones(){add('bone','root','root','none');add('addBone','root');add('bone','child','child','root');add('addBone','child');}
function pathSetup(kind='P'){bones();obj('slotRaw',{name:s('slot'),parent:s('root')});add('slot','slot','slotRaw',0);add('addSlot','slot');add('skin','skin','default');add('addSkin','skin');add('display','display',kind,'curve');add('addDisplay','skin','slot','display');}
begin('transform-precedence-and-retained-angles');obj('raw');add('transformSet','rotation','n:2');add('transformSet','skew','n:3');add('transform','raw','n:2');obj('old',{x:'n:2',y:'n:3',skX:'n:45',skY:'n:30',scX:'n:-2',scY:'n:0'});add('transform','old','n:0.5');add('put','old','rotate','null');add('put','old','skew','undefined');add('transform','old','n:-2');obj('bad',{toString:s('invalid')});add('put','old','scY','o:bad');add('transform','old','n:1');
for(const value of ['n:-0','n:NaN','n:Infinity','n:-Infinity','n:5e-324','n:360','n:-540','n:1e20']){begin('transform-extreme-'+value);obj('raw',{x:value,y:value,rotate:value,skew:value,scX:value,scY:value});add('transform','raw','n:-2');}
begin('colors-defaults-percentages-and-failure');obj('raw');add('color','raw');obj('color',{aM:'n:50',rM:'n:200',gM:'n:-50',bM:'n:0',aO:'n:-1',rO:'n:2',gO:'n:3',bO:'n:4'});add('color','color');obj('bad',{toString:s('blocked')});add('put','color','gM','o:bad');add('color','color');
begin('pivot-default-explicit-and-failure');add('display','image','I','image');obj('raw');add('pivot','image','raw');obj('point',{x:'n:-1',y:'n:2'});add('put','raw','pivot','o:point');add('pivot','image','raw');add('put','raw','pivot','null');add('pivot','image','raw');
for(const type of [s('rectangle'),s('ellipse'),'n:0','n:1','n:99','undefined','null']){begin('box-kind-'+type);obj('raw',{subType:type,color:'n:123',width:'n:10',height:'n:20'});add('box','box','raw');add('return','box');}
for(const values of [[],['n:2','n:3'],['n:3','n:4','n:-2','n:-1','n:8','n:5'],['n:1','n:2','n:3'],['n:1','undefined','null','n:4']]){begin('polygon-vertices-'+values.join(','));arr('verts',values);obj('raw',{subType:s('polygon'),vertices:'o:verts'});add('setArm','scale','n:2');add('box','box','raw');add('return','box');}
begin('polygon-missing-null-and-negative-scale');obj('raw',{subType:s('polygon')});add('box','missing','raw');add('put','raw','vertices','null');add('box','bad','raw');arr('verts',['n:1','n:2','n:5','n:7']);add('put','raw','vertices','o:verts');add('setArm','scale','n:-2');add('box','negative','raw');
begin('slots-default-color-actions-and-ownership');bones();obj('raw',{name:s('slot'),parent:s('child'),blendMode:s('ADD')});add('slot','one','raw',7);add('addSlot','one');obj('color',{rM:'n:25',bO:'n:10'});add('put','raw','color','o:color');add('put','raw','actions',s('walk'));add('slot','two','raw',3);add('addSlot','two');add('return','one');add('return','two');
begin('slot-null-color-fails-after-allocation');obj('raw',{name:s('partial'),color:'null'});add('slot','bad','raw',5);
begin('IK-missing-bone-target-and-chain');bones();obj('raw',{bone:s('missing'),target:s('root')});add('ik','none','raw');add('put','raw','bone',s('child'));add('put','raw','target',s('missing'));add('ik','none','raw');add('put','raw','target',s('root'));for(const chain of ['n:0','n:1','n:-1','n:NaN']){add('put','raw','chain',chain);add('ik','ik','raw');add('return','ik');}add('put','raw','bone',s('root'));add('ik','rootIK','raw');
begin('IK-raw-parent-undefined-versus-null');add('rawBone','rawBone','raw');add('addBone','rawBone');add('bone','target','target','none');add('addBone','target');obj('raw',{bone:s('raw'),target:s('target'),chain:'n:1'});add('ik','undefinedParent','raw');add('parent','rawBone','none');add('ik','nullParent','raw');
for(const kind of ['P','Y','I']){begin('path-constraint-type-'+kind);pathSetup(kind);arr('names',[s('missing'),s('child'),s('root'),s('child')]);obj('raw',{target:s('slot'),targetDisplay:s('curve'),bones:'o:names',name:s('path'),positionMode:s('FIXED'),spacingMode:s('PERCENT'),rotateMode:s('CHAINSCALE'),position:'n:2',spacing:'n:3',rotateOffset:'n:4',rotateMix:'n:0.5',translateMix:'n:0.25'});add('path','path','raw');add('return','path');}
for(const value of ['null','undefined','o:empty','o:missing','o:bad','b:false','n:3',s('child')]){begin('path-bones-'+value);pathSetup();arr('empty');arr('missing',[s('absent')]);obj('bad',{length:'n:1'});obj('raw',{target:s('slot'),targetDisplay:s('curve'),bones:value});add('path','path','raw');}
begin('path-default-skin-undefined-versus-null');add('newArm');obj('rawSlot',{name:s('slot')});add('slot','slot','rawSlot',0);add('addSlot','slot');obj('raw',{target:s('slot')});add('path','undefinedSkin','raw');add('clearArm');add('slot','slot2','rawSlot',0);add('addSlot','slot2');add('path','nullSkin','raw');
begin('actions-string-array-references-and-payload');bones();obj('slotraw',{name:s('slot'),parent:s('root')});add('slot','slot','slotraw',0);add('addSlot','slot');arr('ints',['n:1','undefined','n:3','undefined']);arr('floats',['n:-0','n:NaN','n:Infinity']);arr('strings',[s('hello'),'null',s('😀')]);obj('a',{gotoAndPlay:s('walk'),type:s('sound'),bone:s('child'),slot:s('slot'),ints:'o:ints',floats:'o:floats',strings:'o:strings'});obj('b',{type:s('frame'),name:s('event'),bone:s('missing')});arr('actions',['o:a','o:b']);add('actions','actions','o:actions',11,'root','slot');add('payloadRead','actions',0,1);add('payloadRead','actions',0,3);add('returnActions','actions');add('actions','string',s('run'),11,'root','slot');add('returnActions','string');
for(const v of ['null','undefined','n:3','b:false','o:plain','o:sparse','o:invalid','o:badPayload']){begin('action-input-'+v);obj('plain');arr('sparse',['undefined']);arr('invalid',[s('string-entry')]);obj('entry',{ints:'null'});arr('badPayload',['o:entry']);add('actions','actions',v,0,'none','none');}
begin('payload-nonobject-length');obj('entry',{ints:'b:false',floats:'n:3'});arr('actions',['o:entry']);add('actions','actions','o:actions',0,'none','none');add('returnActions','actions');
begin('payload-forof-strings-and-holes');obj('entry',{ints:s('12'),strings:s('😀x')});arr('actions',['o:entry']);add('actions','actions','o:actions',0,'none','none');add('payloadRead','actions',0,0);add('returnActions','actions');
let seed=0x53545255;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let run=0;run<4;run++){begin('deterministic-transforms-slots-'+run);bones();for(let i=0;i<35;i++){const value=(rand(4001)-2000)/17;obj('raw',{name:s('s'+i),parent:s(i%2?'child':'absent'),alpha:'n:'+value,displayIndex:'n:'+rand(6),blendMode:i%2?s('multiply'):'n:'+rand(15),x:'n:'+value,rotate:'n:'+value,skY:'n:30'});add('transform','raw','n:0.5');add('slot','s','raw',i);add('return','s');}}
let d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId,RealmArray;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v,'utf16le').toString('hex');if(typeof v==='boolean')return v?'true':'false';if(typeof v==='object')return 'object';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function register(o){if(!seen.has(o)){seen.add(o);allocated.push(o);}return o;}
function reset(){raws={};objects={};lists={};allocated=[];seen=new WeakSet();warnings=[];ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;RealmArray=vm.runInContext('Array',ctx);B=d.BaseObject;P=d.ObjectDataParser;p=new P();const borrow=B.borrowObject;B.borrowObject=function(C){return register(borrow.call(this,C));};classes={A:d.ArmatureData,B:d.BoneData,S:d.SlotData,K:d.SkinData,P:d.PathDisplayData,I:d.ImageDisplayData,R:d.RectangleBoundingBoxData,E:d.EllipseBoundingBoxData,V:d.PolygonBoundingBoxData,C:d.IKConstraintData,D:d.PathConstraintData,Q:d.ActionData,U:d.UserData};classes.Y=class extends d.PathDisplayData{};p._armature=B.borrowObject(d.ArmatureData);}
function execute(r){const [op,a,b,c,e,f]=r;
 if(op==='object')raws[a]={};else if(op==='array')raws[a]=new RealmArray();else if(op==='put')raws[a][b]=decode(c);else if(op==='append')raws[a].push(decode(b));
 else if(op==='bone'||op==='rawBone'){const o=op==='rawBone'?register(new d.BoneData()):B.borrowObject(d.BoneData);o.name=b;if(op==='bone')o.parent=objects[c]||null;objects[a]=o;}
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
const primitive=(o,keys)=>id(o)+':'+keys.map(k=>scalar(o[k])).join(',');
const transformKeys=['x','y','rotation','skew','scaleX','scaleY'],colorKeys=['alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'];
function describe(o){const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(kind==='A')out.push(scalar(o.scale),ref(o.defaultSkin),...['bones','slots','skins'].map(k=>id(o[k])+':'+Object.keys(o[k]).sort().map(n=>n+'='+ref(o[k][n])).join(',')));
 if(kind==='B')out.push(scalar(o.name),ref(o.parent));
 if(kind==='S')out.push(...['name','displayIndex','zOrder','zIndex','alpha','blendMode'].map(k=>scalar(o[k])),ref(o.parent),o.color==null?'nil':primitive(o.color,colorKeys));
 if(kind==='K')out.push(scalar(o.name),ref(o.parent),id(o.displays)+':'+Object.keys(o.displays).sort().map(k=>k+'='+array(o.displays[k])).join(','));
 if(['I','P','Y'].includes(kind)){out.push(scalar(o.name),ref(o.parent),primitive(o.transform,transformKeys));if(kind==='I')out.push(primitive(o.pivot,['x','y']));}
 if(['R','E','V'].includes(kind)){out.push(...['type','color','width','height'].map(k=>scalar(o[k])));if(kind==='V')out.push(scalar(o.x),scalar(o.y),array(o.vertices,'value'));}
 if(['C','D'].includes(kind)){out.push(...['type','name','order'].map(k=>scalar(o[k])),ref(o.root),ref(o.target),ref(o.bone));if(kind==='C')out.push(scalar(o.scaleEnabled),scalar(o.bendPositive),scalar(o.weight));else out.push(ref(o.pathSlot),ref(o.pathDisplayData),array(o.bones),...['positionMode','spacingMode','rotateMode','position','spacing','rotateOffset','rotateMix','translateMix'].map(k=>scalar(o[k])));}
 if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.bone),ref(o.slot),ref(o.data));
 if(kind==='U')out.push(...['ints','floats','strings'].map(k=>array(o[k],'value')));
 return out.join(':');}
function snapshot(){return [scalar(B._hashCode),allocated.map(describe).join('|'),Object.keys(objects).sort().map(k=>k+'='+ref(objects[k])).join('|'),Object.keys(lists).sort().map(k=>k+'='+array(lists[k])).join('|'),primitive(p._helpTransform,transformKeys),primitive(p._helpColorTransform,colorKeys),Object.keys(p._slotChildActions).sort().map(k=>k+'='+array(p._slotChildActions[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),warnings.map(w=>Buffer.from(w).toString('hex')).join('|')];}
const modelCoverage={};const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag='error';}}for(const o of allocated)modelCoverage[o.constructor.name]=true;expected.push([String(i),tag,...snapshot()]);}
for(const name of ['SlotData','IKConstraintData','PathConstraintData','EllipseBoundingBoxData','PolygonBoundingBoxData','ActionData','UserData'])if(!modelCoverage[name])throw Error('Missing positive source coverage '+name);
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'structural-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'structural-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/structural_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'structural-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('Structural mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,integration:'nine parser methods with real armature/bones/slots/skins/displays/bounding boxes/constraints/actions/userdata and pool',lua,result:'passed'};fs.writeFileSync(path.join(dir,'structural-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
