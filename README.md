# Bono-Lua — DragonBones reconstruído em Lua

**Linguagem do projeto: Lua.** O [DragonBonesJS](https://github.com/DragonBones/DragonBonesJS) é apenas a **referência técnica** para o porte, não uma dependência de execução.

A branch principal (`main`) contém agora uma base escrita inteiramente em Lua, no lugar do protótipo JavaScript anterior. O histórico do protótipo continua acessível nos commits antigos do Git. **Não é ainda uma cópia funcional completa do DragonBones**: este é o primeiro núcleo executável do porte.

## Como executar

Requisitos para testes: **Lua 5.4** (nenhum pacote Lua externo).

```sh
lua tests/run.lua
```

Para abrir a visualização 2D com sprites de atlas, instale [LÖVE 11.x](https://love2d.org/) e execute:

```sh
love .
```

Controles: **espaço** pausa/continua; **esquerda/direita** troca animação; **B** mostra/oculta ossos; **R** recarrega; clique seleciona o osso mais próximo.

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

O atlas atual renderiza **displays de imagem não rotacionados** com os pivôs e matrizes de seus ossos; omite malhas, regiões rotacionadas e outros tipos de display ainda não implementados. A renderização de PNG externos exige o LÖVE, mas todo o código do projeto está em Lua.

## Núcleo Lua incluído

- Leitor JSON estrito e independente de JavaScript.
- Parser dos dados DragonBones JSON 5.x: armaduras, ossos, hierarquia, slots, skins e timelines básicas.
- Matrizes 2D e transformações baseadas na matemática original do DragonBones.
- Reprodução em Lua de timelines de translação e rotação, com keyframes, looping, easing e curva cúbica Bézier.
- Cálculo de transformações hierárquicas, associação de imagens de atlas aos slots e quadros de renderização LÖVE.
- Renderização inicial de sprites recortados do PNG e sobreposição opcional de ossos.
- Testes de importação, matrizes, hierarquia, pausas, keyframes, curvas e geração de comandos de sprites.
- Teste de integração com o **Mecha 1406** oficial: 17 ossos, 13 slots e 13 sprites resolvidos pelo runtime Lua (o exemplo é obtido durante a CI, sem distribuir seus assets).
- Teste gráfico com o LÖVE em tela virtual, com captura de imagem disponível como artefato no GitHub Actions.

## Limites atuais

Faltam os recursos do motor original: atlas rotacionados, trocas animadas de displays, malhas ponderadas e deformação FFD, IK, constraints de caminho, skins dinâmicas, interpolação completa de todos os canais, eventos, suporte binário DBBIN, editor clássico completo e exportação. **Não confundir esta etapa com uma implementação 1:1 concluída.**

A camada gráfica LÖVE é um host externo, assim como qualquer motor Lua usa bibliotecas nativas para obter janela, GPU e áudio; o código da aplicação e da lógica de animação continua em Lua.

## Licenças e referência

O projeto original DragonBonesJS utiliza licença MIT. Este porte é trabalho independente e deve preservar avisos de atribuição quando incorporar código original substancial. Não copia assets nem redistribui o runtime JavaScript.

O nome do repositório permanece Bono-Lua por decisão prévia, mas agora corresponde à tecnologia usada. A execução gráfica real é verificada separadamente no GitHub Actions usando uma tela virtual; isso valida a prévia básica, mas não prova equivalência 1:1 com todas as animações e funcionalidades originais.
