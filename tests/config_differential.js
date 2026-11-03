'use strict';
// Execute pinned AnimationConfig and BaseObject. Const enum uses are resolved
// from the genuine core namespace at compile time, without a runtime core stub.
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
const code=['core/BaseObject','model/AnimationConfig'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const fields=['pauseFadeOut','fadeOutMode','fadeOutTweenType','fadeOutTime','pauseFadeIn','actionEnabled','additive','displayControl','resetToPose','fadeInTweenType','playTimes','layer','position','duration','timeScale','weight','fadeInTime','autoFadeOutTime','name','animation','group'];
const bools=new Set(['pauseFadeOut','pauseFadeIn','actionEnabled','additive','displayControl','resetToPose']);
const strings=new Set(['name','animation','group']);
const rows=[];
function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
scenario('constructors-clear-and-pool',[
 ['new','raw'],['borrow','clean'],['string'],['append','raw','s:root'],['set','raw','extra','s:keep'],['maskExtra','raw','s:keep-mask'],
 ['clear','raw'],['clear','raw'],['return','raw'],['borrow','again'],['clear','again'],['return','again'],['return','again'],['borrow','last']]);
scenario('every-field-copy-and-distinct-destination-array',[
 ['borrow','src'],['borrow','dest'],
 ...fields.map((k,i)=>['set','src',k,bools.has(k)?'false':strings.has(k)?'s:campo-'+k:String(i+0.125)]),
 ['append','src','s:root'],['append','src','s:arm'],['append','dest','s:old'],['append','dest','s:old-tail'],['append','dest','s:extra-tail'],
 ['copy','dest','src'],['maskSet','src',0,'s:changed-source'],['maskSet','dest',1,'s:changed-dest'],['copy','src','src'],['clear','dest']]);
scenario('copy-uninitialized-fields-is-not-reset',[
 ['new','src'],['borrow','dest'],['append','dest','s:old'],['copy','dest','src'],['copy','dest','dest'],['clear','dest']]);
scenario('sparse-length-growth-shrink-and-copy',[
 ['borrow','src'],['borrow','dest'],['length','src',5],['maskSet','src',3,'s:hand'],['copy','dest','src'],
 ['maskSet','src',1,'s:spine'],['length','src',2],['copy','dest','src'],['maskDelete','src',1],['copy','dest','src'],
 ['maskSet','src',6,'s:tail'],['length','dest',12],['copy','dest','src'],['copy','src','src'],['length','src',0],['copy','dest','src']]);
scenario('aliasing-shared-mask-array',[
 ['borrow','a'],['borrow','b'],['append','a','s:root'],['append','a','s:root'],['append','a','s:'],['append','a','s:ação'],
 ['alias','b','a'],['copy','a','b'],['append','b','s:tail'],['copy','b','a'],['clear','a'],['append','b','s:rebuilt'],['return','b'],['borrow','again']]);
scenario('numeric-binary64-copy-preservation',[
 ['borrow','src'],['borrow','dest'],
 ...['-0','0.1','-0.1','5e-324','-5e-324','1.7976931348623157e308','NaN','Infinity','-Infinity','9007199254740992'].flatMap(v=>[
  ...fields.filter(k=>!bools.has(k)&&!strings.has(k)).map(k=>['set','src',k,v]),['copy','dest','src']]),['clear','dest']]);
scenario('array-length-range-and-named-properties',[
 ['borrow','a'],['append','a','s:root'],['maskExtra','a','s:persist'],
 ...['-1','0.5','NaN','Infinity','4294967296','2','-0'].map(n=>['length','a',n]),
 ['length','a',4294967295],['maskSet','a',4294967294,'s:last-index'],['length','a',4294967294],['clear','a']]);
for(const limit of ['0','1','2','0.5','1.5','NaN','-1'])scenario('pool-limit-'+limit,[
 ['borrow','a'],['borrow','b'],['append','a','s:root'],['set','a','weight','-0'],['limit',limit],['return','a'],['return','b'],
 ['limit',limit],['borrow','first'],['borrow','second'],['clearPool'],['return','a'],['borrow','third']]);
// Sources are genuine instances instrumented with getters only in the test.
// This observes read/assignment order and partial destination state on failure.
for(const failure of [0,1,3,4,10,18,21,22,23,24])scenario('getter-read-order-failure-'+failure,[
 ['borrow','src'],['borrow','dest'],...fields.map((k,i)=>['set','src',k,bools.has(k)?'false':strings.has(k)?'s:source-'+k:String(100+i)]),
 ['append','src','s:root'],['append','src','s:child'],['append','dest','s:old'],['append','dest','s:tail'],['append','dest','s:third'],
 ['reader','src',failure],['copy','dest','src']]);
let seed=0x434f4e46;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<6;s++){
 const steps=[['borrow','a'],['borrow','b'],['new','c']];
 for(let i=0;i<100;i++){
  const id=['a','b','c'][rand(3)];
  switch(rand(8)){
   case 0:{const k=fields[rand(fields.length)];steps.push(['set',id,k,bools.has(k)?(rand(2)?'true':'false'):strings.has(k)?'s:name'+rand(8):String((rand(101)-50)/8)]);break;}
   case 1:steps.push(['append',id,'s:bone'+rand(5)]);break;
   case 2:steps.push(['length',id,rand(7)]);break;
   case 3:steps.push(['maskSet',id,rand(8),'s:bone'+rand(5)]);break;
   case 4:steps.push(['maskDelete',id,rand(8)]);break;
   case 5:steps.push(['copy',id,['a','b','c'][rand(3)]]);break;
   case 6:steps.push(['clear',id]);break;
   case 7:steps.push(['alias',id,['a','b','c'][rand(3)]]);break;
  }
 }
 steps.push(['return','a'],['return','b'],['return','c'],['borrow','reused']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='undefined'?undefined:s==='true'?true:s==='false'?false:s.startsWith('s:')?s.slice(2):Number(s);
let B,C,objects,labels,warnings,readers,reads,arrayIds,nextArray;
const ref=o=>'#'+o.hashCode;
const field=(o,k)=>readers.has(o)?readers.get(o).values[k]:o[k];
function begin(){warnings=[];reads=[];readers=new WeakMap();objects={};labels=new Set();arrayIds=new WeakMap();nextArray=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);B=ctx.dragonBones.BaseObject;C=ctx.dragonBones.AnimationConfig;}
function execute(row){const [op,a,b,c]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new C():B.borrowObject(C);objects[a]=o;labels.add(a);return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='append')objects[a].boneMask.push(decode(b));
 else if(op==='maskSet')objects[a].boneMask[Number(b)]=decode(c);
 else if(op==='maskDelete')delete objects[a].boneMask[Number(b)];
 else if(op==='maskExtra')objects[a].boneMask.extra=decode(b);
 else if(op==='length')objects[a].boneMask.length=Number(b);
 else if(op==='alias')objects[a].boneMask=objects[b].boneMask;
 else if(op==='copy')objects[a].copyFrom(objects[b]);
 else if(op==='clear')objects[a].clear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='limit')B.setMaxCount(C,Number(a));
 else if(op==='clearPool')B.clearPool(C);
 else if(op==='string')return 'string:'+C.toString();
 else if(op==='reader'){
  const o=objects[a],values={};for(const k of [...fields,'boneMask'])values[k]=o[k];const state={values,count:0};readers.set(o,state);
  for(const k of [...fields,'boneMask'])Object.defineProperty(o,k,{configurable:true,get(){reads.push(a+'.'+k);if(++state.count===Number(b))throw Error('read failure');return values[k];}});
 }else throw Error('Unknown test command '+op);
 return 'void';
}
function mask(a){if(!arrayIds.has(a))arrayIds.set(a,++nextArray);return [arrayIds.get(a),scalar(a.length),
 Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+scalar(a[k])).join(','),scalar(a.extra)].join(':');}
function describe(o){return [ref(o),o._isInPool?'1':'0',...fields.map(k=>scalar(field(o,k))),scalar(o.extra),mask(field(o,'boneMask'))].join(':');}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),
 Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),
 Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),reads.join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'config-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'config-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/config_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'config-'+path.basename(lua)+'-actual.tsv'),actual);
const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Config transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('Config mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,scalarFields:fields.length,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',arrayNormalization:'holes and explicit undefined compare by value and logical length, not property descriptors',lua,result:'passed'};fs.writeFileSync(path.join(dir,'config-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
