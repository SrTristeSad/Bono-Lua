# Seus arquivos DragonBones

Coloque nesta pasta os três arquivos de uma exportação em JSON/PNG:

- `project_ske.json`
- `project_tex.json`
- `project_tex.png`

Depois execute `love .` na raiz do projeto. A prévia usa a primeira armadura, os slots em ordem e o atlas de imagens.

Os arquivos do usuário são ignorados pelo Git. O projeto não executa JavaScript.

**Compatibilidade em desenvolvimento:** sprites não rotacionados e posições derivadas da hierarquia de ossos. Malhas ponderadas, múltiplos atlases, máscaras, IK e deformações ainda não estão implementados.
