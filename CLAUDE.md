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
- `audioplayers: ^6.8.1` — música de fundo (loop) e efeitos de toque

## Estrutura do projeto

```
lib/
  main.dart                       # entry point: trava landscape, navegação temporária via navigatorKey
  core/
    app_colors.dart               # paleta (menuBlue #1E90FF, acentos elétricos)
    app_assets.dart               # caminhos de assets
    audio_controller.dart         # singleton: música de fundo + SFX (respeita liga/desliga)
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
      cutscene_frame.dart          # modelo de 1 quadro (sprite do personagem + fala)
      cutscene_script.dart         # roteiro = List<CutsceneFrame> (falas/sprites PROVISÓRIOS)
      cutscene_screen.dart         # tela: fundo + personagem + balão (digitação) + Pular
assets/
  images/backgroundgame.png        # fundo de sala de aula
  images/link_sprite.png           # SPRITE SHEET do personagem-guia: 1536×1024 = 3 poses
                                   #   lado a lado (512×1024 cada): 0 acenando · 1 pensativo · 2 apresentando
  images/proton.png, eletron.png, neutron.png  # cards de partícula (p/ Quiz 1)
  audio/backgroundsong.mp3         # música de fundo
  audio/touch.mp3                  # SFX de toque
test/widget_test.dart              # widget tests (splash/menu)
test/cutscene_test.dart            # testes da cutscene (avanço, onFinished, Pular)
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
- **Esquema de sprite sheet:** os personagens vêm em sheets horizontais (poses lado a lado, mesma largura). Cada `CutsceneFrame` referencia o sheet (`characterSprite`), o total de colunas (`spriteColumns`) e qual pose mostrar (`spriteIndex`). O widget `SheetSprite` recorta a coluna: `Align(widthFactor: 1/columns)` + `ClipRect`, com `alignX = -1 + 2*index/(columns-1)` (−1 = coluna da esquerda, +1 = da direita). Sheet só precisa ter colunas de largura igual. Hoje só o `link_sprite` (3 colunas) é usado.
- Balão é **desenhado** (não é sprite); fundo usa o `GameBackground` default; texto renderizado com efeito máquina de escrever.
- Personagem posicionado no **canto inferior direito** ("no chão"), altura `screenHeight * 0.72` (ajustável em `cutscene_screen.dart`).
- Otimizações: `precacheImage` de todos os sprites, `gaplessPlayback` (sem flash na troca), `AnimatedBuilder` isolando o rebuild só no balão.
- **Provisório:** falas e sprites são placeholders (todos usam `link_sprite`) — ver `TODO(falas)` / `TODO(sprites)` em `cutscene_script.dart`. A cutscene **deveria tocar só na 1ª vez** (precisa de `shared_preferences`), mas isso ainda não foi ligado.

- **Fluxo atual de telas:** `SplashScreen` (toque para continuar) → `MenuScreen` → **JOGAR** abre a `CutsceneScreen` (ligação **provisória, só p/ teste**: ao fim ela volta pro menu; depois deve seguir para o Quiz 1). Gameplay ainda não conectado.

## Próximos passos (TODO)

- [x] **Cutscene de introdução** — quadros (sprite + fala), balão desenhado, digitação, Pular, testes (`cutscene_test.dart`).
- [ ] **Cutscene — finalizar:** trocar falas/sprites provisórios (`TODO` em `cutscene_script.dart`), ajustar visual (posição do personagem, estilo do balão, velocidade), e fazer tocar **só na 1ª vez** via `shared_preferences`.
- [ ] **Definir o que "Fases do jogo" abre** no menu (seleção direta dos blocos vs. trilha de progresso com fases bloqueadas).
- [ ] **Criar o `AppRouter`** e substituir a navegação temporária (`navigatorKey` em `main.dart` + push provisório do JOGAR→cutscene) — após a cutscene, seguir para o **Quiz 1**.
- [ ] Implementar **Quiz 1** (cards de partícula `proton/eletron/neutron`; opções = alternativas) e o `core/game_controller.dart` (pontuação + `List<AnswerResult>` para a endphase).
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
