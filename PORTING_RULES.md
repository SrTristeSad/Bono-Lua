# REGRAS PERMANENTES — BONO-LUA: PORTE DO DRAGONBONES ORIGINAL

Repositório: https://github.com/SrTristeSad/Bono-Lua

Objetivo: reconstruir o DragonBones original em Lua, preservando estrutura, métodos, algoritmos e comportamento. Primeiro portar e verificar. SOMENTE DEPOIS discutir melhorias.

1. Somente Lua para o motor, aplicação e editor. LÖVE pode fornecer janela, GPU e entrada. Nunca reimplementar a lógica em JS/TS, Python ou C++.
2. Fixar o runtime fonte em DragonBones/DragonBonesJS, commit 64b6c69ae35777c2404be68c9192e2c56906079e; abrir cada arquivo TypeScript original antes de portar.
3. Portar arquivo a arquivo e método a método, sem atalhos, reescritas por conveniência, recursos inventados, alteração de regras ou simplificações. Manter classes, nomes, contratos, retornos, mutabilidade, cálculos, peculiaridades e casos especiais. Adaptar somente sintaxe/linguagem/infraestrutura e registrar cada diferença.
4. Os módulos Lua antigos são protótipos NÃO equivalentes. Não os contabilizar como porte completo. Separar a estrutura do original de adaptadores LÖVE.
5. Antes de trabalhar, ler docs/PORTING_STATUS.md, este arquivo e os arquivos do repositório. Manter uma fonte original fixa e licença MIT atribuída.
6. Portar em ordem de dependência, garantir testes de casos normais, limites e divergências; quando possível, comparar resultados com a versão original. Não dizer 1:1 se não estiver comprovado.
7. O código DragonBonesJS contém o RUNTIME. Para portar o EDITOR ORIGINAL, localizar e validar separadamente o código do editor, sua versão e licença; não supor que o runtime inclui o editor.
8. Continuar de verdade no GitHub: editar código Lua, testar CI, corrigir falhas, integrar via PR com segurança. Não responder somente com planos.
9. Após cada alteração, atualizar docs/PORTING_STATUS.md: fonte, destino, o que foi efetivamente portado, testes, divergências, o que falta, SHA do commit.
10. Quando o usuário disser "continua o processo", executar automaticamente a próxima parte do porte original, sem mudar tecnologias nem fazer perguntas repetitivas.
11. Não começar melhorias, novas funcionalidades, Studio alternativo nem interface inventada até o porte original ser considerado concluído e validado.
12. Em cada resposta, declarar fatos verificáveis: links de commits/PR, CI aprovado ou pendente, e limites reais. Nunca afirmar conclusão 1:1 de partes não verificadas.

AGORA: consultar o status, escolher o próximo arquivo original exigido pela ordem de dependências, portar seu conteúdo para Lua e testar, sem desviar do objetivo.
