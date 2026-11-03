'use strict';
// All reference calculations execute the pinned original TypeScript classes.
const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const ts=require('typescript');
const PIN='64b6c69ae35777c2404be68c9192e2c56906079e';
const upstream=path.resolve(process.argv[2] || '../DragonBonesJS'),lua=process.argv[3] || 'lua5.4';
const root=path.resolve(__dirname,'..');
const git=(...a)=>cp.execFileSync('git',['-C',upstream,...a],{encoding:'utf8'});
if(git('rev-parse','HEAD').trim()!==PIN)throw Error('Wrong upstream HEAD');
const context=vm.createContext({});
for(const name of ['Matrix','Transform']) {
  const source=git('show',PIN+':DragonBones/src/dragonBones/geom/'+name+'.ts');
  const code=ts.transpileModule(source,{compilerOptions:{target:ts.ScriptTarget.ES5},reportDiagnostics:true});
  if(code.diagnostics.length)throw Error('Transpile failed: '+name);
  vm.runInContext(code.outputText,context,{filename:name+'.ts'});
}
const {Matrix,Transform}=context.dragonBones;
const fields={Matrix:['a','b','c','d','tx','ty'],Transform:['x','y','skew','rotation','scaleX','scaleY']};
const rows=[];
const add=(cls,op,args='',other='',option='')=>rows.push([cls,op,String(rows.length),args,other,option]);
for(const cls of ['Matrix','Transform']) {
  const file=cls==='Matrix'?'matrix_cases.tsv':'transform_cases.tsv';
  for(const line of fs.readFileSync(path.join(__dirname,'fixtures',file),'utf8').split(/\r?\n/)) {
    if(!line || line.startsWith('#'))continue;
    const [op,name,args,other='',option='']=line.split('\t');
    add(cls,op,args,other,option);
  }
}
for(const line of fs.readFileSync(path.join(__dirname,'fixtures/geom_strings_cases.tsv'),'utf8').split(/\r?\n/)) {
  if(!line || line.startsWith('#'))continue;
  const [cls,name,args]=line.split('\t');add(cls,'string',args);
}
// Constructors, self-aliases, omitted/sparse array data, singular matrices,
// signed zero and non-finite values complement the preserved finite fixtures.
const special=['0','-0','1','-1','0.125','-2.5','NaN','Infinity','-Infinity','5e-324','1e308'];
for(const cls of ['Matrix','Transform']) {
  add(cls,'new');add(cls,'new','undefined,undefined,undefined,undefined,undefined,undefined');
  for(let slot=0;slot<6;slot++)for(const value of special) {
    const args=(cls==='Matrix'?['1','0','0','1','0','0']:['0','0','0','0','1','1']).slice();args[slot]=value;
    const s=args.join(',');
    add(cls,'new',s);add(cls,'self',s);add(cls,'identity',s);add(cls,'string',s);
    if(cls==='Matrix') {
      add(cls,'invert',s);add(cls,'concat',s,'2,3,-1,4,-5,6');
      add(cls,'concatSelf',s);add(cls,'point',s,'-0,0.125','false');
      add(cls,'point',s,'3,-2','true');add(cls,'rect',s,'-0,-0,0,0','false');
    } else {
      add(cls,'toMatrix',s);add(cls,'fromMatrix',s,'2,1,-3,4,5,6');
      add(cls,'addSelf',s);add(cls,'minusSelf',s);
      add(cls,'add',s,'1,2,-0.2,0.3,-1,0');add(cls,'minus',s,'1,2,-0.2,0.3,0,-1');
    }
  }
}
for(const offset of ['undefined','0','2','-1','10'])add('Matrix','copyArray','99,-0,NaN,Infinity,-Infinity,1,2,3',offset);
add('Matrix','copyArray','1,2,undefined,4,5,6','0');
add('Matrix','rect','-0,-0,-0,-0,-0,-0','1,1,0,0','false');
for(const value of [...special,String(Math.PI/4),String(-Math.PI/4),'1e20','-1e20'])add('Transform','normalize',value);
add('Transform','constants');
// Fixed seed and bounded decimal inputs: regenerated identically by CI.
let seed=0x4d415448;
function random(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return (seed%2049-1024)/32;}
for(let i=0;i<128;i++) {
  const a=Array.from({length:6},random).join(','),b=Array.from({length:6},random).join(',');
  for(const op of ['concat','invert','point','rect'])add('Matrix',op,a,
    op==='point'?b.split(',').slice(0,2).join(','):op==='rect'?b.split(',').slice(0,4).join(','):b,i%2?'true':'false');
  for(const op of ['add','minus','fromMatrix','toMatrix'])add('Transform',op,a,b);
}
const decode=s=>s==='undefined'?undefined:Number(s);
const parse=s=>s===''?[]:s.split(',').map(decode);
function encode(n) {return n===undefined?'undefined':Number.isNaN(n)?'NaN':Object.is(n,-0)?'-0':String(n);}
const expected=[];
for(const [cls,op,id,raw,other,option] of rows) {
  const C=cls==='Matrix'?Matrix:Transform;
  const args=parse(raw),b=parse(other);let object=new C(...args),ret,values;
  const initial=fields[cls].map(k=>encode(object[k]));
  if(op==='new') {ret=object;values=fields[cls].map(k=>object[k]);}
  else if(op==='normalize') {ret=Transform.normalizeRadian(args[0]);values=[ret];}
  else if(op==='constants'){values=['PI','PI_D','PI_H','PI_Q','RAD_DEG','DEG_RAD'].map(k=>Transform[k]);}
  else if(op==='string'){ret=object.toString();values=[ret];}
  else {
    let source;
    switch(op) {
      case 'self':ret=object.copyFrom(object);break;
      case 'concatSelf':ret=object.concat(object);break;
      case 'addSelf':ret=object.add(object);break;
      case 'minusSelf':ret=object.minus(object);break;
      case 'identity':ret=object.identity();break;
      case 'invert':ret=object.invert();break;
      case 'copyFrom':case 'concat':case 'add':case 'minus':
        source=new C(...b);ret=object[op](source);break;
      case 'copyArray':source=args;ret=object.copyFromArray(source,decode(other));break;
      case 'point': {
        const dest={x:999,y:999};ret=object.transformPoint(b[0],b[1],dest,option==='true');values=[dest.x,dest.y];break;
      }
      case 'rect': {
        const dest={x:b[0],y:b[1],width:b[2],height:b[3]};ret=object.transformRectangle(dest,option==='true');values=[dest.x,dest.y,dest.width,dest.height];break;
      }
      case 'toMatrix': {
        const dest=new Matrix(9,8,7,6,5,4);ret=object.toMatrix(dest);values=fields.Matrix.map(k=>dest[k]);break;
      }
      case 'fromMatrix':source=new Matrix(...b);ret=object.fromMatrix(source);break;
      default:throw Error('Unknown original operation '+op);
    }
    if(!values)values=fields[cls].map(k=>object[k]);
    // Queries and toMatrix must preserve their receiver.
    if(['point','rect','toMatrix'].includes(op) && fields[cls].some((k,i)=>encode(object[k])!==initial[i]))throw Error('Original mutated query receiver');
  }
  const kind=op==='normalize'?'number':op==='string'?'string':ret===object?'self':ret===undefined?'void':'unexpected';
  if(kind==='unexpected')throw Error('Unexpected original return');
  expected.push([cls,op,id,kind,...values.map(v=>op==='string'?v:encode(v))]);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});
const input=path.join(dir,'math-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');
fs.writeFileSync(path.join(dir,'math-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const output=cp.execFileSync(lua,['tests/math_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:8*1024*1024});
fs.writeFileSync(path.join(dir,'math-'+path.basename(lua)+'-actual.tsv'),output);
const actual=output.trimEnd().split('\n').map(r=>r.split('\t'));
if(actual.length!==expected.length)throw Error('Row count mismatch');
let numeric=0,strings=0,approximate=0;
for(let row=0;row<expected.length;row++) {
  const [cls,op]=rows[row];
  if(actual[row].length!==expected[row].length)throw Error('Column mismatch at '+row);
  for(let col=0;col<expected[row].length;col++) {
    const a=actual[row][col],e=expected[row][col];let equal=a===e;
    if(col>=4 && op!=='string') {
      numeric++;
      if(!['NaN','Infinity','-Infinity','-0','undefined'].includes(e)) {
        const n=Number(a),x=Number(e);
        equal=a!=='' && a!=='-0' && Number.isFinite(n) && Object.is(n,x);
        // Only trig decomposition/composition can vary between V8 and libm.
        // Translation fields remain exact; zero and its sign remain exact.
        const trigField=(op==='fromMatrix' && col>=6) || (op==='toMatrix' && col<8);
        if(!equal && cls==='Transform' && trigField && x!==0 && n!==0 && Number.isFinite(n)) {
          equal=Math.abs(n-x)<=8*Number.EPSILON*Math.max(1,Math.abs(x));if(equal)approximate++;
        }
      }
    } else if(col>=4)strings++;
    if(!equal)throw Error('Mismatch '+rows[row].join(' | ')+' column '+col+': expected '+e+', got '+a);
  }
}
const result={upstream:PIN,operations:rows.length,numericFields:numeric,strings,approximateComparisons:approximate,
  tolerance:'exact except nonzero trig results: 8*epsilon*max(1,abs(expected))',lua,result:'passed'};
fs.writeFileSync(path.join(dir,'math-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
