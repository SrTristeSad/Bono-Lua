# Estado da reconstrução integral

Fonte única: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`.
Destino único: SrTristeSad/Bono-Lua. Branch: `rebuild/integral-20261103`.

## Etapa 00 — preparada

- Main consultada: `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb`.
- Backup remoto: `backup/pre-integral-rebuild-20261103`, confirmado por `git ls-remote --heads origin backup/pre-integral-rebuild-20261103`, no mesmo SHA.
- Branch de reconstrução criada a partir desse SHA, sem modificar main.
- Implementação anterior removida somente nesta branch; licença MIT preservada.
- Nenhum PR aberto encontrado na consulta inicial. A consulta de workflows do SHA da main retornou lista vazia; isso não prova ausência de execuções push, pois o conector filtra execuções de PR.

## Etapa 01 — inventário estrutural disponível, auditoria pendente

1.203 caminhos rastreados, 182 arquivos autorais TS/JS examinados por AST, 240 classes declaradas. Ver UPSTREAM_INVENTORY.md.
Os 37 arquivos TS do núcleo incluem 34 arquivos de código e três contratos de interface.
Não foram traduzidos módulos nesta unidade. Toda correspondência Lua é proposta e está ausente na branch limpa.
Grafo de dependências: candidatos estáticos por identificador, ainda não confirmado por resolução semântica.
APIs globais, contratos de integrações, código executável de topo e relações dinâmicas precisam de revisão humana/técnica arquivo a arquivo.

## Histórico anterior

O backup contém implementação, testes e documentação acumulados até a etapa antiga 61. Aqueles resultados não são atribuídos à reconstrução limpa. Sua existência foi constatada, mas as alegações antigas de CI/GPU não foram reexecutadas nesta sessão.
A preservação de implementações comprovadamente equivalentes poderá ser feita após comparação real com o original, sem aproveitar módulos automaticamente.

## Cobertura

- Inventariado: caminhos e declarações estruturais.
- Implementado nesta reconstrução: nenhum módulo.
- Validado isoladamente/em integração: nenhum comportamento de runtime nesta reconstrução.
- Equivalência integral: pendente, sem porcentagem atribuída.

## Publicação e CI

Checkpoint `eac7d2b83f09ff572bd751616ab4e7218373ddbf`, PR #63 em rascunho. [CI estrutural](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41575623832): job `inventory` aprovado e evidência publicada, conferidos pela API. Nenhum merge realizado. Etapa 01 continua semanticamente pendente.
