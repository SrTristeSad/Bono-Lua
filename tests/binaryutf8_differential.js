'use strict';
// Execute the pinned BinaryDataParser decoder and native Uint8Array oracle.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const rows=[],add=(...r)=>rows.push(r.map(String));
const hex=bytes=>Buffer.from(bytes).toString('hex');
add('singleton');
add('decode','');for(let a=0;a<256;a++)add('decode',hex([a]));
for(let a=0;a<256;a++)for(let b=0;b<256;b++)add('decode',hex([a,b]));
for(const cp of [0,1,127,128,2047,2048,55295,57344,65533,65535,65536,128512,1114111]){const b=Buffer.from(String.fromCodePoint(cp));for(let n=0;n<=b.length;n++)add('decode',b.subarray(0,n).toString('hex'));add('decode',Buffer.concat([Buffer.from([0,65]),b,Buffer.from([66,0])]).toString('hex'));}
for(const b of [[0xe0,0x80,0x80],[0xed,0xa0,0x80],[0xf4,0x90,0x80,0x80],[0xf5,0x80,0x80,0x80],[0xc2,65,66],[0xc2,0xe2,0x82,0xac],[0xe1,0x80,65],[0xef,0xbf,0xbd],[0xef,0xbb,0xbf],[0xf0,0x90,0x80,0x80]])add('decode',hex(b));
let seed=0x55544638;const next=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};for(let i=0;i<1024;i++)add('decode',hex(Array.from({length:next()%65},()=>next()%256)));
for(const a of ['NaN','Infinity','-Infinity','-0','0','1','255'])for(const lo of ['-1','0','128','255'])add('range',a,lo,'255');
const values=['undefined','null','b:false','b:true','n:0','n:-0','n:1.9','n:-1.9','n:255.9','n:256','n:65537','n:NaN','n:Infinity','n:-Infinity','n:9007199254740992','s:'+Buffer.from('0xFF').toString('hex'),'s:'+Buffer.from('0b101').toString('hex'),'s:'+Buffer.from(' -1.5 ').toString('hex'),'s:'+Buffer.from('bad').toString('hex'),'empty','array','blocked'];
for(const value of values)for(const index of ['0','1','2','-1','0.5','NaN','Infinity'])add('write',index,value);
for(const [o,n,k] of [[1,2,'uint8'],[4,0,'uint8'],[5,0,'uint8'],[-1,1,'uint8'],[0,5,'uint8'],[1,2,'uint16'],[0,3,'uint16']])add('view',o,n,k);
for(const key of ['length','buffer','byteOffset','byteLength','BYTES_PER_ELEMENT'])add('readonly',key);
add('aliases');
const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);const P=ctx.dragonBones.BinaryDataParser,p=new P();
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const value=s=>s==='undefined'?undefined:s==='null'?null:s==='empty'?[]:s==='array'?['12']:s==='blocked'?{toString:'blocked'}:s.startsWith('s:')?Buffer.from(s.slice(2),'hex').toString():s.startsWith('b:')?s==='b:true':num(s.slice(2));
function execute(r){const [op,a,b,c]=r;
 if(op==='singleton'){const q=P.getInstance();return [q instanceof P,q===P.getInstance(),q!==p,...['_binaryOffset','_binary','_intArrayBuffer','_frameArrayBuffer','_timelineArrayBuffer'].map(k=>q[k]===undefined),q._helpPoint!==p._helpPoint].map(Number).join(',');}
 if(op==='decode'){const bytes=Buffer.from(a,'hex'),buf=new ArrayBuffer(bytes.length+4),view=new Uint8Array(buf,2,bytes.length);view.set(bytes);return Buffer.from(p._decodeUTF8(view),'utf16le').toString('hex');}
 if(op==='range')return String(p._inRange(num(a),num(b),num(c)));
 if(op==='write'){const buf=new ArrayBuffer(4),v=new Uint8Array(buf,1,2);let tag='ok';try{v[num(a)]=value(b);}catch(e){tag='error';}return tag+':'+Buffer.from(new Uint8Array(buf)).toString('hex')+':'+[v.length,v.byteOffset,v.byteLength,v.BYTES_PER_ELEMENT,v.buffer===buf].join(',');}
 if(op==='view'){const C={uint8:Uint8Array,uint16:Uint16Array}[c];if(num(b)%C.BYTES_PER_ELEMENT!==0)throw Error('adapter byte length');const buf=new ArrayBuffer(4),v=new C(buf,num(a),num(b)/C.BYTES_PER_ELEMENT);return [v.length,v.byteOffset,v.byteLength,v.BYTES_PER_ELEMENT,v.buffer===buf].join(',');}
 if(op==='readonly'){const v=new Uint8Array(2);v[a]=3;return 'miss';}
 if(op==='aliases'){const buf=new ArrayBuffer(4),v=new Uint8Array(buf),w=new Uint16Array(buf);v[0]=255;v[1]=127;const before=Buffer.from(v).toString('hex'),word=w[0];w[0]=0x1234;return before+':'+word+':'+Buffer.from(v).toString('hex')+':'+v[0]+','+v[1];}
 throw Error('Unknown op');
}
if(new Uint8Array(new Uint16Array([1]).buffer)[0]!==1)throw Error('Little endian oracle required');
const expected=rows.map((r,i)=>{let result;try{result=execute(r);}catch(e){result='error';}return [String(i),result];});
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'binaryutf8-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'binaryutf8-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/binaryutf8_differential.lua',input],{cwd:root,encoding:'utf8',timeout:30000,maxBuffer:32*1024*1024});fs.writeFileSync(path.join(dir,'binaryutf8-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Rows');let compared=0;for(let i=0;i<lines.length;i++)for(let j=0;j<2;j++){compared++;if(lines[i][j]!==expected[i][j])throw Error('BinaryUTF8 mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': '+expected[i][j]+' vs '+lines[i][j]);}
const result={upstream:PIN,operations:rows.length,comparedColumns:compared,exhaustiveTwoByteInputs:65536,tolerance:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'binaryutf8-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
