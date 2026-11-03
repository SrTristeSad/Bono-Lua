// Only a CI oracle: execute pinned MIT DragonBonesJS IKConstraint.update
// on reproducible single-bone and two-bone cases. Never ship JS to the app.
// Source: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
"use strict";
const fs=require("fs"),vm=require("vm");
const [bundle,fixture,out]=process.argv.slice(2);
if(!bundle||!fixture||!out) throw Error("usage: node differential_ik_solver_original.js original.js cases.tsv expected.tsv");
const sandbox={PIXI:{Sprite:class Sprite{}},console};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(bundle,"utf8"),sandbox,{timeout:15000,filename:"pinned-DragonBonesJS"});
const api=sandbox.dragonBones;
if(!api?.IKConstraint||!api?.Transform||!api?.Matrix)
  throw Error("Pinned IKConstraint/Transform/Matrix missing from DragonBonesJS");
const matrixKeys=["a","b","c","d","tx","ty"];
const keys=["rotation","x","y",...matrixKeys];
const fmt=n=>Number.isNaN(n)?"NaN":n===Infinity?"Infinity":n===-Infinity?"-Infinity":Object.is(n,-0)?"-0":String(n);
const rows=[];
for(const line of fs.readFileSync(fixture,"utf8").trim().split(/\r?\n/)){
  if(!line||line.startsWith("#"))continue;
  const fields=line.split("\t");
  if(fields.length!==17)throw Error("IK fixture requires 17 fields: "+line);
  const [name,mode,...rest]=fields;
  const [rx,ry,rr,rsx,rsy,cx,cy,cr,csx,clen,tx,ty,w,bend,mirror]=rest.map(Number);
  function bone(x,y,rotation,scaleX,scaleY,length){
    const global=new api.Transform();
    global.x=x;global.y=y;global.rotation=rotation;global.scaleX=scaleX;global.scaleY=scaleY;
    const globalTransformMatrix=new api.Matrix();
    global.toMatrix(globalTransformMatrix);
    return {
      global,globalTransformMatrix,_boneData:{length},parent:null,
      updateByConstraint(){} // integration surface; only pinned solver computes poses
    };
  }
  const root=bone(rx,ry,rr,rsx,rsy,0);
  const child=bone(cx,cy,cr,csx,1,clen);
  child.parent=root;
  const target=bone(tx,ty,0,1,1,0);
  if(mirror){
    const mirrorMatrix=new api.Matrix();
    mirrorMatrix.a=-1;
    root.parent={globalTransformMatrix:mirrorMatrix};
  }
  const solver=Object.create(api.IKConstraint.prototype);
  solver._root=root;solver._target=target;solver._bone=mode==="D"?child:null;
  solver._bendPositive=!!bend;solver._weight=w;
  solver.update();
  function dump(b){return keys.map(k=>k in b.global?fmt(b.global[k]):fmt(b.globalTransformMatrix[k]));}
  const fieldsOut=[name,...dump(root),...(mode==="D"?dump(child):Array(keys.length).fill("none"))];
  rows.push(fieldsOut.join("\t"));
}
if(rows.length!==56)throw Error("Fixture count changed: "+rows.length);
fs.writeFileSync(out,rows.join("\n")+"\n");
console.log("Pinned original DragonBonesJS IKConstraint.update: "+rows.length+" single/two-bone reference cases.");
