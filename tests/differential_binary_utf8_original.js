// Only a CI reference: executes the ORIGINAL compiled DragonBonesJS,
// pinned MIT commit 64b6c69ae35777c2404be68c9192e2c56906079e.
// It does not reimplement the decoder nor ship any JS product code.
"use strict";
const fs=require("fs"),vm=require("vm");
const [originalBundle,fixture,outputPath]=process.argv.slice(2);
if(!originalBundle||!fixture||!outputPath)throw Error("Usage: node differential_binary_utf8_original.js original.js cases.tsv expected.tsv");
const sandbox={PIXI:{Sprite:class PixiSprite{}}};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(originalBundle,"utf8"),sandbox,{
 filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",timeout:15000
});
const Binary=sandbox.dragonBones?.BinaryDataParser;
if(typeof Binary!=="function")throw Error("Pinned original BinaryDataParser unavailable");
const parser=new Binary();
const expected=[];
for(const line of fs.readFileSync(fixture,"utf8").split(/\r?\n/)){
 if(!line||line[0]==="#")continue;
 const [name,hex=""]=line.split("\t");
 if(!name||!/^(?:[0-9a-f]{2})*$/i.test(hex))throw Error("Bad fixture "+line);
 const bytes=Uint8Array.from(Buffer.from(hex,"hex"));
 const result=parser._decodeUTF8(bytes); // ACTUAL upstream decoder
 expected.push([name,Buffer.from(result,"utf8").toString("hex")].join("\t"));
}
if(expected.length!==52)throw Error("Wrong fixture count "+expected.length);
fs.writeFileSync(outputPath,expected.join("\n")+"\n");
console.log("Pinned DragonBonesJS BinaryDataParser._decodeUTF8 executed: "+expected.length+" reference cases");
