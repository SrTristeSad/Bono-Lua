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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','event/EventObject','animation/WorldClock','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot','armature/Constraint'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const ctx=vm.createContext({console:{warn(){},assert(){},info(){}}});vm.runInContext(code,ctx);const d=ctx.dragonBones,B=d.BaseObject;
let abstract=false;try{B.borrowObject(d.Constraint);}catch(e){abstract=true;}if(!abstract)throw Error('Constraint must remain abstract');
const targets=[[8,8],[30,0],[1,0],[0,0],[18,0],[2,0],[-12,5],[0,-12]];
const weights=[-.5,0,.25,1,1.5],cases=[];
for(let chain=0;chain<2;chain++)for(let bend=0;bend<2;bend++)for(let weight=0;weight<weights.length;weight++)for(let target=0;target<targets.length;target++)for(let flip=0;flip<4;flip++)for(let down=0;down<2;down++)for(const reflect of [0,1,-1])for(let shape=0;shape<4;shape++)cases.push([chain,bend,weight,target,flip,down,reflect,shape,'solve']);
for(let chain=0;chain<2;chain++)for(const op of ['direct','cacheHit','cacheRestore','cacheMiss','reinit','readonly','baseClear','clear','missingRoot','missingTarget','missingBone','missingTargetData','missingArmature','getterBeforeInit','negativeRoot','negativeChild','negativeLength','scaleEnabled','nanTarget','integerPose','signedZero'])cases.push([chain,1,2,0,0,1,-1,0,op]);
for(let chain=0;chain<2;chain++)cases.push([chain,1,2,1,0,1,-1,0,"scaleEnabledFar"]);
const selection=process.argv[4];if(selection!==undefined){const selected=/^\d+$/.test(selection)?[cases[Number(selection)]]:cases.filter(c=>c[8]===selection);if(!selected.length||!selected[0])throw Error("Unknown IK selection");cases.splice(0,cases.length,...selected);}
function scalar(v){if(v===undefined)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const matrix=m=>['a','b','c','d','tx','ty'].map(k=>scalar(m[k])).join(',');
function execute(c){const [chain,bend,wi,ti,flip,down,reflect,shape,op]=c;d.DragonBones.yDown=!!down;const gd=B.borrowObject(d.DragonBonesData),ad=B.borrowObject(d.ArmatureData);ad.name='ik';gd.addArmature(ad);const arm=B.borrowObject(d.Armature);arm._armatureData=ad;arm._flipX=!!(flip&1);arm._flipY=!!(flip&2);
 const ids=new Map([[arm,'arm']]);function boneData(name,parent){const x=B.borrowObject(d.BoneData);x.name=name;x.parent=parent;x.inheritTranslation=x.inheritRotation=x.inheritScale=x.inheritReflection=true;ad.addBone(x);return x;}
 const gpData=reflect?boneData('grand',null):null;if(gpData)gpData.transform.scaleX=reflect;
 const targetData=boneData('target',null),rootData=boneData('upper',gpData),childData=boneData('lower',rootData);rootData.length=10;childData.length=shape===3?0:8;childData.transform.x=shape===2?0:10;targetData.transform.x=targets[ti][0];targetData.transform.y=targets[ti][1];
 if(shape===1){rootData.transform.rotation=.35;rootData.transform.skew=.12;rootData.transform.scaleX=1.2;rootData.transform.scaleY=.8;childData.transform.y=3;childData.transform.rotation=-.2;childData.transform.skew=.15;}
 if(op==='negativeRoot')rootData.transform.scaleX=-1;if(op==='negativeChild')childData.transform.scaleX=-1;if(op==='negativeLength')childData.length=-8;
 const runtime=[];for(const bd of ad.sortedBones){const bone=B.borrowObject(d.Bone);bone.init(bd,arm);runtime.push(bone);ids.set(bone,bd.name);}const target=arm.getBone('target'),rootBone=arm.getBone('upper'),child=arm.getBone('lower'),gp=arm.getBone('grand');
 const data=B.borrowObject(d.IKConstraintData);data.name='aim';data.root=rootData;data.target=targetData;data.bone=chain?childData:null;data.bendPositive=!!bend;data.weight=weights[wi];data.scaleEnabled=op==='scaleEnabled'||op==='scaleEnabledFar';ad.addConstraint(data);
 const ik=B.borrowObject(d.IKConstraint);const cache=op.startsWith('cache');if(cache)for(const bone of runtime)bone._cachedFrameIndices=[];
 if(op==='missingRoot')arm._bones=arm._bones.filter(x=>x!==rootBone);if(op==='missingTarget')arm._bones=arm._bones.filter(x=>x!==target);if(op==='missingBone')arm._bones=arm._bones.filter(x=>x!==child);if(op==='missingTargetData')data.target=null;
 const id=x=>x==null?'nil':ids.get(x)||'unexpected';const out=[];
 function array(x){return x==null?'nil':x.length+':'+Array.from({length:x.length},(_,i)=>i in x?scalar(x[i]):'hole').join(',');}
 function state(bone){return [matrix(bone.globalTransformMatrix),['x','y','skew','rotation','scaleX','scaleY'].map(k=>scalar(bone.global[k])).join(','),['_transformDirty','_childrenTransformDirty','_localDirty','_globalDirty','_hasConstraint','_cachedFrameIndex'].map(k=>scalar(bone[k])).join(','),array(bone._cachedFrameIndices)].join('|');}
 function snap(status){let name='error';try{name=ik.name;}catch(e){}return[status,state(rootBone),state(child),state(target),gp?state(gp):'nil',ik._constraintData===data,id(ik._armature),id(ik._root),id(ik._bone),id(ik._target),name,scalar(ik._bendPositive),scalar(ik._weight),arm._constraints.length,array(gd.cachedFrames),d.IKConstraint._helpMatrix===d.Constraint._helpMatrix,d.Constraint._helpMatrix!==d.TransformObject._helpMatrix].map(String);}
 function stage(fn){let status='ok';try{fn();}catch(e){status='error';}out.push(...snap(status));}
 function solve(index){target.update(index);if(gp)gp.update(index);if(op==='direct'){ik.update();}else{rootBone.update(index);child.update(index);}}
 stage(()=>{if(op==='getterBeforeInit'){const name=ik.name;}ik.init(data,op==='missingArmature'?null:arm);arm._addConstraint(ik);arm._addConstraint(ik);if(op==='reinit')ik.init(null,null);for(const bone of runtime)bone.invalidUpdate();if(op==='nanTarget')target.offset.x=NaN;solve(cache?0:-1);});
 stage(()=>{if(op==='integerPose'||op==='signedZero'){for(const bone of [rootBone,child,target]){bone.global.x=op==='signedZero'?-0:0;bone.global.y=op==='signedZero'?-0:0;}if(chain)ik._computeB();else ik._computeA();}else{target.offset.x=3;target.offset.y=-2;target.invalidUpdate();ik.invalidUpdate();solve(op==='cacheHit'?0:cache?1:-1);}});
 stage(()=>{if(op==='readonly')ik.name='changed';else if(op==='baseClear')d.Constraint.prototype._onClear.call(ik);else if(op==='clear')ik._onClear();else if(op==='cacheRestore'){rootBone._cachedFrameIndex=-1;rootBone.globalTransformMatrix.identity();rootBone.update(0);}else{ik.invalidUpdate();solve(cache?2:-1);}});
 const registered=arm._constraints.indexOf(ik)>=0;if(!registered)ik.returnToPool();const missing=runtime.filter(x=>arm._bones.indexOf(x)<0);arm.returnToPool();for(const bone of missing)bone.returnToPool();out.push(ik._isInPool,ik._constraintData===null,ik._armature===null,ik._target===null,ik._root===null,ik._bone===null,ik._bendPositive,scalar(ik._weight),rootBone._isInPool,child._isInPool,arm._constraints.length);gd.returnToPool();return out.map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'ik-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'ik-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/ik_differential.lua',input],{cwd:root,encoding:'utf8',timeout:180000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'ik-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('Rows');let columns=0,approximate=0;const decode=s=>s&&s[0]==='n'&&s.length===17?Buffer.from(s.slice(1),'hex').readDoubleLE():NaN;
function limits(row,c,stage){
 const pose=j=>row[stage*17+j].split('|')[1].split(',').map(decode);
 const r=pose(1),b=pose(2),t=pose(3),m=row[stage*17+2].split('|')[0].split(',').map(decode);
 const finite=x=>Number.isFinite(x)?x:0;
 const length=(c[7]===3?0:8);
 const chain=Math.hypot(finite(b[0]-r[0]),finite(b[1]-r[1]))+Math.hypot(finite(m[0]*length),finite(m[1]*length));
 const separation=Math.hypot(finite(t[0]-b[0]),finite(t[1]-b[1]));
 const coordinate=Math.max(1,chain,...[r,b,t].flatMap(p=>p.slice(0,2).map(x=>Math.abs(finite(x)))));
 const gain=c[0]&&separation>0?Math.min(8,Math.max(1,Math.abs(weights[c[2]])*(1+chain/separation))):1;
 return {coordinate,gain};
}
for(let i=0;i<rows.length;i++){
 if(rows[i].length!==expected[i].length)throw Error('Columns '+i);
 const bounds=[0,1,2].map(stage=>limits(expected[i],cases[i],stage));
 for(let j=0;j<rows[i].length;j++){
  columns++;if(rows[i][j]===expected[i][j])continue;
  const a=rows[i][j].split(/([,:|])/),b=expected[i][j].split(/([,:|])/);
  let good=j<51&&[1,2,3,4,14].includes(j%17)&&a.length===b.length;
  let section=0,index=0;
  const bound=bounds[Math.floor(j/17)];
  if(good)for(let k=0;k<a.length;k++){
   if(b[k]==='|'){section++;index=0;continue;}
   if(b[k]===','||b[k]===':')continue;
   if(a[k]!==b[k]){
    const x=decode(a[k]),y=decode(b[k]);
    const cache=j%17===14;
    const coordinate=cache?[4,5].includes((index-1)%10):section===0?index>=4:section===1?index<2:false;
    const derived=cache?index>0:section<=1;
    const scale=coordinate?bound.coordinate:1;
    const gain=coordinate?1:([1,2,14].includes(j%17)?bound.gain:1);
    if(derived&&Number.isFinite(x)&&Number.isFinite(y)&&x!==0&&y!==0&&Math.abs(x-y)<=8*Number.EPSILON*gain*Math.max(scale,Math.abs(y)))approximate++;
    else good=false;
   }
   index++;
  }
  if(!good)throw Error('IK mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);
 }
}
const result={upstream:PIN,scenarios:cases.length,stages:cases.length*3,comparedColumns:columns,sourceErrors:expected.reduce((n,r)=>n+r.filter((x,i)=>i<51&&i%17===0&&x==='error').length,0),approximateComparisons:approximate,lua,result:'passed'};fs.writeFileSync(path.join(dir,'ik-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
