/* Bono-Lua — viewport bone geometry and read-only DragonBones slot inspector.
 * No changes to upstream rendering or skeleton format. */
(function (root) {
  'use strict';

  function slotList(document, armatureName) {
    const armature = root.BonoRigEditor.armature(document, armatureName);
    const slots = Array.isArray(armature.slot) ? armature.slot : [];
    const skins = Array.isArray(armature.skin) ? armature.skin : [];
    return slots.map((slot, index) => {
      const displays = [];
      for (const skin of skins) {
        const entry = (skin.slot || []).find(item => item.name === slot.name);
        if (entry) {
          for (const display of entry.display || []) {
            if (display) displays.push({ skin: skin.name || 'default', name: display.name || display.path || '(sem nome)', type: display.type || 'image' });
          }
        }
      }
      return {
        name: slot.name, parent: slot.parent || null, zOrder: index,
        displayIndex: Number.isInteger(slot.displayIndex) ? slot.displayIndex : 0,
        displays
      };
    });
  }

  function screenPoint(display, runtimeBone) {
    if (!display || !runtimeBone) return null;
    const matrix = runtimeBone.globalTransformMatrix;
    if (!matrix || !Number.isFinite(matrix.tx) || !Number.isFinite(matrix.ty)) return null;
    const p = display.toGlobal({ x: matrix.tx, y: matrix.ty });
    if (!p || !Number.isFinite(p.x) || !Number.isFinite(p.y)) return null;
    return { x: p.x, y: p.y };
  }

  function bonePositions(model) {
    if (!model) return [];
    const armatureName = model.spec.armature;
    return root.BonoRigEditor.hierarchy(model.document, armatureName).map(bone => {
      const runtimeBone = model.display.armature.getBone(bone.name);
      const point = screenPoint(model.display, runtimeBone);
      return point ? { name: bone.name, ...point } : null;
    }).filter(Boolean);
  }

  root.BonoVisualInspector = Object.freeze({ slotList, screenPoint, bonePositions });
})(typeof window !== 'undefined' ? window : globalThis);
