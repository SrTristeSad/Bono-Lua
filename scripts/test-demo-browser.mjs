// Optional graphical integration test. Install playwright and its Chromium browser first.
// Example: npm install --no-save playwright@1.56.1 && npx playwright install chromium
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
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


  await mkdir('artifacts',{recursive:true});
  await page.screenshot({path:'artifacts/bono-lua-viewer.png',fullPage:true});
  assert.deepEqual(errors,[],'JavaScript errors');
  console.log('Browser test passed: original Mecha rendering in a PixiJS canvas.');
} finally {
  if(browser) await browser.close();
  server.kill();
}
