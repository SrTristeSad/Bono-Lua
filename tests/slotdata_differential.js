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
const code=['core/BaseObject','geom/Point','geom/Rectangle','geom/Matrix','geom/Transform','geom/ColorTransform','model/TextureAtlasData','model/CanvasData','model/UserData','model/DisplayData','model/AnimationData','model/ArmatureData','model/ConstraintData','model/SkinData','model/DragonBonesData','model/BoundingBoxData','parser/DataParser','parser/ObjectDataParser','parser/BinaryDataParser','armature/TransformObject','core/DragonBones','armature/Armature','armature/Bone','armature/Surface','armature/Slot'].map(p=>{const js=emitted.get(prefix+'DragonBones/src/dragonBones/'+p+'.js');if(!js)throw Error(p);return js;}).join('\n');

const ctx=vm.createContext({console:{warn(){},assert(){}}});vm.runInContext(code,ctx);
const d=ctx.dragonBones,B=d.BaseObject;
const cases=[];
for(let r=0;r<6;r++)for(let v=0;v<6;v++)for(let rot=0;rot<2;rot++)for(let trim=0;trim<2;trim++)for(let down=0;down<2;down++)for(let scale=0;scale<2;scale++)for(let weight=0;weight<2;weight++)cases.push([r,v,rot,trim,down,scale,weight,'normal']);
for(const op of ['nullSkin','noDefaults','nullDefault','shortDefaults','negativeIndex','omittedIndex','inactiveIndex','aboveIndex','fractionIndex','nanIndex','noFrames','missingArmature','missingAtlas','sameReplacementAsRaw','nullTexture','trig','boxOnly'])for(let down=0;down<2;down++)for(let weight=0;weight<2;weight++)cases.push([op==='boxOnly'?4:1,op==='boxOnly'||op==='nullTexture'?0:op==='trig'?1:2,1,1,down,1,weight,op]);
function scalar(v){if(v===undefined)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const matrix=m=>['a','b','c','d','tx','ty'].map(k=>scalar(m[k])).join(',');
function execute(c){const [rk,vk,rot,trim,down,scale,weighted,op]=c;d.DragonBones.yDown=!!down;
 const ids=new Map(),owned=[];function borrow(C,id){const x=B.borrowObject(C);ids.set(x,id);owned.push(x);return x;}
 const gd=B.borrowObject(d.DragonBonesData),ad=B.borrowObject(d.ArmatureData);ad.name='arm';ad.scale=scale?.5:1;gd.addArmature(ad);gd.intArray=new Int16Array([3,0,0]);
 const arm=B.borrowObject(d.Armature);arm._armatureData=ad;
 const bones=[];for(const name of ['root','missing','other']){const bd=B.borrowObject(d.BoneData);bd.name=name;ad.addBone(bd);bones.push(bd);if(name!=='missing'){const b=B.borrowObject(d.Bone);b.init(bd,arm);}}
 const sd=B.borrowObject(d.SlotData);sd.name='slot';sd.parent=bones[0];sd.color=new d.ColorTransform();ad.addSlot(sd);
 const skin=B.borrowObject(d.SkinData);skin.name='default';ad.addSkin(skin);
 const atlas=new d.TextureAtlasData();atlas._onClear();atlas.scale=scale?3:1;
 function texture(id,w,h){const t=new d.TextureData();t._onClear();t.parent=atlas;t.region.width=w;t.region.height=h;t.rotated=!!rot;if(trim){t.frame=new d.Rectangle();t.frame.x=-7;t.frame.y=-11;t.frame.width=w+30;t.frame.height=h+20;}ids.set(t,id);return t;}
 const rt=texture('rawTexture',100,80),vt=texture('replacementTexture',200,120),override=texture('overrideTexture',60,40);
 function display(kind,id,t){if(!kind)return null;const C=[null,d.ImageDisplayData,d.MeshDisplayData,d.PathDisplayData,d.BoundingBoxDisplayData,d.ArmatureDisplayData][kind],x=borrow(C,id);ids.set(x.transform,id+'Transform');x.transform.x=id==='raw'?5:15;x.transform.y=id==='raw'?-3:-9;if(op==='trig'){x.transform.rotation=id==='raw'?.25:-.4;x.transform.scaleX=1.2;x.transform.scaleY=.8;}
  if(kind===1){x.pivot.x=.25;x.pivot.y=.75;x.texture=t;}if(kind===2){x.texture=t;}if(kind===2||kind===3){ids.set(x.geometry,id+'Geometry');x.geometry.data=gd;if(weighted){x.geometry.weight=B.borrowObject(d.WeightData);x.geometry.weight.count=4;for(const bd of [bones[0],bones[1],bones[2],bones[0]])x.geometry.weight.addBone(bd);}}if(kind===4){x.boundingBox=B.borrowObject(d.RectangleBoundingBoxData);ids.set(x.boundingBox,id+'Box');}return x;}
 const raw=display(rk,'raw',rt),replacement=display(vk,'replacement',vt),fallback=display(1,'fallback',rt);owned.pop();skin.addDisplay(op==='noDefaults'?'other':'slot',op==='nullDefault'?null:fallback);if(op==='nullDefault'){owned.push(fallback);}if(op==='nullSkin')ad.defaultSkin=null;
 const hooks=[];class Observer extends d.Slot{static toString(){return'[test.SlotDataObserver]';}_initDisplay(){hooks.push("init");}_disposeDisplay(){hooks.push("dispose");}_onUpdateDisplay(){hooks.push("onUpdate");}_addDisplay(){hooks.push("add");}}
 B.clearPool(Observer);const s=B.borrowObject(Observer);s.init(sd,arm,null,null);s.displayFrameCount=op==='noFrames'?0:2;for(let i=0;i<s._displayFrames.length;i++)ids.set(s._displayFrames[i],'frame'+i);s._displayIndex=op==='negativeIndex'?-1:op==='shortDefaults'?1:0;
 const target=s._displayIndex<0?0:s._displayIndex;let index=target;if(op==='negativeIndex')index=-5;if(op==='omittedIndex')index=undefined;if(op==='inactiveIndex')index=1;if(op==='aboveIndex')index=99;if(op==='fractionIndex')index=.5;if(op==='nanIndex')index=NaN;
 if(op==='missingArmature')s._armature=null;if(op==='missingAtlas')rt.parent=null;if(op==='nullTexture'&&raw)raw.texture=null;
 const id=x=>x==null?'nil':ids.get(x)||'unexpected';const all=[];
 function reset(){for(const k of ['_geometryDirty','_verticesDirty','_textureDirty','_transformDirty','_displayDataDirty'])s[k]=false;}
 function snap(status){const f=s._displayFrames[target],a=f?f.deformVertices:[];return [status,id(s._displayFrame),id(s._geometryData),id(s._textureData),id(s._boundingBoxData),id(s.origin),matrix(s._localMatrix),['x','y','skew','rotation','scaleX','scaleY'].map(k=>scalar(s.global[k])).join(','),scalar(s._pivotX),scalar(s._pivotY),['_geometryDirty','_verticesDirty','_textureDirty','_transformDirty','_displayDataDirty'].map(k=>scalar(s[k])).join(','),s._geometryBones.length+':'+Array.from({length:s._geometryBones.length},(_,i)=>s._geometryBones[i]?s._geometryBones[i].name:'nil').join(','),f?id(f.rawDisplayData):'absent',f?id(f.displayData):'absent',f?id(f.textureData):'absent',a.length+':'+Array.from({length:a.length},(_,i)=>i in a?scalar(a[i]):'hole').join(',')].map(String);}
 function stage(fn){let status='ok';try{fn();}catch(e){status='error';}all.push(...snap(status));}
 stage(()=>{s.replaceRawDisplayData(raw,index);s.replaceDisplayData(op==='sameReplacementAsRaw'?raw:replacement,index);s._updateDisplayData();});
 stage(()=>{reset();s.offset.x=9;s._updateDisplayData();});
 stage(()=>{reset();const f=s._displayFrames[target];if(f)f.deformVertices.push(7,-0);s.replaceRawDisplayData(raw,index);s._updateDisplayData();});
 stage(()=>{reset();if(op==='boxOnly'&&raw){raw.boundingBox.returnToPool();raw.boundingBox=B.borrowObject(d.EllipseBoundingBoxData);ids.set(raw.boundingBox,'changedBox');}s._updateDisplayData();});
 stage(()=>{reset();s.replaceRawDisplayData(null,index);s._updateDisplayData();});
 stage(()=>{reset();s.replaceDisplayData(null,index);s._updateDisplayData();});
 stage(()=>{reset();s.replaceTextureData(override,index);s._updateDisplayData();});
 stage(()=>{reset();s._setDisplayIndex(1);s._updateDisplayData();});
 stage(()=>{reset();s._setDisplayIndex(-1);s._updateDisplayData();});
 arm.returnToPool();all.push(s._isInPool,s._displayFrames.length,s._geometryBones.length,s.origin===null,hooks.join(";"));for(const x of owned.reverse())x.returnToPool();gd.returnToPool();return all.map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'slotdata-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>c.join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'slotdata-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/slotdata_differential.lua',input],{cwd:root,encoding:'utf8',timeout:120000,maxBuffer:64*1024*1024});fs.writeFileSync(path.join(dir,'slotdata-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('Rows');let columns=0,approximate=0;const decode=s=>s&&s[0]==='n'&&s.length===17?Buffer.from(s.slice(1),'hex').readDoubleLE():NaN;for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('Columns '+i);for(let j=0;j<rows[i].length;j++){columns++;if(rows[i][j]===expected[i][j])continue;const a=rows[i][j].split(','),b=expected[i][j].split(',');if(cases[i][7]==='trig'&&[6,7,8,9].includes(j%16)&&a.length===b.length){let good=true;for(let k=0;k<a.length;k++){if(a[k]===b[k])continue;const x=decode(a[k]),y=decode(b[k]);if(Number.isFinite(x)&&Number.isFinite(y)&&x!==0&&y!==0&&Math.abs(x-y)<=8*Number.EPSILON*Math.max(1,Math.abs(y)))approximate++;else good=false;}if(good)continue;}throw Error('Slot data mismatch '+i+' '+cases[i]+' column '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={upstream:PIN,scenarios:cases.length,stages:cases.length*9,comparedColumns:columns,sourceErrors:expected.reduce((n,r)=>n+r.filter((x,i)=>i<144&&i%16===0&&x==='error').length,0),approximateComparisons:approximate,lua,result:'passed'};fs.writeFileSync(path.join(dir,'slotdata-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
