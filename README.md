# Bono-Lua — DragonBones reconstruído em Lua

**Linguagem do projeto: Lua.** O [DragonBonesJS](https://github.com/DragonBones/DragonBonesJS) é apenas a **referência técnica** para o porte, não uma dependência de execução.

Esta branch substitui o protótipo JavaScript anterior por uma base inteiramente escrita em Lua. O histórico da implementação anterior permanece acessível na branch main e nos commits antigos. **Não é ainda uma cópia funcional completa do DragonBones**: este é o primeiro núcleo executável do porte.

## Como executar

Requisitos para testes: **Lua 5.4** (nenhum pacote Lua externo).

```sh
lua tests/run.lua
```

Para abrir a visualização 2D do esqueleto, instale [LÖVE 11.x](https://love2d.org/) e execute:

```sh
love .
```

Controles: espaço pausa/continua; esquerda/direita troca animação; clique para selecionar um osso.

## Núcleo Lua incluído

- Leitor JSON estrito e independente de JavaScript.
- Parser dos dados DragonBones JSON 5.x: armaduras, ossos, hierarquia, slots, skins e timelines básicas.
- Matrizes 2D e transformações baseadas na matemática original do DragonBones.
- Reprodução em Lua de timelines de translação e rotação, com keyframes, looping, easing e curva cúbica Bézier.
- Cálculo de transformações hierárquicas e demonstração no LÖVE.
- Testes de importação, matrizes, hierarquia, pausas, keyframes e curvas.

## Limites atuais

Faltam os recursos do motor original: sprites por atlas, malhas ponderadas e deformação FFD, IK, constraints de caminho, skins dinâmicas, interpolação completa de todos os canais, eventos, suporte binário DBBIN, editor clássico completo e exportação. **Não confundir esta etapa com uma implementação 1:1 concluída.**

A camada gráfica LÖVE é um host externo, assim como qualquer motor Lua usa bibliotecas nativas para obter janela, GPU e áudio; o código da aplicação e da lógica de animação continua em Lua.

## Licenças e referência

O projeto original DragonBonesJS utiliza licença MIT. Este porte é trabalho independente e deve preservar avisos de atribuição quando incorporar código original substancial. Não copia assets nem redistribui o runtime JavaScript.

O nome do repositório permanece Bono-Lua por decisão prévia, mas agora corresponde à tecnologia usada.
