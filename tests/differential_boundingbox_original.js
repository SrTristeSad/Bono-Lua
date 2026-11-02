// CI-only differential oracle: execute the REAL pinned DragonBonesJS
// BoundingBoxData.ts subclasses; none of this JS ships with Bono-Lua.
// MIT upstream revision 64b6c69ae35777c2404be68c9192e2c56906079e.
"use strict";
const fs=require("fs"),vm=require("vm");
const [bundlePath,fixturePath,outputPath]=process.argv.slice(2);
if(!bundlePath||!fixturePath||!outputPath)throw Error("Usage: node differential_boundingbox_original.js original.js cases.tsv expected.tsv");
const sandbox={PIXI:{Sprite:class PixiSprite{}}};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(bundlePath,"utf8"),sandbox,{
 filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",timeout:15000
});
const original=sandbox.dragonBones;
const constructors={rect:original.RectangleBoundingBoxData,ellipse:original.EllipseBoundingBoxData,polygon:original.PolygonBoundingBoxData};
for(const cls of Object.values(constructors))if(typeof cls!=="function")throw Error("Original BoundingBox subclass unavailable");
const toNum=v=>Number(v);
const fmt=v=>v===undefined?"undefined":Number.isNaN(v)?"NaN":v===Infinity?"Infinity":v===-Infinity?"-Infinity":Object.is(v,-0)?"-0":String(v);
const expected=[];
for(const line of fs.readFileSync(fixturePath,"utf8").split(/\r?\n/)){
 if(!line||line[0]==="#")continue;
 const [op,shape,name,geo,rawCoords,flags]=line.split("\t");
 if(!op||!shape||!name||!geo||!rawCoords||!flags)throw Error("Malformed fixture "+line);
 const object=new constructors[shape]();
 const fields=geo.split(";");
 const dimensions=fields[0].split(",").map(toNum);
 if(shape==="polygon"){
   [object.x,object.y,object.width,object.height]=dimensions;
   object.vertices.push(...fields[1].split(",").map(toNum));
 }else{
   [object.width,object.height]=dimensions;
 }
 const coords=rawCoords.split(",").map(toNum);
 let result;
 if(op==="point"){
   result=object.containsPoint(...coords)?"true":"false";
   expected.push([name,result].join("\t"));
 }else if(op==="segment"){
   const pointA=flags==="all"||flags==="pointA"||flags==="pointA_normals"?{x:901.25,y:902.5}:null;
   const pointB=flags==="all"||flags==="pointB"||flags==="pointB_normals"?{x:903.25,y:904.5}:null;
   const normals=flags==="all"||flags==="normals"||flags==="pointA_normals"||flags==="pointB_normals"?{x:905.25,y:906.5}:null;
   const r=object.intersectsSegment(...coords,pointA,pointB,normals);
   expected.push([name,fmt(r),...(pointA?[fmt(pointA.x),fmt(pointA.y)]:[]),
       ...(pointB?[fmt(pointB.x),fmt(pointB.y)]:[]),...(normals?[fmt(normals.x),fmt(normals.y)]:[])].join("\t"));
 }else throw Error("Bad fixture operation "+op);
}
if(expected.length!==62)throw Error("Unexpected reference count "+expected.length);
fs.writeFileSync(outputPath,expected.join("\n")+"\n");
console.log("Pinned DragonBonesJS BoundingBoxData executed: "+expected.length+" reference cases");
