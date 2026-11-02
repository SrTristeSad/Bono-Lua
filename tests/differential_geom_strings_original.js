// Differential oracle: execute the ORIGINAL tracked DragonBonesJS classes,
// not reimplemented numeric behavior. JS only runs in CI test infrastructure.
// Upstream MIT commit 64b6c69ae35777c2404be68c9192e2c56906079e.
"use strict";
const fs=require("fs"),vm=require("vm");
const [bundle,fixtures,output]=process.argv.slice(2);
if (!bundle||!fixtures||!output) throw Error("usage: node differential_geom_strings_original.js original.js fixtures.tsv result.tsv");
const sandbox={PIXI:{Sprite:class PixiSprite{}}};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(bundle,"utf8"),sandbox,{
  filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",timeout:15000
});
const original=sandbox.dragonBones;
if(typeof original?.Matrix!=="function"||typeof original?.Transform!=="function")throw Error("Missing original DragonBonesJS classes");
const outputLines=[];
for (const line of fs.readFileSync(fixtures,"utf8").split(/\r?\n/)) {
  if (!line||line.startsWith("#"))continue;
  const [type,name,args]=line.split("\t");
  if(!["Matrix","Transform"].includes(type)||!name||!args)throw Error("Malformed case: "+line);
  const fields=args.split(",").map(x=>Number(x));
  if(fields.length!==6)throw Error("Expected six numbers: "+name);
  const instance=new original[type](...fields);
  outputLines.push([type,name,instance.toString()].join("\t"));
}
if(outputLines.length!==26)throw Error("Unexpected fixture count: "+outputLines.length);
fs.writeFileSync(output,outputLines.join("\n")+"\n");
console.log("Pinned DragonBonesJS Matrix/Transform.toString executed: "+outputLines.length+" reference cases");
