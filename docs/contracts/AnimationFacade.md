# Facade público de Animation

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, Animation.ts. Lidos os corpos restantes: _fadeOut, reset, stop, playConfig, play, fadeIn, seis gotoAndPlay/Stop, getState, hasAnimation, getStates, getters e setter animations. Consultado o backup Lua cd4206a8. Lifecycle/getBlendState/advanceTime foram portados na etapa StateAdvance.

## Comportamento preservado

playConfig valida o nome antes de modificar a configuração; ausência emite aviso no stderr e retorna nil. Single retorna o primeiro estado ainda não faded com o mesmo modelo e layer, antes da normalização. Os seis modos de fade conservam os filtros por camada/grupo e ignoram estados com parent. Configuração é modificada no lugar: primeiro estado força fade zero, sentinela timeScale<=-100 usa 1/scale, position usa resto com sinal, fim exato recua 0.000001, duração pode ser recortada e duração zero volta a -1. O ramo de posição negativa conserva duration-remainder, mesmo que ultrapasse a duração. Não há correção desse comportamento upstream.

Estados são criados pelo pool e ordenados por layer, com inserção estável nas igualdades. Child Armature elegível recebe fadeIn do mesmo nome. Nós de animação criam/reutilizam filhos via Single, desativam ações/reset de pose, pausam o filho, ligam timelines reais e reposicionam o parent antes dele. A configuração compartilhada pode ser alterada pelas chamadas recursivas, como no original. O último estado volta a ser o parent ao terminar.

play sem nome escolhe o default quando não há último estado, retoma o último estado pausado e incompleto, ou reproduz novamente pelo nome do estado. Falha com nome explícito conserva o último estado anterior como retorno de play; playConfig/fadeIn/goto retornam nil na falha. getState pesquisa de trás para frente, por nome do estado e layer opcional. getStates e getters de nomes/mapa devolvem as coleções existentes. animations copia os modelos sem adquiri-los, conserva identidade das coleções, e atribuição do mesmo mapa é no-op. animationConfig limpa e devolve a mesma instância a cada leitura. reset devolve estados imediatamente, limpa a configuração/lista e o último estado; o registro de modelos permanece.

## Representação e fronteiras

Arrays usam JSArray com length lógico, índices públicos base zero e armazenamento Lua base um. Inserção/remoção desloca os elementos sem usar o comprimento físico de tabela. Os mapas recebidos por animations devem usar JSMap.new (ad.animations já usa); a ordem de chaves inteiras e inserção das demais é preservada. Propriedades somente com getter rejeitam escrita, como JS em modo estrito. Referências null/undefined opcionais viram nil. O aviso usa stderr em vez de console.warn; conteúdo semântico e contagem são preservados, não a formatação da console do host. Nomes de protótipo, propriedades herdadas, coerções arbitrárias, reentrância e ciclos nos nós de animação ficam fora deste domínio; a recursão não ganhou um guard que mudaria o original.

## Validação

animationfacade_differential transpila os blobs do pin e compara 839 cenários/2.325.490 colunas por VM Lua 5.4/LuaJIT. Seis exceções esperadas são as escritas readonly; zero aproximações. Compara retornos/identidades, ordem dos estados e pais, configuração externa/compartilhada, tempos/poses/fades/pool, buscas/status, nomes/mapa, filas de eventos e callbacks reais de Bone/Surface/Slot/IK/core via fixture playback_ske.json. Matriz trigonométrica não recebe nova tolerância nem é comparada nesta suíte; os contratos específicos anteriores continuam vigentes.

A grade cruza seis modos, três layers, cinco posições, três durações e três escalas de tempo. Casos adicionais exercitam controller/filhos reutilizados/ausentes, seis goto, progresso negativo/NaN, modelo com frameCount zero/scale zero, nome ausente/vazio, nome customizado/duplicado, ausência de default, estado faded, conclusão, mapa com chaves numéricas e child Armature real com/sem inheritAnimation/modelo/estado existente. Montagem de Armature continua explícita e o renderer é uma subclasse observadora dos 14 hooks; não há controlador substituto.

Oito mutações rejeitadas: fade omitido, Single desativado, ordem de layer invertida, posição negativa alterada, configuração não limpa, conversão de frame alterada, propagação para child omitida e parent não reposicionado. Regressão stateadvance refeita nas duas VMs. CI executa todas as 52 suítes e vinte exemplos por VM.

## Exemplo e próxima etapa

`lua5.4 examples/run.lua animation` (ou LuaJIT) usa play para criar o estado, stop/play para retomar, gotoAndStopByFrame(12) para chegar a 0.50 s pausado, fadeIn('alt',.25,0) para chegar a progresso 0.50 após delta .125 e reset para zerar os estados. O exemplo playback também passou a usar play, sem registro protegido manual. Core real gerencia os objetos adiados; backend apenas observa callbacks, sem desenho.

Todos os corpos de Animation.ts estão representados no domínio declarado. Atualização posterior: Armature foi integrado e validado em [ArmatureRuntime.md](ArmatureRuntime.md). Factories e backends gráficos ainda faltam para uma API completa de carregamento e reprodução. Esse marco não significa paridade integral do DragonBonesJS.
