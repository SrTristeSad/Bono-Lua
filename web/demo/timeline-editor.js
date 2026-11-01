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

  // DragonBones reads duration from each frame except the last, which ends
  // at animation.duration. Some official exports add a zero-duration marker
  // exactly at the clip boundary. Never treat that marker as an editable frame.
  function validatedTimeline(document, armatureName, animationName, boneName, channel) {
    const clip = animation(document, armatureName, animationName);
    const raw = track(document, armatureName, animationName, boneName, channel);
    if (!raw || !raw.length) throw new Error('Crie primeiro uma animação com esse canal.');
    if (!Number.isInteger(clip.duration) || clip.duration < 2) {
      throw new Error('A animação precisa ter pelo menos 2 quadros.');
    }
    const entries = frames(document,armatureName,animationName,boneName,channel);
    if (entries.some(key => !Number.isInteger(key.duration) || key.duration < 0) ||
        entries.some((key,i)=> i < entries.length-1 && key.duration < 1) ||
        entries.some(key => key.start > clip.duration)) {
      throw new Error('Timeline possui durações inválidas para edição.');
    }
    const editable = entries.filter(key => key.start < clip.duration);
    if (!editable.length || editable[0].start !== 0) {
      throw new Error('Timeline sem quadro inicial válido.');
    }
    if (editable.length < entries.length &&
        (entries.length-editable.length !== 1 || entries.at(-1).start !== clip.duration ||
         entries.at(-1).duration !== 0)) {
      throw new Error('Marcador terminal incompatível.');
    }
    return { clip, raw, entries, editable };
  }
  function insertFrame(document, armatureName, animationName, boneName, channel, atFrame, values = null) {
    const {clip,raw,entries,editable}=validatedTimeline(document,armatureName,animationName,boneName,channel);
    if (!Number.isInteger(atFrame) || atFrame <= 0 || atFrame >= clip.duration) {
      throw new Error('Novo keyframe precisa ficar dentro do clipe.');
    }
    if (editable.some(key=>key.start===atFrame)) throw new Error('Já existe keyframe neste quadro.');
    const previous=editable.filter(key=>key.start<atFrame).at(-1);
    const next=entries[previous.index+1];
    const end=next ? next.start : clip.duration;
    if (atFrame >= end || previous.start >= atFrame) throw new Error('Intervalo não pode ser dividido.');
    const config=CHANNELS[channel];
    const source=raw[previous.index];
    const inserted={duration:end-atFrame};
    if ('tweenEasing' in source) inserted.tweenEasing=source.tweenEasing;
    if (Array.isArray(source.curve)) inserted.curve=source.curve.slice();
    const nextValues={};
    for(const prop of config.properties) nextValues[prop]=
      values===null ? (source[prop]??0) : values[prop];
    for(const prop of config.properties) {
      if(typeof nextValues[prop]!=='number'||!Number.isFinite(nextValues[prop])||Math.abs(nextValues[prop])>100000)
        throw new Error('Valor inválido para novo keyframe: '+prop);
      inserted[prop]=nextValues[prop];
    }
    const newDuration=atFrame-previous.start;
    // Validate the source position before changing the source.
    if(newDuration<1||inserted.duration<1) throw new Error('Keyframe precisa durar pelo menos um quadro.');
    source.duration=newDuration;
    raw.splice(previous.index+1,0,inserted);
    return frames(document,armatureName,animationName,boneName,channel)[previous.index+1];
  }
  function removeFrame(document, armatureName, animationName, boneName, channel, index) {
    const {raw,editable}=validatedTimeline(document,armatureName,animationName,boneName,channel);
    const current=editable.find(key=>key.index===index);
    if(!current || index===0) throw new Error('O primeiro quadro e o marcador final não podem ser removidos.');
    const previous=editable.find(key=>key.index===index-1);
    if(!previous) throw new Error('Keyframe anterior não encontrado.');
    const next=editable.find(key=>key.index===index+1);
    const end=next ? next.start : animation(document,armatureName,animationName).duration;
    const span=end-previous.start;
    if(span<1) throw new Error('Intervalo inválido para remoção.');
    raw[index-1].duration=span;
    raw.splice(index,1);
    return frames(document,armatureName,animationName,boneName,channel)[index-1];
  }
  function setFrameDuration(document, armatureName, animationName, boneName, channel, index, duration) {
    const {raw,editable}=validatedTimeline(document,armatureName,animationName,boneName,channel);
    const selected=editable.find(key=>key.index===index);
    const next=editable.find(key=>key.index===index+1);
    if(!selected || !next) {
      throw new Error('Ajuste a duração somente entre dois keyframes ativos.');
    }
    if(!Number.isInteger(duration) || duration<1) throw new Error('Duração precisa ser inteira e positiva.');
    const nextAfter=editable.find(key=>key.index===index+2);
    const end=nextAfter ? nextAfter.start : animation(document,armatureName,animationName).duration;
    const available=end-selected.start;
    if(duration>=available) throw new Error('O próximo keyframe precisa durar ao menos um quadro.');
    raw[index].duration=duration;
    raw[index+1].duration=available-duration;
    return frames(document,armatureName,animationName,boneName,channel)[index];
  }

  // DragonBones 5.x parser semantics (ObjectDataParser._parseTweenFrame):
  // -2 = hold; 0 = linear; -1 = quadratic-in; +1 = quadratic-out;
  // +2 = quadratic-in-out. A 4-number curve is one cubic Bezier segment.
  const EASING_PRESETS = Object.freeze({
    hold: -2, linear: 0, easeIn: -1, easeOut: 1, easeInOut: 2
  });
  function easing(document, armatureName, animationName, boneName, channel, index) {
    const {raw, editable}=validatedTimeline(document,armatureName,animationName,boneName,channel);
    const selected=editable.find(f=>f.index===index);
    if(!selected) throw new Error('Quadro terminal ou keyframe inexistente.');
    const source=raw[index];
    if(Array.isArray(source.curve)) {
      if(source.curve.length===4 && source.curve.every(Number.isFinite)) {
        return { mode:'bezier', control:source.curve.slice() };
      }
      return { mode:'original', control:null };
    }
    const amount=typeof source.tweenEasing==='number'?source.tweenEasing:-2;
    const mode=Object.keys(EASING_PRESETS).find(k=>EASING_PRESETS[k]===amount) ?? 'original';
    return { mode, control:null };
  }
  function editEasing(document, armatureName, animationName, boneName, channel, index, next) {
    if(!next || !Object.hasOwn(EASING_PRESETS,next.mode) && next.mode!=='bezier')
      throw new Error('Modo de interpolação inválido.');
    const {raw,editable}=validatedTimeline(document,armatureName,animationName,boneName,channel);
    if(!editable.some(frame=>frame.index===index)) throw new Error('Keyframe terminal não editável.');
    let curve=null;
    if(next.mode==='bezier') {
      curve=next.control;
      if(!Array.isArray(curve) || curve.length!==4 ||
         curve.some(v=>typeof v!=='number' || !Number.isFinite(v) || v<0 || v>1))
        throw new Error('Curva Bézier precisa de quatro coordenadas de 0 a 1.');
      if(curve[0]>curve[2]) throw new Error('Os controles X da curva precisam estar em ordem.');
      curve=curve.slice();
    }
    const source=raw[index];
    // Remove the mutually exclusive field. The original parser gives curve priority.
    if(curve) {
      source.curve=curve;
      delete source.tweenEasing;
    } else {
      delete source.curve;
      source.tweenEasing=EASING_PRESETS[next.mode];
    }
    return easing(document,armatureName,animationName,boneName,channel,index);
  }
  root.BonoTimelineEditor = Object.freeze({
    CHANNELS, animation, frames, editExistingFrame,
    insertFrame, removeFrame, setFrameDuration,
    EASING_PRESETS, easing, editEasing
  });
})(typeof window !== 'undefined' ? window : globalThis);
