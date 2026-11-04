'use strict';
// Execute pinned PathConstraint with real parser/model/runtime objects.
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
const cases=[];
for(let closed=0;closed<2;closed++)for(let speed=0;speed<2;speed++)for(let weight=0;weight<3;weight++)for(let rotate=0;rotate<3;rotate++)for(let spacing=0;spacing<3;spacing++)for(let percent=0;percent<2;percent++)for(let pos=0;pos<3;pos++)for(let mix=0;mix<2;mix++)for(let reflect=0;reflect<2;reflect++)cases.push(['run',closed,speed,weight,rotate,spacing,percent,pos,mix,reflect,'normal']);
for(let closed=0;closed<2;closed++)for(let speed=0;speed<2;speed++)for(let tangents=0;tangents<2;tangents++)for(let percent=0;percent<2;percent++)for(let spaces=0;spaces<2;spaces++)for(let pos=0;pos<5;pos++)cases.push(['curve',closed,speed,1,0,spaces,percent,pos,tangents,0,'normal']);
for(const op of ['reinit','missingWeightBone','noGeometry','offsetMismatch','cleanReturn','verticesDirty','boneDirty','rootDirty','positionBelow','positionAbove','zeroLength','zeroMix','rotateOffset','negativeSpacing','badVertexCount','missingSlot','missingRoot','missingDisplayData','readonly','clear','segmentsKept','preseed','fixedScale'])for(let weighted=0;weighted<3;weighted++)cases.push(['run',0,1,weighted,1,0,1,1,0,0,op]);
for(const op of ['copy','curvePoint','undefinedEndpoint'])for(let pos=0;pos<5;pos++)for(let tangent=0;tangent<2;tangent++)cases.push(['helper',0,1,1,0,0,0,pos,tangent,0,op]);
const selection=process.argv[4];if(selection!==undefined){const selected=/^\d+$/.test(selection)?[cases[Number(selection)]]:cases.filter(c=>c[10]===selection);if(!selected.length||!selected[0])throw Error('Unknown selection');cases.splice(0,cases.length,...selected);}
const vertices=[-10,0,0,0,10,0,20,10,30,10,40,10];
function rawFor(c){const weighted=c[3],display={name:'curve',type:'path',closed:!!c[1],constantSpeed:!!c[2],vertices,vertexCount:6,lengths:[32,64]};if(weighted){display.weights=[];for(let i=0;i<6;i++)display.weights.push(...(weighted===1?[1,0,1]:[2,0,.5,1,.5]));display.slotPose=[1,0,0,1,0,0];display.bonePose=weighted===1?[0,1,0,0,1,0,0]:[0,1,0,0,1,0,0,1,1,0,0,1,0,0];}return{version:'5.6',name:'path-test',frameRate:24,armature:[{name:'arm',bone:[{name:'guide',transform:{x:2,y:-1,scX:c[9]?-1:1}},{name:'aux',transform:{x:3,y:-2}},{name:'a',length:c[10]==='zeroLength'?0:10},{name:'b',parent:'a',length:8,transform:{x:10}}],slot:[{name:'path',parent:'guide'}],skin:[{name:'default',slot:[{name:'path',display:[display]}]}],path:[{name:'follow',target:'path',targetDisplay:'curve',bones:['a','b'],positionMode:c[6]?'percent':'fixed',spacingMode:['fixed','length','percent'][c[5]],rotateMode:['tangent','chain','chainScale'][c[4]],position:[0,.25,1,-.25,100][c[7]],spacing:c[5]===2?.1:3,rotateMix:c[8]?.5:1,translateMix:c[8]?.5:1}]}]};}
function scalar(v){if(v===undefined)return'u';if(typeof v==='boolean')return String(v);if(Number.isNaN(v))return'NaN';const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const matrix=m=>['a','b','c','d','tx','ty'].map(k=>scalar(m[k])).join(',');
function array(a,fn=scalar){return a.length+':'+Array.from({length:a.length},(_,i)=>i in a?fn(a[i]):'hole').join(',');}
function execute(c){const [family,closed,speed,weighted,rotate,spacing,percent,pos,mix,reflect,op]=c;ctx.__json=JSON.stringify(rawFor(c));const gd=new d.ObjectDataParser().parseDragonBonesData(vm.runInContext('JSON.parse(__json)',ctx),op==='fixedScale'?.5:1);const ad=gd.getArmature('arm'),arm=B.borrowObject(d.Armature);arm._armatureData=ad;d.DragonBones.yDown=true;const allBones=[];for(const bd of ad.sortedBones){if(op==='missingWeightBone'&&bd.name==='aux')continue;const b=B.borrowObject(d.Bone);b.init(bd,arm);allBones.push(b);b.invalidUpdate();b.update(-1);}
 class Observer extends d.Slot{static toString(){return'[test.PathSlotObserver]';}_initDisplay(){}_disposeDisplay(){}_onUpdateDisplay(){}_addDisplay(){}}
 B.clearPool(Observer);const slot=B.borrowObject(Observer);slot.init(ad.getSlot('path'),arm,null,null);slot.displayFrameCount=1;slot.replaceRawDisplayData(ad.defaultSkin.getDisplay('path','curve'),0);slot._setDisplayIndex(0);slot._updateDisplayData();const data=ad.getConstraint('follow'),display=data.pathDisplayData,p=B.borrowObject(d.PathConstraint);const arrays=[p._spaces,p._positions,p._curves,p._boneLengths,p._pathGlobalVertices,p._segments,p._bones];const aux=arm.getBone('aux');
 if(op==='missingSlot'){arm._slots.length=0;}if(op==='missingRoot')data.root=B.borrowObject(d.BoneData);if(op==='missingRoot')data.root.name='absent';const absent=op==='missingRoot'?data.root:null;if(op==='missingDisplayData')data.pathDisplayData=null;
 const out=[],helper=[];function snapshot(status){let name='error';try{name=p.name;}catch(e){}return[status,p._constraintData===data,name,p._root?p._root.name:'nil',p._target?p._target.name:'nil',p._pathSlot===slot,array(p._bones,b=>b.name),...['_spaces','_positions','_curves','_boneLengths','_pathGlobalVertices','_segments'].map(k=>array(p[k])),['dirty','pathOffset','position','spacing','rotateOffset','rotateMix','translateMix'].map(k=>scalar(p[k])).join(','),...['a','b','guide'].map(n=>{const b=arm.getBone(n);return matrix(b.globalTransformMatrix)+'|'+['x','y','skew','rotation','scaleX','scaleY',''].slice(0,6).map(k=>scalar(b.global[k])).join(',')+'|'+['_localDirty','_transformDirty','_childrenTransformDirty','_globalDirty','_hasConstraint'].map(k=>scalar(b[k])).join(',');}),[slot._verticesDirty,slot._geometryData===display.geometry,slot._geometryBones.length].join(','),array(helper)].map(String);}
 function stage(fn){let status='ok';try{fn();}catch(e){status='error';}out.push(...snapshot(status));}
 stage(()=>{p.init(data,arm);arm._addConstraint(p);if(op==='reinit')p.init(data,arm);if(op==='readonly')p.name='x';});
 stage(()=>{if(family==='helper'){if(op==='copy'){p._pathGlobalVertices.length=4;p._pathGlobalVertices[0]=1;p._pathGlobalVertices[2]=3;p._computeVertices(0,[2,4,6,8,10][pos],[0,2,4,0,2][pos],helper);}else{p.addCurvePosition([0,1,.25,-.25,NaN][pos],op==='undefinedEndpoint'?undefined:0,0,10,0,20,10,op==='undefinedEndpoint'?undefined:30,10,helper,2,!!mix);}}else if(family==='curve'){p._pathGlobalVertices.length=vertices.length;vertices.forEach((v,i)=>p._pathGlobalVertices[i]=v);p._spaces.length=3;for(let i=0;i<3;i++)p._spaces[i]=spacing?.1:0;p._computeBezierCurve(display,3,!!mix,!!percent,!!spacing);}else{if(op==='segmentsKept')p._segments.push(99);if(op==='preseed'){p._pathGlobalVertices.length=12;for(let i=0;i<12;i++)p._pathGlobalVertices[i]=100+i;}if(op==='noGeometry')slot._geometryData=null;if(op==='offsetMismatch')p.pathOffset+=1;if(op==='badVertexCount')gd.intArray[display.geometry.offset]=7;if(op==='positionBelow')p.position=-1000;if(op==='positionAbove')p.position=1000;if(op==='negativeSpacing')p.spacing=-4;if(op==='rotateOffset')p.rotateOffset=30;if(op==='zeroMix')p.rotateMix=p.translateMix=0;p.dirty=true;p.update();}});
 stage(()=>{if(op==='clear'){p._onClear();return;}if(family==='helper'){if(op==='undefinedEndpoint')p.addCurvePosition(1,undefined,0,10,0,20,10,undefined,10,helper,0,false);return;}if(family==='curve'){p.position+=.1;p._computeBezierCurve(display,3,!!mix,!!percent,!!spacing);return;}for(const b of allBones)b._childrenTransformDirty=false;slot._verticesDirty=false;p.dirty=false;if(op==='verticesDirty')slot._verticesDirty=true;else if(op==='boneDirty'&&aux)aux._childrenTransformDirty=true;else if(op==='rootDirty')p._root._childrenTransformDirty=true;else if(op!=='cleanReturn'){p.position+=.1;p.dirty=true;}if(op==='cleanReturn')p.position+=.1;p.invalidUpdate();p.update();});
 const registered=arm._constraints.indexOf(p)>=0;if(!registered)p.returnToPool();if(op==='missingSlot')slot.returnToPool();arm.returnToPool();out.push(p._isInPool,p._constraintData===data,...arrays.map((a,i)=>a===[p._spaces,p._positions,p._curves,p._boneLengths,p._pathGlobalVertices,p._segments,p._bones][i]),array(p._segments),[p._spaces.length,p._positions.length,p._curves.length,p._boneLengths.length,p._pathGlobalVertices.length,p._bones.length].join(','));if(absent)absent.returnToPool();gd.returnToPool();return out.map(String);
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),input=path.join(dir,'path-'+tag+'-cases.tsv');fs.writeFileSync(input,cases.map(c=>[...c,Buffer.from(JSON.stringify(rawFor(c))).toString('hex')].join('\t')).join('\n')+'\n');const expected=cases.map(execute);fs.writeFileSync(path.join(dir,'path-'+tag+'-original.tsv'),expected.map(r=>r.join('\t')).join('\n')+'\n');const actual=cp.execFileSync(lua,['tests/path_differential.lua',input],{cwd:root,encoding:'utf8',timeout:240000,maxBuffer:128*1024*1024});fs.writeFileSync(path.join(dir,'path-'+tag+'-actual.tsv'),actual);const rows=actual.replace(/\n$/,'').split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('Rows');let columns=0,approximate=0;const decode=s=>s&&s[0]==='n'&&s.length===17?Buffer.from(s.slice(1),'hex').readDoubleLE():NaN;for(let i=0;i<rows.length;i++){
 if(rows[i].length!==expected[i].length)throw Error('Columns '+i);
 const boneCount=Math.max(1,...[0,1,2].map(stage=>Number(expected[i][stage*19+6].split(':')[0])));
 const finiteValues=expected[i].filter((_,j)=>j<57&&[8,11,14,15].includes(j%19)).flatMap(s=>s.split(/[,:|]/).map(decode).filter(Number.isFinite).map(Math.abs));
 const scale=Math.max(1,...finiteValues);
 for(let j=0;j<rows[i].length;j++){
  columns++;if(rows[i][j]===expected[i][j])continue;
  const field=j%19,a=rows[i][j].split(/([,:|])/),b=expected[i][j].split(/([,:|])/);
  let good=j<57&&[7,8,10,14,15,18].includes(field)&&a.length===b.length,section=0,index=0;
  if(good)for(let k=0;k<a.length;k++){
   if(b[k]==='|'){section++;index=0;continue;}
   if(b[k]===','||b[k]===':')continue;
   if(a[k]!==b[k]){
    const x=decode(a[k]),y=decode(b[k]);let allowed=true,coordinate=false,epsilon=8,cancellation=false;
    if(field===14||field===15){allowed=section<=1;coordinate=section===0?index>=4:index<2;epsilon=coordinate?32:32*boneCount;cancellation=section===1&&index===2;if(cancellation)epsilon=8;}
    else{allowed=index>0;coordinate=field===8&&(index-1)%3!==2;if(coordinate)epsilon=32;if(field===18)allowed=cases[i][0]==='helper'&&cases[i][8]===1&&index-1===4;}
    const zero=!(x===0&&y===0)&&(cancellation||x!==0&&y!==0);
    if(allowed&&Number.isFinite(x)&&Number.isFinite(y)&&zero&&Math.abs(x-y)<=epsilon*Number.EPSILON*Math.max(coordinate?scale:1,Math.abs(y)))approximate++;else good=false;
   }
   index++;
  }
  if(!good)throw Error('Path mismatch '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);
 }
}
const result={upstream:PIN,scenarios:cases.length,stages:cases.length*3,comparedColumns:columns,sourceErrors:expected.reduce((n,r)=>n+r.filter((x,i)=>i<57&&i%19===0&&x==='error').length,0),approximateComparisons:approximate,lua,result:'passed'};fs.writeFileSync(path.join(dir,'path-'+tag+'-result.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
