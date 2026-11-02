// CI-only differential harness. Engine/application/editor remain Lua.
// Load the PREBUILT DragonBonesJS bundle from the pinned upstream commit,
// not a rewritten approximation of its Matrix algorithms.
"use strict";
const fs = require("fs");
const vm = require("vm");
const [upstreamPath, inputPath, outputPath] = process.argv.slice(2);
if (!upstreamPath || !inputPath || !outputPath) {
  throw new Error("Usage: node differential_matrix_original.js upstream.js cases.tsv expected.tsv");
}
// The upstream bundle declares PixiArmatureDisplay extends PIXI.Sprite,
// but this harness instantiates ONLY the original pure Matrix class.
const sandbox = { PIXI: { Sprite: class PixiSprite {} } };
vm.createContext(sandbox);
vm.runInContext(fs.readFileSync(upstreamPath, "utf8"), sandbox, {
  filename: "DragonBonesJS@64b6c69/Pixi/5.x/out/dragonBones.js",
  timeout: 15000
});
const Matrix = sandbox.dragonBones && sandbox.dragonBones.Matrix;
if (typeof Matrix !== "function") {
  throw new Error("Pinned upstream bundle did not expose dragonBones.Matrix");
}
const parseNumbers = s => s.split(",").map(x => {
  const n = Number(x);
  if (!Number.isFinite(n)) throw new Error("Invalid fixture number: " + x);
  return n;
});
const fields = m => [m.a, m.b, m.c, m.d, m.tx, m.ty];
const output = [];
const lines = fs.readFileSync(inputPath, "utf8").split(/\r?\n/);
for (const line of lines) {
  if (!line || line.startsWith("#")) continue;
  const [op, name, args, other, option] = line.split("\t");
  if (!op || !name || !args) throw new Error("Malformed fixture: " + line);
  const n = parseNumbers(args);
  let m, result, values;
  if (op === "copyArray") {
    m = new Matrix();
    result = m.copyFromArray(n, Number(other));
    values = fields(m);
  } else {
    if (n.length !== 6) throw new Error("Matrix needs 6 values: " + name);
    m = new Matrix(...n);
    switch (op) {
      case "concat":
        result = m.concat(new Matrix(...parseNumbers(other)));
        values = fields(m);
        break;
      case "invert":
        result = m.invert();
        values = fields(m);
        break;
      case "point": {
        const [x,y] = parseNumbers(other);
        const point = {x:0,y:0};
        result = m.transformPoint(x, y, point, option === "true");
        values = [point.x, point.y];
        break;
      }
      case "rect": {
        const [x,y,width,height] = parseNumbers(other);
        const rect = {x,y,width,height};
        result = m.transformRectangle(rect, option === "true");
        values = [rect.x,rect.y,rect.width,rect.height];
        break;
      }
      case "identity":
        result = m.identity();
        values = fields(m);
        break;
      case "copyFrom":
        result = m.copyFrom(new Matrix(...parseNumbers(other)));
        values = fields(m);
        break;
      default:
        throw new Error("Unknown operation: " + op);
    }
  }
  if (!values.every(Number.isFinite)) throw new Error("Non-finite reference: " + name);
  const returnKind = result === m ? "self" : result === undefined ? "void" : "other";
  if (returnKind === "other") throw new Error("Unexpected upstream return: " + name);
  output.push([op, name, returnKind, ...values.map(String)].join("\t"));
}
if (output.length !== 22) throw new Error("Case count changed unexpectedly: " + output.length);
fs.writeFileSync(outputPath, output.join("\n") + "\n");
console.log("Pinned DragonBonesJS Matrix executed: " + output.length + " reference cases");
