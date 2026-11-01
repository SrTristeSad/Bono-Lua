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
    host: $('canvas-host'), stageLayer: $('stage-layer'), boneOverlay: $('bone-overlay'),
    pickBones: $('pick-bones'), slotList: $('slot-list'), slotDetails: $('slot-details'),
    slotDisplay: $('slot-display'), slotUp: $('slot-up'), slotDown: $('slot-down'),
    slotRestore: $('slot-restore'), slotStatus: $('slot-status'),
    status: $('status'), fps: $('fps'),
    character: $('character'), characterName: $('character-name'),
    armatureName: $('armature-name'), animation: $('animation'),
    play: $('play'), pause: $('pause'), reset: $('reset'),
    timeline: $('timeline'), timelineOutput: $('timeline-output'),
    speed: $('speed'), speedOutput: $('speed-output'), bones: $('bones'),
    boneCount: $('bone-count'), slotCount: $('slot-count'),
    skeletonFile: $('skeleton-file'), atlasFile: $('atlas-file'),
    textureFile: $('texture-file'), importCharacter: $('import-character'),
    importStatus: $('import-status'), modelOrigin: $('model-origin'),
    boneTree: $('bone-tree'), boneSelected: $('selected-bone'),
    boneX: $('bone-x'), boneY: $('bone-y'), boneRotation: $('bone-rotation'),
    boneRestore: $('bone-restore'), boneExport: $('bone-export'), boneStatus: $('bone-status')
  };
  const state = {
    ready: false, paused: false, speed: 1, display: null, app: null,
    models: new Map(), factory: null, center: null, importSequence: 0,
    selectedBone: null, selectedSlot: null, markers: new Map()
  };
  window.__bonoDemo = state;

  function status(message, kind = 'loading') {
    el.status.dataset.state = kind;
    el.status.textContent = message;
  }
  function controls(enabled) {
    for (const id of ['character', 'animation', 'play', 'pause', 'reset', 'speed', 'bones', 'pickBones']) {
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

  function activeModel() {
    return state.models.get(el.character.value) ?? null;
  }
  function updateBoneForm() {
    const model = activeModel();
    const name = state.selectedBone;
    const enabled = Boolean(model && name);
    for (const field of [el.boneX, el.boneY, el.boneRotation, el.boneRestore]) {
      field.disabled = !enabled;
    }
    el.boneExport.disabled = !model;
    if (!enabled) {
      el.boneSelected.textContent = 'Selecione um osso';
      for (const field of [el.boneX, el.boneY, el.boneRotation]) field.value = '';
      return;
    }
    const p = BonoRigEditor.pose(model.document, model.spec.armature, name);
    el.boneSelected.textContent = 'Osso selecionado: ' + name;
    el.boneX.value = String(p.x);
    el.boneY.value = String(p.y);
    el.boneRotation.value = String(p.rotation);
  }
  function selectBone(name) {
    state.selectedBone = name;
    for (const button of el.boneTree.querySelectorAll('button')) {
      button.setAttribute('aria-selected', String(button.dataset.bone === name));
    }
    updateBoneForm();
    for (const marker of state.markers.values()) {
      marker.setAttribute('aria-pressed', String(marker.dataset.bone === name));
    }
  }
  function renderBoneTree(model) {
    state.selectedBone = null;
    el.boneTree.replaceChildren();
    const nodes = BonoRigEditor.hierarchy(model.document, model.spec.armature);
    for (const bone of nodes) {
      const button = document.createElement('button');
      button.type = 'button';
      button.dataset.bone = bone.name;
      button.setAttribute('role', 'treeitem');
      button.setAttribute('aria-selected', 'false');
      button.style.paddingLeft = (10 + bone.depth * 13) + 'px';
      button.textContent = bone.name;
      button.title = bone.parent ? bone.name + ' (pai: ' + bone.parent + ')' : bone.name + ' (raiz)';
      button.addEventListener('click', () => selectBone(bone.name));
      el.boneTree.appendChild(button);
    }
    updateBoneForm();
    el.boneStatus.textContent = nodes.length + ' ossos disponíveis. Edições alteram a pose-base.';
  }
  function applyBoneEdit(next) {
    const model = activeModel();
    if (!model || !state.selectedBone) return;
    const name = state.selectedBone;
    const original = BonoRigEditor.pose(model.baseDocument, model.spec.armature, name);
    const edited = BonoRigEditor.setPose(model.document, model.spec.armature, name, next);
    const runtimeBone = model.display.armature.getBone(name);
    BonoRigEditor.applyRuntimeOffset(runtimeBone, original, edited, model.armature.scale);
    model.display.armature.invalidUpdate(null, true);
    model.display.armature.advanceTime(0);
    state.paused = true;
    updateMarkerPositions();
    el.boneStatus.textContent = 'Pose-base modificada: ' + name + '. Salve o JSON para reutilizá-la.';
    updateBoneForm();
  }
  function editFromFields() {
    if (!state.selectedBone) return;
    try {
      applyBoneEdit({
        x: Number(el.boneX.value), y: Number(el.boneY.value),
        rotation: Number(el.boneRotation.value)
      });
    } catch (error) {
      el.boneStatus.textContent = 'Erro: ' + error.message;
      updateBoneForm();
    }
  }
  function restoreBone() {
    const model = activeModel();
    if (!model || !state.selectedBone) return;
    const base = BonoRigEditor.pose(model.baseDocument, model.spec.armature, state.selectedBone);
    applyBoneEdit(base);
    el.boneStatus.textContent = 'Pose-base restaurada: ' + state.selectedBone;
  }
  function exportSkeleton() {
    const model = activeModel();
    if (!model) return;
    const blob = new Blob([BonoRigEditor.serialize(model.document)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    const safeName = (model.spec.armature || 'personagem').replace(/[^a-z0-9_-]+/gi, '_');
    link.href = url;
    link.download = safeName + '_ske.json';
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1500);
    el.boneStatus.textContent = 'Esqueleto JSON preparado para salvar. Guarde também atlas e PNG originais.';
  }


  // Markers use the original DragonBones bone matrices and Pixi world transforms.
  // Their positions are updated every frame, including during playback.
  function renderMarkers(model) {
    const namespace = 'http://www.w3.org/2000/svg';
    el.boneOverlay.replaceChildren();
    state.markers.clear();
    for (const bone of BonoRigEditor.hierarchy(model.document, model.spec.armature)) {
      const marker = document.createElementNS(namespace, 'circle');
      marker.setAttribute('class', 'bone-marker');
      marker.setAttribute('data-bone', bone.name);
      marker.setAttribute('aria-label', 'Selecionar osso ' + bone.name);
      marker.setAttribute('aria-pressed', 'false');
      marker.setAttribute('tabindex', '0');
      marker.setAttribute('role', 'button');
      marker.setAttribute('r', '7');
      marker.setAttribute('cx', '-100');
      marker.setAttribute('cy', '-100');
      const label = document.createElementNS(namespace, 'title');
      label.textContent = bone.name;
      marker.appendChild(label);
      const choose = () => {
        selectBone(bone.name);
        state.paused = true; // Keep joints still while inspecting the rest pose.
        el.boneStatus.textContent = 'Osso selecionado na prévia: ' + bone.name;
      };
      marker.addEventListener('click', choose);
      marker.addEventListener('keydown', event => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          choose();
        }
      });
      el.boneOverlay.appendChild(marker);
      state.markers.set(bone.name, marker);
    }
    updateMarkerVisibility();
    updateMarkerPositions();
  }
  function updateMarkerVisibility() {
    const show = Boolean(el.pickBones.checked);
    el.boneOverlay.style.display = show ? 'block' : 'none';
    if (show) updateMarkerPositions();
  }
  function updateMarkerPositions() {
    if (!state.display || !el.pickBones.checked || state.markers.size === 0) return;
    const model = activeModel();
    if (!model) return;
    for (const point of BonoVisualInspector.bonePositions(model)) {
      const marker = state.markers.get(point.name);
      if (!marker) continue;
      marker.setAttribute('cx', point.x.toFixed(3));
      marker.setAttribute('cy', point.y.toFixed(3));
      marker.style.display = point.x < 0 || point.x > 960 || point.y < 0 || point.y > 540 ? 'none' : '';
    }
  }
  function updateSlotForm() {
    const model = activeModel();
    const name = state.selectedSlot;
    const enabled = Boolean(model && name);
    el.slotDisplay.replaceChildren();
    if (!enabled) {
      const option = document.createElement('option');
      option.textContent = 'Selecione um slot';
      el.slotDisplay.appendChild(option);
      el.slotDisplay.disabled = true;
      el.slotUp.disabled = el.slotDown.disabled = el.slotRestore.disabled = true;
      return;
    }
    const choices = BonoSlotEditor.getDisplayOptions(model.document, model.spec.armature, name);
    for (const item of [{index:-1,name:'(Ocultar slot)'},...choices]) {
      const option = document.createElement('option');
      option.value = String(item.index);
      option.textContent = item.index < 0 ? item.name : item.index + ': ' + item.name;
      el.slotDisplay.appendChild(option);
    }
    const index = BonoSlotEditor.getDisplayIndex(model.document, model.spec.armature, name);
    el.slotDisplay.value = String(index);
    el.slotDisplay.disabled = false;
    el.slotRestore.disabled = false;
    const slots = BonoRigEditor.armature(model.document, model.spec.armature).slot || [];
    const position = slots.findIndex(slot => slot.name === name);
    const safe = BonoSlotEditor.canReorder(model.document, model.spec.armature);
    el.slotUp.disabled = !safe || position >= slots.length - 1;
    el.slotDown.disabled = !safe || position <= 0;
    const selected = BonoVisualInspector.slotList(model.document,model.spec.armature)
      .find(slot => slot.name === name);
    const displays = selected.displays.map(d => d.skin + ': ' + d.name + ' (' + d.type + ')');
    el.slotDetails.textContent = 'Slot: ' + name
      + '\nOsso: ' + (selected.parent || '(nenhum)')
      + '\nÍndice de exibição: ' + selected.displayIndex
      + '\nOrdem inicial: ' + selected.zOrder
      + '\nDesenhos: ' + (displays.length ? displays.join(', ') : '(nenhum)');
    el.slotUp.title = el.slotDown.title = safe ? 'Alterar a ordem-base' : 'Bloqueado: animação Z-order presente';
  }
  function selectSlot(name) {
    state.selectedSlot = name;
    for (const button of el.slotList.querySelectorAll('button')) {
      button.setAttribute('aria-pressed',String(button.dataset.slot === name));
    }
    updateSlotForm();
    const model = activeModel();
    const raw = BonoSlotEditor.getSlot(model.document,model.spec.armature,name);
    if (raw.parent && model.display.armature.getBone(raw.parent)) selectBone(raw.parent);
  }
  function renderSlots(model) {
    const slots = BonoVisualInspector.slotList(model.document, model.spec.armature);
    state.selectedSlot = null;
    el.slotList.replaceChildren();
    el.slotDetails.textContent = slots.length + ' slots disponíveis. Selecione um para editar.';
    el.slotStatus.textContent = 'As alterações modificam a pose-base, não os keyframes de animação.';
    for (const slot of slots) {
      const button = document.createElement('button');
      button.type = 'button';
      button.dataset.slot = slot.name;
      button.textContent = slot.name;
      button.setAttribute('aria-pressed', 'false');
      button.addEventListener('click', () => selectSlot(slot.name));
      el.slotList.appendChild(button);
    }
    updateSlotForm();
  }
  function changeSlotDisplay(value) {
    const model = activeModel();
    if (!model || !state.selectedSlot) return;
    const name = state.selectedSlot;
    try {
      const index = Number(value);
      // Validate before mutation and preserve all other skeleton fields.
      BonoSlotEditor.setDisplayIndex(model.document, model.spec.armature, name, index);
      state.paused = true;
      BonoSlotEditor.applyRuntimeDisplay(model.display.armature, name, index);
      el.slotStatus.textContent = 'Desenho alterado: ' + name + ', índice ' + index + '. Salve o esqueleto JSON.';
      updateSlotForm();
    } catch (error) {
      el.slotStatus.textContent = 'Erro: ' + error.message;
      updateSlotForm();
    }
  }
  function moveSelectedSlot(direction) {
    const model = activeModel();
    if (!model || !state.selectedSlot) return;
    const name = state.selectedSlot;
    try {
      BonoSlotEditor.moveSlot(model.document, model.spec.armature, name, direction);
      state.paused = true;
      BonoSlotEditor.applyRuntimeOrder(model.display.armature,model.baseDocument,model.document,model.spec.armature);
      renderSlots(model);
      selectSlot(name);
      el.slotStatus.textContent = 'Ordem de camadas atualizada: ' + name + '. Salve o esqueleto JSON.';
    } catch (error) {
      el.slotStatus.textContent = 'Erro: ' + error.message;
      updateSlotForm();
    }
  }
  function restoreSelectedSlot() {
    const model = activeModel();
    if (!model || !state.selectedSlot) return;
    const originalIndex = BonoSlotEditor.getDisplayIndex(model.baseDocument,model.spec.armature,state.selectedSlot);
    changeSlotDisplay(String(originalIndex));
    el.slotStatus.textContent = 'Desenho original restaurado: ' + state.selectedSlot;
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
    renderBoneTree(model);
    renderSlots(model);
    renderMarkers(model);
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
        imported.push({ spec, armature, display,
          document: BonoRigEditor.clone(skeleton), baseDocument: BonoRigEditor.clone(skeleton) });
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
    if (!window.PIXI || !window.dragonBones?.PixiFactory || !window.BonoRigEditor || !window.BonoVisualInspector || !window.BonoSlotEditor) {
      throw new Error('Bibliotecas não encontradas. Rode npm run demo:prepare.');
    }
    const app = new PIXI.Application();
    await app.init({
      width: 960, height: 540,
      background: '#1b2639', antialias: true, preference: 'webgl'
    });
    state.app = app;
    app.canvas.setAttribute('aria-label', 'Personagem original DragonBones animado');
    el.stageLayer.prepend(app.canvas);

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
      state.models.set(spec.id, { spec, armature, display,
        document: BonoRigEditor.clone(skeleton), baseDocument: BonoRigEditor.clone(skeleton) });
    }

    app.ticker.add(ticker => {
      if (state.ready && !state.paused) {
        dragonBones.PixiFactory.advanceTime(Math.min(ticker.deltaMS, 50) * 0.001 * state.speed);
      }
      el.fps.textContent = Math.round(ticker.FPS) + ' FPS';
      updateMarkerPositions();
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
    for (const field of [el.boneX, el.boneY, el.boneRotation]) field.addEventListener('change', editFromFields);
    el.boneRestore.addEventListener('click', restoreBone);
    el.boneExport.addEventListener('click', exportSkeleton);
    el.slotDisplay.addEventListener('change', () => changeSlotDisplay(el.slotDisplay.value));
    el.slotUp.addEventListener('click', () => moveSelectedSlot(1));
    el.slotDown.addEventListener('click', () => moveSelectedSlot(-1));
    el.slotRestore.addEventListener('click', restoreSelectedSlot);
    el.pickBones.addEventListener('change', updateMarkerVisibility);
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
