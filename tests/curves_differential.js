'use strict';
// Differential test: compile methods taken from the *pinned* TypeScript original.
const fs=require('fs'),path=require('path'),cp=require('child_process'),ts=require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2]||'../DragonBonesJS');
const vm=process.argv[3]||'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...args)=>cp.execFileSync('git',['-C',upstream,...args],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN)throw Error('Wrong upstream HEAD');
const file='DragonBones/src/dragonBones/parser/ObjectDataParser.ts';
const source=git('show',PIN+':'+file);
const parsed=ts.createSourceFile(file,source,ts.ScriptTarget.Latest,true);
let declaration;
function visit(node) {
  if(node.kind===ts.SyntaxKind.ClassDeclaration &&
      node.name && node.name.text==='ObjectDataParser')declaration=node;
  ts.forEachChild(node,visit);
}
visit(parsed);
if(!declaration)throw Error('Pinned ObjectDataParser class missing');
const methods=['_getCurvePoint','_samplingEasingCurve'].map(name=>{
  const method=declaration.members.find(m=>m.name && m.name.text===name);
  if(!method)throw Error('Pinned method missing: '+name);
  return method.getText(parsed);
});
const emitted=ts.transpileModule('class Original {\n'+methods.join('\n')+'\n}',{
  compilerOptions:{target:ts.ScriptTarget.ES5}
}).outputText;
const Original=new Function(emitted+'\nreturn Original;')();
const hex=value=>{
  if(Number.isNaN(value))return 'nan';
  const b=Buffer.alloc(8);b.writeDoubleLE(value);return b.toString('hex');
};
const token=v=>Object.is(v,-0)?'-0':String(v);
const cases=[];
const pushPoint=(...args)=>cases.push({kind:'P',values:args});
const pushSample=(curve,sampleCount)=>cases.push({kind:'S',curve,sampleCount});
pushPoint(0,0,0.2,0.3,0.8,0.7,1,1,0.5);
pushPoint(-0,0,-0,0,-0,-0,0,-0,0);
pushPoint(1,-3,0.7,-2,0.2,8,-1,5,1);
pushPoint(-2,10,7,-9,3,12,4,-8,0);
pushPoint(2,4,-3,8,-5,1,9,-2,1.5);
pushPoint(NaN,1,1,2,2,3,3,4,0.5);
pushPoint(1,1,Infinity,2,3,4,5,6,0.25);
pushPoint(1,1,2,2,3,3,4,4,-0.25);
const curves=[
  [],[0.25,0.1,0.75,0.9],
  [0,0,0.25,0.1,0.75,0.9,1,1],
  [0.1,0.2,0.2,0.4,0.5,0.5,0.7,0.6,0.8,0.9],
  [0,0,0.15,0.2,0.35,0.4,0.5,0.5,0.65,0.6,0.85,0.9,1,1],
  [0,0,0,0,0,0,1,1],
  [NaN,1,2,3],
  [0,0,NaN,0,0,0,1,1],
  [1,1,1,1]
];
for(const curve of curves)for(const n of [0,1,2,3,5,16,45])pushSample(curve,n);
let seed=0x43555256;
function rand(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;}
for(let i=0;i<110;i++){
  const r=()=>Math.round((rand()*20-10)*1000)/1000;
  const step=rand();
  pushPoint(r(),r(),r(),r(),r(),r(),r(),r(),step);
  const x1=rand()*0.5,x2=0.5+rand()*0.5;
  const curve=i%2 ? [0,0,x1,r(),x2,r(),1,1] : [x1,r(),x2,r()];
  pushSample(curve,1+Math.floor(rand()*26));
}
const rows=[],expected=[];
for(const c of cases){
  const obj=new Original();
  obj._helpPoint={x:0,y:0};
  if(c.kind==='P'){
    rows.push(['P',...c.values.map(token)].join('\t'));
    obj._getCurvePoint(...c.values,obj._helpPoint);
    expected.push(['P',hex(obj._helpPoint.x),hex(obj._helpPoint.y)].join('\t'));
  } else {
    rows.push(['S',String(c.curve.length),String(c.sampleCount),
      ...c.curve.map(token)].join('\t'));
    const samples=new Array(c.sampleCount);
    const omitted=obj._samplingEasingCurve(c.curve,samples);
    expected.push(['S',omitted?'1':'0',hex(obj._helpPoint.x),
      hex(obj._helpPoint.y),...samples.map(hex)].join('\t'));
  }
}
const result=cp.spawnSync(vm,['tests/curves_differential.lua'],{
  cwd:root,input:rows.join('\n')+'\n',encoding:'utf8',maxBuffer:10*1024*1024
});
if(result.error)throw result.error;
if(result.status!==0)throw Error('Lua process failed: '+result.stderr);
const observed=result.stdout.trimEnd().split('\n');
const failures=[];
for(let i=0;i<expected.length;i++){
  if(expected[i]!==observed[i]){
    failures.push({case:i,input:rows[i],original:expected[i],lua:observed[i]});
  }
}
if(observed.length!==expected.length)
  failures.push({expectedRows:expected.length,actualRows:observed.length});
fs.mkdirSync(path.join(root,'artifacts'),{recursive:true});
const report={pin:PIN,source:file,methods:['_getCurvePoint','_samplingEasingCurve'],
  vm,cases:cases.length,failures:failures.slice(0,10),passed:failures.length===0};
fs.writeFileSync(path.join(root,'artifacts','curves-'+vm+'.json'),
  JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
if(failures.length)process.exitCode=1;
