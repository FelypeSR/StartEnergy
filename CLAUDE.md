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
  features/
    splash/splash_screen.dart      # "toque para continuar" → inicia música + menu
    menu/menu_screen.dart          # JOGAR / Fases / Créditos / Sair + toggle de som
assets/
  images/backgroundgame.png        # fundo de sala de aula
  audio/backgroundsong.mp3         # música de fundo
  audio/touch.mp3                  # SFX de toque
test/widget_test.dart              # widget tests
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
- **Fluxo atual de telas:** `SplashScreen` (toque para continuar) → `MenuScreen`. Gameplay ainda não conectado.

## Próximos passos (TODO)

- [ ] **Definir o que "Fases do jogo" abre** no menu (seleção direta dos blocos vs. trilha de progresso com fases bloqueadas).
- [ ] **Criar o `AppRouter`** e substituir a navegação temporária (`navigatorKey` em `main.dart`) — ligar o botão **JOGAR** ao Quiz 1.
- [ ] Implementar **Quiz 1** (opções em SVG com rotação por passagem) e o `core/game_controller.dart` (pontuação + `List<AnswerResult>` para a endphase).
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
