'use strict';
// Execute genuine constraint models and dependencies, with real armature integration.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={C:'ConstraintData',I:'IKConstraintData',P:'PathConstraintData',A:'ArmatureData',B:'BoneData',S:'SurfaceData',L:'SlotData',H:'PathDisplayData',W:'WeightData'};
const baseFields=['order','name','type'];const ikFields=['scaleEnabled','bendPositive','weight'];
const pathFields=['positionMode','spacingMode','rotateMode','position','spacing','rotateOffset','rotateMix','translateMix'];
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
for(const kind of ['C','I','P'])scenario('construct-clear-and-pool-'+kind,[
 ['new','raw',kind],['set','raw','order',21],['set','raw','name','s:before'],['set','raw','type',99],['set','raw','extra','s:keep'],['clear','raw'],['string',kind],
 ['return','raw'],['borrow','again',kind],...(kind==='C'?[]:[['clear','again'],['return','again'],['return','again'],['borrow','last',kind]])]);
scenario('path-cleanup-preserves-pinned-base-type',[
 ['borrow','p','P'],['set','p','type',1],...pathFields.map((k,i)=>['set','p',k,i+0.25]),['clear','p'],['borrow','i','I'],
 ['set','i','scaleEnabled','true'],['set','i','bendPositive','true'],['set','i','weight',-12.5],['return','i'],['borrow','reuse','I']]);
scenario('references-and-bones-are-not-owned',[
 ['borrow','p','P'],['borrow','i','I'],['borrow','root','B'],['set','root','name','s:root'],['borrow','target','S'],['set','target','name','s:target'],['borrow','slot','L'],['borrow','display','H'],['borrow','weight','W'],
 ['geom','g','display'],['link','g','weight','weight'],
 ...['p','i'].flatMap(id=>[['link',id,'root','root'],['link',id,'target','target'],['link',id,'bone','root']]),
 ['link','p','pathSlot','slot'],['link','p','pathDisplayData','display'],['append','p','root'],['append','p','target'],['append','p','root'],
 ['hook','return:root','throw'],['hook','return:target','throw'],['hook','return:slot','throw'],['hook','return:display','throw'],['hook','return:weight','throw'],
 ['return','p'],['return','i'],['borrow','reuseP','P'],['borrow','reuseI','I']]);
scenario('logical-length-aliases-and-original-capitalization',[
 ['borrow','a','P'],['borrow','b','P'],['borrow','bone','B'],['append','a','bone'],['length','a',5],['append','a','bone'],['alias','b','a'],['append','b','bone'],
 ['extra','a','s:keep'],['wrongCase','a','bone'],['clear','b'],['append','a','bone'],['return','a'],['borrow','again','P']]);
scenario('push-overflow-keeps-partial-non-index-property',[
 ['borrow','p','P'],['borrow','bone','B'],['length','p',4294967295],['append','p','bone'],['clear','p'],['append','p','bone'],['clear','p']]);
scenario('invalid-array-length-does-not-reset-values',[
 ['borrow','p','P'],['borrow','bone','B'],['append','p','bone'],...['-1','0.5','NaN','Infinity','4294967296'].map(v=>['length','p',v]),['clear','p']]);
scenario('raw-path-only-initializes-bones',[
 ['new','p','P'],['borrow','bone','B'],['append','p','bone'],['clear','p'],['return','p'],['borrow','reuse','P']]);
for(const kind of ['I','P'])scenario('real-constraint-armature-order-and-cleanup-'+kind,[
 ['borrow','a','A'],['borrow','root','B'],['borrow','target','S'],['borrow','other','B'],
 ['set','root','name','s:root'],['set','target','name','s:target'],['set','other','name','s:other'],['borrow','c',kind],['set','c','name','s:constraint'],
 ['link','c','root','root'],['link','c','target','target'],['link','c','bone','other'],
 ...(kind==='P'?[['append','c','root'],['append','c','other'],['borrow','slot','L'],['borrow','display','H'],['link','c','pathSlot','slot'],['link','c','pathDisplayData','display']]:[]),
 ['addBone','a','root'],['addBone','a','other'],['addBone','a','target'],['addConstraint','a','c'],['sort','a'],['sort','a'],['return','a'],['borrow','reuse',kind]]);
scenario('duplicate-constraint-preserves-original-and-failure-state',[
 ['borrow','a','A'],['borrow','first','I'],['borrow','duplicate','P'],['set','first','name','s:same'],['set','duplicate','name','s:same'],
 ['addConstraint','a','first'],['addConstraint','a','duplicate'],['hook','return:first','throw'],['return','a'],['return','a'],['borrow','reuse','I']]);
for(const limit of [0,1,2,0.5,1.5])scenario('pool-limit-'+limit,[
 ['borrow','i1','I'],['borrow','i2','I'],['borrow','p1','P'],['borrow','p2','P'],['borrow','bone','B'],['append','p1','bone'],['limit','I',limit],['limit','P',limit],
 ['return','i1'],['return','i2'],['return','p1'],['return','p2'],['limit','I',limit],['limit','P',limit],['borrow','ri','I'],['borrow','rp','P']]);
scenario('binary64-field-preservation',[
 ['borrow','p','P'],['borrow','i','I'],
 ...['-0','5e-324','-5e-324','1.7976931348623157e308','NaN','Infinity','-Infinity'].flatMap(v=>[
  ...['order','type',...pathFields].map(k=>['set','p',k,v]),['set','i','order',v],['set','i','weight',v]]),['clear','p'],['clear','i']]);
let seed=0x434f4e53;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','p','P'],['borrow','q','P'],['borrow','i','I'],['borrow','root','B'],['borrow','target','S'],['borrow','slot','L'],['borrow','display','H']];
 for(let n=0;n<80;n++)switch(rand(8)){
  case 0:steps.push(['append',rand(2)?'p':'q',rand(2)?'root':'target']);break;
  case 1:steps.push(['length',rand(2)?'p':'q',rand(9)]);break;
  case 2:steps.push(['clear',rand(2)?'p':'q']);break;
  case 3:steps.push(['alias',rand(2)?'p':'q',rand(2)?'p':'q']);break;
  case 4:steps.push(['set','p',pathFields[rand(pathFields.length)],(rand(200)-100)/8]);break;
  case 5:steps.push(['set','i','weight',(rand(200)-100)/8]);break;
  case 6:steps.push(['link','p',rand(2)?'root':'target',rand(2)?'root':'target']);break;
  case 7:steps.push(['link','p','pathDisplayData','display']);break;
 }
 steps.push(['return','p'],['return','q'],['return','i']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='true'?true:s==='false'?false:s.startsWith('s:')?s.slice(2):Number(s);
let d,B,classes,objects,labels,log,hooks,warnings,ids,nextId;
const ref=o=>o==null?'nil':'#'+o.hashCode;
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
function begin(){objects={};labels=new Set();log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];}
function execute(row){const [op,a,b,c]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);if(!o._wrapped){o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+a);fire('return:'+a);return original.call(this);};}return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='link')objects[a][b]=objects[c];
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes[a].toString();
 else if(op==='append')objects[a].AddBone(objects[b]);
 else if(op==='wrongCase')objects[a].addBone(objects[b]);
 else if(op==='length')objects[a].bones.length=Number(b);
 else if(op==='alias')objects[a].bones=objects[b].bones;
 else if(op==='extra')objects[a].bones.extra=decode(b);
 else if(op==='addBone'||op==='addConstraint')objects[a][op](objects[b]);
 else if(op==='sort')objects[a].sortBones();
 else if(op==='geom'){objects[a]=objects[b].geometry;labels.add(a);return 'geometry:'+identity(objects[a]);}
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else throw Error('Unknown test command '+op);
 return 'void';
}
function array(a){return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+ref(a[k])).join(',')+':extra='+scalar(a.extra)+':nonIndex='+ref(a[4294967295]);}
function primitive(o){return identity(o)+':'+['x','y','rotation','skew','scaleX','scaleY'].map(k=>scalar(o[k])).join(',');}
function geometry(g){return identity(g)+':'+[scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)].join(':');}
function describe(o){if(o instanceof d.GeometryData)return 'G:'+geometry(o);const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(o instanceof classes.C){out.push(...baseFields.map(k=>scalar(o[k])),...['target','root','bone'].map(k=>ref(o[k])),scalar(o.extra));if(kind==='I')out.push(...ikFields.map(k=>scalar(o[k])));if(kind==='P')out.push(ref(o.pathSlot),ref(o.pathDisplayData),array(o.bones),...pathFields.map(k=>scalar(o[k])));}
 else if(kind==='A'){out.push(scalar(o.name),array(o.sortedBones),array(o.sortedSlots),identity(o.bones)+':'+Object.keys(o.bones).sort().map(k=>k+'='+ref(o.bones[k])).join(','),identity(o.constraints)+':'+Object.keys(o.constraints).sort().map(k=>k+'='+ref(o.constraints[k])).join(','));}
 else if(kind==='B'||kind==='S'){out.push(scalar(o.type),scalar(o.name),scalar(o.length),scalar(o.alpha),ref(o.parent),ref(o.userData),primitive(o.transform));if(kind==='S')out.push(scalar(o.segmentX),scalar(o.segmentY),geometry(o.geometry));}
 else if(kind==='L')out.push(scalar(o.name),scalar(o.alpha),ref(o.parent),ref(o.userData));
 else if(kind==='H')out.push(scalar(o.type),scalar(o.name),scalar(o.path),primitive(o.transform),geometry(o.geometry),scalar(o.closed),scalar(o.constantSpeed));
 else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones));return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'constraintdata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'constraintdata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/constraintdata_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'constraintdata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('ConstraintData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('ConstraintData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',integration:'real ArmatureData/BoneData/SurfaceData/SlotData/PathDisplayData',normalization:'object null/undefined to nil; holes/undefined by value and length',lua,result:'passed'};fs.writeFileSync(path.join(dir,'constraintdata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
