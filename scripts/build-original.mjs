import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, copyFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { UPSTREAM } from '../upstream.lock.mjs';
const vendor = resolve('vendor/DragonBonesJS');
const runtime = resolve(vendor, 'DragonBones');
const output = resolve('dist/original/dragonBones.js');
function run(command,args,cwd) {
  const p=spawnSync(command,args,{cwd,stdio:'inherit',shell:process.platform==='win32'});
  if(p.error || p.status!==0) throw new Error(command+' failed: '+(p.error?.message??p.status));
}
if (!existsSync(resolve(runtime,'tsconfig.json'))) throw new Error('Run npm run upstream:clone first');
const rev=spawnSync('git',['-C',vendor,'rev-parse','HEAD'],{encoding:'utf8'});
if(rev.status!==0 || rev.stdout.trim()!==UPSTREAM.commit) throw new Error('Wrong upstream commit');
run('npm',['install','--no-audit','--no-fund'],runtime);
run('npm',['exec','--','tsc','-p','tsconfig.json'],runtime);
const built=resolve(runtime,'out/dragonBones.js');
if(!existsSync(built)) throw new Error('Expected upstream output missing');
mkdirSync(resolve('dist/original'),{recursive:true});
copyFileSync(built,output);
console.log('Original runtime compiled at dist/original/dragonBones.js');
