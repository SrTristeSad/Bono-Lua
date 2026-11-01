// Optional graphical integration test. Install playwright and its Chromium browser first.
// Example: npm install --no-save playwright@1.56.1 && npx playwright install chromium
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
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
  await page.locator('#pause').click();
  assert.match(await page.locator('#status').innerText(),/Pausado/);
  await page.locator('#play').click();
  await page.locator('#speed').evaluate(input => { input.value='1.5'; input.dispatchEvent(new Event('input',{bubbles:true})); });
  assert.equal(await page.locator('#speed-output').innerText(),'1,50×');
  await page.locator('#bones').check();
  await page.waitForTimeout(300);
  await mkdir('artifacts',{recursive:true});
  await page.screenshot({path:'artifacts/bono-lua-viewer.png',fullPage:true});
  assert.deepEqual(errors,[],'JavaScript errors');
  console.log('Browser test passed: original Mecha rendering in a PixiJS canvas.');
} finally {
  if(browser) await browser.close();
  server.kill();
}
