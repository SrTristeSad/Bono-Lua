'use strict';
// Compare real Armature orchestration and queries with the pinned TypeScript.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationConfig','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint','animation/BaseTimelineState','animation/TimelineState','animation/AnimationState','animation/Animation'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');



let warnings=0;const ctx=vm.createContext({console:{warn(){warnings++;},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const fixture=fs.readFileSync(path.join(root,'examples/playback_ske.json'),'utf8');
const cases=[];for(const clip of ['move','alt','controller','empty'])for(const cache of [0,4])for(const speed of [-1,.5,1])for(const alpha of [.25,1])for(let sort=0;sort<3;sort++)for(let clock=0;clock<2;clock++)cases.push([clip,cache,speed,alpha,sort,clock,'normal',0,0]);
for(let mask=0;mask<8;mask++)for(let segment=0;segment<6;segment++)for(let sort=0;sort<3;sort++)cases.push(['empty',0,1,1,sort,0,'queries',mask,segment]);
for(const op of ['reinit','reenterSlot','reenterProxy','locked','alphaParent','texture','textureFalse','actionSelf','actionSlot','actionBone','actionMissing','actionOther','actionNoData','proxyAction','dispose','noModel','noParentData','initError','dbUpdateError','readonly','changeClock','flip','cacheSame','complete'])cases.push(['move',4,1,.5,1,1,op,7,0]);
if(process.argv[4]!==undefined){const n=+process.argv[4];cases.splice(0,cases.length,cases[n]);}
function scalar(v){if(v===null||v===undefined)return'u';if(typeof v==='boolean')return String(v);if(typeof v==='string')return's'+Buffer.from(v).toString('hex');if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}

const ak=['_lockUpdate','_slotsDirty','_zOrderDirty','_zIndexDirty','_alphaDirty','_cacheFrameIndex','_alpha','_globalAlpha','_isInPool'];
const bk=['_alpha','_globalAlpha','_transformDirty','_childrenTransformDirty','_localDirty','_cachedFrameIndex'];
const slk=['_alpha','_globalAlpha','_zOrder','_zIndex','_displayIndex','_transformDirty','_colorDirty','_verticesDirty','_cachedFrameIndex'];
function execute(c){const[clip,cache,speed,alpha,sort,useClock,op,mask,segment]=c;warnings=0;ctx.__json=fixture;const raw=vm.runInContext('JSON.parse(__json)',ctx);
if(op==='queries'){const a=raw.armature[0];a.bone=vm.runInContext('([{name:"root"}])',ctx);delete a.ik;a.animation=vm.runInContext('([{name:"empty",duration:24}])',ctx);for(let i=0;i<a.slot.length;i++){a.slot[i].parent='root';a.skin[0].slot[i].display=vm.runInContext('([{name:"box",type:"boundingBox",subType:"rectangle",width:10,height:10}])',ctx);a.skin[0].slot[i].display[0].transform={x:[0,10,-10][i],y:0};}}
const gd=new d.ObjectDataParser().parseDragonBonesData(raw),ad=gd.getArmature('playback');if(cache)ad.cacheFrames(cache);
const arm=B.borrowObject(d.Armature),display={},hooks=[],dispatch=[],proxies=[],children=[],ownedActions=[];let updates=0,clears=0,reentered=false,queueAction;
const proxy={hasDBEventListener(){return true;},dispatchDBEvent(type,e){dispatch.push(type+'~'+e.name+'~'+scalar(e.time));},dbInit(value){proxies.push(['init',value===arm,value._armatureData===ad,value._animation!==null,value._animation._armature===null,value.display===display].join('~'));if(op==='initError')throw Error('init');},dbUpdate(){updates++;proxies.push('update~'+arm._lockUpdate);if(op==='reenterProxy'&&updates===1)arm.advanceTime(0);if(op==='proxyAction'&&updates===1)queueAction('self');if(op==='dbUpdateError'&&updates===1)throw Error('update');},dbClear(){clears++;}};
const core=new d.DragonBones({dispatchDBEvent(type,e){dispatch.push('sound~'+e.name+'~'+scalar(e.time));}});
const out=[];const push=(...v)=>out.push(...v.map(String));const fields=(o,keys)=>push(...keys.map(k=>scalar(o[k])));let initStatus='ok';try{arm.init(ad,proxy,display,core);}catch(e){initStatus='error';}push(initStatus,proxies.join('|'),arm.proxy===proxy,arm.eventDispatcher===proxy,arm.getDisplay()===display);
if(op==='initError'||op==='noModel'||op==='noParentData'){if(op==='noModel')arm._armatureData=null;if(op==='noParentData')ad.parent=null;for(let i=0;i<2;i++){let status='ok';try{arm.advanceTime(.25);}catch(e){status='error';}push(status);fields(arm,ak);push(warnings,updates);}if(op==='noParentData')ad.parent=gd;arm.returnToPool();push(clears);gd.returnToPool();return out;}
for(const bd of ad.sortedBones)B.borrowObject(bd.type===1?d.Surface:d.Bone).init(bd,arm);
class Observer extends d.Slot{static toString(){return'[test.PlaybackSlot]';}}
for(const hook of ['_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'])Observer.prototype[hook]=function(){hooks.push(this.name+':'+hook);if(op==='reenterSlot'&&!reentered&&arm._lockUpdate){reentered=true;arm.advanceTime(99);}};
B.clearPool(Observer);for(const sd of ad.sortedSlots){const slot=B.borrowObject(Observer);slot.init(sd,arm,{},{});const displays=ad.defaultSkin.getDisplays(sd.name);slot.displayFrameCount=displays.length;displays.forEach((v,i)=>{slot.replaceRawDisplayData(v,i);slot.replaceDisplay(v.type===2?slot.meshDisplay:slot.rawDisplay,i);});slot._setDisplayIndex(0);slot._updateDisplayData();}
for(const name in ad.constraints){const ik=B.borrowObject(d.IKConstraint);ik.init(ad.constraints[name],arm);arm._addConstraint(ik);}

const animation=arm.animation;animation.timeScale=speed;const state=animation.play(clip,op==='complete'?1:0);if(op==='complete')state.autoFadeOutTime=.125;arm._alpha=alpha;
if(op==='alphaParent')arm._parent=arm.getSlot('plain');
if(op==='actionSlot'||op==='actionBone'){for(const name of ['plain','extra']){const child=B.borrowObject(d.Armature);child.init(ad,{dbInit(){},dbUpdate(){},dbClear(){},hasDBEventListener(){return true;},dispatchDBEvent(type,e){dispatch.push('child~'+type+'~'+e.name);}}, {},core);for(const bd of ad.sortedBones)B.borrowObject(bd.type===1?d.Surface:d.Bone).init(bd,child);children.push(child);arm.getSlot(name).replaceDisplay(child,0);}}
queueAction=function(kind){const action=B.borrowObject(d.EventObject);if(kind!=='nil'){const data=B.borrowObject(d.ActionData);data.type=kind==='other'?10:0;data.name='alt';ownedActions.push(data);action.actionData=data;}if(kind==='slot')action.slot=arm.getSlot('plain');if(kind==='bone')action.bone=arm.getBone('child');if(kind==='missing')action.slot=arm.getSlot('meshSlot');arm._bufferAction(action,true);arm._bufferAction(action,false);};
if(useClock)arm.clock=core.clock;
class Atlas extends d.TextureAtlasData{static toString(){return '[test.ArmatureAtlas]';}createTexture(){throw Error('Unused');}}B.clearPool(Atlas);const tex={},atlas=B.borrowObject(Atlas);let atlasHeld=false;
const nums=a=>a?Array.from(a,scalar).join(','):'';
function snap(status){push(status);fields(arm,ak);push(updates,clears,warnings,arm.animation===animation,arm.clock===core.clock,arm.proxy===proxy,arm.replacedTexture===tex,atlas._isInPool,proxies.join('|'),hooks.join('|'),dispatch.join('|'));for(const b of arm.getBones()){push(b.name);fields(b,bk);fields(b.animationPose,['x','y','rotation','skew','scaleX','scaleY']);if(b._boneData.type===1)push(nums(b._deformVertices));}for(const s of arm.getSlots()){push(s.name);fields(s,slk);push(nums(s._cachedFrameIndices),arm.getSlotByDisplay(s.display)===s,arm.getBoneByDisplay(s.display)===s.parent);for(const f of s._displayFrames)push(nums(f.deformVertices));}push(arm.getSlotByDisplay(null)===null,arm.getBoneByDisplay({})===null);for(const a of animation.getStates()){push(a.name,scalar(a.currentTime),a._fadeState,a._subFadeState,a._playheadState);}push(arm._actions.length,core._events.map(e=>e.type+'~'+e.name+'~'+scalar(e.time)).join('|'),core._objects.map(o=>o.constructor.toString()).join('|'));for(const child of children)push(child.animation.lastAnimationName,child.animation.getStates().length,scalar(child._globalAlpha),child._lockUpdate);}
function query(){const seg=[[-30,0,30,0],[30,0,-30,0],[0,-30,0,30],[-30,-30,30,30],[0,0,1,1],[-30,30,30,30]][segment];const a={x:7,y:-8},b={x:9,y:-10},n={x:11,y:-12};for(const point of [[0,0],[10,0],[30,30]]){const slot=arm.containsPoint(...point);push(slot?slot.name:'-');}const slot=arm.intersectsSegment(...seg,mask&1?a:null,mask&2?b:null,mask&4?n:null);push(slot?slot.name:'-');fields(a,['x','y']);fields(b,['x','y']);fields(n,['x','y']);}
const deltas=[0,.125,.125,.25,.5,.5,0,.25];for(let step=0;step<deltas.length;step++){hooks.length=dispatch.length=proxies.length=0;let status='ok';try{
if(step===1&&op==='reinit')arm.init(ad,{}, {},core);if(step===1&&op==='locked')arm._lockUpdate=true;if(step===2&&op==='locked')arm._lockUpdate=false;if(step===2&&op==='flip'){arm.flipX=true;arm.flipY=true;}
if(step===2&&op==='changeClock')arm.clock=null;if(step===4&&op==='changeClock')arm.clock=core.clock;
if(step===1&&op.startsWith('texture')){arm._replaceTextureAtlasData=atlas;atlasHeld=true;arm.replacedTexture=op==='textureFalse'?false:tex;arm.replacedTexture=arm.replacedTexture;}
if(step===2&&op.startsWith('action'))queueAction(({actionSelf:'self',actionSlot:'slot',actionBone:'bone',actionMissing:'missing',actionOther:'other',actionNoData:'nil'})[op]);
if(step===2&&op==='dispose')arm.dispose();
if(!arm._lockUpdate&&sort!==0){for(let i=0;i<arm.getSlots().length;i++){const s=arm.getSlots()[i];s._zIndex=sort===0?0:sort===1?0:[.002,0,-.002][i];if(sort===1)s._zOrder=0;}arm._slotsDirty=true;arm._zIndexDirty=sort===2;}if(step===3){arm._alpha=alpha/2;arm._alphaDirty=true;}
if(!useClock)arm.advanceTime(deltas[step]);core.advanceTime(deltas[step]);if(op==='queries')query();
}catch(e){status='error';}snap(status);if(op==='dispose'&&arm._isInPool)break;}
if(op==='readonly'){let status='ok';try{arm.proxy=false;}catch(e){status='error';}snap(status);}
arm._parent=null;arm.clock=null;if(!arm._isInPool)arm.returnToPool();core.advanceTime(0);core.advanceTime(0);if(!atlasHeld)atlas.returnToPool();for(const action of ownedActions)action.returnToPool();push(clears,arm._isInPool,core._objects.length,core._events.length,...children.map(c=>c._isInPool));gd.returnToPool();return out;}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'armatureruntime-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'armatureruntime-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/armatureruntime_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'armatureruntime-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/, '').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0,sourceErrors=0;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i+' '+rows[i].length+' '+expected[i].length);for(let j=0;j<rows[i].length;j++){columns++;if(expected[i][j]==='error')sourceErrors++;if(rows[i][j]!==expected[i][j])throw Error('Armature mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,comparedColumns:columns,sourceErrors,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(path.join(dir,'armatureruntime-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
