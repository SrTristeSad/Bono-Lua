// CI-only oracle: run the pinned *actual* DragonBonesJS ObjectDataParser
// on the same weighted/FFD fixture used by the real LÖVE application.
// Source: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
// MIT upstream. This JS file never ships with the Lua runtime.
"use strict";
const fs=require("fs"),vm=require("vm");
const [originalBundle,fixturePath,outputPath]=process.argv.slice(2);
if(!originalBundle||!fixturePath||!outputPath){
  throw Error("Usage: node differential_weighted_mesh_original.js original.js mesh.json expected.tsv");
}
const sandbox={PIXI:{Sprite:class Sprite{}},console};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(originalBundle,"utf8"),sandbox,
  {timeout:15000,filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js"});
const original=sandbox.dragonBones;
if(typeof original?.ObjectDataParser!=="function"){
  throw Error("Pinned original ObjectDataParser class missing");
}
// Arrays must be constructed in the SAME vm realm as the pinned parser:
// its implementation intentionally uses 'instanceof Array' checks.
const json=JSON.stringify(JSON.parse(fs.readFileSync(fixturePath,"utf8")));
const input=vm.runInContext("("+json+")",sandbox);
const result=new original.ObjectDataParser().parseDragonBonesData(input);
if(!result||!result.binary)throw Error("Pinned parser did not emit binary typed views");
const rig=result.getArmature("rig");
const geometry=rig?.defaultSkin?.getDisplay("body","red")?.geometry;
const weight=geometry?.weight;
if(!weight||weight.bones.length!==2||weight.count!==6){
  throw Error("Pinned parser failed to compile 2-bone 6-influence model");
}
const keys=["intArray","floatArray","frameIntArray","frameFloatArray",
 "frameArray","timelineArray","colorArray"];
const row=[
  ["binary",Buffer.from(new Uint8Array(result.binary)).toString("hex")],
  ["views",keys.map(k=>result[k].length).join(",")],
  ["weight",String(weight.count)],
  ["bones",weight.bones.map(b=>b.name).join(",")],
];
fs.writeFileSync(outputPath,row.map(x=>x.join("\t")).join("\n")+"\n");
console.log("Pinned original DragonBonesJS weighted/FFD parser: 2 bones, 6 influences, full binary bytes emitted.");
