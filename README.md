# Bono-Lua — reconstrução do DragonBones em JavaScript/TypeScript

> **Fase 0 — preparação do código original (não é ainda um editor funcional).**

Este repositório será usado para estudar, executar e reconstruir a experiência original do DragonBones antes de desenvolver modificações.

## Referência original

- Projeto: https://github.com/DragonBones/DragonBonesJS
- Runtime comum: `DragonBones/src`
- Linguagens: JavaScript / TypeScript
- Licença do runtime: MIT (preservar os avisos de copyright)
- A integração de editor visual não está incluída nesse runtime; sua reconstrução é uma etapa própria.

## Obter o runtime original

Requisitos: Git e Node.js.

```bash
npm run upstream:clone
```

O script baixa o repositório oficial para `vendor/DragonBonesJS`, sem modificar o código original. A pasta é ignorada no Git para evitar importação não auditada de exemplos e recursos de terceiros.

Depois de baixar, explore `vendor/DragonBonesJS/DragonBones/src` e consulte as instruções do projeto original. **Ainda não há comando de build do editor.**

## Etapas

1. Arquivar e identificar uma revisão de referência do upstream.
2. Executar e testar o runtime original.
3. Reconstruir a interface e o fluxo do editor clássico com testes comparativos.
4. Somente após a equivalência funcional: rig automático por silhueta, biblioteca de animações e Studio por comandos.
5. Exportar vídeo e sequência de imagens.

## Licenças

O código DragonBonesJS pertence aos autores originais e tem licença MIT no repositório upstream. Cópias substanciais devem preservar seus avisos. Avaliar separadamente a licença de cada recurso do editor, exemplo e asset antes de incorporá-lo.

Este repositório não se apresenta como versão oficial do DragonBones.
