'use strict';
const fs=require('fs'),path=require('path'),cp=require('child_process'),vm=require('vm');
const root=path.resolve(__dirname,'..'),upstream=process.argv[2]||'../DragonBonesJS',lua=process.argv[3]||'lua5.4';
const PIXI=require('./pixi_public_bridge')(upstream),code=require('./pixi_sprite_source')(upstream,true);
const ctx=vm.createContext({PIXI,console:{info(){},warn(){},assert(){}}});vm.runInContext(code,ctx);
const d=ctx.dragonBones,F=d.PixiFactory;
const fixture=fs.readFileSync(path.join(root,'examples/public_factory_ske.json'),'utf8'),atlasText=fs.readFileSync(path.join(root,'examples/love/sprites_tex.json'),'utf8');
function parse(s){ctx.input=s;return vm.runInContext('JSON.parse(input)',ctx);}
function scalar(v){if(v==null)return'u';if(typeof v==='boolean')return String(v);if(typeof v==='string')return's'+Buffer.from(v).toString('hex');const b=Buffer.alloc(8);b.writeDoubleLE(v);return'n'+b.toString('hex');}
const cases=[];
for(let parser=0;parser<3;parser++)for(let debug=0;debug<3;debug++)for(let flip=0;flip<2;flip++)for(let boxes=0;boxes<2;boxes++)cases.push(['factory',parser,debug,flip,boxes]);
for(const mode of ['normal','removeDuring','addDuring','once','reenter','throw','contexts','special'])cases.push(['events',mode,0,0,0]);
function execute(c){const out=[],push=v=>out.push(scalar(v));
 if(c[0]==='events'){
  const p=new d.PixiArmatureDisplay(),t1={tag:'one'},t2={tag:'two'},trace=[];let changed=false;
  function a(e){trace.push('a:'+(this===p?'self':this.tag)+':'+e.name);if(!changed){changed=true;if(c[1]==='removeDuring')p.removeDBEventListener('custom',b,t2);if(c[1]==='addDuring')p.addDBEventListener('custom',cc,t1);if(c[1]==='reenter')p.dispatchDBEvent('custom',{name:'inner'});if(c[1]==='throw')throw Error('listener');}}
  function b(e){trace.push('b:'+this.tag+':'+e.name);}function cc(e){trace.push('c:'+this.tag+':'+e.name);}
  push(p.hasDBEventListener('custom'));
  if(c[1]==='once'||c[1]==='throw')p.once('custom',a,t1);else p.addDBEventListener('custom',a,t1);
  p.addDBEventListener('custom',b,t2);
  if(c[1]==='contexts'){p.addDBEventListener('custom',a,t2);p.addDBEventListener('custom',a,t1);p.removeDBEventListener('custom',a,t1);}
  if(c[1]==='special'){p.addDBEventListener('__proto__',a,0);p.dispatchDBEvent('__proto__',{name:'proto'});p.addDBEventListener('',a,'');p.dispatchDBEvent('',{name:'empty'});p.removeDBEventListener('',a,0);push(p.hasDBEventListener(''));}
  for(const name of ['first','second']){try{p.dispatchDBEvent('custom',{name});push('ok');}catch(e){push('error');}push(p.hasDBEventListener('custom'));push(p.listeners('custom').length);}
  p.removeDBEventListener('custom',a);p.removeDBEventListener('custom',b);p.removeDBEventListener('custom',cc);push(p.hasDBEventListener('custom'));push(trace.join('|'));return out;
 }
 F._factory=null;F._dragonBonesInstance=null;PIXI.ticker.shared.callbacks=[];d.DragonBones.debugDraw=false;
 const parser=c[1]===1?new d.ObjectDataParser():null,f=c[1]===2?F.factory:new F(parser),other=new F();f.clock.time=0;
 push(f.dragonBones===other.dragonBones);push(f.clock===other.clock);push(F.factory===F.factory);push(F.factory.dragonBones===f.dragonBones);push(!parser||f._dataParser===parser);
 const raw=parse(fixture);if(c[4])for(const slot of raw.armature[0].slot)slot.displayIndex=1;
 f.parseDragonBonesData(raw,'public');const image={width:48,height:16},atlas=f.parseTextureAtlasData(parse(atlasText),c[1]===2?null:image,'public');f.autoSearch=true;atlas.autoSearch=true;
 push(other.getDragonBonesData('public')===null);push(f.buildArmatureDisplay('missing','public')===null);
 const sprite=f.getTextureDisplay('red','public');push(sprite!==null);push(sprite!==null&&sprite.texture===atlas.getTexture('red').renderTexture);push(f.getTextureDisplay('red')!==null);push(f.getTextureDisplay('missing')===null);
 const p=f.buildArmatureDisplay('demo','public'),a=p.armature,plain=f.buildArmature('demo','public');
 push(a.proxy===p);push(a.eventDispatcher===p);push(p.animation===a.animation);push(f.clock.contains(a));push(f.clock.contains(plain));
 for(const [o,k]of [[p,'armature'],[p,'animation'],[f,'soundEventManager'],[F,'factory']]){try{o[k]=null;push('written');}catch(e){push('readonly');}}
 const trace=[],localTarget={tag:'local'},soundTarget={tag:'global'};
 function event(e){trace.push(this.tag+':'+e.type+':'+e.name);}
 for(const kind of ['start','loopComplete','frameEvent','soundEvent'])p.addDBEventListener(kind,event,localTarget);
 f.soundEventManager.addDBEventListener('soundEvent',event,soundTarget);
 a.flipX=!!c[3];p.debugDraw=c[2]===1;d.DragonBones.debugDraw=c[2]===2;p.animation.play('move',0);
 function snap(){push(p._debugDraw);push(p.children.length);const drawer=p._debugDrawer;push(!!drawer);push(!!drawer&&drawer.parent===p);if(!drawer)return;push(drawer.children.length);for(const child of drawer.children){push(child.name);for(const key of ['x','y','scaleX','scaleY','rotation','skewX','skewY','pivotX','pivotY'])push(child[key]);push(child.commands.length);for(const cmd of child.commands){push(cmd.length);for(const v of cmd)push(v);}}}
 for(let step=0;step<4;step++){
  if(step===1&&c[4])for(const slot of a.getSlots())slot.displayIndex=0;
  if(step===2&&c[4])for(const slot of a.getSlots())slot.displayIndex=1;
  if(step===3){p.debugDraw=false;d.DragonBones.debugDraw=false;}
  PIXI.ticker.shared.step(step===1?.5:1,[0,500,250,500][step]);snap();push(p.animation.lastAnimationState.currentTime);
 }
 push(trace.join('|'));p.removeDBEventListener('frameEvent',event,localTarget);push(p.hasDBEventListener('frameEvent'));
 p.dispose(false);push(p.armature===null);push(f.clock.contains(a));try{void p.animation;push('animation');}catch(e){push('error');}
 p.destroy();plain.dispose();f.dragonBones.advanceTime(0);push(f.clock.contains(a));push(p._debugDrawer===null);push(p.children.length);push(p.hasDBEventListener('start'));
 if(sprite)sprite.destroy();f.soundEventManager.removeDBEventListener('soundEvent',event,soundTarget);f.clear();f.dragonBones.advanceTime(0);d.DragonBones.debugDraw=false;
 return out;
}
const dir=path.join(root,'artifacts');fs.mkdirSync(dir,{recursive:true});const tag=path.basename(lua),prefix=path.join(dir,'publicfactory-'+tag);
fs.writeFileSync(prefix+'-cases.tsv',cases.map(c=>c.join('\t')).join('\n')+'\n');
const expected=cases.map(execute);fs.writeFileSync(prefix+'-original.tsv',expected.map(r=>r.join('\t')).join('\n')+'\n');
const child=cp.spawnSync(lua,['tests/publicfactory_differential.lua',prefix+'-cases.tsv'],{cwd:root,encoding:'utf8',maxBuffer:32*1024*1024});
fs.writeFileSync(prefix+'-stderr.txt',child.stderr||'');if(child.status!==0)throw Error(child.stderr||child.error||'Lua failed');
const actual=child.stdout;fs.writeFileSync(prefix+'-actual.tsv',actual);
const rows=actual.trimEnd().split('\n').map(r=>r.split('\t'));if(rows.length!==expected.length)throw Error('rows');let columns=0;
for(let i=0;i<rows.length;i++){if(rows[i].length!==expected[i].length)throw Error('columns '+i+' '+cases[i]+' expected '+expected[i].length+' actual '+rows[i].length);for(let j=0;j<rows[i].length;j++){columns++;if(rows[i][j]!==expected[i][j])throw Error('API '+i+' '+cases[i]+' col '+j+' expected '+expected[i][j]+' actual '+rows[i][j]);}}
const result={scenarios:cases.length,comparedColumns:columns,approximateComparisons:0,lua,result:'passed'};fs.writeFileSync(prefix+'-result.json',JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
