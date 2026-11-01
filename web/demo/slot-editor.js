/* Bono-Lua — edição conservadora de slots em JSON DragonBones 5.x.
 * O runtime original continua responsável pela renderização e animação. */
(function (root) {
  'use strict';
  function arm(document, name) {
    return root.BonoRigEditor.armature(document, name);
  }
  function getSlot(document, armatureName, slotName) {
    const slot = (arm(document, armatureName).slot || []).find(s => s.name === slotName);
    if (!slot) throw new Error('Slot desconhecido: ' + slotName);
    return slot;
  }
  function getDisplayOptions(document, armatureName, slotName) {
    const data = arm(document, armatureName);
    const skin = (data.skin || []).find(s => s.name === 'default') || (data.skin || [])[0];
    const entry = (skin?.slot || []).find(s => s.name === slotName);
    return (entry?.display || []).map((d, index) => ({
      index, name: d?.name || d?.path || '(vazio)', type: d?.type || 'image'
    }));
  }
  function getDisplayIndex(document, armatureName, slotName) {
    const value = getSlot(document, armatureName, slotName).displayIndex;
    return Number.isInteger(value) ? value : 0;
  }
  function setDisplayIndex(document, armatureName, slotName, index) {
    const options = getDisplayOptions(document, armatureName, slotName);
    if (!Number.isInteger(index) || index < -1 || index >= options.length) {
      throw new Error('Índice de desenho inválido: ' + index);
    }
    getSlot(document, armatureName, slotName).displayIndex = index;
    return index;
  }
  function canReorder(document, armatureName) {
    const animations = arm(document, armatureName).animation || [];
    // Alterar a ordem-base muda os índices usados nas timelines Z-order.
    // Impedir reordenação sem remapeamento evita corromper animações existentes.
    return !animations.some(a => a.zOrder ||
      (a.timeline || []).some(t => t.type === 1 || t.type === 'zOrder'));
  }
  function moveSlot(document, armatureName, slotName, direction) {
    if (direction !== -1 && direction !== 1) throw new Error('Direção inválida');
    if (!canReorder(document, armatureName)) {
      throw new Error('Este projeto possui animação de ordem Z: reordenação bloqueada para preservar os keyframes.');
    }
    const slots = arm(document, armatureName).slot || [];
    const index = slots.findIndex(s => s.name === slotName);
    if (index < 0) throw new Error('Slot desconhecido: ' + slotName);
    const next = index + direction;
    if (next < 0 || next >= slots.length) return index;
    [slots[index], slots[next]] = [slots[next], slots[index]];
    return next;
  }
  function applyRuntimeDisplay(runtimeArmature, name, index) {
    const runtimeSlot = runtimeArmature.getSlot(name);
    if (!runtimeSlot) throw new Error('Slot ausente na armadura em execução: ' + name);
    runtimeSlot.displayIndex = index;
    runtimeSlot.invalidUpdate();
    runtimeArmature.advanceTime(0);
  }
  function applyRuntimeOrder(runtimeArmature, originalDocument, editedDocument, armatureName) {
    const originalSlots = (arm(originalDocument, armatureName).slot || []).map(s => s.name);
    const editedSlots = (arm(editedDocument, armatureName).slot || []).map(s => s.name);
    if (originalSlots.length !== editedSlots.length || new Set(originalSlots).size !== originalSlots.length) {
      throw new Error('A lista de slots foi alterada além da ordem de exibição.');
    }
    const indices = editedSlots.map(name => originalSlots.indexOf(name));
    if (indices.some(index => index < 0)) throw new Error('Slot ausente no projeto original.');
    // API interna do runtime PINNED; testes garantem compatibilidade nesta revisão.
    runtimeArmature._sortZOrder(indices, 0);
    runtimeArmature.advanceTime(0);
  }
  root.BonoSlotEditor = Object.freeze({
    getSlot, getDisplayOptions, getDisplayIndex, setDisplayIndex,
    canReorder, moveSlot, applyRuntimeDisplay, applyRuntimeOrder
  });
})(typeof window !== 'undefined' ? window : globalThis);
