# API pública de factory e proxy

Fonte exclusiva de comportamento de motor: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts e PixiArmatureDisplay.ts. Lidos integralmente, com BaseFactory, Armature, IArmatureProxy e o dispatcher da dependência Pixi. Não se criou outro motor de animação: os métodos usam os parsers, modelos, Armature, Animation, clock e pool existentes.

## Conjunto portado

PixiFactory tem nove corpos: getter factory, construtor, _clockHandler, três hooks, buildArmatureDisplay, getTextureDisplay e soundEventManager. Os nove estão representados em love/Factory.lua. O parser passado ao construtor é preservado; o padrão compartilha uma instância de DragonBones/clock/eventManager entre factories. Os caches de dados/atlas continuam separados por factory, como no original. O singleton é criado sob demanda, e factory/soundEventManager são readonly.

buildArmatureDisplay monta pelo BaseFactory, registra a armadura no clock e retorna seu display; buildArmature não registra automaticamente. Falha de busca retorna nil. getTextureDisplay usa _getTextureData com o mesmo nome/default e flags autoSearch, retornando sprite apenas quando existe renderTexture. A Image continua do chamador.

PixiArmatureDisplay tem onze corpos: dbInit/dbClear/dbUpdate, dispose/destroy, quatro métodos de eventos e dois getters. O display é agora o proxy real usado por Armature.init, em vez de uma tabela local com hooks vazios. dispose limpa imediatamente a referência pública de armature, mas o core continua responsável pela devolução adiada ao pool; dbClear destrói os recursos do display, desliga filhos e remove listeners. disposeProxy permanece sem efeito, como no original. Ler animation após dispose falha como o getter original.

## Host e callbacks

LÖVE não tem PIXI.ticker.shared. O jogo chama factory:update(dt), em segundos, uma vez por frame para cada core distinto; não se substitui love.update do usuário automaticamente. _clockHandler conserva elapsedMS*passedTime*.001, recebendo elapsedMS explicitamente no adaptador. Factory.new(core) anterior continua válido; Factory.new(dataParser,core) também permite um core isolado. O padrão passa a ser compartilhado, acompanhando o original.

addDBEventListener(kind,listener,target) chama listener(target,event) em Lua. Se target for omitido/falsy em JS, o primeiro argumento é o próprio display/manager. Isso representa o this do callback original; funções de objeto podem ser passadas como objeto.metodo com o objeto como target. O payload é o EventObject real, não uma cópia. Eventos de som são encaminhados ao manager global; não é reprodução de áudio.

EventEmitter.lua adapta registro, remoção por função/contexto, once e emissão reentrante do host. Mantém a lista e o tamanho capturados no início do dispatch: remover outro listener não o retira da emissão já iniciada, e adicionar não o invoca nessa mesma emissão. Exceções propagam; once é removido antes da chamada. Strings arbitrárias, vazia e __proto__ são aceitas. O onEvent(kind,event) anterior permanece como extensão compatível, além dos listeners originais.

## Diagnóstico

O dbUpdate completo cria/reutiliza o drawer, desenha bones e trata Rectangle/Ellipse/Polygon, remove boxes ausentes e desliga o drawer quando debugDraw é desativado. Os comandos e os argumentos são os originais, sem corrigir a forma incomum como drawEllipse é chamado. Display agora aplica pivôs de setTransform e Graphics adapta os comandos para desenho vetorial no LÖVE. Isso não equivale a portar o renderer Pixi; a rasterização e joins dos vetores entre hosts não têm prova de igualdade de pixels neste checkpoint.

## Uso

Exemplo executável sem renderizador: `lua examples/public_factory.lua` (também LuaJIT). Ele carrega JSON, cria o display pela API pública, reproduz a animação, recebe eventos de frame/som e libera a armadura. Não monta bones, slots ou clocks manualmente. O exemplo gráfico `love .` também passou a usar buildArmatureDisplay e factory:update.

Num jogo LÖVE, carregue seus dados/atlas com parseDragonBonesData e parseTextureAtlasData, obtenha display=factory:buildArmatureDisplay(nome,dados), use display.animation:play(nomeAnimacao) e display:draw(x,y) no desenho. Os recursos gráficos e limites já documentados do backend permanecem aplicáveis.

## Verificação

publicfactory_differential compila as duas classes TypeScript originais junto do núcleo fixado e as executa com operações de plataforma observáveis. O emitter do oracle é o código real da dependência extraído do bundle Pixi do mesmo commit; não uma segunda reimplementação de listeners. A factory/proxy Lua usa o runtime real. São 44 cenários/8.941 colunas exatas em Lua 5.4 e LuaJIT: três formas de construtor, debug local/global/desligado, flip, imagens/boxes e oito casos de eventos. Observa getters readonly, core/clock compartilhados com caches separados, busca/texturas, registro automático, tempo, comandos e transforms de diagnóstico, frame/sound events e descarte. A prova é limitada a esses domínios, não a todo valor JS/host possível.

CI: 61 suítes e 23 exemplos de terminal por VM. Um smoke LÖVE real cria a armadura pela API, recebe eventos, desenha bones e três bounding boxes em Canvas e verifica a limpeza. As 94 capturas anteriores e seus critérios continuam. Não se infere sucesso da configuração; é necessário conferir a execução da CI.

O restante do porte continua no mesmo repositório e arquitetura. Outros backends oficiais, blends/filtros e uso integrado de assets externos ainda não são declarados concluídos; números de testes não medem percentual global.
