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
    timeline: $('timeline'), timelineOutput: $('timeline-output'),
    speed: $('speed'), speedOutput: $('speed-output'), bones: $('bones'),
    boneCount: $('bone-count'), slotCount: $('slot-count'),
    skeletonFile: $('skeleton-file'), atlasFile: $('atlas-file'),
    textureFile: $('texture-file'), importCharacter: $('import-character'),
    importStatus: $('import-status'), modelOrigin: $('model-origin')
  };
  const state = {
    ready: false, paused: false, speed: 1, display: null, app: null,
    models: new Map(), factory: null, center: null, importSequence: 0
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
    const clip = animation.lastAnimationState;
    const duration = Number(clip?.totalTime || 0);
    el.timeline.max = String(Math.max(0.001, duration));
    el.timeline.value = '0';
    el.timeline.disabled = duration <= 0;
    el.timelineOutput.value = '0,00 / ' + duration.toFixed(2).replace('.', ',') + ' s';
    status('Reproduzindo: ' + name, 'ready');
  }
  function selectCharacter(id) {
    const model = state.models.get(id);
    if (!model) throw new Error('Personagem inexistente: ' + id);
    for (const value of state.models.values()) value.display.visible = (value === model);
    state.display = model.display;

    el.characterName.textContent = (model.spec.local ? 'Importado: ' : 'Exemplo oficial: ') + model.spec.label;
    el.modelOrigin.textContent = model.spec.local ? 'Arquivo local' : 'DragonBonesJS oficial';
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

  function validateJsonFiles(skeletonFile, atlasFile, textureFile) {
    if (!skeletonFile || !atlasFile || !textureFile) {
      throw new Error('Selecione esqueleto JSON, atlas JSON e textura PNG.');
    }
    for (const file of [skeletonFile, atlasFile]) {
      if (!/\.json$/i.test(file.name)) throw new Error('Esqueleto e atlas precisam de extensão .json.');
      if (file.size === 0 || file.size > 8 * 1024 * 1024) {
        throw new Error('Arquivo JSON vazio ou maior que 8 MB: ' + file.name);
      }
    }
    if (!/\.png$/i.test(textureFile.name) || textureFile.size === 0 || textureFile.size > 20 * 1024 * 1024) {
      throw new Error('A imagem precisa ser um PNG de até 20 MB.');
    }
  }
  function validateStructure(skeleton, atlas) {
    if (!skeleton || typeof skeleton !== 'object'
        || !Array.isArray(skeleton.armature) || !skeleton.armature.length) {
      throw new Error('O esqueleto não possui o campo armature válido.');
    }
    if (typeof skeleton.version !== 'string') {
      throw new Error('Esqueleto DragonBones sem versão declarada.');
    }
    if (!atlas || typeof atlas !== 'object'
        || !Array.isArray(atlas.SubTexture)) {
      throw new Error('Atlas incompatível: faltou SubTexture.');
    }
    const armatureNames = skeleton.armature.map(armature => armature?.name);
    if (armatureNames.some(name => typeof name !== 'string' || !name)) {
      throw new Error('Uma armadura não possui nome.');
    }
    return armatureNames;
  }
  async function importCharacter() {
    const btn = el.importCharacter;
    if (btn.disabled || !state.factory || !state.center) return;
    btn.disabled = true;
    el.importStatus.textContent = 'Lendo os arquivos locais...';
    let url = null;
    try {
      const skeletonFile = el.skeletonFile.files[0];
      const atlasFile = el.atlasFile.files[0];
      const textureFile = el.textureFile.files[0];
      validateJsonFiles(skeletonFile, atlasFile, textureFile);
      const [skeleton, atlas] = await Promise.all([
        skeletonFile.text().then(JSON.parse),
        atlasFile.text().then(JSON.parse)
      ]);
      validateStructure(skeleton, atlas);
      url = URL.createObjectURL(textureFile);
      // PixiJS 8 Texture.from accepts an already-decoded HTMLImageElement.
      // Do not rely on Assets loader URL-extension detection for blob: URLs.
      const image = new Image();
      image.src = url;
      await image.decode();
      const texture = PIXI.Texture.from(image);
      if (!texture?.source) throw new Error('O PNG não foi carregado pelo PixiJS.');
      const importIndex = ++state.importSequence;
      const cacheKey = 'bono-local-' + importIndex;
      const data = state.factory.parseDragonBonesData(skeleton, cacheKey);
      if (!data) throw new Error('O parser DragonBones rejeitou o esqueleto. Confira a versão.');
      state.factory.parseTextureAtlasData(atlas, texture.source, cacheKey);

      const imported = [];
      for (const armatureName of data.armatureNames) {
        const display = state.factory.buildArmatureDisplay(armatureName, cacheKey);
        if (!display) throw new Error('Não foi possível montar a armadura ' + armatureName);
        const armature = data.getArmature(armatureName);
        if (!armature) throw new Error('Armadura não encontrada: ' + armatureName);
        const id = cacheKey + '-' + imported.length;
        const spec = {
          id, label: skeletonFile.name + ' / ' + armatureName,
          armature: armatureName, data: cacheKey, local: true
        };
        display.visible = false;
        display.scale.set(0.70);
        display.position.set(0, 40);
        imported.push({ spec, armature, display });
      }
      if (!imported.length) throw new Error('Nenhuma armadura montada.');
      for (const model of imported) {
        state.center.addChild(model.display);
        state.models.set(model.spec.id, model);
        const option = document.createElement('option');
        option.value = model.spec.id;
        option.textContent = model.spec.label;
        el.character.appendChild(option);
      }
      el.character.value = imported[0].spec.id;
      selectCharacter(imported[0].spec.id);
      el.importStatus.textContent = imported.length + ' armadura(s) importada(s). Nenhum arquivo foi enviado a servidor.';
    } catch (error) {
      console.error('Falha na importação DragonBones:', error);
      el.importStatus.textContent = 'Erro: ' + error.message;
    } finally {
      // The texture has already been decoded; no object URL remains available outside this session.
      if (url) URL.revokeObjectURL(url);
      btn.disabled = false;
    }
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
    state.factory = factory;
    const center = new PIXI.Container();
    center.position.set(480, 270);
    app.stage.addChild(center);
    state.center = center;

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
      const clip = state.display?.animation?.lastAnimationState;
      if (clip && clip.totalTime > 0) {
        const now = Math.min(clip.totalTime, Math.max(0, clip.currentTime));
        el.timeline.value = String(now);
        el.timelineOutput.value = now.toFixed(2).replace('.', ',') + ' / '
          + clip.totalTime.toFixed(2).replace('.', ',') + ' s';
      }
    });

    el.character.replaceChildren();
    for (const spec of examples) {
      const option = document.createElement('option');
      option.value = spec.id;
      option.textContent = spec.label;
      el.character.appendChild(option);
    }
    controls(true);
    el.importCharacter.disabled = false;
    state.ready = true;
    selectCharacter(el.character.value);
    el.character.addEventListener('change', () => selectCharacter(el.character.value));
    el.importCharacter.addEventListener('click', importCharacter);
    el.timeline.addEventListener('input', () => {
      const clip = state.display?.animation?.lastAnimationState;
      if (!clip || clip.totalTime <= 0) return;
      state.paused = true;
      clip.currentTime = Math.max(0, Math.min(clip.totalTime - 0.00001, Number(el.timeline.value)));
      state.display.armature.advanceTime(0);
      status('Posição: ' + clip.currentTime.toFixed(2) + ' s', 'ready');
    });
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
