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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','parser/DataParser','parser/ObjectDataParser'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');
const rows=[];const add=(...r)=>rows.push(r.map(String));const begin=name=>add('begin',name),s=v=>'s:'+Buffer.from(v).toString('hex');
const obj=(id,props={})=>{add('object',id);for(const [k,v] of Object.entries(props))add('put',id,k,v);};
const arr=(id,values=[])=>{add('array',id);for(const v of values)add('append',id,v);};
const tex=(id,name,props={})=>obj(id,{name:s(name),x:'n:2',y:'n:3',width:'n:20',height:'n:30',...props});
const atlas=(id,values=[])=>{arr(id+'List',values.map(v=>'o:'+v));obj(id,{name:s('atlas'),imagePath:s('atlas.png'),width:'n:128',height:'n:256',scale:'n:2',SubTexture:'o:'+id+'List'});};
begin('helpers-values');arr('empty');arr('one',['n:3']);arr('nullOne',['null']);arr('many',['n:1','n:2']);arr('nested',['o:one','null','o:empty']);obj('plain');obj('blocked',{toString:s('not callable')});
const vals=['absent','undefined','null','b:true','b:false','n:0','n:-0','n:NaN','n:Infinity','n:-Infinity','n:5e-324','n:1e21','n:1e-7','n:1.23456789012345','o:empty','o:one','o:nullOne','o:many','o:nested','o:plain','o:blocked',...['','0','-0','NaN','nan','false','False','null','undefined','true',' 12 ','+12.5','.5','5.','5e2','5e','0x10','0Xffffffffffffffff','0x1p2','-0x10','0b101','0o17','0o8','Infinity','+Infinity','-Infinity','inf','12junk','\u00a0-0\ufeff','\u20031.5\u2028','\u008512','\u180e12','\0','😀','1,2'].map(s)];
for(const method of ['Boolean','Number','String'])for(const v of vals)for(const def of method==='Boolean'?['b:false','b:true']:method==='Number'?['n:-7','n:NaN','n:-0']:['s:','s:64656661756c74'])add('helper',method,v,def);
let seed=0x41544c41;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let i=0;i<400;i++){
 const n=(rand(200000)-100000)/113;for(const value of ['n:'+n,s(String(n)),s(' '+String(n)+' '),s(String(n)+'!')])add('helper','Number',value,'n:-7');
 if(i<80)add('helper','String','n:'+n,'s:');
}
for(const [base,prefix] of [[2,'0b'],[8,'0o'],[16,'0x']])for(const n of [0n,1n,2n**53n-1n,2n**53n+1n,2n**63n-1n,2n**64n-1n,2n**100n+12345n])add('helper','Number',s(prefix+n.toString(base)),'n:-7');
for(const ws of ['\t','\n','\v','\f','\r',' ','\u00a0','\u1680',...Array.from({length:11},(_,i)=>String.fromCodePoint(0x2000+i)),'\u2028','\u2029','\u202f','\u205f','\u3000','\ufeff'])add('helper','Number',s(ws+' 42 '+ws),'n:-7');
begin('constructors-and-singleton');add('newParser');add('singleton');add('singleton');add('actionFrame');
begin('atlas-basic-frame-duplicates');tex('t','region',{rotated:'b:true',frameWidth:'n:40',frameHeight:'n:50',frameX:'n:-4',frameY:'n:-5'});tex('duplicate','region');tex('other','2',{frameWidth:'n:0',frameHeight:'n:10'});atlas('raw',['t','duplicate','other']);add('parse','o:raw','omit');add('parse','o:raw','n:0.5');add('clearAtlas');add('parse','o:raw','omit');add('returnAtlas');add('borrowAtlas');
for(const value of ['n:0','n:-0','n:NaN','n:Infinity','n:-Infinity','null','undefined',s('0'),s('NaN')]){
 begin('raw-scale-'+value);obj('raw',{scale:value,width:value,name:value,imagePath:value});add('parse','o:raw','omit');add('parse','o:raw','n:2');
}
for(const scale of ['n:0','n:-0','n:NaN','n:Infinity','n:-Infinity','n:1','n:0.25','null','undefined']){begin('argument-scale-'+scale);obj('raw');add('parse','o:raw',scale);}
for(const [w,h] of [['n:2','n:3'],['n:2','n:0'],['n:-1','n:3'],['n:Infinity','n:Infinity'],['null','undefined']]){begin('frame-size-'+w+'-'+h);tex('t','f',{frameWidth:w,frameHeight:h});atlas('raw',['t']);add('parse','o:raw','omit');}
begin('factory-failure-and-retry');tex('a','a');tex('b','b');atlas('raw',['a','b']);add('failAt',2);add('parse','o:raw','omit');add('parse','o:raw','omit');add('clearAtlas');
begin('conversion-failure-after-texture-allocation');obj('blocked',{toString:s('not callable')});tex('t','partial',{x:'o:blocked'});atlas('raw',['t']);add('parse','o:raw','omit');add('put','t','x','n:2');add('parse','o:raw','omit');
begin('captured-SubTexture-length');tex('a','a');tex('b','b');atlas('raw',['a']);add('factoryHook','append','rawList','o:b');add('parse','o:raw','omit');add('parse','o:raw','omit');
for(const bad of ['null','undefined','o:plain']){begin('invalid-SubTexture-'+bad);obj('plain');obj('raw',{SubTexture:bad,name:s('partial')});add('parse','o:raw','omit');}
begin('array-like-object');tex('a','arraylike');obj('items',{'0':'o:a',length:s('1')});obj('raw',{SubTexture:'o:items'});add('parse','o:raw','omit');
begin('sparse-SubTexture');tex('a','a');arr('items',['o:a','undefined']);obj('raw',{SubTexture:'o:items'});add('parse','o:raw','omit');
begin('queue-empty-and-consumption');add('parse','null','omit');arr('queue');add('queue','queue');add('parse','null','omit');obj('a',{name:s('A')});obj('b',{name:s('B')});arr('queue2',['o:a','o:b']);add('queue','queue2');add('parse','null','omit');add('parse','null','n:2');add('parse','null','omit');
begin('queue-failure-index-survives');tex('t','t');atlas('a',['t']);obj('b',{name:s('B')});arr('queue',['o:a','o:b']);add('queue','queue');add('failAt',1);add('parse','null','omit');add('parse','null','omit');
begin('queue-sparse-undefined-assertion');arr('queue',['undefined']);add('queue','queue');add('parse','null','omit');add('parse','null','omit');add('parse','undefined','omit');add('parseOmit');
begin('queue-null-entry');arr('queue',['null']);add('queue','queue');add('parse','null','omit');
begin('queue-live-field-after-recursion');tex('t','t');atlas('a',['t']);arr('queue',['o:a']);arr('replacement',['o:a','o:a']);add('queue','queue');add('factoryHook','queue','replacement');add('parse','null','omit');add('parse','null','omit');
let d,B,P,p,A,T,raws,atlasObject,textures,warnings,log,hook,ids,nextId,frames;
const num=s=>s==='NaN'?NaN:s==='Infinity'?Infinity:s==='-Infinity'?-Infinity:s==='-0'?-0:Number(s);
const decode=v=>v==='null'?null:v==='undefined'?undefined:v.startsWith('s:')?Buffer.from(v.slice(2),'hex').toString():v.startsWith('n:')?num(v.slice(2)):v.startsWith('b:')?v==='b:true':raws[v.slice(2)];
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'null';if(typeof v==='string')return 's:'+Buffer.from(v).toString('hex');if(typeof v==='boolean')return v?'true':'false';if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const ref=o=>o==null?'nil':'#'+o.hashCode;function id(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function reset(){raws={};textures=[];frames=[];warnings=[];log=[];hook=null;ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s),assert:v=>{if(!v)warnings.push('Assertion failed');}}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;P=d.ObjectDataParser;p=new P();
 T=class extends d.TextureData{static toString(){return '[test.Atlas.Texture]';}};
 A=class extends d.TextureAtlasData{static toString(){return '[test.Atlas.Atlas]';}createTexture(){this.calls=(this.calls||0)+1;log.push('create:'+this.calls);if(this.failAt===this.calls)throw Error('factory failure');if(hook){const command=hook;hook=null;execute(command);}const t=B.borrowObject(T);textures.push(t);return t;}};
 atlasObject=B.borrowObject(A);
}
function execute(r){const [op,a,b,c]=r;
 if(op==='object')raws[a]={};else if(op==='array')raws[a]=[];else if(op==='put')raws[a][b]=decode(c);else if(op==='append')raws[a].push(decode(b));
 else if(op==='helper'){const raw={};if(b!=='absent')raw.v=decode(b);return scalar(P['_get'+a](raw,'v',decode(c)));}
 else if(op==='parse')return scalar(b==='omit'?p.parseTextureAtlasData(decode(a),atlasObject):p.parseTextureAtlasData(decode(a),atlasObject,decode(b)));
 else if(op==='parseOmit')return scalar(p.parseTextureAtlasData());
 else if(op==='queue'){p._rawTextureAtlases=raws[a];p._rawTextureAtlasIndex=0;}
 else if(op==='failAt')atlasObject.failAt=Number(a);
 else if(op==='factoryHook')hook=r.slice(1);
 else if(op==='clearAtlas')atlasObject._onClear();
 else if(op==='returnAtlas')atlasObject.returnToPool();
 else if(op==='borrowAtlas')atlasObject=B.borrowObject(A);
 else if(op==='newParser')p=new P();
 else if(op==='singleton'){const old=p;p=P.getInstance();return old===p?'same':'different';}
 else if(op==='actionFrame')frames.push(new d.ActionFrame());
 else throw Error(op);return 'void';
}
const arrayFields=['_rawBones','_helpArray','_intArray','_floatArray','_frameIntArray','_frameFloatArray','_frameArray','_timelineArray','_colorArray','_cacheRawMeshes','_cacheMeshes','_actionFrames'];
const mapFields=['_weightSlotPose','_weightBonePoses','_cacheBones','_slotChildActions'];
const refs=['_data','_armature','_bone','_geometry','_slot','_skin','_mesh','_animation','_timeline'];
const scalars=['_rawTextureAtlasIndex','_frameValueType','_defaultColorOffset','_prevClockwise','_prevRotation','_frameDefaultValue','_frameValueScale'];
function rect(r){return r==null?'nil':id(r)+':'+['x','y','width','height'].map(k=>scalar(r[k])).join(',');}
function parser(){return [id(p),...scalars.map(k=>scalar(p[k])),...refs.map(k=>p[k]==null?'nil':'present'),...arrayFields.map(k=>id(p[k])+':'+p[k].length),...mapFields.map(k=>id(p[k])+':'+Object.keys(p[k]).sort().join(',')),...['_helpMatrixA','_helpMatrixB','_helpTransform','_helpColorTransform','_helpPoint'].map(k=>id(p[k])+':'+Object.keys(p[k]).sort().map(f=>f+'='+scalar(p[k][f])).join(',')),p._rawTextureAtlases==null?'nil':id(p._rawTextureAtlases)+':'+p._rawTextureAtlases.length].join('|');}
function snapshot(){return [scalar(B._hashCode),parser(),[ref(atlasObject),atlasObject._isInPool,...['width','height','scale','name','imagePath','calls','failAt'].map(k=>scalar(atlasObject[k])),id(atlasObject.textures)+':'+Object.keys(atlasObject.textures).sort().map(k=>k+'='+ref(atlasObject.textures[k])).join(',')].join('|'),textures.map(t=>[ref(t),t._isInPool,scalar(t.name),scalar(t.rotated),ref(t.parent),rect(t.region),rect(t.frame)].join(':')).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),log.join('|'),warnings.join('|'),Object.keys(raws).filter(k=>Array.isArray(raws[k])).sort().map(k=>k+'='+id(raws[k])+':'+raws[k].length).join('|'),frames.map(f=>id(f)+':'+scalar(f.frameStart)+':'+id(f.actions)+':'+f.actions.length).join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')reset();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag='error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'objectatlas-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'objectatlas-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/objectatlas_differential.lua',input],{cwd:root,encoding:'utf8',timeout:15000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'objectatlas-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Transcript length');let comparisons=0;for(let i=0;i<expected.length;i++){if(lines[i].length!==expected[i].length)throw Error('Columns');for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('ObjectAtlas mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,integration:'real ObjectDataParser helpers/atlas method, TextureAtlasData/TextureData/Rectangle/pool; test-only concrete texture factory',lua,result:'passed'};fs.writeFileSync(path.join(dir,'objectatlas-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
