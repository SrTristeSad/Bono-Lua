// Optional graphical integration test. Install playwright and its Chromium browser first.
// Example: npm install --no-save playwright@1.56.1 && npx playwright install chromium
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { mkdir, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
const port=4179;
const url='http://127.0.0.1:'+port+'/';
const server=spawn(process.execPath,['scripts/serve-demo.mjs'],{
  env:{...process.env,PORT:String(port)},stdio:['ignore','pipe','pipe']
});
let browser=null;
try {
  let active=false;
  for(let i=0;i<80;i++) {
    if(server.exitCode!==null) throw new Error('Demo server exited unexpectedly');
    try {
      const res=await fetch(url);
      if(res.ok) {active=true; break;}
    } catch {}
    await new Promise(resolve=>setTimeout(resolve,250));
  }
  if(!active) throw new Error('Local server did not start');
  browser=await chromium.launch({
    headless:true,
    args:['--use-gl=angle','--use-angle=swiftshader','--enable-webgl']
  });
  const page=await browser.newPage({viewport:{width:1280,height:820}});
  const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(url,{waitUntil:'networkidle',timeout:60000});
  await page.waitForFunction(() => document.getElementById('status')?.dataset.state!=='loading',{timeout:60000});
  const finalState=await page.locator('#status').getAttribute('data-state');
  if(finalState!=='ready') throw new Error('Demo failed: '+await page.locator('#status').innerText());
  assert.equal(await page.locator('#bone-count').innerText(),'20');
  assert.equal(await page.locator('#slot-count').innerText(),'19');
  assert.equal(await page.locator('#animation').inputValue(),'idle');
  const state=await page.evaluate(()=>({
    canvas:document.querySelectorAll('#canvas-host canvas').length,
    armature:window.__bonoDemo.display?.armature?.name,
    children:window.__bonoDemo.display?.children?.length,
    ready:window.__bonoDemo.ready
  }));
  assert.equal(state.canvas,1,'canvas');
  assert.ok(state.ready,'ready');
  assert.ok((state.children??0)>0,'mounted display objects');
  const before=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  await page.waitForTimeout(260);
  const after=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.notEqual(after,before,'original DragonBones animation must advance');
  await page.locator('#character').selectOption('mecha1406');
  assert.equal(await page.locator('#bone-count').innerText(),'17');
  assert.equal(await page.locator('#slot-count').innerText(),'13');
  await page.locator('#animation').selectOption('walk');
  assert.match(await page.locator('#status').innerText(),/walk/);
  const walkBefore=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  await page.waitForTimeout(260);
  const walkAfter=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.notEqual(walkAfter,walkBefore,'original walk timeline must advance');
  await page.locator('#pause').click();
  const pauseBefore=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  await page.waitForTimeout(200);
  const pauseAfter=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.equal(pauseAfter,pauseBefore,'pause must freeze the animation clock');
  assert.match(await page.locator('#status').innerText(),/Pausado/);
  await page.locator('#play').click();
  await page.locator('#speed').evaluate(input => { input.value='1.5'; input.dispatchEvent(new Event('input',{bubbles:true})); });
  assert.equal(await page.locator('#speed-output').innerText(),'1,50×');
  await page.locator('#bones').check();
  await page.waitForTimeout(300);
  const sampleDir = resolve('vendor/DragonBonesJS/Cocos/Demos/assets/resources/mecha_1406');
  await page.locator('#skeleton-file').setInputFiles(resolve(sampleDir,'mecha_1406_ske.json'));
  await page.locator('#atlas-file').setInputFiles(resolve(sampleDir,'mecha_1406_tex.json'));
  await page.locator('#texture-file').setInputFiles(resolve(sampleDir,'mecha_1406_tex.png'));
  await page.locator('#import-character').click();
  await page.waitForFunction(() => {
    const txt=document.getElementById('import-status')?.textContent || '';
    return txt.includes('importada(s)') || txt.startsWith('Erro:');
  },{timeout:30000});
  const importResult=await page.locator('#import-status').innerText();
  assert.match(importResult,/1 armadura\(s\) importada\(s\)/,'local DragonBones import');
  assert.match(await page.locator('#model-origin').innerText(),/Arquivo local/);
  assert.match(await page.locator('#character').inputValue(),/^bono-local-1-/);
  assert.equal(await page.locator('#bone-count').innerText(),'17');
  assert.equal(await page.locator('#slot-count').innerText(),'13');
  await page.locator('#animation').selectOption('walk');
  const importedStart=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  await page.waitForTimeout(240);
  const importedEnd=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.notEqual(importedStart,importedEnd,'imported original animation must advance');
  await page.locator('#timeline').evaluate(input => {
    input.value='0.65';
    input.dispatchEvent(new Event('input',{bubbles:true}));
  });
  assert.equal(await page.evaluate(()=>window.__bonoDemo.paused),true,'scrubbing pauses playback');
  const seekTime=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.ok(Math.abs(seekTime - 0.65) < 0.05,'seek must use original currentTime API');
  await page.waitForTimeout(200);
  const held=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.equal(held,seekTime,'scrubbed frame remains frozen');
  await page.locator('#play').click();
  await page.waitForTimeout(180);
  const resumed=await page.evaluate(()=>window.__bonoDemo.display.animation.lastAnimationState.currentTime);
  assert.notEqual(resumed,held,'play resumes after seeking');
  await page.locator('#skeleton-file').setInputFiles({
    name:'broken.json', mimeType:'application/json',buffer:Buffer.from('{broken')
  });
  await page.locator('#import-character').click();
  await page.waitForFunction(() => document.getElementById('import-status')?.textContent?.startsWith('Erro:'));
  assert.match(await page.locator('#import-status').innerText(),/Erro:/);
  assert.match(await page.locator('#model-origin').innerText(),/Arquivo local/,'bad import preserves previous selection');


  // Select a joint visually on top of the ORIGINAL Pixi canvas.
  await page.locator('#pick-bones').check();
  assert.equal(await page.locator('#bone-overlay .bone-marker').count(),17);
  const visibleMarkers = await page.locator('#bone-overlay .bone-marker').evaluateAll(nodes =>
    nodes.map(node => ({ name:node.dataset.bone, x:Number(node.getAttribute('cx')), y:Number(node.getAttribute('cy')) }))
      .filter(p => p.x > 10 && p.x < 950 && p.y > 10 && p.y < 530));
  assert.ok(visibleMarkers.length > 0,'bone markers should be projected onto the stage');
  const chosenMarker = page.locator('#bone-overlay .bone-marker')
    .filter({has: page.locator('title')}).first();
  await chosenMarker.click({force:true});
  assert.match(await page.locator('#bone-status').innerText(),/selecionado na prévia/);
  assert.equal(await page.locator('#bone-x').isEnabled(),true);

  // The read-only slot inspector must reveal the parent bone and skin displays.
  assert.equal(await page.locator('#slot-list button').count(),13);
  await page.locator('#slot-list button').first().click();
  assert.match(await page.locator('#slot-details').innerText(),/Slot:/);
  assert.match(await page.locator('#slot-details').innerText(),/Osso:/);
  assert.match(await page.locator('#slot-details').innerText(),/Desenhos:/);

  // Phase 8: change the default slot display without editing animation keyframes.
  const firstSlotName = await page.locator('#slot-list button').first().getAttribute('data-slot');
  const defaultDisplay = Number(await page.locator('#slot-display').inputValue());
  const oldOrder = await page.evaluate(() =>
    window.__bonoDemo.models.get(document.getElementById('character').value)
      .document.armature.find(a=>a.name==='mecha_1406').slot.map(s=>s.name));
  await page.locator('#slot-display').selectOption('-1');
  const hidden = await page.evaluate(name => ({
    runtime:window.__bonoDemo.display.armature.getSlot(name).displayIndex,
    raw:window.BonoSlotEditor.getDisplayIndex(
      window.__bonoDemo.models.get(document.getElementById('character').value).document,
      'mecha_1406',name)
  }), firstSlotName);
  assert.equal(hidden.runtime,-1,'runtime slot must hide display');
  assert.equal(hidden.raw,-1,'JSON slot index must be updated');
  await page.locator('#slot-restore').click();
  assert.equal(Number(await page.locator('#slot-display').inputValue()),defaultDisplay);
  await page.locator('#slot-up').click();
  const moved = await page.evaluate(() => ({
    raw:window.__bonoDemo.models.get(document.getElementById('character').value)
      .document.armature.find(a=>a.name==='mecha_1406').slot.map(s=>s.name),
    orders:window.__bonoDemo.display.armature.getSlots()
      .map(s=>({name:s.name,order:s._zOrder}))
  }));
  assert.equal(moved.raw[1],firstSlotName,'JSON order changed');
  assert.deepEqual(moved.raw.slice(2),oldOrder.slice(2),'other slots unaffected');
  assert.ok(moved.orders.find(s=>s.name===firstSlotName).order > 0,'runtime z-order updated');
  await page.locator('#slot-down').click();
  const restoredOrder=await page.evaluate(() =>
    window.__bonoDemo.models.get(document.getElementById('character').value)
      .document.armature.find(a=>a.name==='mecha_1406').slot.map(s=>s.name));
  assert.deepEqual(restoredOrder,oldOrder,'inverse move restores original slot order');
  await page.locator('#slot-display').selectOption('-1');
  assert.match(await page.locator('#slot-status').innerText(),/Desenho alterado/);

  // Editing the rest pose works through the ORIGINAL bone offset API.
  const boneChoices=page.locator('#bone-tree button');
  assert.equal(await boneChoices.count(),17,'Imported mecha must expose 17 editable bones');
  const chosenBone=await boneChoices.nth(1).getAttribute('data-bone');
  await boneChoices.nth(1).click();
  assert.equal(await page.locator('#bone-x').isEnabled(),true);
  const baseX=Number(await page.locator('#bone-x').inputValue());
  const baseRotation=Number(await page.locator('#bone-rotation').inputValue());
  await page.locator('#bone-x').fill(String(baseX+14));
  await page.locator('#bone-x').press('Tab');
  await page.locator('#bone-rotation').fill(String(baseRotation+15));
  await page.locator('#bone-rotation').press('Tab');
  const preview=await page.evaluate(name=>{
    const bone=window.__bonoDemo.display.armature.getBone(name);
    return {x:bone.offset.x,rotation:bone.offset.rotation};
  },chosenBone);
  assert.ok(Math.abs(preview.x-14)<.001,'bone offset should change preview');
  assert.ok(Math.abs(preview.rotation-Math.PI/12)<.001,'bone rotation should change preview');
  const pendingDownload=page.waitForEvent('download');
  await page.locator('#bone-export').click();
  const download=await pendingDownload;
  assert.match(download.suggestedFilename(),/_ske\.json$/);
  const exported=JSON.parse(await readFile(await download.path(),'utf8'));
  const arm=exported.armature.find(a=>a.name==='mecha_1406');
  const saved=arm.bone.find(b=>b.name===chosenBone);
  assert.equal(saved.transform.x,baseX+14);
  assert.equal(arm.slot.find(slot=>slot.name===firstSlotName).displayIndex,-1,'slot selection must persist in exported JSON');
  assert.ok(Math.abs((saved.transform.rotate??saved.transform.skY)-(baseRotation+15))<1e-9);

  // A saved JSON document is a genuine DragonBones skeleton; reimport it
  // with the matching atlas and texture, without converting to a new format.
  await page.locator('#skeleton-file').setInputFiles({
    name:'edited_ske.json',mimeType:'application/json',
    buffer:Buffer.from(JSON.stringify(exported))
  });
  await page.locator('#import-character').click();
  await page.waitForFunction(()=> {
    const txt=document.getElementById('import-status')?.textContent||'';
    return txt.startsWith('Erro:') || txt.includes('importada(s)');
  });
  assert.match(await page.locator('#import-status').innerText(),/importada\(s\)/);
  const importedPose=await page.evaluate(name=>{
    const state=window.__bonoDemo;
    const model=state.models.get(document.getElementById('character').value);
    return window.BonoRigEditor.pose(model.document,model.spec.armature,name);
  },chosenBone);
  assert.equal(importedPose.x,baseX+14,'roundtrip X');
  const reimportedSlot=await page.evaluate(name=>{
    const state=window.__bonoDemo;
    const model=state.models.get(document.getElementById('character').value);
    return window.BonoSlotEditor.getDisplayIndex(model.document,model.spec.armature,name);
  },firstSlotName);
  assert.equal(reimportedSlot,-1,'roundtrip slot displayIndex');
  assert.ok(Math.abs(importedPose.rotation-(baseRotation+15))<1e-9,'roundtrip rotation');
  await page.locator('#bone-tree button').nth(1).click();
  await page.locator('#bone-restore').click();
  assert.equal(Number(await page.locator('#bone-x').inputValue()),baseX+14,'restore uses reimported baseline');

  // Phase 9 — edit a REAL original DragonBones walk keyframe.
  await page.locator('#animation').selectOption('walk');
  await page.locator('#bone-tree button[data-bone="pelvis"]').click();
  await page.locator('#key-channel').selectOption('translate');
  assert.ok(await page.locator('#key-list button:not([disabled])').count() >= 2,
    'official Mecha walk must contain editable pelvis keyframes');
  await page.locator('#key-list button:not([disabled])').first().click();
  const beforeTimeline=await page.evaluate(() => {
    const model=window.__bonoDemo.models.get(document.getElementById('character').value);
    const clip=model.document.armature.find(a=>a.name==='mecha_1406').animation.find(a=>a.name==='walk');
    const pelvis=clip.bone.find(b=>b.name==='pelvis');
    return {
      x:pelvis.translateFrame[0].x,
      duration:pelvis.translateFrame[0].duration,
      runtimePose:window.__bonoDemo.display.armature.getBone('pelvis').animationPose.x
    };
  });
  await page.locator('#key-x').fill(String(beforeTimeline.x+30));
  await page.locator('#key-apply').click();
  await page.waitForFunction(()=>{
    const text=document.getElementById('key-status')?.textContent||'';
    return text.includes('Keyframe original atualizado') || text.startsWith('Erro:');
  },{timeout:30000});
  assert.match(await page.locator('#key-status').innerText(),/Keyframe original atualizado/);
  const afterTimeline=await page.evaluate(() => {
    const model=window.__bonoDemo.models.get(document.getElementById('character').value);
    const clip=model.document.armature.find(a=>a.name==='mecha_1406').animation.find(a=>a.name==='walk');
    const pelvis=clip.bone.find(b=>b.name==='pelvis');
    return {
      x:pelvis.translateFrame[0].x,
      duration:pelvis.translateFrame[0].duration,
      runtimePose:window.__bonoDemo.display.armature.getBone('pelvis').animationPose.x,
      cacheKey:model.editorCacheKey,
      displayChildren:window.__bonoDemo.display.children.length
    };
  });
  assert.equal(afterTimeline.x,beforeTimeline.x+30,'original keyframe JSON updated');
  assert.equal(afterTimeline.duration,beforeTimeline.duration,'frame duration preserved');
  assert.match(afterTimeline.cacheKey,/^bono-keyframe-/);
  assert.ok(afterTimeline.displayChildren>0,'original Pixi armature rebuilt');
  assert.ok(Math.abs(afterTimeline.runtimePose-beforeTimeline.runtimePose)>1,
    'recompiled DragonBones animation should change the actual bone pose');

  const timelineDownload=page.waitForEvent('download');
  await page.locator('#bone-export').click();
  const timelineSaved=JSON.parse(await readFile(await (await timelineDownload).path(),'utf8'));
  const exportedClip=timelineSaved.armature.find(a=>a.name==='mecha_1406')
    .animation.find(a=>a.name==='walk');
  assert.equal(exportedClip.bone.find(b=>b.name==='pelvis').translateFrame[0].x,beforeTimeline.x+30);
  await page.locator('#skeleton-file').setInputFiles({
    name:'edited_timeline_ske.json',mimeType:'application/json',
    buffer:Buffer.from(JSON.stringify(timelineSaved))
  });
  await page.locator('#import-character').click();
  await page.waitForFunction(() => {
    const text=document.getElementById('import-status')?.textContent||'';
    return text.includes('importada(s)') || text.startsWith('Erro:');
  },{timeout:30000});
  assert.match(await page.locator('#import-status').innerText(),/importada\(s\)/,
    'edited keyframes reimport in official parser');
  await page.locator('#animation').selectOption('walk');
  const reimportedKey=await page.evaluate(() => {
    const model=window.__bonoDemo.models.get(document.getElementById('character').value);
    return model.document.armature.find(a=>a.name==='mecha_1406')
      .animation.find(a=>a.name==='walk').bone.find(b=>b.name==='pelvis').translateFrame[0].x;
  });
  assert.equal(reimportedKey,beforeTimeline.x+30,'roundtrip keyframe value');

  await mkdir('artifacts',{recursive:true});
  await page.screenshot({path:'artifacts/bono-lua-viewer.png',fullPage:true});
  assert.deepEqual(errors,[],'JavaScript errors');
  console.log('Browser test passed: original Mecha rendering in a PixiJS canvas.');
} finally {
  if(browser) await browser.close();
  server.kill();
}
