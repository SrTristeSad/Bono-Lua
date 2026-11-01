/* Bono-Lua: non-destructive editing of ORIGINAL DragonBones JSON bone rest transforms.
 * Pure functions; usable in browser and Node tests. No animation engine replacement. */
(function (root) {
  'use strict';
  const copy = value => JSON.parse(JSON.stringify(value));
  const number = (value, fallback = 0) => typeof value === 'number' && Number.isFinite(value) ? value : fallback;
  function armature(document, armatureName) {
    const result = document?.armature?.find(a => a?.name === armatureName);
    if (!result) throw new Error('Armadura não encontrada: ' + armatureName);
    return result;
  }
  function rawBone(document, armatureName, boneName) {
    const bone = armature(document, armatureName).bone?.find(b => b.name === boneName);
    if (!bone) throw new Error('Osso não encontrado: ' + boneName);
    return bone;
  }
  function pose(document, armatureName, boneName) {
    const t = rawBone(document, armatureName, boneName).transform ?? {};
    return {
      x: number(t.x), y: number(t.y),
      rotation: number('rotate' in t ? t.rotate : t.skY)
    };
  }
  function setPose(document, armatureName, boneName, next) {
    if (!['x', 'y', 'rotation'].every(k => typeof next[k] === 'number' && Number.isFinite(next[k]))) {
      throw new Error('Coordenadas e rotação precisam ser números finitos.');
    }
    if (Math.abs(next.x) > 100000 || Math.abs(next.y) > 100000 || Math.abs(next.rotation) > 36000) {
      throw new Error('Transformação excedeu o limite do editor.');
    }
    const bone = rawBone(document, armatureName, boneName);
    const original = bone.transform ?? {};
    const previous = pose(document, armatureName, boneName);
    const t = bone.transform ?? (bone.transform = {});
    t.x = next.x;
    t.y = next.y;
    if ('rotate' in original || (!('skX' in original) && !('skY' in original))) {
      t.rotate = next.rotation;
    } else {
      const delta = next.rotation - previous.rotation;
      t.skY = next.rotation;
      if ('skX' in original) t.skX = number(original.skX) + delta;
    }
    return pose(document, armatureName, boneName);
  }
  function hierarchy(document, armatureName) {
    const bones = armature(document, armatureName).bone ?? [];
    const byName = new Map(bones.map(b => [b.name, b]));
    const result = [];
    const visited = new Set();
    function walk(bone, depth) {
      if (visited.has(bone.name)) return;
      visited.add(bone.name);
      result.push({ name: bone.name, parent: bone.parent || null, depth });
      for (const child of bones) if (child.parent === bone.name) walk(child, depth + 1);
    }
    for (const bone of bones) if (!bone.parent || !byName.has(bone.parent)) walk(bone, 0);
    for (const bone of bones) walk(bone, 0); // tolerate orphaned or cyclic data
    return result;
  }
  function offset(original, edited) {
    return {
      x: edited.x - original.x,
      y: edited.y - original.y,
      rotation: (edited.rotation - original.rotation) * Math.PI / 180
    };
  }
  function applyRuntimeOffset(runtimeBone, base, edited, scale = 1) {
    if (!runtimeBone) throw new Error('Osso não disponível no runtime.');
    const delta = offset(base, edited);
    runtimeBone.offset.x = delta.x * scale;
    runtimeBone.offset.y = delta.y * scale;
    runtimeBone.offset.rotation = delta.rotation;
    // The angle control changes rotation, not skew.
    runtimeBone.offset.skew = 0;
    runtimeBone.invalidUpdate();
  }
  root.BonoRigEditor = Object.freeze({
    clone: copy, armature, rawBone, pose, setPose, hierarchy, offset, applyRuntimeOffset,
    serialize: document => JSON.stringify(document, null, 2) + '\n'
  });
})(typeof window !== 'undefined' ? window : globalThis);
