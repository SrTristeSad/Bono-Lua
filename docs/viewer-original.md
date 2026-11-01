# Viewer original DragonBonesJS + PixiJS 8

**Objetivo:** reproduzir graficamente um exemplo real do DragonBones original, antes de desenvolver o editor novo.

## Como executar

Requisitos: Node.js 18+, npm, Git e navegador moderno com WebGL.

```bash
npm run upstream:clone
npm run original:build
npm run demo:prepare
npm run demo:serve
```

Abra **http://127.0.0.1:4173** no navegador.

Não abra `web/demo/index.html` diretamente com `file://`: o carregamento dos arquivos JSON e PNG requer servidor HTTP.

## O que este viewer usa

- `Pixi/8.x/out/dragonBones.js`: adapter original que traz o runtime DragonBones e a fábrica PixiJS 8.
- `Pixi/Demos/8.x/libs/pixi/8.9.2/pixi.js`: cópia local da biblioteca PixiJS do upstream fixado.
- `Cocos/Demos/assets/resources/mecha_1002_101d_show/`: exemplo oficial, esqueleto, textura e atlas.
- `web/demo/app.js`: interface independente para controlar **somente** a reprodução, sem modificar os algoritmos de animação originais.

O script `demo:prepare` copia esses arquivos para `web/demo/vendor` e `web/demo/assets`, preservando os bytes. As pastas de saída estão ignoradas no Git.

## Controles

- Seleção de animação (o exemplo atualmente contém `idle`).
- Pausa, retomada e reinício.
- Alteração da velocidade da reprodução.
- Exibir ossos/articulações para depuração.
- Visualização do número de ossos e slots.

**Não há** criação de ossos, edição de keyframes, rigging por silhueta, controle de câmera ou exportação de vídeo nesta fase. A biblioteca original de execução não inclui a interface antiga do DragonBones.

## Testes

```bash
npm test
```

Após preparar o viewer, opcionalmente execute o teste gráfico em Chromium:

```bash
npm install --no-save playwright@1.56.1
npx playwright install chromium
npm run demo:test-browser
```

Esse teste usa a mesma página do usuário, espera a armadura aparecer, compara a contagem de ossos/slots, verifica a evolução temporal da animação e testa os controles. A CI executa esse teste automaticamente.

## Licença

DragonBonesJS, o adapter PixiJS e o código do demo original pertencem aos seus autores. Preserve o arquivo `vendor/DRAGONBONES-LICENSE` ao redistribuir a cópia do runtime. Os direitos e licenças das bibliotecas e exemplos usados também devem ser respeitados; consulte os repositórios originais.

- https://github.com/DragonBones/DragonBonesJS
- https://github.com/pixijs/pixijs

O viewer independente do Bono-Lua não reivindica afiliação oficial com DragonBones.
