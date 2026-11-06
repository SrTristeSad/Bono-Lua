'use strict';
// Real pinned Pixi Screen/Multiply with semitransparent source texels.
const fs=require('fs'),path=require('path'),{chromium}=require('playwright');
const root=path.resolve(__dirname,'..'),output=path.join(root,'artifacts/love');
const input=JSON.parse(fs.readFileSync(path.join(root,'examples/love/texture_alpha.json')));
const code=require('./pixi_sprite_source')(process.argv[2]||'../DragonBonesJS');
const sprites=JSON.parse(fs.readFileSync(path.join(root,'examples/love/sprites_ske.json'))),meshes=JSON.parse(fs.readFileSync(path.join(root,'examples/love/meshes_ske.json'))),atlas=JSON.parse(fs.readFileSync(path.join(root,'examples/love/rotated_tex.json')));
(async()=>{const browser=await chromium.launch({headless:true,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader','--enable-webgl','--ignore-gpu-blocklist']});try{const page=await browser.newPage();await page.setContent('<html><body></body></html>');await page.addScriptTag({path:require.resolve('pixi.js/dist/pixi.js')});await page.addScriptTag({content:code});
const frames=await page.evaluate(({sprites,meshes,atlas,input})=>{const d=dragonBones,B=d.BaseObject,result=[];function image(replace){
 const canvas=document.createElement('canvas');canvas.width=64;canvas.height=32;
 const ctx=canvas.getContext('2d'),pixels=ctx.createImageData(64,32),colors=replace?input.replacement:input.colors;
 for(let y=0;y<32;y++)for(let x=0;x<64;x++){
  let color=[173,53,227,0];
  for(const r of atlas.SubTexture)if(x>=r.x&&x<r.x+r.width&&y>=r.y&&y<r.y+r.height){
   const right=x-r.x>=r.width/2,bottom=y-r.y>=r.height/2;
   color=colors[(right?1:0)+(bottom?2:0)];
  }
  pixels.data.set(color,(y*64+x)*4);
 }
 ctx.putImageData(pixels,0,0);
 const texture=PIXI.BaseTexture.fromCanvas(canvas);texture.scaleMode=PIXI.SCALE_MODES.NEAREST;return texture;
}
const base=image(false),replacement=image(true),cases=[];
for(const mode of [12,10])for(const alpha of [0,.25,.5,1])for(const tint of [1,.5])for(const rotated of [false,true])cases.push([alpha,tint,rotated,mode]);
let scene=0;
for(const c of cases){const core=new d.DragonBones({dispatchDBEvent(){}});class Factory extends d.BaseFactory{constructor(){super();this._dragonBones=core;}_buildTextureAtlasData(a,t){if(a===null)return B.borrowObject(d.PixiTextureAtlasData);a.renderTexture=t;return a;}_buildArmature(p){const a=B.borrowObject(d.Armature);a.init(p.armature,{dbInit(){},dbUpdate(){},dbClear(){},hasDBEventListener(){return false;},dispatchDBEvent(){}},new PIXI.Container(),core);return a;}_buildSlot(p,s,a){const slot=B.borrowObject(d.PixiSlot);slot.init(s,a,new PIXI.Sprite(),new PIXI.mesh.Mesh(null,null,null,null,PIXI.mesh.Mesh.DRAW_MODES.TRIANGLES));return slot;}}
scene++;
const raw=JSON.parse(JSON.stringify(sprites)),ar=JSON.parse(JSON.stringify(atlas));
if(!c[2])for(const texture of ar.SubTexture)texture.rotated=false;
for(const slot of raw.armature[0].slot){slot.blendMode=c[3];slot.color={aM:c[0]*100,rM:c[1]*100,gM:100,bM:100};}
const f=new Factory();f.parseDragonBonesData(raw,'sprites');f.parseTextureAtlasData(ar,base,'sprites');
const a=f.buildArmature('demo','sprites');a.animation.play('move',0);if(scene%5===0)a.replacedTexture=replacement;a.flipX=scene%3===0;
if(scene%4===0){a.getSlot('red')._zIndex=3;a._zIndexDirty=true;}a.advanceTime(.25);
const stage=new PIXI.Container();stage.position.set(64,32);const backdrop=new PIXI.Graphics();backdrop.beginFill(0x90b050,1);backdrop.drawRect(-64,-32,160,64);backdrop.endFill();stage.addChild(backdrop);stage.addChild(a.display);const renderer=new PIXI.WebGLRenderer(160,128,{transparent:false,backgroundColor:0x406080,antialias:false,preserveDrawingBuffer:true,resolution:1});renderer.render(stage);const gl=renderer.gl,bottom=new Uint8Array(160*128*4),rgba=new Uint8Array(bottom.length);gl.readPixels(0,0,160,128,gl.RGBA,gl.UNSIGNED_BYTE,bottom);for(let y=0;y<128;y++)rgba.set(bottom.subarray((127-y)*640,(128-y)*640),y*640);result.push({rgba:Array.from(rgba),png:renderer.view.toDataURL('image/png')});a.dispose();core.advanceTime(0);f.clear();core.advanceTime(0);renderer.destroy(true);}
return result;},{sprites,meshes,atlas,input});
let compared=0,changedChannels=0,maxError=0;
const scenes=[];
for(let i=0;i<frames.length;i++){
 const expected=Buffer.from(frames[i].rgba),actual=fs.readFileSync(path.join(output,'love-texture-alpha-'+i+'.rgba'));
 if(actual.length!==expected.length)throw Error('size');
 fs.writeFileSync(path.join(output,'pixi-texture-alpha-'+i+'.rgba'),expected);
 fs.writeFileSync(path.join(output,'pixi-texture-alpha-'+i+'.png'),Buffer.from(frames[i].png.split(',')[1],'base64'));
 let changed=0,error=0;
 for(let j=0;j<expected.length;j++){
  compared++;const difference=Math.abs(actual[j]-expected[j]);
  if(difference)changed++;
  error=Math.max(error,difference);
 }
 changedChannels+=changed;maxError=Math.max(maxError,error);
 scenes.push({scene:i,changedChannels:changed,maxError:error});
}
const result={reference:'Pinned PixiSlot + real Pixi 4.8.9 premultiplied upload and WebGLRenderer / Chromium',
 runtime:'Real LÖVE Screen/Multiply with RGBA8 destination snapshots / Mesa',frames:frames.length,
 comparedChannels:compared,changedChannels,maxError,scenes,result:changedChannels?'failed':'passed'};
fs.writeFileSync(path.join(output,'texture-alpha-result.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
if(changedChannels)throw Error('Texture alpha differs in '+changedChannels+' channels; max error '+maxError);
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exit(1);});
