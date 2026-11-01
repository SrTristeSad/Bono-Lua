/* Bono-Lua viewer: playback with the ORIGINAL DragonBonesJS Pixi 8 runtime.
 * The rig, animation blending, and mesh evaluation are provided by upstream. */
(() => {
  'use strict';

  const examples = [
    {
      id: 'mecha1002', label: 'Mecha 1002 (idle)',
      armature: 'mecha_1002_101d', data: 'mecha_1002_101d_show',
      skeleton: './assets/mecha_ske.json', atlas: './assets/mecha_tex.json',
      texture: './assets/mecha_tex.png'
    },
    {
      id: 'mecha1406', label: 'Mecha 1406 (8 animações)',
      armature: 'mecha_1406', data: 'mecha_1406',
      skeleton: './assets/mecha1406_ske.json', atlas: './assets/mecha1406_tex.json',
      texture: './assets/mecha1406_tex.png'
    }
  ];
  const $ = id => document.getElementById(id);
  const el = {
    host: $('canvas-host'), status: $('status'), fps: $('fps'),
    character: $('character'), characterName: $('character-name'),
    armatureName: $('armature-name'), animation: $('animation'),
    play: $('play'), pause: $('pause'), reset: $('reset'),
    speed: $('speed'), speedOutput: $('speed-output'), bones: $('bones'),
    boneCount: $('bone-count'), slotCount: $('slot-count')
  };
  const state = {
    ready: false, paused: false, speed: 1, display: null, app: null,
    models: new Map()
  };
  window.__bonoDemo = state;

  function status(message, kind = 'loading') {
    el.status.dataset.state = kind;
    el.status.textContent = message;
  }
  function controls(enabled) {
    for (const id of ['character', 'animation', 'play', 'pause', 'reset', 'speed', 'bones']) {
      el[id].disabled = !enabled;
    }
  }
  function selectAnimation(name) {
    const animation = state.display.animation;
    if (!animation.hasAnimation(name)) throw new Error('Animação inexistente: ' + name);
    animation.play(name, 0);
    state.paused = false;
    status('Reproduzindo: ' + name, 'ready');
  }
  function selectCharacter(id) {
    const model = state.models.get(id);
    if (!model) throw new Error('Personagem inexistente: ' + id);
    for (const value of state.models.values()) value.display.visible = (value === model);
    state.display = model.display;

    el.characterName.textContent = 'Exemplo oficial: ' + model.spec.label;
    el.armatureName.textContent = model.spec.armature;
    el.boneCount.textContent = String(model.armature.sortedBones.length);
    el.slotCount.textContent = String(model.armature.sortedSlots.length);
    const names = Array.from(model.display.animation.animationNames);
    if (!names.length) throw new Error('Personagem importado sem animações.');
    el.animation.replaceChildren();
    for (const name of names) {
      const option = document.createElement('option');
      option.value = name;
      option.textContent = name;
      el.animation.appendChild(option);
    }
    el.animation.value = names.includes('idle') ? 'idle' : names[0];
    model.display.debugDraw = el.bones.checked;
    selectAnimation(el.animation.value);
  }
  async function loadJson(path) {
    const response = await fetch(path);
    if (!response.ok) throw new Error('Falha ao carregar ' + path + ': ' + response.status);
    return response.json();
  }
  async function main() {
    if (!window.PIXI || !window.dragonBones?.PixiFactory) {
      throw new Error('Bibliotecas não encontradas. Rode npm run demo:prepare.');
    }
    const app = new PIXI.Application();
    await app.init({
      width: 960, height: 540,
      background: '#1b2639', antialias: true, preference: 'webgl'
    });
    state.app = app;
    app.canvas.setAttribute('aria-label', 'Personagem original DragonBones animado');
    el.host.appendChild(app.canvas);

    // Drive the original runtime with elapsed seconds for pause/speed control.
    dragonBones.PixiFactory.useSharedTicker = false;
    const factory = dragonBones.PixiFactory.newInstance(false);
    const center = new PIXI.Container();
    center.position.set(480, 270);
    app.stage.addChild(center);

    for (const spec of examples) {
      const [skeleton, atlas, texture] = await Promise.all([
        loadJson(spec.skeleton), loadJson(spec.atlas), PIXI.Assets.load(spec.texture)
      ]);
      if (!texture?.source) throw new Error('Textura PixiJS inválida: ' + spec.texture);
      const data = factory.parseDragonBonesData(skeleton);
      if (!data) throw new Error('Parser original rejeitou: ' + spec.skeleton);
      factory.parseTextureAtlasData(atlas, texture.source);
      const display = factory.buildArmatureDisplay(spec.armature, spec.data);
      if (!display) throw new Error('Falha na armadura: ' + spec.armature);
      display.visible = false;
      display.scale.set(0.70);
      display.position.set(0, 40);
      center.addChild(display);
      const armature = data.getArmature(spec.armature);
      state.models.set(spec.id, { spec, armature, display });
    }

    app.ticker.add(ticker => {
      if (state.ready && !state.paused) {
        dragonBones.PixiFactory.advanceTime(Math.min(ticker.deltaMS, 50) * 0.001 * state.speed);
      }
      el.fps.textContent = Math.round(ticker.FPS) + ' FPS';
    });

    el.character.replaceChildren();
    for (const spec of examples) {
      const option = document.createElement('option');
      option.value = spec.id;
      option.textContent = spec.label;
      el.character.appendChild(option);
    }
    controls(true);
    state.ready = true;
    selectCharacter(el.character.value);
    el.character.addEventListener('change', () => selectCharacter(el.character.value));
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
      state.display.debugDraw = el.bones.checked;
    });
  }
  main().catch(error => {
    console.error('Bono-Lua viewer:', error);
    state.error = error.message;
    status('Erro: ' + error.message, 'error');
    controls(false);
  });
})();
