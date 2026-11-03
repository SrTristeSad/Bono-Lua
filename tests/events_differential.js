'use strict';
// Execute pinned core, event, user-data, clock and pool algorithms.
// Probes implement only the unported Armature/dispatcher/animatable boundaries.
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
const options={...converted.options,declaration:false,watch:false,preserveConstEnums:true};delete options.outFile;
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
const code=['core/BaseObject','animation/WorldClock','event/EventObject','model/UserData','core/DragonBones'].map(p=>{
 const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');
 if(!js)throw Error('Missing original emitted class '+p);return js;
}).join('\n');
const rows=[];
function scenario(name,steps){rows.push(['begin',name]);for(const step of steps)rows.push(step.map(String));}
const event=(id,type='frameEvent',arm='a')=>[['borrow',id,'E'],['set',id,'type','s:'+type],['link',id,'armature',arm]];
scenario('queue-order-and-delayed-pooling',[
 ['arm','a'],['arm','disposed'],['dispose','disposed'],...event('frame'),...event('sound','soundEvent'),...event('dead','soundEvent','disposed'),
 ['bufferEvent','frame'],['bufferEvent','frame'],['bufferEvent','sound'],['bufferEvent','dead'],['tick',0.25],['tick',0],
 ['borrow','reuse1','E'],['borrow','reuse2','E'],['borrow','reuse3','E'],['readonly','clock'],['readonly','eventManager']]);
scenario('same-dispatch-growth-and-mutation',[
 ['arm','a'],...event('first'),...event('late','soundEvent'),['bufferEvent','first'],
 ['hook','dispatch:a','bufferEvent','late'],['tick',1],['tick',1],...event('changing'),['bufferEvent','changing'],
 ['hook','dispatch:a','set','changing','type','s:soundEvent'],['tick',1],['tick',1]]);
scenario('disposed-after-dispatch-check-still-sounds',[
 ['arm','a'],...event('e','soundEvent'),['bufferEvent','e'],['hook','dispatch:a','dispose','a'],['tick',0.5],['tick',0.5]]);
scenario('failure-in-armature-dispatch',[
 ['arm','a'],...event('first'),...event('bad','soundEvent'),['bufferEvent','first'],['bufferEvent','bad'],
 ['hook','dispatch:a','hook','dispatch:a','throw'],['tick',1],['tick',1],['tick',1]]);
scenario('failure-in-global-dispatch',[
 ['arm','a'],...event('e','soundEvent'),['bufferEvent','e'],['hook','manager','throw'],['tick',0],['tick',0],['tick',0]]);
scenario('buffer-objects-before-clock-and-dynamic-iteration',[
 ['borrow','u','U'],['addInt','u',123],['borrow','v','U'],['addInt','v',456],['bufferObject','u'],['bufferObject','u'],
 ['hook','return:u','bufferObject','v'],['hook','tick','borrow','again','U'],['tick',0.5],['tick',0.5]]);
scenario('return-failure-retains-queue-and-partial-pool',[
 ['borrow','u','U'],['borrow','v','U'],['bufferObject','u'],['bufferObject','v'],['hook','return:v','throw'],['tick',0.5],['tick',0.5],['tick',0.5]]);
scenario('clock-failure-retains-events',[
 ['arm','a'],...event('e'),['bufferEvent','e'],['hook','tick','throw'],['tick',1],['tick',1],['tick',0]]);
scenario('event-clock-enqueue-and-dispatch-reentry',[
 ['arm','a'],...event('e','soundEvent'),['hook','tick','bufferEvent','e'],['tick',1],['tick',0],
 ...event('x'),['bufferEvent','x'],['hook','dispatch:a','tick',0.125],['tick',1],['tick',0]]);
scenario('nested-return-clears-growing-queue-like-original',[
 ['borrow','u','U'],['borrow','v','U'],['bufferObject','u'],['bufferObject','v'],['hook','return:u','tick',0.25],['tick',1],['tick',1]]);
scenario('strict-identity-despite-lua-equality',[
 ['probe','p'],['probe','q'],['bufferObject','p'],['bufferObject','q'],['bufferObject','p'],['tick',1],
 ['arm','a'],...event('e'),...event('f'),['equal','e'],['equal','f'],['bufferEvent','e'],['bufferEvent','f'],['tick',1],['tick',0]]);
scenario('event-constructor-clear-and-non-owning-payload',[
 ['new','raw','E'],['borrow','e','E'],['borrow','u','U'],['borrow','act','A'],['link','act','data','u'],['link','e','data','u'],['link','e','actionData','act'],
 ['set','e','time','-0'],['set','e','name','s:hello'],['return','e'],['borrow','reuse','E'],['return','act'],['borrow','again','U']]);
scenario('action-conversion-lookups-stale-fields-and-errors',[
 ['arm','a'],['borrow','e','E'],['borrow','act','A'],['borrow','u','U'],['link','act','data','u'],['set','act','name','s:run'],['set','e','time',3.25],
 ['convert','act','e','a'],['bone','act','b1'],['slot','act','s1'],['set','act','type',10],['convert','act','e','a'],
 ['bone','act','none'],['slot','act','none'],['set','act','type',11],['convert','act','e','a'],
 ['set','act','type',999],['convert','act','e','a'],['bone','act','missing'],['slot','act','missing'],['convert','act','e','a'],
 ['bone','act','b1'],['slot','act','s1'],['hook','bone:a','throw'],['convert','act','e','a'],['convert','act','e','a'],
 ['hook','slot:a','throw'],['convert','act','e','a'],['return','act'],['borrow','u2','U']]);
scenario('userdata-defaults-index-boundaries-and-array-identity',[
 ['new','raw','U'],['borrow','u','U'],['borrow','act','A'],['new','rawact','A'],
 ...['-0','0','1','2','-1','0.5','NaN','Infinity','-Infinity','undefined'].flatMap(i=>[['getInt','u',i],['getFloat','u',i],['getString','u',i]]),
 ...['-0','NaN','Infinity','-Infinity','5e-324','1.2345678901234567','2147483648'].flatMap(n=>[['addInt','u',n],['addFloat','u',n]]),
 ['addString','u','s:'],['addString','u','s:hello'],['addString','u','s:ação'],
 ...['0','1','2','3','6','7','-1','0.5','1.5','5e-324','0.9999999999999999','1.0000000000000002','NaN','undefined'].flatMap(i=>[['getInt','u',i],['getFloat','u',i],['getString','u',i]]),
 ['link','act','data','u'],['return','act'],['borrow','again','U'],['borrow','againact','A'],['clear','again']]);
scenario('action-payload-return-failure-partial-state',[
 ['borrow','u','U'],['borrow','act','A'],['set','act','type',11],['set','act','name','s:sound'],['addInt','u',42],['link','act','data','u'],
 ['hook','return:u','throw'],['return','act'],['return','act'],['return','act'],['borrow','reuse','A']]);
for(const limit of [0,1,2])scenario('pool-capacity-'+limit,[
 ['limit','E',limit],['arm','a'],...event('e'),...event('f'),['bufferEvent','e'],['bufferEvent','f'],['tick',1],['tick',0],['borrow','r','E'],['borrow','s','E']]);
scenario('missing-event-manager-preserves-armature-dispatch',[
 ['arm','a'],...event('e','soundEvent'),['bufferEvent','e'],['manager','off'],['tick',0],['manager','on'],['tick',0],['tick',0]]);
let seed=0x45564e54;const rand=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let s=0;s<6;s++){
 const steps=[['arm','a'],['arm','b'],...Array.from({length:8},(_,i)=>event('e'+i,i%2?'soundEvent':'frameEvent',i%3?'a':'b')).flat(),['borrow','u','U'],['borrow','act','A']];
 for(let i=0;i<100;i++){
  const id='e'+rand(8);
  switch(rand(9)){
   case 0:steps.push(['bufferEvent',id]);break;
   case 1:steps.push(['tick',[0,0.125,1,-1][rand(4)]]);break;
   case 2:steps.push(['set',id,'name','s:n'+rand(9)]);break;
   case 3:steps.push(['set',id,'type','s:'+(rand(2)?'soundEvent':'frameEvent')]);break;
   case 4:steps.push(['link',id,'armature',rand(2)?'a':'b']);break;
   case 5:steps.push(['dispose',rand(2)?'a':'b']);break;
   case 6:steps.push(['revive',rand(2)?'a':'b']);break;
   case 7:steps.push(['addFloat','u',rand(100)/8]);break;
   case 8:steps.push(['getFloat','u',rand(12)-1]);break;
  }
 }
 steps.push(['tick',1],['tick',0]);scenario('deterministic-'+s,steps);
}
function scalar(v){if(v===undefined)return 'undefined';if(v===null)return 'nil';if(typeof v==='boolean')return v?'true':'false';if(typeof v!=='number')return 's:'+v;if(Number.isNaN(v))return 'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return 'n:'+b.toString('hex');}
const decode=s=>s==='undefined'?undefined:s.startsWith('s:')?s.slice(2):Number(s);
let d,B,D,E,U,A,engine,objects,arms,labels,log,hooks,warnings,infos,arrayIds,nextArray,manager;
function ref(o){if(o==null)return 'nil';return o.hashCode!==undefined?'#'+o.hashCode:o.id;}
function fire(key){const command=hooks[key];if(command){delete hooks[key];execute(command);}}
function wrap(o,id){const original=o.returnToPool;o.returnToPool=function(){log.push('return:'+id);fire('return:'+id);return original.call(this);};}
function begin(){
 log=[];hooks={};warnings=[];infos=[];objects={};arms={};labels=new Set();arrayIds=new WeakMap();nextArray=0;
 class HostDate {getTime(){return 1700000000000;}}HostDate.now=()=>1700000000000;
 const ctx=vm.createContext({Date:HostDate,console:{warn:s=>warnings.push(s),info:s=>infos.push(s)}});vm.runInContext(code,ctx);
 d=ctx.dragonBones;B=d.BaseObject;D=d.DragonBones;E=d.EventObject;U=d.UserData;A=d.ActionData;
 manager={dispatchDBEvent(type,e){log.push('manager:'+type+':'+ref(e));fire('manager');}};engine=new D(manager);
 engine.clock.add({clock:null,advanceTime(dt){log.push('tick:'+scalar(dt));fire('tick');}});
}
function execute(row){
 const [op,a,b,c]=row;const classes={E,U,A};let value;
 if(op==='borrow'||op==='new'){value=op==='borrow'?B.borrowObject(classes[b]):new classes[b]();objects[a]=value;labels.add(a);if(!value._wrapped){wrap(value,a);value._wrapped=true;}return 'object:'+ref(value);}
 if(op==='arm'){arms[a]={id:'arm:'+a,_armatureData:{},eventDispatcher:{dispatchDBEvent(type,e){log.push('dispatch:'+a+':'+type+':'+ref(e));fire('dispatch:'+a);}},getBone(name){log.push('bone:'+a+':'+name);fire('bone:'+a);return name==='missing'?null:{id:'bone:'+a+':'+name};},getSlot(name){log.push('slot:'+a+':'+name);fire('slot:'+a);return name==='missing'?null:{id:'slot:'+a+':'+name};}};return 'void';}
 if(op==='probe'){objects[a]={id:a,returnToPool(){log.push('return:'+a);fire('return:'+a);}};labels.add(a);return 'void';}
 if(op==='equal'){/* Lua __eq must not change strict JS identity. */return 'void';}
 if(op==='hook'){hooks[a]=row.slice(2);return 'void';}
 if(op==='throw')throw Error('callback failure');
 if(op==='dispose'||op==='revive'){arms[a]._armatureData=op==='dispose'?null:{};return 'void';}
 if(op==='set'){objects[a][b]=decode(c);return 'void';}
 if(op==='link'){objects[a][b]=c==='none'?null:objects[c]||arms[c];return 'void';}
 if(op==='bone'||op==='slot'){objects[a][op]=b==='none'?null:{name:b};return 'void';}
 if(op==='convert'){E.actionDataToInstance(objects[a],objects[b],arms[c]);return 'void';}
 if(op==='bufferEvent'||op==='bufferObject'){engine[op](objects[a]);return 'void';}
 if(op==='tick'){engine.advanceTime(Number(a));return 'void';}
 if(op==='return'||op==='clear'){objects[a][op==='return'?'returnToPool':'_onClear']();return 'void';}
 if(op==='limit'){B.setMaxCount(classes[a],Number(b));return 'void';}
 if(op==='manager'){engine._eventManager=a==='off'?null:manager;return 'void';}
 if(op==='readonly'){engine[a]={};return 'void';}
 if(/^add(Int|Float|String)$/.test(op)){objects[a][op](decode(b));return 'void';}
 if(/^get(Int|Float|String)$/.test(op))return scalar(objects[a][op](decode(b)));
 throw Error('Unknown command '+op);
}
function array(a){if(!arrayIds.has(a))arrayIds.set(a,++nextArray);return arrayIds.get(a)+'['+a.map(scalar).join(',')+']';}
function describe(o){
 if(!o)return 'nil';if(o.hashCode===undefined)return 'probe:'+o.id;
 const base=[ref(o),o._isInPool?'1':'0'];
 if(o instanceof U)return ['U',...base,array(o.ints),array(o.floats),array(o.strings)].join(':');
 if(o instanceof A)return ['A',...base,scalar(o.type),scalar(o.name),o.bone?o.bone.name:'nil',o.slot?o.slot.name:'nil',ref(o.data)].join(':');
 return ['E',...base,scalar(o.time),scalar(o.type),scalar(o.name),...['armature','bone','slot','animationState','actionData','data'].map(k=>ref(o[k]))].join(':');
}
function snapshot(){return [[D.VERSION,D.yDown,D.debug,D.debugDraw,engine.clock===engine._clock,engine.eventManager===engine._eventManager,engine.eventManager==null?'nil':'manager',...['START','LOOP_COMPLETE','COMPLETE','FADE_IN','FADE_IN_COMPLETE','FADE_OUT','FADE_OUT_COMPLETE','FRAME_EVENT','SOUND_EVENT'].map(k=>E[k])].join(','),scalar(B._hashCode),scalar(engine.clock.time),engine._objects.map(ref).join(','),engine._events.map(ref).join(','),
 [...labels].sort().map(k=>k+'='+describe(objects[k])).join('|'),Object.keys(arms).sort().map(k=>k+'='+(arms[k]._armatureData===null?'disposed':'live')).join('|'),
 Object.keys(B._poolsMap).sort().map(k=>k+'='+B._poolsMap[k].map(ref).join(',')).join('|'),log.join('|'),
 Object.keys(hooks).sort().map(k=>k+'='+hooks[k].join(',')).join('|'),warnings.join('|'),infos.join('|').replace(/\n/g,'~')];}
const expected=[];
for(let i=0;i<rows.length;i++){let tag='void';if(rows[i][0]==='begin')begin();else{warnings=[];try{tag=execute(rows[i]);}catch(e){tag='error';}}expected.push([String(i),tag,...snapshot()]);}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const input=path.join(dir,'events-cases.tsv');
fs.writeFileSync(input,rows.map(r=>r.join('\t')).join('\n')+'\n');fs.writeFileSync(path.join(dir,'events-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');
// Every enum value is read from emitted original const enums, not copied into oracle expectations.
const enumExpected=Object.keys(d).filter(k=>d[k]&&typeof d[k]==='object'&&Object.keys(d[k]).some(n=>typeof d[k][n]==='number')).sort().flatMap(k=>Object.keys(d[k]).filter(n=>typeof d[k][n]==='number').sort().map(n=>[k,n,d[k][n]].join('\t')));
fs.writeFileSync(path.join(dir,'events-enums-original.tsv'),enumExpected.join('\n')+'\n');
const actual=cp.execFileSync(lua,['tests/events_differential.lua',input],{cwd:root,encoding:'utf8',maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'events-'+path.basename(lua)+'-actual.tsv'),actual);
const lines=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(lines.length!==expected.length)throw Error('Event transcript length differs '+lines.length+' / '+expected.length);
let comparisons=0;for(let i=0;i<expected.length;i++)for(let j=0;j<expected[i].length;j++){comparisons++;if(lines[i][j]!==expected[i][j])throw Error('Event mismatch row '+i+' '+rows[i].join(' ')+' col '+j+': expected '+expected[i][j]+', got '+lines[i][j]);}
const enumActual=fs.readFileSync(path.join(dir,'events-'+path.basename(lua)+'-enums.tsv'),'utf8').trimEnd().split('\n');if(enumExpected.join('\n')!==enumActual.join('\n'))throw Error('Enum mismatch');
const result={upstream:PIN,scenarios:rows.filter(r=>r[0]==='begin').length,operations:rows.length,comparedColumns:comparisons,enumValues:enumExpected.length,tolerance:0,numericComparison:'binary64 bytes; NaN canonicalized',referenceNormalization:'null and undefined object references map to nil',lua,result:'passed'};
fs.writeFileSync(path.join(dir,'events-'+path.basename(lua)+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
