// Test-only JS reference runner; never part of the Lua engine or editor.
// Execute the compiled ORIGINAL DragonBonesJS at fixed MIT commit
// 64b6c69ae35777c2404be68c9192e2c56906079e.
"use strict";
const fs=require("fs");
const vm=require("vm");
const [bundle,fixture,outfile]=process.argv.slice(2);
if (!bundle || !fixture || !outfile) throw new Error("usage: node differential_transform_original.js bundle.js fixtures.tsv expected.tsv");
const sandbox={PIXI:{Sprite:class PixiSprite{}}};
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(bundle,"utf8"),sandbox,{
  filename:"DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",timeout:15000
});
const Transform=sandbox.dragonBones.Transform;
const Matrix=sandbox.dragonBones.Matrix;
if (typeof Transform!=="function"||typeof Matrix!=="function") throw new Error("Pinned upstream classes missing");
const parse=s=>s.split(",").map(part=>{
  const n=Number(part);
  if (!Number.isFinite(n)) throw new Error("Nonfinite fixture: "+part);
  return n;
});
const transformFields=t=>[t.x,t.y,t.skew,t.rotation,t.scaleX,t.scaleY];
const matrixFields=m=>[m.a,m.b,m.c,m.d,m.tx,m.ty];
const format=n=>Number.isNaN(n)?"NaN":n===Infinity?"Infinity":n===-Infinity?"-Infinity":Object.is(n,-0)?"-0":String(n);
const result=[];
for (const line of fs.readFileSync(fixture,"utf8").split(/\r?\n/)){
  if(!line||line.startsWith("#"))continue;
  const [op,name,first,second]=line.split("\t");
  if(!op||!name||!first)throw new Error("Invalid fixture: "+line);
  let obj,returnValue,values;
  if(op==="normalize"){
    returnValue=Transform.normalizeRadian(Number(first));
    values=[returnValue];
  }else{
    obj=new Transform(...parse(first));
    switch(op){
      case "toMatrix":{
        const dest=new Matrix(9,8,7,6,5,4);
        returnValue=obj.toMatrix(dest);
        values=matrixFields(dest);break;
      }
      case "fromMatrix":
        returnValue=obj.fromMatrix(new Matrix(...parse(second)));
        values=transformFields(obj);break;
      case "add":
        returnValue=obj.add(new Transform(...parse(second)));
        values=transformFields(obj);break;
      case "minus":
        returnValue=obj.minus(new Transform(...parse(second)));
        values=transformFields(obj);break;
      case "copyFrom":
        returnValue=obj.copyFrom(new Transform(...parse(second)));
        values=transformFields(obj);break;
      case "identity":
        returnValue=obj.identity();
        values=transformFields(obj);break;
      default:throw new Error("Unknown method: "+op);
    }
  }
  const returnKind=op==="normalize"?"number":returnValue===obj?"self":returnValue===undefined?"void":"unexpected";
  if(returnKind==="unexpected")throw new Error("Original return contract changed: "+name);
  result.push([op,name,returnKind,...values.map(format)].join("\t"));
}
if(result.length!==44)throw new Error("Expected 44 fixtures, got "+result.length);
fs.writeFileSync(outfile,result.join("\n")+"\n");
console.log("Pinned DragonBonesJS Transform executed: "+result.length+" reference cases");
