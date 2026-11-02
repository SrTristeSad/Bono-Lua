# Bono-Lua — porte do DragonBones original para Lua

**Linguagem do projeto: Lua.** O [DragonBonesJS](https://github.com/DragonBones/DragonBonesJS) é apenas a **referência técnica** para o porte, não uma dependência de execução.

A aplicação `love .` usa diretamente o porte original em `dragonbones/original/`, com `dragonbones.love_original.Factory` como adaptação gráfica ao LÖVE. **O protótipo Lua antigo continua no repositório, mas não é mais a rota executada pela demonstração principal.** O porte ainda não é uma cópia funcional completa do DragonBones: há recursos pendentes, explicitados em `docs/PORTING_STATUS.md`.


## Direção obrigatória: porte fiel do original

**O objetivo é portar o DragonBones original, não criar um novo motor inspirado nele.** Os módulos anteriores eram protótipos simplificados. Eles continuam para preservar a prévia existente, mas não representam fidelidade 1:1.

O trabalho verificável de porte original está em `dragonbones/original/`, incluindo os cinco módulos `geom/`, `core/BaseObject.lua`, `animation/WorldClock.lua`, `model/UserData.lua`, `event/EventObject.lua` e `core/DragonBones.lua`, além de `armature/TransformObject.lua` e modelos de Canvas, Constraint e TextureAtlas, DisplayData, SkinData, DragonBonesData, ArmatureData, AnimationData, AnimationConfig e BoundingBoxData. Os protótipos antigos continuam isolados. Os testes específicos estão em `tests/original_geom.lua`, `tests/original_core.lua`, `tests/original_worldclock.lua`, `tests/original_events.lua`, `tests/original_transform_models.lua`, `tests/original_display_skin_data.lua` e `tests/original_armature_data.lua` e `tests/original_animation_data.lua` e `tests/original_animation_config.lua` e `tests/original_boundingbox.lua`; os detalhes por arquivo estão em `docs/PORTING_STATUS.md`. As regras permanentes estão em PORTING_RULES.md. O código original pertence ao DragonBones team, sob licença MIT (LICENSE-DRAGONBONES).

## Como executar

Para abrir o **runtime original portado para Lua**, instale [LÖVE 11.x](https://love2d.org/) e execute:

```sh
love .
```

Controles: **espaço** pausa/continua; **esquerda/direita** troca animação; **B** mostra/oculta ossos; **R** recarrega; clique seleciona o osso mais próximo. No exemplo integrado, escolha a animação **`swap`** para ver a troca e a ocultação dos desenhos do braço.

## Personagens externos — JSON + PNG

A demonstração abre por padrão uma fixture simples de dois sprites, cuja textura de exemplo é **gerada em Lua**; não é necessário baixar recursos.

Para abrir uma exportação DragonBones sua, crie a pasta `assets/` na raiz e coloque estes arquivos:

```text
assets/
  project_ske.json  # JSON de armadura DragonBones
  project_tex.json  # Atlas JSON (SubTexture)
  project_tex.png   # Imagem PNG do atlas
```

Depois execute `love .`. O programa lê os três arquivos locais automaticamente e usa a primeira armadura e o primeiro clip. Para voltar ao exemplo integrado, mova ou renomeie `assets/project_ske.json`.

A aplicação principal agora utiliza `ObjectDataParser`, `BaseFactory`, `Armature`, `Animation` e `Slot` do porte original, com a GPU LÖVE no lugar de PixiJS. Há suporte e testes no backend original para malhas, FFD, atlas, relógio, eventos e Z-order; **isso não comprova compatibilidade com todas as exportações reais**. Máscaras e alguns blend modes avançados continuam ausentes. Não há dependência JavaScript no produto.

## Troca de desenhos durante a animação

O motor Lua já interpreta as timelines **`animation[].slot[].displayFrame`** e o formato legado **`animation[].slot[].frame`**, reconhecendo o campo `value` ou `displayIndex`.

- Índice `0`: primeiro desenho cadastrado no slot; `1`: segundo desenho, e assim por diante.
- Índice `-1`: oculta a peça sem apagar o osso.
- As mudanças são discretas, exatamente no quadro definido, sem interpolar índices de imagem.
- Ao pausar, a peça mantém o desenho selecionado; ao repetir o clipe ou mudar de animação, o estado é recalculado.
- A ordem dos slots continua vindo do esqueleto; ainda não há suporte à **animação de ordem Z**, nem à troca de skins completas.

Na demonstração `swap`, a peça do braço muda entre os dois sprites de exemplo, desaparece e retorna. O CI verifica os quadros por testes de Lua e compara pixels renderizados pelo LÖVE, inclusive ocultação e looping.

## Protótipo antigo (preservado, mas não utilizado por `love .`)

Os módulos simplificados em `dragonbones/*.lua` descritos abaixo são históricos. **Eles não são o motor original nem a implementação da janela principal atual.** O motor atualmente executado fica em `dragonbones/original/` e seu adaptador LÖVE em `dragonbones/love_original.lua`.

- Leitor JSON estrito e independente de JavaScript.
- Parser dos dados DragonBones JSON 5.x: armaduras, ossos, hierarquia, slots, skins e timelines básicas.
- Matrizes 2D e transformações baseadas na matemática original do DragonBones.
- Reprodução em Lua de timelines de translação e rotação, com keyframes, looping, easing e curva cúbica Bézier.
- Cálculo de transformações hierárquicas, associação de imagens de atlas aos slots, troca/ocultação animada de desenhos e quadros de renderização LÖVE.
- Renderização inicial de sprites recortados do PNG e sobreposição opcional de ossos.
- Testes de importação, matrizes, hierarquia, pausas, keyframes, curvas, displays animados e geração de comandos de sprites.
- Teste de integração com o **Mecha 1406** oficial: 17 ossos, 13 slots e 13 sprites resolvidos pelo runtime Lua (o exemplo é obtido durante a CI, sem distribuir seus assets).
- Teste gráfico com o LÖVE em tela virtual, com captura de imagem disponível como artefato no GitHub Actions. O CI também valida os pixels de uma textura propositalmente rotacionada em 90°, além de conferir a matriz e o pivô.

## Limites atuais

O runtime original portado possui verificações específicas de malhas, FFD, IK, slots, Z-order, animação, eventos, parser JSON/binário e renderização LÖVE. Porém **não existe comprovação de equivalência global 1:1**: buffers binários ainda não implementam `ArrayBuffer` compartilhado mutável; máscaras e os modos Pixi `Difference`, `HardLight` e `Overlay` permanecem pendentes; o editor original precisa de fonte e licença verificadas; mais exportações reais e comportamentos devem ser comparados. Os módulos legados têm limites diferentes e não devem ser confundidos com o porte.

A camada gráfica LÖVE é um host externo, assim como qualquer motor Lua usa bibliotecas nativas para obter janela, GPU e áudio; o código da aplicação e da lógica de animação continua em Lua.

## Licenças e referência

O projeto original DragonBonesJS utiliza licença MIT. Este porte é trabalho independente e deve preservar avisos de atribuição quando incorporar código original substancial. Não copia assets nem redistribui o runtime JavaScript.

O nome do repositório permanece Bono-Lua por decisão prévia, mas agora corresponde à tecnologia usada. A execução gráfica real é verificada separadamente no GitHub Actions usando uma tela virtual; isso valida a prévia básica, mas não prova equivalência 1:1 com todas as animações e funcionalidades originais.
