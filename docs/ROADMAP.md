# Etapas obrigatórias

| Etapa | Objetivo | Estado |
| --- | --- | --- |
| 00 | Backup remoto e reconstrução isolada | Concluída |
| 01 | Inventário integral, contratos e dependências | Arquivos, contratos declarados e dependências estáticas catalogados; fronteiras externas registradas |
| 02 | Matemática: Matrix, Transform, Point, Rectangle, ColorTransform | Cinco classes implementadas e comparadas isoladamente; integração e auditoria exaustiva pendentes |
| 03 | Core, modelos e ciclo de vida | Em andamento: BaseObject, núcleo DragonBones/enums, UserData/ActionData e dados de Canvas/atlas/textura comparados; demais modelos pendentes |
| 04 | Parsers JSON/DBDT | Pendente |
| 05 | Armature, Bone, Slot, Surface, TransformObject | Pendente |
| 06 | IKConstraint e PathConstraint | Pendente |
| 07 | Animação, timelines, blending e eventos | WorldClock e núcleo/EventObject comparados; Armature, animação, listeners/backend e precisão de host pendentes |
| 08 | BaseFactory e runtime | Pendente |
| 09 | Adaptador gráfico Lua/LÖVE e comparação real | Pendente |
| 10 | Auditoria de todas as integrações oficiais | Pendente |
| 11 | Exportações reais e testes externos | Pendente |
| 12 | Auditoria final de equivalência | Pendente |

O proprietário autorizou posteriormente a main a acompanhar checkpoints do porte em andamento. Integrar somente unidades com testes/CI pertinentes aprovados e status explícito de incompletude; CI estrutural verde não comprova equivalência do motor.
