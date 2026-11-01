# Bono-Lua — reconstrução compatível com DragonBonesJS

Projeto independente para recuperar primeiro o funcionamento do **DragonBones original** e depois construir um Studio de animação 2D simplificado.

## Estado atual: fase 10 — inserir, remover e ajustar keyframes

- Fonte upstream: [DragonBones/DragonBonesJS](https://github.com/DragonBones/DragonBonesJS).
- Revisão fixa: `64b6c69ae35777c2404be68c9192e2c56906079e` (2025-05-24).
- Runtime original: TypeScript compilado para JavaScript sem modificar o upstream.
- Testes automatizados: matrizes, classes, hierarquia de ossos, animações, relógio e importação de um exemplo real.
- Integração: [GitHub Actions](.github/workflows/dragonbones-original.yml), com build e testes em Node.js 20.

**Importante:** o runtime e o viewer de reprodução visual já foram validados no Chromium, mas ainda não constituem o **editor original completo**. O DragonBonesJS é a biblioteca de execução; a interface de criação/edição será reconstruída separadamente.

## Reproduzir

Pré-requisitos: Node.js >= 18, npm, Git e conexão de rede (para baixar as dependências originais).

```bash
npm run upstream:clone
npm run original:build
npm run original:verify
```

O script de download **não altera o original** e verifica o commit fixado em `upstream.lock.mjs`. O JavaScript compilado aparece em `dist/original/dragonBones.js`.

Para rodar apenas os testes, use `npm test`. Testes dependentes do código original são marcados como ignorados caso você ainda não tenha realizado o build; a CI executa os testes **após** compilar e verifica que todos foram executados.

## O que foi comprovado

- `ObjectDataParser` lê o personagem de teste do projeto e um exemplo autêntico do DragonBonesJS (20 ossos, 19 slots, animação `idle`).
- `Matrix` transforma coordenadas e executa a transformação inversa.
- `WorldClock` avança objetos animáveis registrados.
- Classes principais da API pública são carregadas.
- A CI compila o runtime original sem modificar os arquivos upstream.

Veja [docs/compatibilidade.md](docs/compatibilidade.md).

## Viewer original — fases 4–5 (integração gráfica e importação)

A versão de compatibilidade inclui agora um viewer de navegador baseado no **adapter PixiJS 8 oficial do DragonBonesJS**, sem substituir seu motor de animação.

```bash
npm run upstream:clone
npm run original:build
npm run demo:prepare
npm run demo:serve
```

Abra http://127.0.0.1:4173 e veja [instruções do viewer](docs/viewer-original.md). A interface permite trocar personagens/animações, importar localmente esqueleto JSON, atlas JSON e PNG, navegar pelo tempo e agora **selecionar ossos na hierarquia ou na prévia**, editar X/Y/rotação da pose-base, trocar o desenho padrão dos slots, alterar a ordem-base das camadas (quando seguro), **editar valores de keyframes, dividir intervalos, remover quadros intermediários e ajustar suas durações** nos canais de translação e rotação, e salvar o esqueleto JSON. Os arquivos binários e texturas originais são copiados apenas ao preparar o demo, não ficam permanentemente versionados. Há um teste opcional de navegador em `npm run demo:test-browser` (requer Playwright/Chromium).

## Próximas etapas

1. Testar projetos DragonBones mais complexos: skins, malhas, deformações, constraints e IK.
2. Ampliar compatibilidade de slots para skins alternativas e animações com ordem Z, com testes de remapeamento.
3. Evoluir a timeline para criação de canais e edição de interpolação (curvas, easing), com testes de salvamento e reabertura.
4. Testar compatibilidade avançada de exportação, inclusive projetos com constraints, meshes e animações complexas.
5. **Somente depois**: rigging por silhueta, múltiplas perspectivas, ações de cena e exportação de vídeo/PNG.

## Licença e autoria

O runtime original DragonBonesJS é licenciado sob MIT, copyright DragonBones team e contribuidores (2012–2025). Reutilizações e distribuições devem preservar esses avisos. Outros recursos (demos, imagens e editores) têm de ser auditados separadamente antes de distribuição.

**Bono-Lua não é um projeto oficial DragonBones.**
