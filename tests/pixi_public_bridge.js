'use strict';
// Numeric host bridge. The emitter dependency is executed from the pinned Pixi
// bundle, not replaced by a second implementation of event dispatch semantics.
const cp=require('child_process');
module.exports=function(upstream){
 const p=require('./pixi_sprite_bridge');
 const text=cp.execFileSync('git',['-C',upstream,'show','64b6c69ae35777c2404be68c9192e2c56906079e:Pixi/Demos/4.x/libs/pixi/pixi.js'],{encoding:'utf8',maxBuffer:8*1024*1024});
 const signature='3:[function(require,module,exports){',start=text.indexOf(signature)+signature.length,end=text.indexOf('},{}],4:[',start);
 if(start<signature.length||end<start)throw Error('Cannot find pinned emitter');
 const mod={exports:{}};new Function('require','module','exports',text.slice(start,end))(()=>{throw Error('unexpected dependency');},mod,mod.exports);
 const E=mod.exports;
 function Sprite(texture){Object.assign(this,new p.Sprite());E.call(this);this.texture=texture||null;this.pivotX=this.pivotY=0;}
 Sprite.prototype=Object.create(p.Sprite.prototype);Sprite.prototype.constructor=Sprite;
 for(const key of Object.getOwnPropertyNames(E.prototype))if(key!=='constructor')Sprite.prototype[key]=E.prototype[key];
 const proto=p.Container.prototype;
 proto.getChildAt=function(i){if(i<0||i>=this.children.length)throw Error('index');return this.children[i];};
 proto.getChildByName=function(name){return this.children.find(c=>c.name===name)||null;};
 const transform=proto.setTransform;
 proto.setTransform=function(x=0,y=0,sx=1,sy=1,r=0,kx=0,ky=0,px=0,py=0){transform.call(this,x,y,sx,sy,r,kx,ky);this.pivotX=px;this.pivotY=py;};
 Sprite.prototype.destroy=function(options){
  if(this.parent)this.parent.removeChild(this);
  const children=this.children;this.children=[];
  for(const child of children){child.parent=null;if(options===true||options&&options.children)child.destroy(options);}
  this.removeAllListeners();this.texture=null;this.destroyed=true;
 };
 function Graphics(){Object.assign(this,new p.Container());this.pivotX=this.pivotY=0;this.commands=[];}
 Graphics.prototype=Object.create(proto);Graphics.prototype.constructor=Graphics;
 Graphics.prototype.clear=function(){this.commands=[];return this;};
 for(const name of ['lineStyle','moveTo','lineTo','beginFill','endFill','drawCircle','drawRect','drawEllipse'])Graphics.prototype[name]=function(...args){this.commands.push([name,...args]);return this;};
 p.mesh.Mesh.DRAW_MODES={TRIANGLE_MESH:0,TRIANGLES:1};
 const shared={elapsedMS:0,callbacks:[],add(fn,context){this.callbacks.push({fn,context});},step(scale,elapsed){this.elapsedMS=elapsed;for(const c of this.callbacks)c.fn.call(c.context,scale);}};
 return {...p,Sprite,Graphics,ticker:{shared}};
};
