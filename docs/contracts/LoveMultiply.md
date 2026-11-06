# Multiply sobre Canvas no LÖVE

Atualização: texels semitransparentes em Screen/Multiply têm recorte específico em [LoveTextureAlpha.md](LoveTextureAlpha.md). Limites anteriores abaixo são históricos.

Referência: PixiSlot.ts de Pixi/4.x no commit DragonBonesJS 64b6c69ae35777c2404be68c9192e2c56906079e. O ramo Sprite passa BlendMode.Multiply para PIXI.BLEND_MODES.MULTIPLY=2. O ramo mesh continua ignorando a solicitação, como no original. O runtime de animação não recebe lógica de composição.

## Composição

O Pixi 4.8.9 usa os fatores DST_COLOR e ONE_MINUS_SRC_ALPHA: resultado=S*D+D*(1-S.a), inclusive no canal alpha. S é o texel premultiplicado multiplicado pelo tint/alpha empacotado pelo batcher. Mantém-se o empacotamento implementado para Screen: RGB arredondado, alpha truncado. Isso pode produzir RGB maior que alpha e impede substituir a fórmula por uma simples mistura multiply do LÖVE sem risco de saturação intermediária.

Antes de cada sprite Multiply, o adaptador copia integralmente o Canvas de destino para um Canvas privado do display. A cópia usa replace/premultiplied com transform identidade, shader/scissor/stencil/depth desativados e canais habilitados. Em seguida restaura o estado e o destino. O shader lê a cópia pelas coordenadas de pixel e aplica a fórmula original; o resultado é escrito com replace. Nunca lê e escreve a mesma textura simultaneamente. A sobreposição entre sprites usa uma nova cópia antes de cada desenho.

Shader e cópia são criados sob demanda, reutilizados, redimensionados quando o destino muda e liberados no destroy do display. A Image do chamador continua compartilhada e não é liberada. O draw conserva o estado gráfico do chamador. A cópia integral por sprite é um custo de desempenho conhecido; este checkpoint prioriza a fidelidade das cenas cobertas, sem declarar desempenho de produção.

## Contrato de uso

Exige um único Canvas 2D rgba8, MSAA=0 e DPI scale=1 ativo. Janela direta, MRT, outros formatos, MSAA e DPI são recusados explicitamente. Use newCanvas com essas opções, setCanvas antes de arm.display:draw e, ao apresentar o Canvas na janela, alpha/premultiplied. Essa preparação não é exigida para Normal/Add/Screen.

A demonstração `love .` prepara o Canvas automaticamente. N alterna Multiply e seleciona sprites; T alterna o atlas; M permite observar o ramo mesh, onde o blend solicitado continua ignorado. B alterna Screen e desliga Multiply. Esc fecha, Espaço pausa, R reinicia e F espelha.

## Verificação e limites

lovesprites_differential com argumento multiply usa o PixiSlot original compilado e probes de plataforma: 33 cenários/6.588 colunas exatas por VM Lua 5.4/LuaJIT. Cobre escalas, flip, alpha/tint, operações anteriores e troca Multiply→Screen→Normal→Multiply. Os diferenciais anteriores continuam como regressões.

O job gráfico acrescenta 18 cenas reais LÖVE/Mesa vs Pixi WebGLRenderer/Chromium. Dezesseis sprites combinam alpha 0/.25/.5/1, tint 1/.5 e atlas normal/rotacionado, com flip/ordem selecionados. Fundo de duas cores detecta leitura no eixo errado; quadrantes assimétricos do atlas detectam UVs incorretos; sobreposição verifica a atualização do snapshot. Uma cena desenha primeiro em Canvas menor e depois no tamanho final com a mesma armadura para exercitar a recriação do recurso. Dois casos de mesh verificam o comportamento original sem Multiply. Exigem-se 1.474.560 canais idênticos, sem tolerância nova. Capturas e multiply-result.json ficam no artefato da CI; configuração não equivale a execução aprovada. LÖVE não está disponível localmente, portanto a prova gráfica roda na CI real.

A CI sobe para 60 suítes e 22 exemplos por VM, mantendo as 44 capturas anteriores com seus critérios. A prova é limitada a texels opacos, nearest, fundos opacos e cenas descritas. Texels semitransparentes, destinos transparentes, filtragem complexa, stencil/depth personalizados, configurações recusadas e exports externos não foram validados. Outros blends e integrações oficiais continuam incompletos.
