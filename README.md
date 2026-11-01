# Bono-Lua — reconstrução compatível com DragonBonesJS

Projeto independente para recuperar primeiro o funcionamento do **DragonBones original** e depois construir um Studio de animação 2D simplificado.

## Estado atual: fase 3 — runtime original compilado e testado

- Fonte upstream: [DragonBones/DragonBonesJS](https://github.com/DragonBones/DragonBonesJS).
- Revisão fixa: `64b6c69ae35777c2404be68c9192e2c56906079e` (2025-05-24).
- Runtime original: TypeScript compilado para JavaScript sem modificar o upstream.
- Testes automatizados: matrizes, classes, hierarquia de ossos, animações, relógio e importação de um exemplo real.
- Integração: [GitHub Actions](.github/workflows/dragonbones-original.yml), com build e testes em Node.js 20.

**Importante:** o runtime validado ainda não é o **editor visual**. O DragronBonesJS é a biblioteca de execução; a interface do editor será reconstruída separadamente. A reprodução visual de um personagem também não está concluída.

## Reproduzir

Pré-requisitos: Node.js >= 18, npm, Git e conexão de rede (para baixar as dependências originais).

```bash
npm run upstream:clone
npm run original:build
npm run original:verify
```

O script de download **não altera o original** e verifica o commit fixado em `upstream.lock.mjs`. O JavaScript compilado aparece em `dist/original/dragonBones.js`.

Para rodar apenas os testes, use `npm test`. Testes dependentes do código original são marcados como ignorados caso você ainda não tenha realizado o build; a CI executa os testes **após** compilar e verifica que todos foram executados.

## O que foi comprovado

- `ObjectDataParser` lê o personagem de teste do projeto e um exemplo autêntico do DragonBonesJS (20 ossos, 19 slots, animação `idle`).
- `Matrix` transforma coordenadas e executa a transformação inversa.
- `WorldClock` avança objetos animáveis registrados.
- Classes principais da API pública são carregadas.
- A CI compila o runtime original sem modificar os arquivos upstream.

Veja [docs/compatibilidade.md](docs/compatibilidade.md).

## Próximas etapas

1. Renderizar um personagem real usando um adaptador gráfico oficial do DragonBonesJS.
2. Reproduzir animações reais, com pausa, troca de animação e duração.
3. Validar skins, malhas, deformações, timelines e exportação.
4. Reconstruir interface equivalente ao editor clássico, com importação e edição.
5. **Somente depois**: rigging por silhueta, múltiplas perspectivas, ações de cena e exportação de vídeo/PNG.

## Licença e autoria

O runtime original DragonBonesJS é licenciado sob MIT, copyright DragonBones team e contribuidores (2012–2025). Reutilizações e distribuições devem preservar esses avisos. Outros recursos (demos, imagens e editores) têm de ser auditados separadamente antes de distribuição.

**Bono-Lua não é um projeto oficial DragonBones.**
