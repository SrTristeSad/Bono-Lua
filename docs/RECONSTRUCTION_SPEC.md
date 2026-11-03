# BONO-LUA — COMANDO MESTRE DE RECONSTRUÇÃO INTEGRAL

**MISSÃO: PORTAR O DRAGONBONESJS OFICIAL PARA LUA COM FIDELIDADE FUNCIONAL DE 100%, COMPROVADA POR TESTES.**

**Este documento define o objetivo, a fonte de verdade, os limites de atuação, a metodologia, os critérios de qualidade e as condições obrigatórias de conclusão.**

O agente deve seguir estas instruções durante toda a reconstrução, inclusive ao retomar o trabalho depois de interrupções.

---

# 1. REPOSITÓRIOS OFICIAIS

## REPOSITÓRIO DE DESTINO — BONO-LUA

https://github.com/SrTristeSad/Bono-Lua

Este é o único repositório de destino autorizado.

Todo código Lua, documentação, testes, evidências, alterações e progresso permanente devem ser mantidos nele, utilizando Git e GitHub.

Não criar outro projeto para substituir o Bono-Lua.

Não transferir o desenvolvimento para outro repositório sem autorização explícita do proprietário.

## FONTE DE VERDADE — DRAGONBONESJS

https://github.com/DragonBones/DragonBonesJS

**Commit oficial fixado:**

`64b6c69ae35777c2404be68c9192e2c56906079e`

Este é o único código autorizado como referência funcional.

Não utilizar outros motores de animação como substitutos.

Não copiar implementações alternativas de Spine, Godot, Unity ou outras bibliotecas.

Não atualizar automaticamente o commit de referência.

Não modificar a arquitetura original por preferência pessoal.

**REGRA FUNDAMENTAL: O BONO-LUA DEVE SEGUIR O DRAGONBONESJS. O DRAGONBONESJS NÃO DEVE SER REINTERPRETADO PARA SE ADAPTAR ÀS PREFERÊNCIAS DO AGENTE.**

---

# 2. OBJETIVO ABSOLUTO

Reconstruir o Bono-Lua em Lua, traduzindo sistematicamente o código oficial do DragonBonesJS.

A meta é equivalência funcional integral, incluindo:

- Estruturas de dados.
- Classes, interfaces e métodos.
- Propriedades e estados.
- Algoritmos matemáticos.
- Transformações e hierarquias.
- Cinemática inversa e constraints.
- Animações e interpolação.
- Timelines e blending.
- Parsers JSON e binário.
- Meshes, pesos e deformações.
- Slots, skins e atlas.
- Eventos, cache e ciclo de vida.
- Factories e construção de armaduras.
- Renderização e integração com os ambientes gráficos.
- Funcionalidades e comportamentos públicos existentes no original.

O escopo deve abranger todo o código funcional do repositório oficial, incluindo a identificação das responsabilidades e dependências das integrações de motores gráficos.

Não confundir tradução literal de sintaxe com equivalência funcional.

Lua possui características diferentes de JavaScript. Adaptações são permitidas apenas quando indispensáveis para manter os mesmos comportamentos observáveis.

**Nunca utilizar a necessidade de adaptação como justificativa para inventar outro motor.**

---

# 3. REGRA MÁXIMA — SEMPRE LER OS DOIS REPOSITÓRIOS

Esta regra é obrigatória antes de qualquer criação, modificação ou correção.

## ANTES DE ALTERAR QUALQUER ARQUIVO

1. Consultar o repositório oficial DragonBonesJS.
2. Abrir o arquivo original correspondente, no commit fixado.
3. Ler as classes, propriedades, métodos e dependências relevantes.
4. Consultar a versão atual do Bono-Lua no GitHub.
5. Abrir o arquivo Lua correspondente, caso exista.
6. Ler seu conteúdo real, não apenas a documentação.
7. Comparar os dois arquivos.
8. Identificar as diferenças.
9. Determinar a alteração mínima necessária.
10. Implementar somente o comportamento definido pelo original.
11. Executar testes.
12. Registrar e publicar o resultado no GitHub.

Se o arquivo Lua ainda não existir, registrar essa ausência e criar sua correspondência no inventário antes da implementação.

**É proibido modificar código baseado apenas em memória, resumos de conversas, suposições ou conhecimento genérico sobre DragonBones.**

## A CADA NOVA SESSÃO

Antes de continuar:

1. Abrir novamente os dois repositórios.
2. Confirmar o commit upstream fixado.
3. Verificar o commit atual e a branch de trabalho do Bono-Lua.
4. Ler os documentos de status e rastreabilidade.
5. Verificar os PRs e os resultados da CI.
6. Conferir os últimos arquivos alterados.
7. Identificar o último objetivo efetivamente concluído.
8. Continuar a partir do estado confirmado no GitHub.

Não assumir que o trabalho descrito em uma conversa anterior está presente no repositório.

Não assumir que testes anteriormente aprovados continuam aprovados depois de alterações.

**O CÓDIGO DO GITHUB PREVALECE SOBRE A MEMÓRIA DO AGENTE.**

---

# 4. REGRA DE PERSISTÊNCIA — TUDO NO GITHUB

O GitHub deve ser a fonte permanente de todo o desenvolvimento.

Não deixar código importante exclusivamente no ambiente temporário.

Não deixar correções apenas em arquivos locais.

Não considerar uma etapa concluída enquanto seus resultados não estiverem registrados e publicados.

Todo trabalho precisa possuir:

- Arquivos versionados.
- Histórico de commits.
- Identificação da branch.
- Referência ao código upstream.
- Documentação atualizada.
- Testes reproduzíveis.
- Evidências de execução.
- Pendências identificadas.
- PR e validação de CI, quando aplicável.

Artefatos necessários à reprodução dos testes devem ser preservados no repositório ou em artefatos persistentes do GitHub Actions, com links verificáveis.

Não publicar arquivos gigantes gerados automaticamente quando não forem necessários à reprodução. Nesse caso, registrar instruções determinísticas para regenerá-los.

## REGRA DE SINCRONIZAÇÃO

Antes de começar:

- Verificar o estado remoto.
- Confirmar a branch correta.
- Verificar alterações existentes.
- Evitar sobrescrever trabalho de outras sessões.

Depois de uma unidade de trabalho validada:

- Criar um commit descritivo.
- Enviar a branch ao GitHub.
- Verificar que o commit realmente apareceu no remoto.
- Atualizar o status do projeto.

Não declarar que algo foi salvo no GitHub sem confirmar sua presença no remoto.

---

# 5. RECOMEÇAR DO ZERO COM SEGURANÇA

A implementação antiga deve ser substituída por uma reconstrução limpa.

Entretanto, **não destruir o histórico Git nem eliminar a possibilidade de recuperação**.

Procedimento obrigatório:

1. Consultar a `main` atual.
2. Registrar seu SHA exato.
3. Verificar se existem alterações remotas ainda não consideradas.
4. Criar uma branch de backup contendo o estado completo anterior.
5. Publicar o backup no GitHub.
6. Confirmar que a branch de backup existe e aponta para o commit correto.
7. Criar uma branch nova para a reconstrução integral.
8. Limpar os arquivos da implementação antiga somente nessa nova branch.
9. Preservar a licença e os avisos legais necessários.
10. Criar a nova estrutura com base no inventário do DragonBonesJS.

A limpeza do código antigo é autorizada somente na branch de reconstrução, depois da confirmação do backup.

**PROIBIDO:**

- Apagar diretamente a `main`.
- Executar `push --force` sobre a `main`.
- Apagar o backup.
- Excluir o histórico para esconder erros.
- Fazer merge de uma reconstrução incompleta apenas porque a CI está verde.
- Destruir alterações desconhecidas sem verificá-las.

A reconstrução substitui a implementação antiga, mas deve preservar a possibilidade de recuperação.

---

# 6. PROIBIÇÃO DE INVENÇÕES

O agente não pode:

1. Criar algoritmos próprios quando existe um algoritmo oficial.
2. Simplificar cálculos matemáticos sem comprovar equivalência.
3. Substituir funcionalidades por simulações.
4. Reescrever módulos em outra arquitetura por conveniência.
5. Remover características difíceis.
6. Ignorar comportamentos incomuns do original.
7. Criar resultados falsos para fazer testes passarem.
8. Omitir erros.
9. Mudar a biblioteca de referência.
10. Alterar o objetivo durante o desenvolvimento.
11. Declarar 100% sem cobertura integral comprovada.
12. Criar uma implementação somente visual e chamá-la de DragonBones completo.

Se algum comportamento original parecer incorreto, investigar sua execução no upstream antes de decidir qualquer mudança.

Se não houver informação suficiente para implementar um comportamento com fidelidade, registrar o impedimento.

**É preferível declarar uma funcionalidade incompleta a inventar uma implementação incorreta.**

---

# 7. INVENTÁRIO COMPLETO DO ORIGINAL

Antes de iniciar o novo porte, criar:

`docs/UPSTREAM_INVENTORY.md`

Enumerar os arquivos do commit oficial.

Classificar cada um como:

- Código-fonte do núcleo.
- Integração com motor gráfico.
- Interface ou declaração de tipos.
- Teste.
- Demonstração.
- Recurso gráfico.
- Arquivo gerado.
- Configuração.
- Documentação.

Para os arquivos funcionais, registrar:

| Campo | Obrigatório |
|---|---|
| Origem | Caminho exato do arquivo TypeScript |
| Destino | Arquivo Lua correspondente |
| Classe | Nome original |
| Métodos | Lista completa |
| Propriedades | Lista completa |
| Dependências | Módulos relacionados |
| Estado | Pendente / implementado / validado |
| Testes | Evidências da comparação |
| Diferenças | Adaptações ou divergências |
| Commit | Referência original |

Não excluir arquivos do inventário porque parecem irrelevantes.

Arquivos de demonstração, recursos, integrações e arquivos gerados devem ser classificados corretamente. Não contabilizá-los indevidamente como módulos de runtime.

Se uma integração exigir APIs específicas de um motor JavaScript inexistentes em Lua, documentar os contratos, as dependências e o que ainda falta para reproduzir seu comportamento.

---

# 8. MAPA DE OBJETIVOS E ETAPAS

O trabalho deve seguir esta sequência de objetivos.

## ETAPA 00 — PREPARAÇÃO

Objetivos:

- Verificar os repositórios.
- Fixar o commit oficial.
- Criar o backup.
- Preparar a branch limpa.
- Configurar a nova documentação.

Conclusão: backup remoto confirmado e reconstrução isolada.

## ETAPA 01 — INVENTÁRIO

Objetivos:

- Examinar o DragonBonesJS completo.
- Catalogar os arquivos.
- Mapear as dependências.
- Definir a correspondência TypeScript/Lua.

Conclusão: inventário integral auditável.

## ETAPA 02 — NÚCLEO MATEMÁTICO

Portar os módulos originais correspondentes a:

- Matrix.
- Transform.
- Point.
- Rectangle.
- ColorTransform.
- Outras operações matemáticas e estruturas fundamentais.

Conclusão: testes diferenciais aprovados.

## ETAPA 03 — CORE E MODELOS

Portar:

- BaseObject.
- DragonBones.
- Objetos de dados.
- Modelos de ossos e armaduras.
- Configurações.
- Texturas e geometrias.
- Bounding boxes.
- Estruturas de animação.

Conclusão: objetos, estados, propriedades e ciclo de vida validados.

## ETAPA 04 — PARSERS

Portar:

- DataParser.
- ObjectDataParser.
- BinaryDataParser.
- Estruturas auxiliares necessárias.

Validar JSON e DBDT, inclusive exportações externas reais.

Conclusão: igualdade de interpretação dos dados, dentro das regras de precisão e representação.

## ETAPA 05 — ARMATURE E OSSOS

Portar:

- Armature.
- Bone.
- Slot.
- Surface.
- TransformObject.
- Hierarquias.
- Atualização de transformações.

Conclusão: estados e matrizes equivalentes ao original.

## ETAPA 06 — CONSTRAINTS

Portar:

- IKConstraint.
- PathConstraint.
- Demais comportamentos relacionados existentes no upstream.

Verificar ordem de execução, dependências, pesos, animações, alvos, espelhamentos e caches.

Conclusão: equivalência diferencial e de integração comprovada.

## ETAPA 07 — ANIMAÇÃO

Portar:

- Animation.
- AnimationState.
- TimelineState.
- BaseTimelineState.
- WorldClock.
- Fades.
- Blending.
- Eventos e máscaras.
- Cache e interpolação.

Conclusão: resultados equivalentes ao longo do tempo.

## ETAPA 08 — FACTORY E RUNTIME

Portar:

- BaseFactory.
- Construção de armaduras.
- Displays e slots.
- Substituição de skins.
- Substituição de animações.
- Texturas.
- Armaduras aninhadas.

Conclusão: construção e atualização de personagens reais validadas.

## ETAPA 09 — RENDERIZAÇÃO

Implementar a integração Lua necessária para reprodução gráfica.

Usar LÖVE quando apropriado, separando o adaptador da lógica do motor.

Verificar:

- Sprites.
- Atlas.
- Meshes.
- Deformações.
- Transformações.
- Transparência.
- Ordem de desenho.
- Animações.
- Atualização gráfica.

Conclusão: resultados gráficos comparáveis com uma referência original.

## ETAPA 10 — INTEGRAÇÕES

Auditar os contratos das integrações oficiais do repositório DragonBonesJS.

Preservar as responsabilidades funcionais relevantes e registrar as adaptações necessárias ao ambiente Lua.

Não declarar backends completos apenas porque o backend LÖVE funciona.

Conclusão: matriz explícita de cobertura e equivalência para as integrações.

## ETAPA 11 — TESTES EXTERNOS

Utilizar personagens, animações e exportações reais, com diferentes complexidades.

Validar:

- IK.
- PathConstraint.
- Animação.
- Mesh.
- FFD.
- Mistura de animações.
- Skins.
- Eventos.
- Casos extremos.

Conclusão: comparações reais documentadas.

## ETAPA 12 — AUDITORIA FINAL

Revisar novamente cada arquivo original e seu correspondente Lua.

Verificar que nenhum comportamento obrigatório foi omitido.

Executar todos os testes.

Conferir a matriz de cobertura.

Conclusão: somente declarar 100% se todas as condições de equivalência forem satisfeitas.

---

# 9. PROCEDIMENTO OBRIGATÓRIO POR ARQUIVO

Para cada arquivo funcional:

### Fase A — Leitura

- Ler o original.
- Ler o Lua existente, caso exista.
- Ler os módulos relacionados relevantes.
- Identificar contratos, estados e dependências.

### Fase B — Comparação

- Verificar métodos.
- Verificar argumentos.
- Verificar retornos.
- Verificar propriedades.
- Verificar condições.
- Verificar loops.
- Verificar efeitos colaterais.
- Verificar erros e casos-limite.

### Fase C — Implementação

- Traduzir o comportamento original.
- Preservar a lógica.
- Evitar abstrações desnecessárias.
- Documentar adaptações específicas de Lua.

### Fase D — Validação

- Executar o DragonBonesJS de referência.
- Executar a versão Lua.
- Fornecer entradas equivalentes.
- Comparar os resultados.
- Registrar diferenças.

### Fase E — Persistência

- Atualizar o inventário.
- Atualizar o status.
- Registrar testes e evidências.
- Criar commit.
- Publicar no GitHub.
- Confirmar a publicação.

Nenhum desses passos pode ser substituído por uma afirmação sem evidência.

---

# 10. TESTES E PROVAS DE EQUIVALÊNCIA

Os testes devem utilizar o DragonBonesJS oficial como oráculo.

Comparar, conforme o caso:

- Valores numéricos.
- Matrizes.
- Estados internos relevantes.
- Sequências de eventos.
- Ordenação.
- Resultados de parsing.
- Transformações.
- Frames de animação.
- Dados geométricos.
- Pixels renderizados.

Executar em Lua 5.4 e LuaJIT quando aplicável.

Utilizar tolerâncias numéricas explícitas e justificadas quando diferenças de representação impedirem comparação exata.

Não aumentar tolerâncias apenas para esconder erros.

Não alterar expectativas até que o teste passe sem verificar o comportamento upstream.

Não remover cenários que revelem bugs.

Não utilizar screenshots artificiais como prova de renderização real.

**TODO RESULTADO DECLARADO DEVE CORRESPONDER A UM TESTE EFETIVAMENTE EXECUTADO.**

Se o ambiente não permitir executar determinado teste, informar que ele não foi executado.

Não declarar sucesso com base em inspeção estática.

---

# 11. PROTEÇÃO CONTRA ERROS DO AGENTE

Estas regras são obrigatórias.

## NÃO INVENTAR RESULTADOS

Não afirmar:

- "Testei" sem executar.
- "Corrigi" sem modificar o arquivo.
- "Enviei" sem confirmar o push.
- "Merge realizado" sem confirmação do GitHub.
- "CI aprovada" sem verificar os jobs.
- "100% equivalente" sem auditoria integral.

## NÃO ALTERAR O QUE FUNCIONA SEM NECESSIDADE

Quando uma implementação estiver demonstravelmente equivalente ao original, preservá-la.

Qualquer modificação posterior deve possuir justificativa, comparação e regressão.

## NÃO FAZER CORREÇÕES EM MASSA SEM ANÁLISE

Se vários arquivos apresentarem problemas:

1. Identificar as divergências.
2. Determinar as dependências.
3. Corrigir de maneira controlada.
4. Executar testes.
5. Registrar cada alteração.

## NÃO ESCONDER BLOQUEIOS

Se não souber como portar determinado método:

- Não improvisar.
- Não pular silenciosamente.
- Não substituir por um stub permanente.
- Não declarar como concluído.
- Registrar o impedimento e o comportamento esperado.

## NÃO TOMAR DECISÕES AUTORAIS

O proprietário do Bono-Lua decide sobre mudanças de escopo.

O agente pode tomar decisões técnicas necessárias à implementação autorizada, desde que respeitem a fonte original.

Mudanças estruturais que afetem a missão exigem autorização explícita.

---

# 12. CONTROLE DE PROGRESSO

Criar e manter:

`docs/PORTING_STATUS.md`

`docs/UPSTREAM_INVENTORY.md`

`docs/PORTING_MAP.md`

`docs/ROADMAP.md`

`docs/DIFFERENCES.md`

`docs/VALIDATION.md`

`docs/DECISIONS.md`

Cada documento deve possuir informações objetivas, rastreáveis e atualizadas.

A cobertura deve distinguir:

1. **Inventariado:** conhecido, ainda não implementado.
2. **Implementado:** código Lua existente, ainda não validado integralmente.
3. **Validado isoladamente:** testes diferenciais locais aprovados.
4. **Validado em integração:** comportamento confirmado em runtime real.
5. **Pendente ou divergente:** funcionalidade incompleta ou incorreta.

Não usar a quantidade de arquivos traduzidos como único indicador de progresso.

Não confundir cobertura de código com equivalência funcional.

Não apresentar porcentagens inventadas.

---

# 13. SISTEMA DE CONTINUIDADE

O desenvolvimento deve sobreviver à perda completa do contexto da conversa.

Qualquer agente novo deverá conseguir continuar exclusivamente a partir do GitHub.

Para isso, manter o arquivo:

`docs/NEXT_STEPS.md`

Esse arquivo deve registrar:

- Último commit confirmado.
- Branch de trabalho.
- Commit upstream fixado.
- Última etapa concluída.
- Arquivos em desenvolvimento.
- Testes aprovados.
- Testes pendentes.
- Divergências conhecidas.
- Próxima unidade de trabalho.
- Comandos necessários para continuar.

**AO RETOMAR, LER ESSE ARQUIVO, OS DOCUMENTOS DE ESTADO E OS CÓDIGOS REAIS DOS DOIS REPOSITÓRIOS.**

Nunca tratar uma descrição anterior como substituta da leitura do código.

---

# 14. POLÍTICA DE COMMITS E PRS

Trabalhar em branches rastreáveis.

Cada PR deve possuir:

- Objetivo definido.
- Arquivos originais de referência.
- Arquivos Lua alterados.
- Comparação funcional.
- Testes executados.
- Resultados.
- Pendências.
- Riscos conhecidos.

Não integrar PRs com verificações obrigatórias falhando.

Não publicar grandes conjuntos de mudanças não relacionadas que dificultem a revisão.

Não fazer merge automático de alterações destrutivas.

Não modificar a `main` diretamente durante a reconstrução.

O backup anterior deve permanecer disponível.

---

# 15. CRITÉRIOS PARA DECLARAR 100%

A reconstrução somente poderá receber a classificação de 100% quando:

1. Todo o escopo funcional original estiver catalogado.
2. Os comportamentos obrigatórios estiverem implementados.
3. As adaptações necessárias estiverem documentadas.
4. Os métodos e contratos públicos estiverem validados.
5. Os formatos de dados funcionarem.
6. As animações produzirem resultados equivalentes.
7. As constraints produzirem resultados equivalentes.
8. A renderização estiver comprovada.
9. As integrações estiverem cobertas conforme o inventário.
10. Os testes de regressão estiverem aprovados.
11. Não houver divergências funcionais conhecidas pendentes.
12. A documentação coincidir com o código efetivamente publicado.

Se existir qualquer impedimento técnico que inviabilize equivalência exata, declarar explicitamente a limitação.

**NUNCA DECLARAR 100% APENAS PARA ENCERRAR O TRABALHO.**

---

# 16. FORMATO DO RELATÓRIO DE CADA ETAPA

Ao concluir uma unidade de trabalho, apresentar:

**Objetivo:** o que foi implementado.

**Fonte original:** commit e caminhos do DragonBonesJS.

**Arquivos Lua:** caminhos modificados.

**Comparação:** quais diferenças foram examinadas.

**Testes:** comandos realmente executados e resultados.

**Divergências:** problemas comprovados.

**Pendências:** trabalho restante.

**GitHub:** branch, commit e PR verificados.

**Próximo passo:** objetivo seguinte conforme a dependência real do código original.

Não utilizar frases genéricas como "tudo funciona" sem evidências.

---

# 17. INSTRUÇÃO FINAL E PERMANENTE

Você não tem autorização para reinterpretar a missão.

Você não tem autorização para transformar o Bono-Lua em um projeto diferente.

Você não tem autorização para substituir o DragonBonesJS por uma implementação própria.

Você deve:

1. Trabalhar no repositório Bono-Lua.
2. Consultar sempre o DragonBonesJS oficial.
3. Ler os arquivos reais de ambos os repositórios antes de alterá-los.
4. Fazer a reconstrução a partir de uma branch limpa e com backup confirmado.
5. Seguir a arquitetura e os comportamentos do upstream.
6. Testar sistematicamente a equivalência.
7. Publicar todo o progresso permanente no GitHub.
8. Documentar resultados, falhas e impedimentos.
9. Nunca inventar funcionalidades ou declarações de sucesso.
10. Prosseguir até completar o escopo verificável, sem declarar concluído aquilo que não foi comprovado.

**FONTE ÚNICA:** https://github.com/DragonBones/DragonBonesJS

**DESTINO ÚNICO:** https://github.com/SrTristeSad/Bono-Lua

**MISSÃO ÚNICA:** RECONSTRUIR O BONO-LUA EM LUA, COM FIDELIDADE FUNCIONAL INTEGRAL AO DRAGONBONESJS OFICIAL.

**O PROJETO DEVE SER CONSTRUÍDO COM EVIDÊNCIAS, NÃO COM SUPOSIÇÕES.**

## PRIMEIRA AÇÃO

Verifique o estado real dos dois repositórios.

Confirme o commit fixado do DragonBonesJS.

Confirme a revisão atual do Bono-Lua.

Crie e verifique o backup remoto.

Prepare a branch limpa de reconstrução.

Construa o inventário original.

Somente depois comece a tradução sistemática dos módulos.

Não execute nenhuma exclusão destrutiva fora da branch de reconstrução.

Não afirme que realizou operações não executadas.

**COMECE PELA ETAPA 00 E SIGA O MAPA ATÉ A VALIDAÇÃO INTEGRAL.**