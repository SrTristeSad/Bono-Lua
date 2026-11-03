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
const source=prefix+'DragonBones/src/dragonBones/parser/DataParser.ts';
const ast=ts.createSourceFile(source,texts.get(source),ts.ScriptTarget.Latest,true);
let declaration;function find(n){if(n.kind===ts.SyntaxKind.ClassDeclaration&&n.name.text==='DataParser')declaration=n;ts.forEachChild(n,find);}find(ast);
const constants=declaration.members.filter(n=>n.kind===ts.SyntaxKind.PropertyDeclaration).map(n=>n.name.text).sort();
const methods=declaration.members.filter(n=>n.kind===ts.SyntaxKind.MethodDeclaration&&n.body).map(n=>({name:n.name.text,words:[...n.body.getText(ast).matchAll(/case "([^"]+)"/g)].map(x=>x[1])}));
const abstract=declaration.members.filter(n=>n.kind===ts.SyntaxKind.MethodDeclaration&&!n.body).map(n=>n.name.text).sort();
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/BoundingBoxData','parser/DataParser'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error('Missing emitted '+p);return js;
}).join('\n');
const ctx=vm.createContext({console:{warn(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,D=d.DataParser,B=d.BaseObject;
class Derived extends D {} // Test-only static inheritance; no parse algorithm.
const hex=s=>Buffer.from(s,'utf8').toString('hex'),unhex=s=>Buffer.from(s,'hex').toString('utf8');
const rows=[],add=(...r)=>rows.push(r.map(String));
for(const k of constants)add('constant',k);
for(const k of abstract)add('abstract',k);
const allWords=[...new Set(methods.flatMap(m=>m.words))];
for(const m of methods){
 for(const word of allWords)for(const v of [word,word.toUpperCase(),word[0].toUpperCase()+word.slice(1)])add('convert',m.name,'string',hex(v));
 for(const word of m.words){
  const letters=[...word].map((c,i)=>/[a-z]/.test(c)?i:-1).filter(i=>i>=0);
  for(let mask=0;mask<2**letters.length;mask++){const v=[...word];letters.forEach((i,b)=>{if(mask&(1<<b))v[i]=v[i].toUpperCase();});add('convert',m.name,'string',hex(v.join('')));}
 }
 for(const word of ['', 'unknown','toString','__proto__','constructor',' '+m.words[0],m.words[0]+' ',m.words[0]+'\0',m.words[0]+'\n','darKen','DARKEN','fİxed','chaın','ſound','ⓟlay','ＰＬＡＹ','é','Σ','😀'])add('convert',m.name,'string',hex(word));
 for(const t of ['null','undefined','number','boolean','object'])add('convert',m.name,t,'0');
}
// Audit the actual engine for non-ASCII scalar characters that lowercase to
// one ASCII letter: this keyword matcher must handle every such candidate.
const unicodeASCII=[];
for(let cp=128;cp<=0x10ffff;cp++){
 if(cp>=0xd800&&cp<=0xdfff)continue;const value=String.fromCodePoint(cp),lower=value.toLowerCase();
 if(/^[a-z]$/.test(lower)){unicodeASCII.push({codePoint:cp,lower});for(const m of methods)for(const word of m.words)for(let i=0;i<word.length;i++)if(word[i]===lower)add('convert',m.name,'string',hex(word.slice(0,i)+value+word.slice(i+1)));}
}
const integration={Armature:['ArmatureType','type'],Bone:['BoneType','type'],Position:['PositionMode','positionMode'],Spacing:['SpacingMode','spacingMode'],Rotate:['RotateMode','rotateMode'],Display:['DisplayType','type'],BoundingBox:['BoundingBoxType','type'],Blend:['BlendMode','blendMode'],Animation:['AnimationBlendType','blendType'],Action:['ActionType','type']};
for(const [kind,[suffix]] of Object.entries(integration)){
 const method=methods.find(m=>m.name==='_get'+suffix);for(const v of [...method.words,...method.words.map(w=>w.toUpperCase()),'unknown'])add('model',kind,method.name,hex(v));
}
let seed=0x50415253;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let i=0;i<1200;i++){const m=methods[rand(methods.length)],word=m.words[rand(m.words.length)];const v=word.split('').map(c=>rand(2)?c.toUpperCase():c).join('');add('convert',m.name,'string',hex(i%3===0?v+'!':v));}
add('versions');add('versionExtra',hex('keep'));add('versionWrite',8,hex('future'));add('versionHole',2);add('versions');add('versionLength',2);add('versions');add('versionLength',4294967295);add('versions');add('versionLength',0);add('versions');add('versionWrite',0,hex('new'));add('derivedAlias');add('shadowVersions');add('versionWrite',0,hex('changed'));add('derivedAlias');add('setConstant','DATA_VERSION_5_6',hex('future'));add('constant','DATA_VERSION');add('constant','DATA_VERSION_5_6');add('constant','DRADON_BONES');add('versions');
const scalar=v=>v===undefined?'undefined':typeof v==='string'?'s:'+hex(v):typeof v==='boolean'?(v?'true':'false'):String(v);
function array(a){return a.length+':'+Object.keys(a).filter(k=>a[k]!==undefined).sort().map(k=>k+'='+scalar(a[k])).join(',');}
function model(kind,method,value){
 const type=D[method](value);let C,field=integration[kind][1];
 switch(kind){case 'Armature':C=d.ArmatureData;break;case 'Bone':C=type===1?d.SurfaceData:d.BoneData;break;case 'Position':case 'Spacing':case 'Rotate':C=d.PathConstraintData;break;case 'Display':C=[d.ImageDisplayData,d.ArmatureDisplayData,d.MeshDisplayData,d.BoundingBoxDisplayData,d.PathDisplayData][type];break;case 'BoundingBox':C=[d.RectangleBoundingBoxData,d.EllipseBoundingBoxData,d.PolygonBoundingBoxData][type];break;case 'Blend':C=d.SlotData;break;case 'Animation':C=d.AnimationData;break;case 'Action':C=d.ActionData;break;default:throw Error('Unknown model');}
 const o=B.borrowObject(C);o[field]=type;const before=o[field],id=o.hashCode;o.returnToPool();return [C.toString(),id,field,scalar(before),scalar(o[field]),scalar(o._isInPool)].join('|');
}
function execute(r){const [op,a,b,c]=r;
 if(op==='constant')return a==='DATA_VERSIONS'?'array:'+array(D[a]):scalar(D[a]);
 if(op==='abstract')return [scalar(typeof D.prototype[a]),scalar(typeof Derived.prototype[a])].join('|');
 if(op==='convert'){let value=b==='string'?unhex(c):b==='null'?null:b==='undefined'?undefined:b==='number'?0:b==='boolean'?false:{};return scalar(D[a](value));}
 if(op==='model')return model(a,b,unhex(c));
 if(op==='versions')return array(D.DATA_VERSIONS);
 if(op==='versionExtra')D.DATA_VERSIONS.extra=unhex(a);
 else if(op==='versionWrite')D.DATA_VERSIONS[Number(a)]=unhex(b);
 else if(op==='versionHole')D.DATA_VERSIONS[Number(a)]=undefined;
 else if(op==='versionLength')D.DATA_VERSIONS.length=Number(a);
 else if(op==='derivedAlias')return scalar(Derived.DATA_VERSIONS===D.DATA_VERSIONS)+'|'+array(Derived.DATA_VERSIONS);
 else if(op==='shadowVersions')Derived.DATA_VERSIONS=['private'];
 else if(op==='setConstant')D[a]=unhex(b);
 else throw Error('Unknown command');return 'void';
}
const expected=rows.map((r,i)=>{let result;try{result=execute(r);}catch(e){if(r[0]!=='convert'||r[2]==='string')throw e;result='error';}return [String(i),r[0],result,String(B._hashCode)];});
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'dataparser-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'dataparser-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/dataparser_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:32*1024*1024});fs.writeFileSync(path.join(dir,'dataparser-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;
for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Column count');for(let j=0;j<expected[i].length;j++){comparisons++;if(expected[i][j]!==lines[i][j])throw Error('DataParser mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,constants:constants.length,conversionMethods:methods.length,abstractSignatures:abstract.length,operations:rows.length,comparedColumns:comparisons,modelApplications:rows.filter(r=>r[0]==='model').length,tolerance:0,unicodeASCIIFolds:unicodeASCII,oracleLocale:Intl.DateTimeFormat().resolvedOptions().locale,lua,result:'passed'};fs.writeFileSync(path.join(dir,'dataparser-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
