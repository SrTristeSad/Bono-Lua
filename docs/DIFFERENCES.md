# Adaptações e divergências

Não existe runtime nesta branch limpa. Nenhuma equivalência funcional foi comprovada.

Pontos que exigem decisões baseadas no original: classes/herança, null/undefined, índices zero, arrays esparsos e tipados, identidade de buffers, números especiais e zeros assinados, remainder, stringificação, relógio e despacho de eventos.
Não adotar automaticamente as adaptações do backup: ler ambos os arquivos e executar o oráculo antes de aproveitar código.

APIs de plataforma dos backends oficiais permanecem indisponíveis até implementação e validação de um contrato Lua correspondente. Um adaptador LÖVE não comprova todos os backends.
