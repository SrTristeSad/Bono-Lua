'use strict';
// Execute genuine AnimationData/TimelineData/AnimationTimelineData and pool.
// Parent records expose the unported ArmatureData sorted-list boundary only.
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
const code=['core/BaseObject','model/AnimationData'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const fields=['frameIntOffset','frameFloatOffset','frameOffset','blendType','frameCount','playTimes','duration','scale','fadeInTime','cacheFrameRate','name'];
const groups=['Bone','Slot','Constraint','Animation'];
const maps=groups.map(k=>k[0].toLowerCase()+k.slice(1)+'Timelines').concat(['boneCachedFrameIndices','slotCachedFrameIndices']);
const rows=[];function scenario(name,steps){rows.push(['begin',name]);for(const s of steps)rows.push(s.map(String));}
scenario('raw-constructors-inheritance-and-pool',[
 ['new','raw','D'],['new','t','T'],['new','at','A'],['borrow','d','D'],['borrow','tc','T'],['borrow','ac','A'],
 ...['type','offset','frameIndicesOffset'].map(k=>['set','ac',k,42]),['set','ac','x','-0'],['set','ac','y','NaN'],
 ['return','ac'],['borrow','reused','A'],['return','tc'],['borrow','reusedT','T'],['clear','d'],['return','d'],['borrow','reusedD','D']]);
scenario('cache-uninitialized-fields-retains-original-partial-state',[
 ['new','d','D'],['cache','d',24],['set','d','scale',1],['cache','d',24],['cache','d','undefined'],['clear','d']]);
scenario('all-timeline-maps-duplicates-lookups-and-recycling',[
 ['borrow','d','D'],['borrow','t','T'],['borrow','a','A'],
 ...groups.flatMap(g=>[['get','missing'+g,g,'d','absent'],['add','d',g,'root','t'],['add','d',g,'root','t'],['add','d',g,'root','a'],['get','found'+g,g,'d','root']]),
 ['link','d','actionTimeline','t'],['link','d','zOrderTimeline','a'],['return','d'],['borrow','first','T'],['borrow','second','A'],['borrow','again','D']]);
scenario('strict-identity-with-equal-timelines',[
 ['borrow','d','D'],['borrow','a','T'],['borrow','b','T'],['equal','a'],['equal','b'],
 ...groups.flatMap(g=>[['add','d',g,'same','a'],['add','d',g,'same','b'],['add','d',g,'same','a']]),['clear','d']]);
scenario('ordered-map-clearing-with-numeric-keys',[
 ['borrow','d','D'],...['z','a','10','2','-0','01'].flatMap((name,i)=>[['borrow','t'+i,'T'],['add','d','Bone',name,'t'+i]]),
 ['deleteKey','d','boneTimelines','z'],['putList','d','boneTimelines','z','t0'],['clear','d'],...Array.from({length:6},(_,i)=>['borrow','r'+i,'T'])]);
scenario('growing-list-and-map-mutation-during-return',[
 ['borrow','d','D'],['borrow','first','T'],['borrow','late','T'],['borrow','deleted','T'],['borrow','newkey','T'],
 ['add','d','Bone','z','first'],['add','d','Bone','a','deleted'],
 ['hook','return:first','add','d','Bone','z','late'],['hook','return:late','deleteKey','d','boneTimelines','a'],
 ['hook','return:deleted','throw'],['hook','return:newkey','throw'],['clear','d'],
 ['add','d','Slot','existing','first'],['hook','return:first','add','d','Slot','new','newkey'],['clear','d']]);
scenario('return-failure-partial-state-and-retry',[
 ['borrow','d','D'],['borrow','a','T'],['borrow','b','A'],['borrow','c','T'],['add','d','Bone','first','a'],['add','d','Bone','second','b'],['add','d','Slot','last','c'],
 ['set','d','duration',123],['hook','return:b','throw'],['return','d'],['return','d'],['borrow','reused','D']]);
scenario('sparse-timeline-list-does-not-stop-before-error',[
 ['borrow','d','D'],['borrow','a','T'],['add','d','Bone','x','a'],['listLength','d','boneTimelines','x',3],['clear','d'],['listLength','d','boneTimelines','x',1],['clear','d']]);
scenario('cache-shape-one-initialized-slot-and-early-return',[
 ['borrow','d','D'],['parent','p'],['member','p','Bone','root'],['member','p','Bone','arm'],['member','p','Slot','slot'],['parentLink','d','p'],
 ['set','d','duration',1.25],['set','d','scale',0.5],['cache','d',24],['get','bone','BoneCachedFrameIndices','d','root'],['get','slot','SlotCachedFrameIndices','d','slot'],
 ['arraySet','bone',2,99],['cachedSet','d',2,'true'],['set','d','duration',4],['cache','d',60],['parentLink','d','none'],['cache','d',-1],['clear','d'],['cache','d',24]]);
scenario('zero-count-still-sets-first-cached-frame',[
 ['borrow','d','D'],['parent','p'],['member','p','Bone','bone'],['member','p','Slot','slot'],['parentLink','d','p'],
 ['set','d','duration',-1],['cache','d',1],['get','emptyBone','BoneCachedFrameIndices','d','bone'],['get','emptySlot','SlotCachedFrameIndices','d','slot'],['clear','d']]);
scenario('recache-truncates-existing-values-and-retains-unmentioned-keys',[
 ['borrow','d','D'],['parent','p'],['member','p','Bone','root'],['member','p','Slot','slot'],['parentLink','d','p'],['set','d','duration',2],['cache','d',4],
 ['cachedSet','d',7,'true'],['cachedSet','d',1,'true'],['set','d','cacheFrameRate',0],['set','d','duration',1],['cache','d',1],
 ['set','d','cacheFrameRate',0],['set','d','duration',0],['cache','d',1],
 ['get','saved','BoneCachedFrameIndices','d','root'],['clearMembers','p','Bone'],['set','d','cacheFrameRate',0],['cache','d',2],['get','still','BoneCachedFrameIndices','d','root'],['clear','d']]);
scenario('cache-parent-order-duplicates-and-getter-failure',[
 ['borrow','d','D'],['parent','p'],['member','p','Bone','same'],['member','p','Bone','same'],['member','p','Slot','slot'],['member','p','Slot','bad'],['parentLink','d','p'],
 ['failName','p','Slot',1],['set','d','duration',1],['cache','d',2],['cache','d',4],['set','d','cacheFrameRate',0],['failName','p','Slot',-1],['cache','d',3]]);
scenario('cache-parent-hole-is-an-error-after-array-allocation',[
 ['borrow','d','D'],['parent','p'],['member','p','Bone','ok'],['membersLength','p','Bone',3],['parentLink','d','p'],['set','d','duration',1],['cache','d',2],['clear','d']]);
for(const [rate,scale,duration] of [
 ['NaN',1,1],[1,'NaN',1],['Infinity',1,1],['Infinity',0,1],[-1,1,1],[0,1,1],[1,-1,1],[1,1,'NaN'],[1,1,'Infinity'],[1,1,-2],
 [1,1,-0.5],[1,1,-1.5],[2,0.25,0.1],[1,1,4294967295],[1,1,4294967294],['-0',1,'-0']
])scenario('cache-numeric-'+rate+'-'+scale+'-'+duration,[
 ['borrow','d','D'],['parent','p'],['parentLink','d','p'],['set','d','scale',scale],['set','d','duration',duration],['cache','d',rate],['cache','d',1],['clear','d']]);
for(const limit of [0,1,2,0.5])scenario('pool-limit-'+limit,[
 ['borrow','d','D'],['borrow','t','T'],['borrow','a','A'],['limit','T',limit],['limit','A',limit],['limit','D',limit],
 ['add','d','Bone','x','t'],['add','d','Slot','x','a'],['return','d'],['borrow','nextD','D'],['borrow','nextT','T'],['borrow','nextA','A']]);
scenario('binary64-fields-and-inherited-clear',[
 ['borrow','d','D'],['borrow','t','T'],['borrow','a','A'],
 ...['-0','5e-324','-5e-324','1.7976931348623157e308','NaN','Infinity','-Infinity'].flatMap(v=>[
  ...fields.filter(k=>k!=='name').map(k=>['set','d',k,v]),...['type','offset','frameIndicesOffset','x','y'].map(k=>['set','a',k,v])]),['return','a'],['clear','d']]);
let seed=0x414e494d;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<5;s++){
 const steps=[['borrow','d','D'],['parent','p'],['member','p','Bone','root'],['member','p','Slot','slot'],['parentLink','d','p'],...Array.from({length:6},(_,i)=>['borrow','t'+i,i%2?'A':'T'])];
 for(let i=0;i<100;i++){
  const g=groups[rand(4)],id='t'+rand(6),name=['z','a','2','10','-0'][rand(5)];
  switch(rand(8)){
   case 0:steps.push(['add','d',g,name,id]);break;
   case 1:steps.push(['get','lookup',g,'d',name]);break;
   case 2:steps.push(['set',id,'offset',(rand(100)-50)/8]);break;
   case 3:steps.push(['set','d','duration',rand(20)/8]);break;
   case 4:steps.push(['cache','d',rand(10)-1]);break;
   case 5:steps.push(['set','d','cacheFrameRate',0]);break;
   case 6:steps.push(['clear','d'],['parentLink','d','p']);break;
   case 7:steps.push(['set',id,'x',rand(100)/8]);break;
  }
 }
 steps.push(['return','d']);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='undefined'?undefined:s==='true'?true:s==='false'?false:s.startsWith('s:')?s.slice(2):Number(s);
let B,D,T,A,classes,objects,labels,parents,arrays,log,hooks,warnings,ids,nextId;
const ref=o=>o==null?'nil':'#'+o.hashCode;
function identity(o){if(!ids.has(o))ids.set(o,++nextId);return ids.get(o);}
function fire(k){if(hooks[k]){const command=hooks[k];delete hooks[k];execute(command);}}
function begin(){objects={};labels=new Set();parents={};arrays={};log=[];hooks={};warnings=[];ids=new WeakMap();nextId=0;const ctx=vm.createContext({console:{warn:s=>warnings.push(s)}});vm.runInContext(code,ctx);B=ctx.dragonBones.BaseObject;D=ctx.dragonBones.AnimationData;T=ctx.dragonBones.TimelineData;A=ctx.dragonBones.AnimationTimelineData;classes={D,T,A};}
function wrap(o,id){if(o._wrapped)return;o._wrapped=true;const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+id);fire('return:'+id);return original.call(this);};}
function mapName(g){return groups.includes(g)?g[0].toLowerCase()+g.slice(1)+'Timelines':g[0].toLowerCase()+g.slice(1);}
function execute(row){const [op,a,b,c,e]=row;
 if(op==='new'||op==='borrow'){const o=op==='new'?new classes[b]():B.borrowObject(classes[b]);objects[a]=o;labels.add(a);wrap(o,a);return 'object:'+ref(o);}
 if(op==='set')objects[a][b]=decode(c);
 else if(op==='add')objects[a]['add'+b+'Timeline'](c,objects[e]);
 else if(op==='get'){const value=objects[c]['get'+b+(groups.includes(b)?'Timelines':'')](e);arrays[a]=value;return value===null?'nil':'array:'+identity(value);}
 else if(op==='link')objects[a][b]=c==='none'?null:objects[c];
 else if(op==='clear')objects[a]._onClear();
 else if(op==='return')objects[a].returnToPool();
 else if(op==='hook')hooks[a]=row.slice(2);
 else if(op==='throw')throw Error('callback failure');
 else if(op==='equal'){/* Lua __eq probe must not alter source strict identity. */}
 else if(op==='deleteKey')delete objects[a][b][c];
 else if(op==='putList')objects[a][b][c]=[objects[e]];
 else if(op==='listLength')objects[a][b][c].length=Number(e);
 else if(op==='cachedSet')objects[a].cachedFrames[Number(b)]=decode(c);
 else if(op==='arraySet')arrays[a][Number(b)]=decode(c);
 else if(op==='limit')B.setMaxCount(classes[a],Number(b));
 else if(op==='cache')objects[a].cacheFrames(Number(b));
 else if(op==='parent')parents[a]={id:a,sortedBones:[],sortedSlots:[],failBone:-1,failSlot:-1};
 else if(op==='parentLink')objects[a].parent=b==='none'?null:parents[b];
 else if(op==='member'){
  const p=parents[a],list=p[b==='Bone'?'sortedBones':'sortedSlots'],index=list.length;
  const item={_name:c};Object.defineProperty(item,'name',{get(){log.push('name:'+a+':'+b+':'+index+':'+c);if(p['fail'+b]===index)throw Error('name failure');return c;}});list.push(item);
 }
 else if(op==='failName')parents[a]['fail'+b]=Number(c);
 else if(op==='clearMembers')parents[a][b==='Bone'?'sortedBones':'sortedSlots'].length=0;
 else if(op==='membersLength')parents[a][b==='Bone'?'sortedBones':'sortedSlots'].length=Number(c);
 else throw Error('Unknown command '+op);
 return 'void';
}
function array(a,kind){if(a==null)return 'nil';return identity(a)+':'+scalar(a.length)+':'+Object.keys(a).filter(k=>/^(0|[1-9]\d*)$/.test(k)&&Number(k)<4294967295&&a[k]!==undefined).sort((a,b)=>Number(a)-Number(b)).map(k=>k+'='+(kind==='timeline'?ref(a[k]):scalar(a[k]))).join(',');}
function describe(o){const out=[o instanceof D?'D':o instanceof A?'A':'T',ref(o),o._isInPool?'1':'0'];
 if(o instanceof D){out.push(...fields.map(k=>scalar(o[k])),o.parent==null?'nil':o.parent.id,ref(o.actionTimeline),ref(o.zOrderTimeline),array(o.cachedFrames));for(const k of maps)out.push(identity(o[k])+':'+Object.keys(o[k]).sort().map(n=>n+'='+array(o[k][n],k.endsWith('Timelines')?'timeline':'number')).join(';'));}
 else out.push(...['type','offset','frameIndicesOffset','x','y'].map(k=>scalar(o[k])));return out.join(':');}
function snapshot(){return [scalar(B._hashCode),[...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(arrays).sort().map(k=>k+'='+array(arrays[k],k.startsWith('found')||k.startsWith('missing')||k==='lookup'?'timeline':'number')).join('|'),
 Object.keys(parents).sort().map(k=>k+'='+identity(parents[k].sortedBones)+':'+parents[k].sortedBones.length+':'+identity(parents[k].sortedSlots)+':'+parents[k].sortedSlots.length+':'+parents[k].failBone+':'+parents[k].failSlot).join('|'),
 Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),Object.keys(B._maxCountMap).sort().map(k=>k+'='+scalar(B._maxCountMap[k])).join('|'),log.join('|'),Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|')];}
const expected=[];for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag=e.name==='RangeError'?'range':'error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'animationdata-cases.tsv');fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'animationdata-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/animationdata_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'animationdata-'+path.basename(lua)+'-actual.tsv'),actual);const lines=actual.replace(/\r?\n$/,'').split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('AnimationData transcript length differs');let comparisons=0;
for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('AnimationData mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',normalization:'object null/undefined to nil; array holes/undefined by value and length',lua,result:'passed'};fs.writeFileSync(path.join(dir,'animationdata-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
