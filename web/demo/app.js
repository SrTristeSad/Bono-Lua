/* Bono-Lua viewer: playback with the original upstream DragonBonesJS Pixi 8 runtime.
 * No custom animation engine is substituted here. */
(() => {
  'use strict';

  const $ = id => document.getElementById(id);
  const el = {
    host: $('canvas-host'), status: $('status'), fps: $('fps'),
    animation: $('animation'), play: $('play'), pause: $('pause'),
    reset: $('reset'), speed: $('speed'), speedOutput: $('speed-output'),
    bones: $('bones'), boneCount: $('bone-count'), slotCount: $('slot-count')
  };
  const state = { ready: false, paused: false, speed: 1, display: null, app: null };
  window.__bonoDemo = state;

  function status(message, kind = 'loading') {
    el.status.dataset.state = kind;
    el.status.textContent = message;
  }
  function controls(enabled) {
    for (const id of ['animation', 'play', 'pause', 'reset', 'speed', 'bones']) {
      el[id].disabled = !enabled;
    }
  }
  function selectAnimation(name) {
    const animation = state.display.animation;
    if (!animation.hasAnimation(name)) throw new Error('Animação inexistente: ' + name);
    animation.play(name, 0);
    state.paused = false;
    el.pause.textContent = '⏸ Pausar';
    status('Reproduzindo: ' + name, 'ready');
  }

  async function main() {
    if (!window.PIXI || !window.dragonBones?.PixiFactory) {
      throw new Error('Bibliotecas não encontradas. Rode npm run demo:prepare.');
    }

    const app = new PIXI.Application();
    await app.init({ width: 960, height: 540, background: '#1b2639', antialias: true, preference: 'webgl' });
    state.app = app;
    app.canvas.setAttribute('aria-label', 'Personagem DragonBones original animado');
    el.host.appendChild(app.canvas);

    // Disable the original automatic clock only to allow pause and speed controls.
    // The animation itself is still evaluated by the original DragonBonesJS runtime.
    dragonBones.PixiFactory.useSharedTicker = false;
    const factory = dragonBones.PixiFactory.newInstance(false);
    const [skeleton, atlas, texture] = await Promise.all([
      fetch('./assets/mecha_ske.json').then(response => {
        if (!response.ok) throw new Error('Falha ao carregar esqueleto: ' + response.status);
        return response.json();
      }),
      fetch('./assets/mecha_tex.json').then(response => {
        if (!response.ok) throw new Error('Falha ao carregar atlas: ' + response.status);
        return response.json();
      }),
      PIXI.Assets.load('./assets/mecha_tex.png')
    ]);
    if (!texture?.source) throw new Error('A textura não forneceu um TextureSource PixiJS.');

    const data = factory.parseDragonBonesData(skeleton);
    if (!data) throw new Error('O parser original rejeitou o arquivo do personagem.');
    factory.parseTextureAtlasData(atlas, texture.source);

    const display = factory.buildArmatureDisplay('mecha_1002_101d', 'mecha_1002_101d_show');
    if (!display) throw new Error('O runtime não conseguiu construir a armadura.');
    state.display = display;

    const armature = data.getArmature('mecha_1002_101d');
    el.boneCount.textContent = String(armature.sortedBones.length);
    el.slotCount.textContent = String(armature.sortedSlots.length);

    display.scale.set(0.70);
    display.position.set(0, 40);
    const center = new PIXI.Container();
    center.position.set(480, 270);
    center.addChild(display);
    app.stage.addChild(center);

    // Forward actual elapsed seconds. The original Pixi 8 adapter advances
    // animations through dragonBones.PixiFactory.advanceTime.
    app.ticker.add(ticker => {
      if (state.ready && !state.paused) {
        dragonBones.PixiFactory.advanceTime(Math.min(ticker.deltaMS, 50) * 0.001 * state.speed);
      }
      el.fps.textContent = Math.round(ticker.FPS) + ' FPS';
    });

    const names = Array.from(display.animation.animationNames);
    if (!names.length) throw new Error('Personagem importado sem animações.');
    el.animation.replaceChildren();
    for (const name of names) {
      const option = document.createElement('option');
      option.value = name;
      option.textContent = name;
      el.animation.appendChild(option);
    }
    el.animation.value = names.includes('idle') ? 'idle' : names[0];
    controls(true);
    state.ready = true;
    selectAnimation(el.animation.value);

    el.animation.addEventListener('change', () => selectAnimation(el.animation.value));
    el.pause.addEventListener('click', () => {
      state.paused = true;
      status('Pausado', 'ready');
    });
    el.play.addEventListener('click', () => {
      state.paused = false;
      status('Reproduzindo: ' + el.animation.value, 'ready');
    });
    el.reset.addEventListener('click', () => selectAnimation(el.animation.value));
    el.speed.addEventListener('input', () => {
      state.speed = Number(el.speed.value);
      el.speedOutput.value = state.speed.toFixed(2).replace('.', ',') + '×';
    });
    el.bones.addEventListener('change', () => {
      display.debugDraw = el.bones.checked;
    });
  }
  main().catch(error => {
    console.error('Bono-Lua viewer:', error);
    state.error = error.message;
    status('Erro: ' + error.message, 'error');
    controls(false);
  });
})();
