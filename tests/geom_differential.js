'use strict';
// Executes original pinned TypeScript, never a hand-written JS replacement.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const vm = require('vm');
const ts = require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2] || '../DragonBonesJS');
const lua=process.argv[3] || 'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...a)=>cp.execFileSync('git',['-C',upstream,...a],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN) throw Error('Wrong upstream HEAD');
const fields={Point:['x','y'],Rectangle:['x','y','width','height'],ColorTransform:[
  'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier',
  'alphaOffset','redOffset','greenOffset','blueOffset']};
const context=vm.createContext({});
for(const name of Object.keys(fields)) {
  const source=git('show',PIN+':DragonBones/src/dragonBones/geom/'+name+'.ts');
  const result=ts.transpileModule(source,{compilerOptions:{target:ts.ScriptTarget.ES5},reportDiagnostics:true});
  if((result.diagnostics || []).length) throw Error('Transpile diagnostics in '+name);
  vm.runInContext(result.outputText,context,{filename:name+'.ts'});
}
const decode=s=>s==='undefined'?undefined:Number(s);
const numbers=['0','-0','1','-1','0.125','-13.75','9007199254740991','1.7976931348623157e308',
  '2.2250738585072014e-308','5e-324','-5e-324','NaN','Infinity','-Infinity'];
const rows=[];
function add(id,name,op,values=[]) {rows.push([id,name,op,...values]);}
for(const [name,keys] of Object.entries(fields)) {
  const defaults=keys.map(()=> 'undefined');
  const full=keys.map((_,i)=>String((i+1)*1.125));
  // Omitted and explicit undefined arguments, independent instances, every
  // positional argument, self-copy, sparse records and all reset methods.
  add(name+'-defaults',name,'new');
  add(name+'-undefined',name,'new',defaults);
  for(let slot=0;slot<keys.length;slot++) {
    for(const n of numbers) {
      const id=name+'-'+slot+'-'+n;
      const args=defaults.slice();args[slot]=n;
      add(id,name,'new',args);
      add(id,name,'self');
      add(id,name,'copy',full);
      add(id,name,'set',[keys[slot],n]);
      add(id,name,'reset');
      add(id,name,'reset');
      add(id,name,'copy',args);
    }
  }
  add(name+'-defaults',name,'observe');
  add(name+'-undefined',name,'observe');
}
const objects=new Map(), expected=[];
function encode(n) {
  if(n===undefined)return 'undefined';
  if(Number.isNaN(n))return 'NaN';
  if(Object.is(n,-0))return '-0';
  // Decimal precision suffices to round-trip binary64. Lua may print a
  // different but numerically identical spelling; the comparator parses it.
  return String(n);
}
for(const [id,name,op,...args] of rows) {
  const keys=fields[name];let object=objects.get(id), result, tag='void';
  if(op==='new') {object=new context.dragonBones[name](...args.map(decode));objects.set(id,object);tag='instance';}
  else if(op==='self')result=object.copyFrom(object);
  else if(op==='copy') {
    const value=Object.fromEntries(keys.map((key,i)=>[key,decode(args[i] || 'undefined')]));
    const before=keys.map(k=>encode(value[k]));
    result=object.copyFrom(value);
    if(keys.some((k,i)=>encode(value[k])!==before[i]))throw Error('Original mutates source');
  } else if(op==='reset')result=name==='ColorTransform'?object.identity():object.clear();
  else if(op==='set')object[args[0]]=decode(args[1]);
  else if(op!=='observe')throw Error('Unknown operation');
  if(result!==undefined)throw Error('Unexpected original return value');
  expected.push([id,name,op,tag,...keys.map(k=>encode(object[k]))]);
}
const artifacts=path.join(root,'artifacts');fs.mkdirSync(artifacts,{recursive:true});
const cases=path.join(artifacts,'geom-cases.tsv');
fs.writeFileSync(cases,rows.map(r=>r.join('\t')).join('\n')+'\n');
fs.writeFileSync(path.join(artifacts,'geom-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const output=cp.execFileSync(lua,['tests/geom_differential.lua',cases],{cwd:root,encoding:'utf8',maxBuffer:8*1024*1024});
const actual=output.trimEnd().split('\n').map(r=>r.split('\t'));
if(actual.length!==expected.length)throw Error('Output row count mismatch');
let values=0;
for(let r=0;r<expected.length;r++) {
  if(actual[r].length!==expected[r].length)throw Error('Column count at row '+r);
  for(let col=0;col<expected[r].length;col++) {
    const a=actual[r][col],e=expected[r][col];
    const equal=col<4 || ['undefined','NaN','-0','Infinity','-Infinity'].includes(e) ? a===e :
      a!=='-0' && Object.is(Number(a),Number(e));
    if(!equal)throw Error('Differential mismatch row '+r+' '+rows[r].join(' ')+' column '+col+': expected '+e+', got '+a);
    if(col>=4)values++;
  }
}
const result={upstream:PIN,classes:Object.keys(fields),operations:rows.length,comparedFields:values,
  tolerance:0,lua,version:cp.execFileSync(lua,['-v'],{encoding:'utf8'}).trim(),result:'passed'};
fs.writeFileSync(path.join(artifacts,'geom-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');
fs.writeFileSync(path.join(artifacts,'geom-'+path.basename(lua)+'-actual.tsv'),output);
console.log(JSON.stringify(result));
