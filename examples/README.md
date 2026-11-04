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
