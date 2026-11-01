# Viewer original DragonBonesJS + PixiJS 8

**Objetivo:** reproduzir graficamente exemplos reais do DragonBones original, antes de desenvolver o editor novo.

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
- `Cocos/Demos/assets/resources/mecha_1002_101d_show/`: exemplo original, 20 ossos e animação `idle`.
- `Cocos/Demos/assets/resources/mecha_1406/`: segundo exemplo original, 17 ossos e 8 animações, incluindo `idle`, `walk`, `jump` e `attack_01`.
- `web/demo/app.js`: interface independente para controlar **somente** a reprodução, sem modificar os algoritmos de animação originais.

O script `demo:prepare` copia esses arquivos para `web/demo/vendor` e `web/demo/assets`, preservando os bytes. As pastas de saída estão ignoradas no Git.

## Controles

- Seleção entre dois personagens oficiais do DragonBonesJS.
- Seleção da animação disponível para cada personagem (incluindo caminhada no Mecha 1406).
- Pausa, retomada e reinício.
- Barra de posição no clipe, usando a propriedade `AnimationState.currentTime` do runtime original. Arrastar a barra pausa a reprodução; o botão Reproduzir continua a partir do ponto escolhido.
- Alteração da velocidade da reprodução.
- Exibir ossos/articulações para depuração.
- Visualização do número de ossos e slots.

**Não há** criação de ossos, edição de keyframes, rigging por silhueta, controle de câmera ou exportação de vídeo nesta fase. A biblioteca original de execução não inclui a interface antiga do DragonBones.

## Importar projetos DragonBones (Fase 5)

No visualizador, selecione **Esqueleto JSON**, **Atlas JSON** e **Textura PNG**. Clique em **Importar projeto**. O personagem é adicionado à lista e suas animações podem ser selecionadas, usando o **runtime original** do DragonBonesJS.

Formatos esperados: exportações JSON do DragonBones que incluam `armature` e atlas com `SubTexture`; textura em PNG. O arquivo `.dbbin`, múltiplos atlases e exportações incompatíveis ainda **não são suportados** pelo importador atual. Os JSONs estão limitados a 8 MB cada; PNG a 20 MB.

Os arquivos são carregados apenas no navegador, sem envio para o servidor e sem salvamento permanente: ao atualizar a página é preciso importar novamente. Cada novo projeto usa um identificador interno próprio, evitando colisões entre personagens de nomes iguais.

Este recurso **não modifica** a obra original; é a primeira etapa para permitir que o futuro editor trabalhe com projetos externos.

## Edição de ossos — fase 6

A área **Ossos · pose-base** apresenta a árvore hierárquica com os nomes e pais dos ossos carregados, usando a estrutura original do DragonBones.

1. Escolha um personagem e selecione um osso na árvore.
2. Ajuste **X**, **Y** ou **Rotação (graus)**. A prévia é atualizada com os offsets do runtime DragonBones e a reprodução é pausada para inspeção.
3. Use **Restaurar osso** para voltar à pose-base original daquele projeto carregado.
4. Use **Salvar esqueleto JSON** para baixar o `_ske.json` preservando animações, skins e demais campos. Para reimportar, utilize também o atlas JSON e a textura PNG correspondentes.

**Limites atuais:** este editor altera a pose-base (rest pose) existente; ainda não cria/apaga ossos, não edita keyframes, não muda hierarquia, não reconstroi malhas e não gera novas imagens. A visualização é feita via `Bone.offset`, enquanto a exportação atualiza as transformações do JSON original. Projetos com malhas ponderadas, IK ou constraints complexas podem exigir adaptação de pesos e binds para reproduzir fielmente mudanças de pose-base: ainda não há validação de equivalência nesses casos.

Os scripts originais e suas licenças continuam preservados; as alterações pertencem somente à cópia local do personagem.

## Seleção de ossos na prévia e inspeção de slots — fase 7

A opção **Selecionar ossos na prévia** mostra marcadores sobre as articulações do personagem. Eles acompanham os ossos durante a reprodução usando as matrizes globais calculadas pelo DragonBonesJS original, convertidas para a posição do PixiJS no canvas. Clique ou selecione um marcador com teclado (Tab, Enter ou Espaço) para escolher o osso e pausar a animação. A árvore e os campos de pose-base são sincronizados. A opção **Mostrar esqueleto (DragonBones)** continua disponível de forma independente, para usar o debug visual original.

No painel **Slots e desenhos**, a seleção exibe nome do slot, osso pai, índice de display, ordem inicial e desenhos registrados por skin. Ao selecionar um slot, o editor também seleciona seu osso pai, quando existir.

Essas duas ferramentas são **inspeção e seleção**, não deformação automática de malhas nem edição dos dados de slots. Alterar o osso na pose-base ainda ocorre pelos campos X/Y/Rotação e pode ser exportado como JSON; os slots são apenas leitura nesta etapa.

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

Esse teste usa a mesma página do usuário, espera a armadura aparecer, compara a contagem de ossos/slots, verifica a evolução temporal das animações, a troca de personagem, a importação de arquivos locais, a busca na timeline, a pausa efetiva do relógio e a preservação do personagem atual quando um JSON inválido é enviado. A CI executa esse teste automaticamente.

## Licença

DragonBonesJS, o adapter PixiJS e o código do demo original pertencem aos seus autores. Preserve o arquivo `vendor/DRAGONBONES-LICENSE` ao redistribuir a cópia do runtime. Os direitos e licenças das bibliotecas e exemplos usados também devem ser respeitados; consulte os repositórios originais.

- https://github.com/DragonBones/DragonBonesJS
- https://github.com/pixijs/pixijs

O viewer independente do Bono-Lua não reivindica afiliação oficial com DragonBones.
