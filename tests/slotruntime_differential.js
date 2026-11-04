'use strict';
// Execute pinned Slot display-data selection with real model/runtime objects.
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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
const fixtures=[fs.readFileSync(path.join(root,'examples/bones_ske.json'),'utf8'),fs.readFileSync(path.join(root,'examples/surface_ske.json'),'utf8')];
const cases=[];
for(let a=0;a<8;a++)for(let b=0;b<8;b++)for(let dup=0;dup<2;dup++)for(const op of ['normal','failInit','failDispose','list','emptySetter','hiddenSetter','opaqueEq','readList'])cases.push(['replace',a,b,dup,op]);
for(let geom=0;geom<5;geom++)for(let display=0;display<5;display++)for(let cache=0;cache<2;cache++)for(const op of ['normal','cacheRestore','reuseCache','parentDirty','meshReset','meshAgain','hide','invalid','_onUpdateDisplay','_replaceDisplay','_updateFrame','_updateVisible','_updateBlendMode','_updateColor','_updateZOrder','_updateMesh','_updateTransform'])cases.push(['update',geom,display,cache,op]);
for(let inherit=0;inherit<2;inherit++)for(let actions=0;actions<3;actions++)for(let clock=0;clock<2;clock++)for(const op of ['attach','detach','replace','clockSwap','dispose','cacheRate','appendActions','readonly'])cases.push(['child',inherit,actions,clock,op]);
const flagKeys=['_displayDataDirty','_displayDirty','_geometryDirty','_textureDirty','_visibleDirty','_blendModeDirty','_colorDirty','_zOrderDirty','_verticesDirty','_transformDirty','_globalDirty','_cachedFrameIndex','_displayIndex'];
function scalar(v){if(v===undefined)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const matrix=m=>['a','b','c','d','tx','ty'].map(k=>scalar(m[k])).join(',');
function execute(c){const [family,a,b,k,op]=c,surface=family==='update'&&a>=3;d.DragonBones.yDown=true;ctx.__json=fixtures[surface?1:0];const gd=new d.ObjectDataParser().parseDragonBonesData(vm.runInContext('JSON.parse(__json)',ctx)),ad=gd.getArmature(gd.armatureNames[0]);const core=new d.DragonBones(null),arm=B.borrowObject(d.Armature);arm._armatureData=ad;arm._dragonBones=core;
 const ids=new Map(),owned=[],trace=[],children=[];let fail='',meshReset=false;
 const raw={},mesh={},A={},Q={},C0={},C1={};for(const [v,id]of [[raw,'raw'],[mesh,'mesh'],[A,'A'],[Q,'B'],[false,'false'],[0,'zero'],['','empty'],[C0,'container0'],[C1,'container1'],[core.clock,'clock0'],[arm,'arm']])ids.set(v,id);
 A.display=C0;A._armatureData=ad;A.clock=core.clock;
 const id=v=>v==null?'nil':ids.get(v)||'unexpected';
 for(const bd of ad.sortedBones){const bone=B.borrowObject(bd.type===1?d.Surface:d.Bone);bone.init(bd,arm);ids.set(bone,'bone:'+bd.name);if(surface&&bd.type===1)bone._deformVertices[9]=80;bone.invalidUpdate();bone.update(-1);}
 const parent=arm.getBone(surface?'grid':'child');const sd=B.borrowObject(d.SlotData);sd.name='probe';sd.parent=parent.boneData;sd.color=new d.ColorTransform();ad.addSlot(sd);
 class Observer extends d.Slot{static toString(){return'[test.SlotRuntimeObserver]';}}
 for(const name of ['_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'])Observer.prototype[name]=function(v,retain){trace.push([name,id(v),retain===undefined?'u':String(retain),id(this.display),String(this._verticesDirty),String(this._transformDirty)].join(':'));if(name==='_updateMesh'&&meshReset)this._verticesDirty=true;if(fail===name)throw Error('injected');};
 B.clearPool(Observer);const s=B.borrowObject(Observer);s.init(sd,arm,raw,mesh);ids.set(s,'slot');const held=[];
 const values=[null,raw,mesh,A,Q,false,0,''];const image=B.borrowObject(d.ImageDisplayData);image.transform.x=5;owned.push(image);ids.set(image,'image');
 function frames(n){s.displayFrameCount=n;for(let i=0;i<n;i++){const f=s.getDisplayFrameAt(i);ids.set(f,'frame'+i);f.rawDisplayData=image;held.push(f);}}
 if(family==='replace'){frames(op==='emptySetter'?0:2);if(s.displayFrameCount){s._displayFrames[0].display=values[a];s._displayFrames[1].display=k?values[a]:Q;s._setDisplayIndex(0);s.update(-1);}trace.length=0;if(op==='failInit')fail='_initDisplay';if(op==='failDispose')fail='_disposeDisplay';if(op==='hiddenSetter'){s._setDisplayIndex(-1);s.update(-1);trace.length=0;}}
 if(family==='update'){frames(1);if(a>0&&a!==4){const model=B.borrowObject(d.MeshDisplayData);owned.push(model);model.geometry.data=gd;ids.set(model,'meshData');ids.set(model.geometry,'geometry');if(a===2){model.geometry.weight=B.borrowObject(d.WeightData);const missing=B.borrowObject(d.BoneData);missing.name='absent';owned.push(missing);for(const bd of [ad.sortedBones[0],missing,parent.boneData])model.geometry.weight.addBone(bd);}s._displayFrames[0].rawDisplayData=model;}s._displayFrames[0].display=[raw,mesh,A,null,false][b];if(k)s._cachedFrameIndices=[];trace.length=0;if(op[0]==='_')fail=op;meshReset=op==='meshReset';}
 let otherClock=null;
 if(family==='child'){for(let i=0;i<2;i++){const cd=B.borrowObject(d.ArmatureData);cd.name='child'+i;gd.addArmature(cd);const child=B.borrowObject(d.Armature);child._armatureData=cd;child._dragonBones=core;child._display=i?C1:C0;child.inheritAnimation=!!a;ids.set(child,'child'+i);children.push(child);}if(k)arm.clock=core.clock;arm.cacheFrameRate=12;frames(1);const model=B.borrowObject(d.ArmatureDisplayData);owned.push(model);if(b){for(let i=0;i<b;i++){const action=B.borrowObject(d.ActionData);action.type=0;action.name='action'+i;action.bone=parent.boneData;action.slot=sd;model.actions.push(action);}}s._displayFrames[0].rawDisplayData=model;s._displayFrames[0].display=children[0];trace.length=0;}
 const result=[];
 function array(v,fn){if(v==null)return'nil';return v.length+':'+Array.from({length:v.length},(_,i)=>fn(v[i])).join(',');}
 function snap(status){return [status,id(s.display),id(s.childArmature),array(s.displayList,id),s.displayFrameCount,s.displayIndex,id(s._displayFrame),flagKeys.map(x=>scalar(s[x])).join(','),matrix(s.globalTransformMatrix),['x','y','skew','rotation','scaleX','scaleY'].map(x=>scalar(s.global[x])).join(','),array(s._cachedFrameIndices,scalar),array(gd.cachedFrames,scalar),array(s._geometryBones,id),trace.join(';'),array(arm._actions,e=>[e.name,id(e.armature),id(e.bone),id(e.slot)].join('/')),children.map(x=>[id(x.parent),id(x.clock),x.cacheFrameRate,x._lockUpdate,x._isInPool].join('/')).join(','),array(core._objects,id),[id(arm.clock),core.clock.contains(arm),...children.map(x=>core.clock.contains(x)),otherClock?otherClock.contains(arm):false].join(','),s.getDisplay()===s.display].map(String);}
 function stage(fn){let status='ok';try{fn();}catch(e){status='error';}result.push(...snap(status));}
 stage(()=>{if(family==='replace'){if(op==='list')s.displayList=[values[b],null,values[a]];else if(op==='emptySetter'||op==='hiddenSetter')s.display=values[b];else if(op==='readList'){const copy=s.displayList;copy[0]=values[b];s.setDisplay(values[b]);}else s.replaceDisplay(values[b],0);}else{s._setDisplayIndex(0);s.update(family==='update'&&k?0:-1);}});
 fail='';stage(()=>s.update(family==='update'&&k?0:-1));
 stage(()=>{if(family==='update'){if(op==='cacheRestore'){s._cachedFrameIndex=-1;s.globalTransformMatrix.identity();s.update(k?0:-1);}else if(op==='reuseCache'){parent._childrenTransformDirty=false;s._transformDirty=false;s.update(1);}else if(op==='parentDirty'){parent.offset.x=10;parent.invalidUpdate();parent.update(-1);s._transformDirty=false;s.update(1);}else if(op==='meshAgain'){s._verticesDirty=false;parent._childrenTransformDirty=true;s.update(k?0:-1);}else if(op==='hide')s.displayIndex=-1;else{s.invalidUpdate();s.update(k?0:-1);}}else if(family==='replace'){s.displayIndex=0;}else{if(op==='detach')s.display=null;if(op==='replace')s.childArmature=children[1];if(op==='clockSwap'){otherClock=new d.WorldClock(0);ids.set(otherClock,'clock1');arm.clock=otherClock;}if(op==='dispose'){children[0].dispose();children[0].dispose();}if(op==='cacheRate')arm.cacheFrameRate=24;if(op==='appendActions'){const e=B.borrowObject(d.EventObject);e.name='tail';arm._bufferAction(e,true);arm._bufferAction(e,false);}if(op==='readonly')arm.display=A;s.update(-1);}});
 for(const child of children)child.inheritAnimation=false;
 stage(()=>{s.invalidUpdate();s.update(-1);});
 arm.returnToPool();result.push(s._isInPool,s._displayFrames.length,held.map(f=>f._isInPool).join(','),array(core._objects,id),children.map(x=>x._isInPool).join(','));for(const child of children)child.dispose();core.advanceTime(0);result.push(array(core._objects,id),children.map(x=>x._isInPool).join(','),children.map(x=>x.parent===null&&x.clock===null).join(','));for(const f of held)if(!f._isInPool)f.returnToPool();for(const x of owned.reverse())x.returnToPool();gd.returnToPool();return result.map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'slotruntime-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'slotruntime-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/slotruntime_differential.lua',input],{cwd:root,encoding:'utf8',timeout:180000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'slotruntime-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('Rows');let columns=0,approximate=0;const decode=s=>s&&s[0]==='n'&&s.length===17?Buffer.from(s.slice(1),'hex').readDoubleLE():NaN;
for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('Columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(rows[i][j]===expected[i][j])continue;const a=rows[i][j].split(/([,:])/),b=expected[i][j].split(/([,:])/);if(cases[i][0]==='update'&&cases[i][1]>=3&&[8,9,11].includes(j%19)&&j<76&&a.length===b.length){let good=true;for(let k=0;k<a.length;k++){if(a[k]===b[k])continue;const x=decode(a[k]),y=decode(b[k]);if(Number.isFinite(x)&&Number.isFinite(y)&&!(x===0&&y===0)&&Math.abs(x-y)<=32*Number.EPSILON*Math.max((j%19===8&&k/2>=4)||(j%19===9&&k/2<2)||(j%19===11&&[4,5].includes(((k-2)/2)%10))?1000:1,Math.abs(y)))approximate++;else good=false;}if(good)continue;}throw Error('Slot runtime mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,stages:cases.length*4,comparedColumns:columns,sourceErrors:expected.reduce((n,r)=>n+r.filter((v,i)=>i<76&&i%19===0&&v==='error').length,0),approximateComparisons:approximate,lua,result:'passed'};fs.writeFileSync(path.join(dir,'slotruntime-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
