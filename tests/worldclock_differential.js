'use strict';
// Test animatables supply only callbacks/clock properties. All scheduling,
// compaction, ownership and arithmetic execute the original WorldClock.ts.
const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const ts=require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2]||'../DragonBonesJS'),lua=process.argv[3]||'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...a)=>cp.execFileSync('git',['-C',upstream,...a],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN)throw Error('Wrong upstream HEAD');
const original=ts.transpileModule(git('show',PIN+':DragonBones/src/dragonBones/animation/WorldClock.ts'),
 {compilerOptions:{target:ts.ScriptTarget.ES5},reportDiagnostics:true});
if(original.diagnostics.length)throw Error('Cannot transpile original WorldClock');
const rows=[];
function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
scenario('fields-plain-ownership-and-clear',[
 ['new','c'],['probe','p','plain'],['add','c','p'],['add','c','p'],['contains','c','p'],['clear','c'],
 ['contains','c','p'],['advance','c',0],['advance','c',0.125],['remove','c','p'],['advance','c','NaN'],
 ['advance','c',0.25],['contains','c','c'],['contains','c','none']]);
scenario('linked-ownership',[
 ['new','a',3],['new','b',5],['new','child',7],['probe','p','linked'],['add','a','p'],['owner','p','b'],
 ['contains','a','p'],['contains','b','p'],['owner','child','a'],['add','child','p'],['contains','a','p'],
 ['owner','child','b'],['owner','child','b'],['owner','child','none'],['remove','child','p'],['owner','p','none']]);
scenario('holes-and-callback-mutation',[
 ['new','c'],...Array.from({length:6},(_,i)=>['probe','p'+i,'linked']),
 ...Array.from({length:5},(_,i)=>['add','c','p'+i]),['remove','c','p1'],['remove','c','p3'],
 ['hook','p0','add','c','p5'],['hook','p2','remove','c','p4'],['hook','p2','add','c','p1'],['hook','p2','remove','c','p2'],
 ['advance','c',0.25],['advance','c',0.125],['add','c','p4'],['hook','p5','clear','c'],
 ['advance','c',0.5],['advance','c',1]]);
scenario('partial-compaction-on-callback-error',[
 ['new','c'],['probe','a','linked'],['probe','b','linked'],['probe','d','plain'],
 ['add','c','a'],['add','c','b'],['add','c','d'],['remove','c','a'],['hook','b','throw'],
 ['now',1700000000123],['advance','c',0.25],['advance','c',0.125],['clear','c'],['advance','c',0.25]]);
scenario('reentrant-and-added-clock',[
 ['new','root'],['new','child'],['probe','a','plain'],['probe','b','linked'],['probe','nested','linked'],
 ['add','root','a'],['add','root','b'],['add','child','nested'],['hook','a','advance','root',0.25],
 ['hook','b','owner','child','root'],['advance','root',0.5],['advance','root',0.125]]);
scenario('strict-object-identity',[
 ['new','c'],['probe','a','equal'],['probe','b','equal'],['add','c','a'],['add','c','b'],
 ['contains','c','a'],['contains','c','b'],['advance','c',0.125],['remove','c','b'],['advance','c',0.25]]);
scenario('reentrant-shrink-and-undefined-slots',[
 ['new','c'],...Array.from({length:5},(_,i)=>['probe','p'+i,'linked']),
 ...Array.from({length:5},(_,i)=>['add','c','p'+i]),
 ['remove','c','p0'],['remove','c','p1'],['remove','c','p2'],['hook','p3','advance','c',0.25],
 ['advance','c',0.5],['contains','c','p4'],['clear','c'],['advance','c',0.125]]);
scenario('reentrant-negative-array-length-error',[
 ['new','c'],['probe','a','linked'],['probe','b','linked'],['probe','d','linked'],
 ['add','c','a'],['add','c','b'],['add','c','d'],['remove','c','a'],['remove','c','b'],
 ['hook','d','clear','c'],['hook','d','advance','c',0.25],['advance','c',0.5],['advance','c',0.125]]);
scenario('finite-cycle-observation-only',[
 ['new','a'],['new','b'],['owner','a','a'],['contains','a','a'],['owner','a','none'],
 ['owner','a','b'],['owner','b','a'],['contains','a','b'],['contains','b','a'],['owner','a','none'],['advance','a',0.125]]);
scenario('wall-provider-errors',[
 ['new','c'],['probe','p','plain'],['add','c','p'],['fault','true'],['advance','c','NaN'],['new','bad'],
 ['fault','false'],['now',1700000000456],['advance','c',0],['advance','c',-1]]);
for(const scale of ['-2','-0','0','0.5','1','2','NaN','Infinity','-Infinity'])scenario('nested-scale-'+scale,[
 ['new','root',-2],['new','child',10],['probe','p','plain'],['probe','q','linked'],['owner','child','root'],
 ['add','root','p'],['add','child','q'],['scale','root',scale],['scale','child',0.5],
 ['now',1700000000123],['advance','root',0.125],['now',1700000000250],['advance','root',-1],
 ['now',1699999999999],['advance','root',-3],['advance','root','NaN'],['advance','root','Infinity'],['advance','root','-Infinity']]);
scenario('callback-time-and-scale-change',[
 ['now',1700000000001],['new','c',1],['probe','a','plain'],['probe','b','linked'],['add','c','a'],['add','c','b'],
 ['hook','a','scale','c',8],['hook','a','now',1700000000789],['advance','c',0.125],['advance','c',-1],
 ['scale','c',1],['now',1700000000790],['advance','c',-1]]);
let seed=0x434c4f43;
const random=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<8;s++){
 const steps=[['new','c0'],['new','c1'],['new','c2'],['owner','c1','c0'],['owner','c2','c0'],
  ...Array.from({length:6},(_,i)=>['probe','p'+i,i%2?'linked':'plain'])];let now=1700000000000;
 for(let i=0;i<100;i++){
  const c='c'+random(3),p='p'+random(6);
  switch(random(8)){
   case 0:steps.push(['add',c,p]);break;
   case 1:steps.push(['remove',c,p]);break;
   case 2:steps.push(['owner',p,random(4)?c:'none']);break;
   case 3:steps.push(['contains',c,p]);break;
   case 4:steps.push(['scale',c,['-2','0','0.5','1','2','NaN'][random(6)]]);break;
   case 5:steps.push(['clear',c]);break;
   case 6:now+=random(41)-10;steps.push(['now',now],['advance',c,['0','-0','0.125','1','-1','NaN'][random(6)]]);break;
   case 7:steps.push(['hook',p,'remove',c,p]);break;
  }
 }
 scenario('deterministic-'+s,steps);
}
const number=s=>s==='undefined'?undefined:Number(s);
function scalar(n){if(Number.isNaN(n))return 'NaN';const bytes=Buffer.alloc(8);bytes.writeDoubleLE(n);return bytes.toString('hex');}
let Clock,objects,ids,hooks,log,nowMs,reads,fault;
function begin(){
 objects={};ids=new WeakMap();hooks={};log=[];nowMs=1700000000000;reads=0;fault=false;
 class HostDate {constructor(){reads++;if(fault)throw Error('host time');this.ms=nowMs;}getTime(){return this.ms;}
  static now(){reads++;if(fault)throw Error('host time');return nowMs;}}
 const context=vm.createContext({Date:HostDate});vm.runInContext(original.outputText,context);Clock=context.dragonBones.WorldClock;
}
const ref=o=>o==null?'null':ids.get(o)||'unknown';
function probe(id,kind){
 const p={kind,calls:[],clock:null,_clock:null};
 if(kind==='linked')Object.defineProperty(p,'clock',{get(){return this._clock;},set(value){
  if(this._clock===value)return;if(this._clock!==null)this._clock.remove(this);this._clock=value;if(value!==null)value.add(this);
 }});
 if(kind==='equal')p.valueOf=()=>1; // JS strict identity ignores coercion.
 p.advanceTime=dt=>{p.calls.push(dt);log.push(id+':'+scalar(dt));const actions=hooks[id]||[];hooks[id]=[];
  for(const action of actions)execute(action);};
 return p;
}
function execute(row){
 const [op,a,b,...rest]=row;
 if(op==='new'){const c=new Clock(b===undefined?undefined:number(b));objects[a]=c;ids.set(c,a);return 'clock:'+a;}
 if(op==='probe'){const p=probe(a,b);objects[a]=p;ids.set(p,a);hooks[a]=[];return 'probe:'+a;}
 if(op==='now'){nowMs=number(a);return 'void';}
 if(op==='fault'){fault=a==='true';return 'void';}
 if(op==='throw')throw Error('probe callback');
 if(op==='hook'){(hooks[a]||(hooks[a]=[])).push([b,...rest]);return 'void';}
 const obj=objects[a],value=b==='none'?null:objects[b];let result;
 if(op==='scale')obj.timeScale=number(b);
 else if(op==='owner')obj.clock=value;
 else if(op==='add')result=obj.add(value);
 else if(op==='remove')result=obj.remove(value);
 else if(op==='clear')result=obj.clear();
 else if(op==='contains')result=obj.contains(value);
 else if(op==='advance')result=obj.advanceTime(number(b));
 else throw Error('Unknown command '+op);
 if(typeof result==='boolean')return result?'true':'false';
 if(result!==undefined)throw Error('Unexpected method return');return 'void';
}
function snapshot(){return [scalar(nowMs),String(reads),fault?'1':'0',Object.keys(objects).sort().map(id=>{
 const o=objects[id];return o instanceof Clock?[id,'clock',scalar(o.time),scalar(o.timeScale),scalar(o._systemTime),ref(o.clock),String(o._animatebles.length),
 Array.from({length:o._animatebles.length},(_,i)=>o._animatebles[i]===undefined?'undefined':ref(o._animatebles[i])).join(',')].join(':'):
 [id,o.kind,ref(o.clock),o.calls.map(scalar).join(','),(hooks[id]||[]).length].join(':');}).join('|'),log.join('|')];}
const expected=[];
for(let i=0;i<rows.length;i++){
 let tag='void';if(rows[i][0]==='begin')begin();else{
  log=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range-error':e.message==='probe callback'?'callback-error':e.message==='host time'?'host-error':'error';}
 }expected.push([String(i),tag,...snapshot()]);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});
const input=path.join(dir,'worldclock-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');
fs.writeFileSync(path.join(dir,'worldclock-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const output=cp.execFileSync(lua,['tests/worldclock_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024});
fs.writeFileSync(path.join(dir,'worldclock-'+path.basename(lua)+'-actual.tsv'),output);
const actual=output.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));
if(actual.length!==expected.length)throw Error('Transcript length differs');let columns=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){
 columns++;if(actual[i][j]!==expected[i][j])throw Error('Clock mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+actual[i][j]);
}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:columns,
 tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',timeSource:'deterministic Date milliseconds converted to epoch seconds',lua,result:'passed'};
fs.writeFileSync(path.join(dir,'worldclock-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
