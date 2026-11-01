/* Bono-Lua — editing EXISTING DragonBones 5.x bone timeline keyframes.
 * Preserve duration, tween easing, other bones, other animation channels and skins.
 * No conversion to an invented animation format. */
(function (root) {
  'use strict';
  const CHANNELS = Object.freeze({
    translate: { field: 'translateFrame', properties: ['x', 'y'] },
    rotate: { field: 'rotateFrame', properties: ['rotate'] }
  });
  function animation(document, armatureName, animationName) {
    const arm = root.BonoRigEditor.armature(document, armatureName);
    const clip = (arm.animation || []).find(a => a.name === animationName);
    if (!clip) throw new Error('Animação não encontrada: ' + animationName);
    return clip;
  }
  function track(document, armatureName, animationName, boneName, channel) {
    const config = CHANNELS[channel];
    if (!config) throw new Error('Canal de animação não suportado: ' + channel);
    const clip = animation(document, armatureName, animationName);
    const bone = (clip.bone || []).find(b => b.name === boneName);
    if (!bone) return null;
    const frames = bone[config.field];
    return Array.isArray(frames) ? frames : null;
  }
  function frames(document, armatureName, animationName, boneName, channel) {
    const raw = track(document, armatureName, animationName, boneName, channel);
    if (!raw) return [];
    let start = 0;
    return raw.map((frame, index) => {
      const duration = frame.duration === undefined ? 1 : frame.duration;
      const result = {index, start, duration, ...Object.fromEntries(
        CHANNELS[channel].properties.map(prop => [prop, frame[prop] ?? 0])
      )};
      start += duration;
      return result;
    });
  }
  function editExistingFrame(document, armatureName, animationName, boneName, channel, index, values) {
    const config = CHANNELS[channel];
    if (!config) throw new Error('Canal não suportado');
    const raw = track(document, armatureName, animationName, boneName, channel);
    if (!raw || !Number.isInteger(index) || index < 0 || index >= raw.length)
      throw new Error('Keyframe inexistente');
    const clip = animation(document, armatureName, animationName);
    const details = frames(document,armatureName,animationName,boneName,channel)[index];
    if (details.start >= clip.duration) throw new Error('Keyframe de encerramento fora da duração do clipe');
    for (const prop of config.properties) {
      const value = values[prop];
      if (typeof value !== 'number' || !Number.isFinite(value) || Math.abs(value) > 100000)
        throw new Error('Valor inválido de keyframe: ' + prop);
    }
    for (const prop of config.properties) raw[index][prop] = values[prop];
    return frames(document, armatureName, animationName, boneName, channel)[index];
  }
  root.BonoTimelineEditor = Object.freeze({
    CHANNELS, animation, frames, editExistingFrame
  });
})(typeof window !== 'undefined' ? window : globalThis);
