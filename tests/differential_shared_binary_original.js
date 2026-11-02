// CI-only: execute the ACTUAL pinned DragonBonesJS ObjectDataParser and
// BinaryDataParser typed-array methods, then mutate their returned views.
// The expected bytes and values come from the original bundle, not a clone.
// Source: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
"use strict";
const fs=require("fs"),vm=require("vm");
const [bundle,out]=process.argv.slice(2);
if(!bundle||!out)throw Error("Usage: node differential_shared_binary_original.js original.js expected.tsv");
const context={PIXI:{Sprite:class Sprite{}}};
vm.createContext(context);
vm.runInContext(fs.readFileSync(bundle,"utf8"),context,{timeout:15000,filename:"pinned-dragonBones.js"});
const api=context.dragonBones;
const keys=["intArray","floatArray","frameIntArray","frameFloatArray","frameArray","timelineArray","colorArray"];
const format=n=>Number.isNaN(n)?"NaN":n===Infinity?"Infinity":n===-Infinity?"-Infinity":Object.is(n,-0)?"-0":String(n);
const inputs=[
 ["object-int-wrap","object","intArray",0,65535],
 ["object-int-negative","object","intArray",1,-32769],
 ["object-float-round","object","floatArray",0,0.1],
 ["object-frame-int","object","frameIntArray",0,65535],
 ["object-frame-float","object","frameFloatArray",0,-0],
 ["object-frame","object","frameArray",1,-30000],
 ["object-timeline","object","timelineArray",0,-1],
 ["object-color","object","colorArray",1,40000],
 ["binary-int-wrap","binary","intArray",0,65535],
 ["binary-float-round","binary","floatArray",1,0.1],
 ["binary-frame-int","binary","frameIntArray",1,-40000],
 ["binary-frame-float","binary","frameFloatArray",0,-0],
 ["binary-frame","binary","frameArray",0,42],
 ["binary-timeline","binary","timelineArray",1,-1],
 ["binary-color","binary","colorArray",0,-32769],
 ["alias-int","alias","intArray",0,-1],
 ["alias-color","alias","colorArray",1,32768],
 ["overlap-int","overlap","intArray",1,16256], // high half of float32 1.0
 ["overlap-float","overlap","floatArray",0,1.0]
];
function make(type){
  if(type==="object"){
    const p=new api.ObjectDataParser();
    p._data={};
    p._intArray=[1,2];
    p._floatArray=[0.5];
    p._frameIntArray=[3,4];
    p._frameFloatArray=[-1];
    p._frameArray=[5,6];
    p._timelineArray=[7,8];
    p._colorArray=[9,10];
    p._modifyArray();
    return p._data;
  }
  const p=new api.BinaryDataParser();
  p._binary=new ArrayBuffer(36);
  p._binaryOffset=0;
  p._data={};
  const offsets=type==="overlap"?
    [0,8,0,8,16,4,20,4,24,4,28,4,32,4]:
    [0,8,8,8,16,4,20,4,24,4,28,4,32,type==="alias"?0:4];
  p._parseArray({offset:offsets});
  return p._data;
}
const rows=[];
for(const [name,type,key,index,value] of inputs){
  const data=make(type);
  data[key][index]=value;
  const byteHex=Buffer.from(new Uint8Array(data.binary)).toString("hex");
  const alias=data.colorArray===data.intArray?"alias":"separate";
  rows.push([name,byteHex,alias,...keys.map(k=>Array.from(data[k],format).join(","))].join("\t"));
}
fs.writeFileSync(out,rows.join("\n")+"\n");
console.log("Pinned DragonBonesJS shared mutable typed views executed: "+rows.length+" cases");
