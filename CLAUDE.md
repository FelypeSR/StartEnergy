# StartEnergy — CLAUDE.md

## Visão geral do projeto

**StartEnergy** é um jogo educativo sobre eletricidade, desenvolvido em Flutter, com destino à Google Play Store (qualidade de produção desde o início).
Orientação **landscape** travada. Telas de início e menu já implementadas; gameplay a seguir.

## Stack técnica

- **Framework:** Flutter (Dart SDK ^3.10.1)
- **Versão:** 1.0.0+1
- **Plataformas alvo:** Android, Web, Windows
- **Linting:** `flutter_lints ^6.0.0`
- **Ícones:** Material Design + Cupertino Icons

## Dependências atuais

- `cupertino_icons: ^1.0.8`
- `audioplayers: ^6.8.1` — música de fundo/cutscene (loop) e efeitos de toque
- `flutter_screenutil: ^5.9.3` — escala adaptativa de tela (estilo Canvas Scaler
  do Unity). Referência de design: **732×412** (landscape 16:9), definida em
  `StartEnergyApp.designSize` e aplicada via `ScreenUtilInit` no `main.dart`.
  **Convenção: toda dimensão de UI usa `.r` (tamanhos/espaçamentos) e `.sp`
  (fontes) — nunca dp fixo.** Em telas ≥412dp de altura a escala é 1.0 (layout
  pleno); menores encolhem proporcionalmente. Alturas "de cena" (ex.: sprite da
  cutscene) continuam em fração da tela (`screenHeight * x`).

## Estrutura do projeto

```
lib/
  main.dart                       # entry point: trava landscape, ScreenUtilInit (732×412),
                                   #   navegação temporária via navigatorKey
  core/
    app_colors.dart               # paleta (menuBlue #1E90FF, acentos elétricos)
    app_assets.dart               # caminhos de assets
    characters.dart               # poses dos sprite sheets dos guias (LinaPose; 6 colunas)
    audio_controller.dart         # singleton: música do menu + música de CENA (loop) + SFX.
                                   #   startSceneMusic(asset)/stopSceneMusic(asset): cutscene e
                                   #   fases trocam a música pausando a do menu; o stop só age
                                   #   se a cena ainda for a dona (transições não se derrubam).
                                   #   mudo (enabled) afeta SÓ a música; SFX sempre toca e
                                   #   não rouba foco de áudio (toque não pausa a música)
    widgets/
      game_background.dart         # fundo sala de aula + scrim (reutilizado)
      brand_wordmark.dart          # marca "StartEnergy" itálica
      sound_button.dart            # botão azul + som de toque
      sound_toggle_button.dart     # liga/desliga som
      speech_balloon.dart          # balão de fala DESENHADO (CustomPainter + rabicho)
      sheet_sprite.dart            # mostra UMA coluna de um sprite sheet horizontal
  features/
    splash/splash_screen.dart      # "toque para continuar" → inicia música + menu
    menu/menu_screen.dart          # JOGAR / Fases / Créditos / Sair + toggle de som
    cutscene/
      cutscene_frame.dart          # modelo de 1 quadro (sprite + fala + trims do sheet)
      cutscene_script.dart         # roteiro da intro (Link; falas ainda PROVISÓRIAS)
      cutscene2.dart               # roteiro da cutscene 2 (Lina apresenta a Lei de Ohm;
                                   #   falas PROVISÓRIAS — TODO(falas))
      cutscene_screen.dart         # tela: fundo + personagem + balão (digitação) + Pular + mudo;
                                   #   toca cutscene.mp3 (loop) e SFX de toque na tela
    tutorial/
      tutorial_prompt.dart         # enum Particle (+ asset da carta) e TutorialPrompt (dica+resposta)
      tutorial_script.dart         # ARQUIVO EDITÁVEL: falas do Link (intro/play/done) e dicas
                                   #   do painel (falas ainda PROVISÓRIAS — TODO(falas))
      tutorial_screen.dart         # tutorial do quiz: intro (balões) → cartas CAEM em ordem
                                   #   sorteada → toque na ordem das dicas → fala final;
                                   #   painel risca dica acertada, carta errada balança,
                                   #   pausa (dialog c/ som + sair), toca song_level1.mp3
    loading/
      phase_loading_screen.dart    # loading entre fases: fundo + Lottie (loading_phase.json)
                                   #   + minDuration/onFinished
    level1/
      quiz_models.dart             # QuizQuestion, AnswerResult, shuffledOrder, starsForCorrect
                                   #   (tudo certo → 3★ · ≥ metade → 2★ · ≥ 1 acerto → 1★ · 0 → 0★)
      quiz_script.dart             # ARQUIVO EDITÁVEL: as 5 questões do Quiz 1 (Questsquiz.md)
      quiz_screen.dart             # Quiz 1: alternativas re-sorteadas (anti-decoreba), avança
                                   #   sempre sem feedback; no fim mostra _QuizResult (estrelas
                                   #   com bounce + Continuar) e onFinished recebe os resultados
      leideohm_screen.dart         # fase Lei de Ohm (V = R · I): Lina + balão (ProfessorWidget);
                                   #   mecânica da fórmula PENDENTE — toque conclui (provisório)
assets/
  images/backgroundgame.png        # fundo de sala de aula
  images/Link.png                  # SPRITE SHEET do personagem-guia: 1536×1024 = 3 poses
                                   #   lado a lado (512×1024 cada): 0 acenando · 1 pensativo · 2 apresentando
                                   #   fundo transparente, com folga lateral entre as poses (sem respingo)
  images/lina.png                  # SPRITE SHEET da Lina (professora-guia): 2526×487 = 6 poses
                                   #   (421×487 cada): 0 acenando · 1 surpresa · 2 comemorando ·
                                   #   3 neutra · 4 rindo · 5 explicando — células justas, sem trims
  images/backgroundlevel1.png      # fundo do Quiz 1
  images/loading_phase.json        # animação Lottie da tela de loading
  images/proton.png, eletron.png, neutron.png  # cartas de partícula (202×233; tutorial e Quiz 1)
  audio/backgroundsong.mp3         # música de fundo (menu)
  audio/cutscene.mp3               # música própria da cutscene (loop)
  audio/song_level1.mp3 (e 2, 3)   # músicas das fases; a 1 também toca no tutorial
  audio/touch.mp3                  # SFX de toque em botão
  audio/touchscene.mp3             # SFX de toque na tela durante a cutscene
test/test_app.dart                 # helper: envolve widgets no ScreenUtilInit (obrigatório nos testes)
test/widget_test.dart              # widget tests (splash/menu)
test/cutscene_test.dart            # testes da cutscene (avanço, onFinished, Pular)
test/tutorial_test.dart            # testes do tutorial (intro, ordem certa/errada, conclusão)
test/small_screen_test.dart        # regressão de telas pequenas (568×320, 640×360, 732×412):
                                   #   menu sem rolagem, splash sem sobreposição, balão fora do sprite
```

## Comandos úteis

```bash
flutter run                  # rodar no dispositivo/emulador padrão
flutter run -d chrome        # rodar na web
flutter run -d windows       # rodar no Windows
flutter test                 # rodar testes (usar para validar — ver nota abaixo)
flutter analyze              # análise estática (QUEBRADO neste ambiente: o caminho com
                             # acento/espaço corrompe o analysis server; validar via flutter test)
flutter build apk --release  # APK de teste (assinado com chave de DEBUG; não serve p/ publicar)
flutter pub get              # instalar dependências
flutter pub add <package>    # adicionar dependência
```

## Contexto do jogo

Jogo educativo de eletricidade em **3 blocos lineares** (sem árvore binária — fluxo não é adaptativo):

1. **Quiz 1** — opções em **imagem vetorizada (SVG)**; a rotação das imagens muda a cada passagem pelo estágio (anti-decoreba).
2. **Quiz 2** — formato a definir.
3. **Drag & Drop** — montar circuitos elétricos.

- O quiz **avança independente de acerto/erro**; os resultados são gravados e a **revisão dos erros acontece só no fim (endphase)** — decisão para manter o jogo polido durante a partida.

### Cutscene de introdução (tutorial/contexto)

- Cena baseada em **quadros** (`CutsceneFrame`): cada toque revela a fala inteira (se ainda "digitando") ou **avança** o quadro, trocando a pose do personagem e a fala. Acabaram as falas (ou botão **Pular**) → chama `onFinished`.
- **Esquema de sprite sheet:** os personagens vêm em sheets horizontais (poses lado a lado, mesma largura). Cada `CutsceneFrame` referencia o sheet (`characterSprite`), o total de colunas (`spriteColumns`) e qual pose mostrar (`spriteIndex`). O widget `SheetSprite` recorta a coluna `index` com `CustomPaint` + `Canvas.drawImageRect` (sub-região exata da `ui.Image`). Aceita `sideTrim`/`topTrim`/`bottomTrim` (frações da célula) para **aparar as bordas**. O sheet atual (`Link.png`) já tem folga lateral entre as poses (sem respingo → `sideTrim 0`); o desenho ocupa as linhas ~18%–67% da célula, então a cutscene usa `topTrim: 0.17` + `bottomTrim: 0.31` para a caixa do sprite corresponder ao desenho visível (pés no chão, topo na cabeça). Hoje só o `Link.png` (3 colunas) é usado.
- Balão é **desenhado** (não é sprite); fundo usa o `GameBackground` default; texto renderizado com efeito máquina de escrever.
- **Layout anti-sobreposição:** balão e personagem dividem a tela num `Row` — balão `Expanded` à esquerda (alinhado ao topo/direita, rabicho apontando p/ o personagem), personagem na coluna da direita ("no chão", altura `screenHeight * 0.62`). Assim o balão nunca cobre o rosto, em qualquer tamanho de tela ou comprimento de fala (garantido por `small_screen_test.dart`).
- Otimizações: `precacheImage` de todos os sprites, `gaplessPlayback` (sem flash na troca), `AnimatedBuilder` isolando o rebuild só no balão.
- **Áudio:** ao entrar, toca `cutscene.mp3` em loop e **pausa** a música do menu; ao sair (fim/Pular), retoma o menu. Cada toque na tela dispara `touchscene.mp3` (não pausa a música). Botão de **mudo** no canto superior direito (afeta só a música).
- **Provisório:** os sprites já são finais (`Link.png`); **as falas** ainda são placeholders — ver `TODO(falas)` em `cutscene_script.dart`. A cutscene **deveria tocar só na 1ª vez** (precisa de `shared_preferences`), mas isso ainda não foi ligado.

- **Fluxo atual de telas:** `SplashScreen` → `MenuScreen` → **JOGAR** → `CutsceneScreen` (Link) → `TutorialScreen` → loading → `QuizScreen` (Quiz 1 + estrelas) → `CutsceneScreen` (Lina, `linaCutscene`) → loading → `LeiDeOhmScreen` → volta ao menu. Encadeado em `MenuScreen._startPlay` e métodos `_to*` (um por etapa), via `pushReplacement` — provisório até o `AppRouter`.
- **Trims por quadro:** `CutsceneFrame` carrega `sideTrim/topTrim/bottomTrim` do sheet (Link precisa: 0.17/0.31; Lina não), repassados ao `SheetSprite` pela `CutsceneScreen` — a mesma tela serve qualquer personagem.

### Tutorial (antecede o level 1 — quiz de cartas)

- 3 atos em `TutorialScreen`: **intro** (balões do Link, toque avança) → **play** (painel de dicas numeradas + as 3 cartas de partícula CAEM com stagger/bounce em ordem SORTEADA; tocar na ordem das dicas marca o selo 1/2/3 e risca a dica; carta errada balança) → **done** (fala final; toque chama `onFinished`).
- Layout no mesmo esquema da cutscene: `Row` com a coluna do quiz (painel + cartas) e a coluna do guia (balão + Link `0.42*altura`) — sem sobreposição por construção.
- **Falas/dicas são editáveis em `tutorial_script.dart`** (mesmo padrão do `cutscene_script.dart`; balão estreito → falas curtas). Sorteio injetável (`random`) p/ testes determinísticos.

## Próximos passos (TODO)

- [x] **Cutscene de introdução** — quadros (sprite + fala), balão desenhado, digitação, Pular, testes (`cutscene_test.dart`).
- [ ] **Cutscene — finalizar:** trocar falas/sprites provisórios (`TODO` em `cutscene_script.dart`), ajustar visual (posição do personagem, estilo do balão, velocidade), e fazer tocar **só na 1ª vez** via `shared_preferences`.
- [x] **Tutorial do quiz** (`TutorialScreen`) — intro com balões, cartas caindo em ordem sorteada, toque na ordem das dicas, pausa. Falas provisórias (`TODO(falas)` em `tutorial_script.dart`).
- [ ] **Definir o que "Fases do jogo" abre** no menu (seleção direta dos blocos vs. trilha de progresso com fases bloqueadas).
- [ ] **Criar o `AppRouter`** e substituir a navegação temporária (`navigatorKey` em `main.dart` + push provisório do JOGAR→cutscene→tutorial).
- [ ] Implementar o **level 1 / Quiz 1** (cartas de partícula; o tutorial deve navegar p/ ele no `onFinished`) e o `core/game_controller.dart` (pontuação + `List<AnswerResult>` para a endphase).
- [ ] Persistir o estado liga/desliga som (`shared_preferences`) — hoje é só em memória.
- [ ] Antes de publicar: migrar o **Kotlin Gradle Plugin** (aviso no build), signing de release, ícone e splash nativa.

## Convenções de código

- Dart com null safety ativado
- `flutter_lints` para estilo — seguir as regras sem desativar salvo necessidade justificada
- Organizar em `lib/features/` conforme o projeto crescer (feature-first)
- Sem comentários redundantes; apenas quando o "porquê" não é óbvio

## Notas de desenvolvimento

- Projeto privado (`publish_to: none`)
- Repositório Git inicializado, branch principal: `main`
