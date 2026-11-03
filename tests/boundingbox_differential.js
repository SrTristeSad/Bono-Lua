'use strict';
// Execute genuine BoundingBoxData with real display/skin/armature ownership.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/SkinData','model/DragonBonesData','model/BoundingBoxData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const names={R:'RectangleBoundingBoxData',E:'EllipseBoundingBoxData',V:'PolygonBoundingBoxData',K:'BoundingBoxDisplayData',D:'DragonBonesData',S:'SkinData',A:'ArmatureData',I:'ImageDisplayData',M:'MeshDisplayData',P:'PathDisplayData',C:'ArmatureDisplayData',W:'WeightData',Q:'ActionData',U:'UserData'};
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
const display=(id,name,kind='I')=>[['borrow',id,kind],['set',id,'name','s:'+name]];
// Predeclared comparison policy: all outputs exact except nonzero atan2-derived
// normal components (including aliased destinations): 8*epsilon*max(1,abs(x)).
const square=[-5,-3,5,-3,5,3,-5,3];
const concave=[-5,-5,5,-5,5,-1,-1,-1,-1,5,-5,5];
const setup=(kind,vs=square)=>[['borrow','box',kind],['set','box','width',10],['set','box','height',6],...(kind==='V'?[['set','box','x',-5],['set','box','y',-3],['vertices','box',...vs]]:[])];
for(const kind of ['R','E','V']){
 scenario('construct-default-clear-pool-'+kind,[['new','raw',kind],['contains','raw',0,0],['segment','raw',-1,0,1,0,'a','b','n'],['borrow','box',kind],['string',kind],['set','box','color',0xabcdef],['baseClear','box'],['clear','raw'],['return','box'],['return','box'],['borrow','reuse',kind]]);
 const points=[[-5,-3],[-5,0],[5,0],[0,-3],[0,3],[5,3],[0,0],[4,2],[6,0],[0,4],[-6,-4],[1e-12,-1e-12]];
 scenario('contains-boundaries-'+kind,[...setup(kind),...points.map(p=>['contains','box',...p]),['set','box','width',0],...points.map(p=>['contains','box',...p]),['set','box','width',-10],['contains','box',0,0]]);
 const segments=[[-10,0,10,0],[10,0,-10,0],[0,-10,0,10],[0,10,0,-10],[0,0,10,2],[10,2,0,0],[0,0,1,1],[-10,9,10,9],[-10,-6,10,6],[-5,-3,5,3],[5,3,-5,-3],[-5,-3,-5,3],[0,0,0,0],[5,0,5,0],[0,3,0,3],[5,3,8,9],[0,4,10,4]];
 for(let mask=0;mask<8;mask++)scenario('segments-optional-'+kind+'-'+mask,[...setup(kind),...segments.map(v=>['segment','box',...v,mask&1?'a':'null',mask&2?'b':'null',mask&4?'n':'null'])]);
 for(const alias of [['a','a','n'],['a','b','a'],['a','b','b'],['n','n','n'],['null','null','n'],['omit','omit','omit']])scenario('destination-aliases-'+kind+'-'+alias.join(''),[...setup(kind),...segments.slice(0,7).map(v=>['segment','box',...v,...alias])]);
 scenario('degenerate-sizes-'+kind,[...setup(kind),['set','box','width',0],['set','box','height',0],['contains','box',0,0],['segment','box',-1,0,1,0,'a','b','n'],['set','box','width',10],['segment','box',-10,1,10,1,'a','b','n'],['set','box','height',6],['segment','box',0,0,0,0,'a','b','n']]);
 for(const special of ['NaN','Infinity','-Infinity','-0','5e-324'])scenario('special-input-'+kind+'-'+special,[...setup(kind),['contains','box',special,0],['segment','box',special,1,0,2,'a','b','n'],['set','box','width',special],['contains','box',0,0]]);
 scenario('ownership-real-global-display-'+kind,[['borrow','global','D'],['borrow','arm','A'],['borrow','skin','S'],['set','skin','name','s:default'],['borrow','display','K'],...setup(kind),['link','display','boundingBox','box'],['add','skin','slot','display'],['addSkin','arm','skin'],['addArmature','global','arm'],['hook','return:box','throw'],['return','global'],['return','global'],['borrow','reuseBox',kind],['borrow','reuseDisplay','K'],['borrow','reuseSkin','S'],['borrow','reuseArm','A'],['borrow','reuseGlobal','D']]);
 for(const limit of [0,1,0.5,1.5])scenario('pool-capacity-'+kind+'-'+limit,[...setup(kind),['limit',kind,limit],['return','box'],['borrow','reuse',kind]]);
}
for(const kind of ['R','E','V'])for(const destination of ['a','b','n'])for(const key of ['x','y'])scenario('output-write-failure-'+kind+'-'+destination+'-'+key,[
 ...setup(kind),['pointHook',destination,key],['hook','write:'+destination+':'+key,'throw'],['segment','box',-10,0,10,0,'a','b','n'],['segment','box',-10,0,10,0,'a','b','n']]);
scenario('rectangle-static-offset-bounds-and-outcodes',[
 ['borrow','box','R'],...[-10,-5,0,5,10].flatMap(x=>[-9,-3,0,3,9].map(y=>['outcode',x,y,-5,-3,5,3])),
 ...[[10,20,40,30],[20,25,40,30],[40,30,20,25],[0,0,0,0]].map(v=>['rect',...v,10,20,30,40,'a','b','n'])]);
scenario('rectangle-preserves-upstream-insideA-pointB-y-xB',[
 ...setup('R'),['segment','box',0,0,10,2,'a','b','n'],['segment','box',0,0,-10,2,'a','b','n']]);
scenario('ellipse-static-nonzero-center-and-normal-dependencies',[
 ['borrow','box','E'],...[[0,0],[-3,2],[3,-2]].flatMap(v=>[...[[ -10,0,10,0],[0,-10,0,10],[0,0,10,2]]].flatMap(line=>[['ellipse',...line,...v,5,3,'a','b','n'],['ellipse',...line,...v,5,3,'null','null','n']]))]);
const polygons=[[],[1,2],[1,2,3],[0,0,0,0,0,0],square,Array.from({length:square.length/2},(_,i)=>square.slice(i*2,i*2+2)).reverse().flat(),concave,[-5,0,0,-5,5,0,0,5],[-5,-5,5,5,-5,5,5,-5]];
for(let i=0;i<polygons.length;i++)scenario('polygon-topology-'+i,[...setup('V',polygons[i]),...[[0,0],[1,1],[-3,2],[5,0]].map(v=>['contains','box',...v]),...[[ -10,0,10,0],[0,-10,0,10],[-8,-8,8,8],[0,0,1,1]].flatMap(v=>[['segment','box',...v,'a','b','n'],['polygon','box',...v,'a','null','n']])]);
scenario('polygon-sparse-odd-length-undefined-and-array-aliases',[
 ...setup('V'),['saveVertices','saved','box'],['vertex','box',3,'undefined'],['contains','box',0,0],['polygon','box',-10,0,10,0,'a','b','n'],['length','box',9],['contains','box',0,0],['polygon','box',-10,0,10,0,'a','b','n'],['extraVertices','box','s:kept'],['clear','box'],['length','box',4294967295],['vertex','box',4294967294,9],['clear','box']]);
scenario('polygon-non-origin-broad-phase-preserves-width-max-test',[
 ...setup('V',[10,20,30,20,30,40,10,40]),['set','box','x',10],['set','box','y',20],['set','box','width',20],['set','box','height',20],['contains','box',25,25],['contains','box',15,25],['segment','box',0,30,40,30,'a','b','n'],['polygon','box',0,30,40,30,'a','b','n']]);
let seed=0x424f5844;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(const kind of ['R','E','V'])for(let iteration=0;iteration<4;iteration++){
 const steps=setup(kind,iteration%2?concave:square);
 for(let i=0;i<160;i++){const nums=Array.from({length:4},()=> (rand(4001)-2000)/113);if(i%5===0)steps.push(['contains','box',...nums.slice(0,2)]);else steps.push(['segment','box',...nums,rand(2)?'a':'null',rand(2)?'b':'null',rand(2)?'n':'null']);}
 scenario('deterministic-'+kind+'-'+iteration,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s.startsWith('s:')?s.slice(2):s==='true'?true:s==='false'?false:Number(s);
let d,B,classes,objects,labels,lists,log,hooks,warnings,ids,nextId,parents,points,pendingTrig,origins;
const ref=o=>o==null?'nil':'#'+o.hashCode;
const entry=o=>o===null?'null':o===undefined?'undefined':ref(o);
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
const value=id=>id==='null'||id==='NULL'?null:id==='undefined'?undefined:objects[id];
function begin(){points={};objects={};labels=new Set();lists={};log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;parents=new WeakMap();pendingTrig=false;origins={};const tracedMath=Object.create(Math);tracedMath.atan2=(y,x)=>{pendingTrig=true;return Math.atan2(y,x);};const ctx=vm.createContext({Math:tracedMath,console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);d=ctx.dragonBones;B=d.BaseObject;classes={};for(const k of Object.keys(names))classes[k]=d[names[k]];points={a:new d.Point(91,92),b:new d.Point(93,94),n:new d.Point(95,96)};
 for(const id of ['a','b','n']){origins[id]={x:false,y:false};for(const key of ['x','y']){let stored=points[id][key];Object.defineProperty(points[id],key,{configurable:true,get(){pendingTrig=pendingTrig||origins[id][key];return stored;},set(v){stored=v;origins[id][key]=pendingTrig;pendingTrig=false;}});}}
}
function execute(row){const [op,a,b,c,e,f]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);if(!o._wrapped){o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+a);fire('return:'+a);return original.call(this);};}return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='add'){if(c==='omit')objects[a].addDisplay(b);else objects[a].addDisplay(b,value(c));}
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='string')return 'string:'+classes[a].toString();
 else if(op==='list'){const v=objects[b].getDisplays(c);lists[a]=v;return v===null?'nil':'list:'+identity(v);}
 else if(op==='lookup'){const v=objects[b].getDisplay(c,e);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='mesh'){const v=objects[b].getMesh(c,e,f);objects[a]=v;labels.add(a);return v===null?'nil':'object:'+ref(v);}
 else if(op==='pointHook'){
  const o=points[a],descriptor=Object.getOwnPropertyDescriptor(o,b);Object.defineProperty(o,b,{configurable:true,get:descriptor.get,set(v){descriptor.set(v);log.push('write:'+a+':'+b);fire('write:'+a+':'+b);}});
 }
 else if(op==='contains')return 'boolean:'+objects[a].containsPoint(Number(b),Number(c));
 else if(op==='segment')return 'number:'+scalar(objects[a].intersectsSegment(...row.slice(2,6).map(Number),...row.slice(6,9).map(p=>p==='omit'?undefined:p==='null'?null:points[p])));
 else if(op==='rect'||op==='ellipse')return 'number:'+scalar(classes[op==='rect'?'R':'E'][op==='rect'?'rectangleIntersectsSegment':'ellipseIntersectsSegment'](...row.slice(1,9).map(Number),...row.slice(9,12).map(p=>p==='omit'?undefined:p==='null'?null:points[p])));
 else if(op==='polygon')return 'number:'+scalar(classes.V.polygonIntersectsSegment(...row.slice(2,6).map(Number),objects[a].vertices,...row.slice(6,9).map(p=>p==='null'?null:points[p])));
 else if(op==='outcode')return 'number:'+scalar(classes.R._computeOutCode(...row.slice(1).map(Number)));
 else if(op==='baseClear')d.BoundingBoxData.prototype._onClear.call(objects[a]);
 else if(op==='vertices'){const array=objects[a].vertices;array.length=0;row.slice(2).forEach((v,i)=>array[i]=Number(v));}
 else if(op==='vertex')objects[a].vertices[Number(b)]=c==='undefined'?undefined:Number(c);
 else if(op==='saveVertices')lists[a]=objects[b].vertices;
 else if(op==='extraVertices')objects[a].vertices.extra=decode(b);
 else if(op==='addArmature')objects[a].addArmature(objects[b]);
 else if(op==='addSkin')objects[a].addSkin(objects[b]);
 else if(op==='link')objects[a][b]=objects[c];
 else if(op==='geom'){objects[a]=objects[b].geometry;labels.add(a);return 'geometry:'+identity(objects[a]);}
 else if(op==='share')objects[a].shareFrom(objects[b]);
 else if(op==='action')objects[a].addAction(objects[b]);
 else if(op==='length')objects[a].vertices.length=Number(b);
 else if(op==='write')objects[a].displays[b][Number(c)]=value(e);
 else if(op==='deleteKey')delete objects[a].displays[b];
 else if(op==='put')objects[a].displays[b]=[value(c)];
 else if(op==='alias')objects[a].displays[b]=objects[c].displays[e];
 else if(op==='extra')objects[a].displays[b].extra=decode(c);
 else if(op==='parentHook'){
  const o=objects[a],state={value:o.parent};parents.set(o,state);Object.defineProperty(o,'parent',{configurable:true,get(){return state.value;},set(v){state.value=v;log.push('parent:'+a+':'+ref(v));fire('parent:'+a);}});
 }
 else if(op==='equal'){/* Lua __eq must not turn a display into the null marker. */}
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else throw Error('Unknown test command '+op);
 return 'void';
}
function numericArray(a){return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).filter(k=>a[k]!==undefined).sort().map(k=>k+'='+scalar(a[k])).join(',');}
function array(a){if(a==null)return 'nil';return identity(a)+':'+scalar(a.length)+':prefix='+Array.from({length:Math.min(a.length,12)},(_,i)=>entry(a[i])).join(',')+':defined='+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+entry(a[k])).join(',')+':extra='+scalar(a.extra)+':nonIndex='+entry(a[4294967295]);}
function primitive(o,ks){return identity(o)+':'+ks.map(k=>scalar(o[k])).join(',');}
function geometry(g){return identity(g)+':'+[scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)].join(':');}
function describe(o){if(o==null)return 'nil';if(o instanceof d.GeometryData)return 'G:'+geometry(o);const kind=Object.keys(classes).find(k=>o.constructor===classes[k]);const out=[kind,ref(o),o._isInPool?'1':'0'];
 if(['R','E','V'].includes(kind)){out.push(...['type','color','width','height','extra'].map(k=>scalar(o[k])));if(kind==='V')out.push(scalar(o.x),scalar(o.y),numericArray(o.vertices));}
 else if(kind==='D')out.push(scalar(o.name),ref(o.stage),ref(o.userData),identity(o.armatures)+':'+Object.keys(o.armatures).sort().map(k=>k+'='+ref(o.armatures[k])).join(';'),numericArray(o.armatureNames));
 else if(kind==='S')out.push(scalar(o.name),ref(o.parent),scalar(o.extra),identity(o.displays)+':'+Object.keys(o.displays).sort().map(k=>k+'='+array(o.displays[k])).join(';'));
 else if(kind==='A')out.push(scalar(o.name),ref(o.defaultSkin),identity(o.skins)+':'+Object.keys(o.skins).sort().map(k=>k+'='+ref(o.skins[k])).join(';'));
 else if(['I','M','P','C','K'].includes(kind)){out.push(scalar(o.type),scalar(o.name),scalar(o.path),ref(o.parent),primitive(o.transform,['x','y','rotation','skew','scaleX','scaleY']));if(kind==='K')out.push(ref(o.boundingBox));if(kind==='I')out.push(primitive(o.pivot,['x','y']),ref(o.texture));if(kind==='M'||kind==='P')out.push(geometry(o.geometry));if(kind==='P')out.push(scalar(o.closed),scalar(o.constantSpeed));if(kind==='C')out.push(scalar(o.inheritAnimation),array(o.actions),ref(o.armature));}
 else if(kind==='W')out.push(scalar(o.count),scalar(o.offset),array(o.bones));
 else if(kind==='Q')out.push(scalar(o.type),scalar(o.name),ref(o.data));
 else if(kind==='U')for(const k of ['ints','floats','strings'])out.push(identity(o[k])+':'+o[k].map(scalar).join(','));return out.join(':');
}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(lists).sort().map(k=>k+'='+numericArray(lists[k])).join('|'),Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|'),...['a','b','n'].flatMap(p=>[scalar(points[p].x),scalar(points[p].y)])];}
// Observe atan2 and actual Point reads/writes without replacing any algorithm.
// This also follows normal.y=normal.x+PI and normal values retained by later calls.
const expected=[],provenanceAtRow=[];
for(let i=0;i<rows.length;i++){
 let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];pendingTrig=false;try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}
 provenanceAtRow[i]=['a','b','n'].flatMap(p=>[origins[p].x,origins[p].y]);
 expected.push([String(i),tag,...snapshot()]);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'boundingbox-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'boundingbox-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/boundingbox_differential.lua',input],{cwd:root,encoding:'utf8',timeout:10000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'boundingbox-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('BoundingBox transcript length differs');let comparisons=0;
let approximate=0;
for(let i=0;i<expected.length;i++){
 if(lines[i].length!==expected[i].length)throw Error('Column count at '+i);
 const row=rows[i],normalProvenance=provenanceAtRow[i];
 for(let j=0;j<expected[i].length;j++){
  comparisons++;const e=expected[i][j],a=lines[i][j];let equal=e===a;
  const component=j-(expected[i].length-6);
  if(!equal&&component>=0&&normalProvenance[component]&&e.startsWith('n:')&&a.startsWith('n:')){
   const x=Buffer.from(e.slice(2),'hex').readDoubleLE(),n=Buffer.from(a.slice(2),'hex').readDoubleLE();
   equal=x!==0&&n!==0&&Number.isFinite(x)&&Number.isFinite(n)&&Math.abs(n-x)<=8*Number.EPSILON*Math.max(1,Math.abs(x));if(equal)approximate++;
  }
  if(!equal)throw Error('BoundingBox mismatch row '+i+' '+row.join(' ')+' col '+j+': expected '+e+', got '+a);
 }
}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:'exact except nonzero atan2-derived normal components: 8*epsilon*max(1,abs(expected))',approximateComparisons:approximate,numericComparison:'binary64 bytes; NaN canonicalized; signed zero exact',integration:'real BoundingBoxData classes, BoundingBoxDisplayData, SkinData, ArmatureData, DragonBonesData and pool',normalization:'vertices base 1/length; undefined numeric fields and holes as NaN in arithmetic; references null/undefined to nil',lua,result:'passed'};fs.writeFileSync(path.join(dir,'boundingbox-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
