'use strict';
// Numeric platform probes only. Pixel validation uses real PIXI in Chromium.
class Node {
 constructor(){this.children=[];this.x=this.y=this.rotation=this.skewX=this.skewY=0;this.scaleX=this.scaleY=1;this.alpha=1;this.tint=0xffffff;this.visible=true;this.blendMode=0;this.texture=null;this.parent=null;}
 setTransform(x=0,y=0,sx=1,sy=1,r=0,kx=0,ky=0){Object.assign(this,{x,y,scaleX:sx,scaleY:sy,rotation:r,skewX:kx,skewY:ky});}
 addChild(c){if(c.parent)c.parent.removeChild(c);this.children.push(c);c.parent=this;}
 getChildIndex(c){const i=this.children.indexOf(c);if(i<0)throw Error('child');return i;}
 removeChild(c){this.children.splice(this.getChildIndex(c),1);c.parent=null;}
 addChildAt(c,i){if(c.parent)c.parent.removeChild(c);this.children.splice(i,0,c);c.parent=this;}
 swapChildren(a,b){const i=this.getChildIndex(a),j=this.getChildIndex(b);[this.children[i],this.children[j]]=[b,a];}
 destroy(){if(this.parent)this.parent.removeChild(this);this.destroyed=true;this.texture=null;}
}
class Sprite extends Node{}
class Mesh extends Node{constructor(){super();this.dirty=this.indexDirty=0;}}
class Rectangle{constructor(x,y,width,height){Object.assign(this,{x,y,width,height});}}
class Texture{constructor(baseTexture,frame,orig,trim,rotate){Object.assign(this,{baseTexture,frame,orig,trim,rotate});}destroy(){this.destroyed=true;}}
module.exports={VERSION:'4.8.9',Container:Node,Sprite,mesh:{Mesh},Rectangle,Texture,BLEND_MODES:{NORMAL:0,ADD:1}};
