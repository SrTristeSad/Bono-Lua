# Exemplos executáveis

Execute na raiz do Bono-Lua com Lua 5.4 ou LuaJIT. Não precisa instalar Node, npm, LÖVE ou dependências gráficas para estes exemplos. No Windows, use o nome do executável Lua instalado no lugar de lua5.4.

```sh
lua5.4 examples/run.lua inspect
lua5.4 examples/run.lua transform
luajit examples/run.lua inspect
```

O primeiro comando carrega examples/minimal_ske.json, um arquivo pequeno de demonstração criado neste repositório. Deve listar uma armadura demo, um osso e uma animação idle de 24 frames/1 segundo, seguidos da confirmação de limpeza. Não é uma exportação do corpus upstream.

Para testar seus arquivos esqueléticos JSON ou DBDT:

```sh
lua5.4 examples/run.lua inspect /caminho/arquivo_ske.json
lua5.4 examples/run.lua inspect /caminho/arquivo_ske.dbbin 0.5
```

O argumento final é a escala, padrão 1. JSON de atlas não é um arquivo esquelético. Erros de abertura, sintaxe ou versão são informados no terminal. O inspector é uma ferramenta de exemplo sobre os parsers; não adiciona I/O ao núcleo.

A demonstração transform deve imprimir posição (0,0)/rotação 0° antes da atualização e posição (40,20)/rotação 90° depois. Ela usa uma subclasse local de demonstração da base abstrata TransformObject e o pool real. A matriz está editável em run.lua. Essa classe não substitui Bone, Slot ou Armature do motor.

Esses exemplos permitem experimentar importação e transformação no terminal. Playback, blending e renderização ainda não estão implementados.

## Hierarquia de ossos

```sh
lua5.4 examples/run.lua bones
luajit examples/run.lua bones
```

Carrega bones_ske.json (fixture criado neste projeto) e usa Bone, Armature parcial, modelos e pool reais. Inicialmente root está em (10,20) e child em (40,20). Depois de girar o pai em 90°, child passa a (10,50), mantendo o vínculo ao pai. Edite os transforms do JSON e execute novamente para experimentar a pose.

Também aceita um JSON esquelético com ossos regulares: `lua5.4 examples/run.lua bones /caminho/arquivo_ske.json`. Usa a primeira armadura e gira seu primeiro osso em 90°. Surface é recusado explicitamente.

É uma montagem manual de baixo nível: atribui _armatureData à armadura e chama Bone.init/update diretamente. Armature.init/advanceTime, animação, slots e factory completos ainda não estão disponíveis. O exemplo não substitui esses métodos por simuladores nem reproduz um clip.

## Grade deformável

```sh
lua5.4 examples/run.lua surface
luajit examples/run.lua surface
```

Carrega surface_ske.json, uma grade 2×2 e um osso filho, criada para esta demonstração. O filho começa em (50,50); o comando desloca o Y do vértice central em +80 e o filho passa a (50,90). Edite os vértices no JSON ou o deslocamento em run.lua para experimentar.

Usa Surface, Bone, modelos importados, dados de cache e Armature parcial reais. _deformVertices usa índices Lua base 1: o Y central está em 10. A montagem de _armatureData e a alteração da deformação são manuais, sem factory, reprodução de clip ou renderização.

## Dados de display e deformação

```sh
lua5.4 examples/run.lua displayframe
luajit examples/run.lua displayframe
```

Cria uma malha com três vértices usando view Int16 real. DisplayFrame gera seis componentes de deformação. O exemplo altera Y para 12 e confirma que atualizar novamente conserva a alteração. A limpeza do frame não destrói os modelos referenciados. Este comando ainda não desenha a malha nem reproduz animação.

## Slot ligado ao osso e colisão

```sh
lua5.4 examples/run.lua slot
luajit examples/run.lua slot
```

Usa Bone/Slot/Armature parcial, dados importados e caixa real. O slot começa em (45,20); mover o pai +10 no eixo X leva o slot a (55,20). Em ambas as poses, containsPoint confirma o centro dentro da caixa. Também confirma getSlot e observa o callback ao ocultar o osso pai.

O exemplo atribui _armatureData/_boundingBoxData/_localMatrix manualmente e chama updateTransformAndMatrix diretamente. Uma subclasse local registra os hooks abstratos; ela não desenha nem implementa Slot.update, animação ou renderer.
