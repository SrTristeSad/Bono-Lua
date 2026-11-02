// CI-only reference: execute the original pinned MIT DragonBonesJS
// BinaryDataParser._parseArray, NOT an independent reimplementation.
// DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
"use strict";
const fs=require("fs"),vm=require("vm");
const [originalBundle,fixtures,output]=process.argv.slice(2);
if(!originalBundle||!fixtures||!output)throw Error("Usage: node differential_binary_typed_original.js original.js cases.tsv expected.tsv");
const sandbox={PIXI:{Sprite:class PixiSprite{}}};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(originalBundle,"utf8"),sandbox,{
  filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",timeout:15000
});
const Binary=sandbox.dragonBones && sandbox.dragonBones.BinaryDataParser;
if(typeof Binary!=="function")throw Error("Pinned upstream BinaryDataParser not present");
const viewKeys=["intArray","floatArray","frameIntArray","frameFloatArray","frameArray","timelineArray","colorArray"];
const formatNumber=n=>Number.isNaN(n)?"NaN":n===Infinity?"Infinity":n===-Infinity?"-Infinity":Object.is(n,-0)?"-0":String(n);
const records=[];
for(const line of fs.readFileSync(fixtures,"utf8").split(/\r?\n/)){
  if(!line||line.startsWith("#"))continue;
  const [name,offset,rawOffsets,hex=""]=line.split("\t");
  if(!name||!/^(?:[0-9a-f]{2})*$/i.test(hex))throw Error("Malformed fixture: "+line);
  const parser=new Binary();
  parser._binary=Uint8Array.from(Buffer.from(hex,"hex")).buffer;
  parser._binaryOffset=Number(offset);
  parser._data={};
  let status="ok";
  try{
    parser._parseArray({offset:rawOffsets.split(",").map(Number)});
  }catch(error){
    if(!(error instanceof Error)&&!error?.message)throw error;
    status="error";
  }
  if(status==="error"){
    records.push([name,"error"].join("\t"));
  }else{
    const data=parser._data;
    const alias=data.colorArray===data.intArray?"alias":"independent";
    records.push([name,"ok",alias,...viewKeys.map(k=>Array.from(data[k],formatNumber).join(","))].join("\t"));
  }
}
if(records.length!==32)throw Error("Unexpected case count "+records.length);
fs.writeFileSync(output,records.join("\n")+"\n");
console.log("Pinned DragonBonesJS BinaryDataParser._parseArray executed: "+records.length+" reference cases");
