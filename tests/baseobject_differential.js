'use strict';
// Test subclasses implement only _onClear probes; the pool algorithm is the
// genuine pinned BaseObject.ts executed below, never a JS replacement.
const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const ts=require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2] || '../DragonBonesJS'),lua=process.argv[3] || 'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...args)=>cp.execFileSync('git',['-C',upstream,...args],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN)throw Error('Wrong upstream HEAD');
const source=git('show',PIN+':DragonBones/src/dragonBones/core/BaseObject.ts');
const compiled=ts.transpileModule(source,{compilerOptions:{target:ts.ScriptTarget.ES5},reportDiagnostics:true});
if(compiled.diagnostics.length)throw Error('Original transpilation failed');
const corpus=[];
function scenario(name,steps){corpus.push(['begin',name]);for(const row of steps)corpus.push(row.map(String));}
scenario('lifecycle',[
 ['abstract'],['new','a','A'],['borrow','b','A'],['value','a',99],['return','a'],['return','a'],
 ['return','b'],['borrow','c','A'],['borrow','d','A'],['clear','*'],['return','a'],['borrow','e','A']]);
scenario('fractional-class',[
 ['set','A',0.5],['borrow','a','A'],['borrow','b','A'],['return','a'],['return','b'],['return','a'],
 ['set','A',1.5],['return','b'],['set','A',0.5],['set','A',3],['return','b'],['set','A',1],
 ['clear','A'],['return','a'],['return','b'],['borrow','c','A']]);
scenario('global-partial-error',[
 ['set','A',4],['set','B',4],['set','C',7],['borrow','a','A'],['return','a'],
 ['borrow','b1','B'],['borrow','b2','B'],['borrow','b3','B'],['return','b1'],['return','b2'],['return','b3'],
 ['set','*',1.5],['borrow','c','C'],['return','c'],['set','*',0],['borrow','d','A']]);
scenario('numeric-key-order',[
 ['set','I10',8],['set','I2',8],['set','A',8],['borrow','a','I10'],['return','a'],
 ['borrow','b','I2'],['borrow','c','I2'],['return','b'],['return','c'],['borrow','d','A'],['return','d'],
 ['set','*',1.5],['set','*',0],['clear','*']]);
scenario('constructor-strings',[
 ['borrow','a','A'],['return','a'],['borrow','alias','Alias'],['return','alias'],['borrow','derived','Derived'],
 ['borrow','bad','Missing'],['set','Missing',2],['clear','Missing'],['key','A','[test.B]'],
 ['return','derived'],['borrow','b','B'],['constructor','b','C'],['return','b'],['borrow','c','C']]);
scenario('negative-zero-string-key',[
 ['key','A','-0'],['set','I2',8],['set','A',8],['borrow','a','I2'],['return','a'],
 ['borrow','b','A'],['borrow','c','A'],['return','b'],['return','c'],['set','*',1.5]]);
scenario('static-string-receiver',[
 ['receiverKey','A'],['borrow','a','A'],['return','a'],['borrow','derived','Derived'],
 ['return','derived'],['borrow','again','A'],['clear','*']]);
scenario('nested-and-throwing-clear',[
 ['borrow','parent','A'],['borrow','child','B'],['child','parent','child'],['return','parent'],['return','parent'],
 ['borrow','thrower','A'],['fail','thrower','true'],['return','thrower'],['fail','thrower','false'],
 ['return','thrower'],['direct','child'],['clear','*']]);
scenario('hash-boundary',[
 ['seed','9007199254740991'],['new','a','A'],['borrow','b','B'],['borrow','c','C'],['return','a'],['borrow','d','A']]);
scenario('default-capacity',[
 ['bulk','A',3002],['borrow','a','A'],['borrow','b','A'],['clear','A'],['return','bulkLast'],['borrow','c','A']]);
for(const max of ['0','-0','1','2','-1','NaN','Infinity','-Infinity','0.5','1.5']) {
  for(const mode of ['A','*'])scenario('limit-'+max+'-'+mode,[
    ['set','C',9],['borrow','a','A'],['borrow','b','A'],['borrow','c','A'],
    ['return','a'],['return','b'],['return','c'],['set',mode,max],['return','a'],
    ['borrow','d','A'],['return','d'],['clear','*'],['return','b']]);
}
let seed=0x504f4f4c;
const random=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<8;s++) {
  const steps=[],ids=[];let count=0;
  for(let i=0;i<100;i++) {
    const op=random(6),cls=['A','B','C','Alias','Derived'][random(5)];
    if(op===0 || !ids.length){const id='o'+count++;ids.push(id);steps.push(['borrow',id,cls]);}
    else if(op===1)steps.push(['return',ids[random(ids.length)]]);
    else if(op===2)steps.push(['set',random(3)?cls:'*',['0','1','2','3','0.5','1.5','NaN','Infinity'][random(8)]]);
    else if(op===3)steps.push(['clear',random(2)?cls:'*']);
    else if(op===4)steps.push(['value',ids[random(ids.length)],random(200)]);
    else steps.push(['direct',ids[random(ids.length)]]);
  }
  scenario('random-'+s,steps);
}
const encode=n=>n===undefined?'undefined':Number.isNaN(n)?'NaN':Object.is(n,-0)?'-0':String(n);
let Base,classes,objects,warnings,trace,serial;
function begin() {
  warnings=[];trace=[];serial=0;objects={};
  const context=vm.createContext({console:{warn:s=>warnings.push(s)}});
  vm.runInContext(compiled.outputText,context);Base=context.dragonBones.BaseObject;
  classes={};
  for(const [name,key] of [['A','[test.A]'],['B','[test.B]'],['C','[test.C]'],['Alias','[test.A]'],['I2','2'],['I10','10'],['Missing',null]]) {
    const Test=class extends Base {
      constructor(){super();this.serial=++serial;this.createdAs=name;this.clears=0;this.value=123;}
      _onClear(){this.clears++;this.value=0;trace.push(this.serial);if(this.failClear)throw Error('clear callback');
        if(this.child){const child=this.child;this.child=null;child.returnToPool();}}
    };
    Test.label=name;if(key!==null)Test.toString=()=>key;
    classes[name]=Test;
  }
  classes.Derived=class extends classes.A {};
  classes.Derived.label='Derived';
}
function snapshot() {
  const scalar=[encode(Base._hashCode),encode(Base._defaultMaxCount),String(serial)];
  scalar.push(Object.keys(objects).sort().map(k=>{
    const o=objects[k];return [k,o.serial,o.createdAs,o.constructor.label,encode(o.hashCode),o._isInPool?'1':'0',o.clears,encode(o.value),o.failClear?'1':'0',o.child?o.child.serial:'none'].join(':');}).join(';'));
  scalar.push(Object.keys(Base._poolsMap).sort().map(k=>k+':'+Base._poolsMap[k].map(o=>o.serial).join(',')).join(';'));
  scalar.push(Object.keys(Base._maxCountMap).sort().map(k=>k+':'+encode(Base._maxCountMap[k])).join(';'));
  scalar.push(warnings.join(';'),trace.join(','));return scalar;
}
const expected=[];
for(let i=0;i<corpus.length;i++) {
  const [op,a,b]=corpus[i];let tag='void';
  if(op==='begin')begin();
  else {
    warnings=[];trace=[];
    try {
      let value;
      if(op==='borrow'){value=Base.borrowObject(classes[b]);objects[a]=value;}
      else if(op==='new'){value=new classes[b]();objects[a]=value;}
      else if(op==='return')value=objects[a].returnToPool();
      else if(op==='direct')value=Base._returnObject(objects[a]);
      else if(op==='set')value=Base.setMaxCount(a==='*'?null:classes[a],Number(b));
      else if(op==='clear')value=a==='*'?Base.clearPool():Base.clearPool(classes[a]);
      else if(op==='abstract')value=Base.toString();
      else if(op==='value')objects[a].value=Number(b);
      else if(op==='child')objects[a].child=objects[b];
      else if(op==='fail')objects[a].failClear=b==='true';
      else if(op==='constructor')objects[a].constructor=classes[b];
      else if(op==='key')classes[a].toString=()=>b;
      else if(op==='receiverKey')classes[a].toString=function(){return '[dynamic.'+this.label+']';};
      else if(op==='seed')Base._hashCode=Number(a);
      else if(op==='bulk'){
        const list=Array.from({length:Number(b)},()=>Base.borrowObject(classes[a]));
        objects.bulkFirst=list[0];objects.bulkLast=list[list.length-1];for(const o of list)o.returnToPool();
      } else throw Error('Unknown test command '+op);
      if(value!==undefined)tag='object:'+value.serial;
    }catch(e){tag=e.name==='RangeError'?'range':e.message==='clear callback'?'clear-error':'error';}
  }
  expected.push([String(i),tag,...snapshot()]);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});
const input=path.join(dir,'baseobject-cases.tsv');fs.writeFileSync(input,corpus.map(r=>r.join('\t')).join('\n')+'\n');
fs.writeFileSync(path.join(dir,'baseobject-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/baseobject_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:16*1024*1024});
fs.writeFileSync(path.join(dir,'baseobject-'+path.basename(lua)+'-actual.tsv'),actual);
const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));
if(lines.length!==expected.length)throw Error('BaseObject output length differs');
let comparisons=0;
for(let i=0;i<expected.length;i++)for(let col=0;col<expected[i].length;col++) {
  comparisons++;
  if(lines[i][col]!==expected[i][col])throw Error('BaseObject mismatch row '+i+' '+corpus[i].join(' ')+' col '+col+': expected '+expected[i][col]+', got '+lines[i][col]);
}
const result={upstream:PIN,scenarios:corpus.filter(r=>r[0]==='begin').length,operations:corpus.length,
  comparedColumns:comparisons,tolerance:0,lua,result:'passed'};
fs.writeFileSync(path.join(dir,'baseobject-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
