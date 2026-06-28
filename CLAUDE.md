# StartEnergy — CLAUDE.md

## Visão geral do projeto

**StartEnergy** é um jogo físico sobre eletricidade, desenvolvido em Flutter.
O projeto está na fase inicial de desenvolvimento (scaffold limpo, `lib/main.dart` ainda vazio).

## Stack técnica

- **Framework:** Flutter (Dart SDK ^3.10.1)
- **Versão:** 1.0.0+1
- **Plataformas alvo:** Android, Web, Windows
- **Linting:** `flutter_lints ^6.0.0`
- **Ícones:** Material Design + Cupertino Icons

## Dependências atuais

Apenas as padrão do Flutter scaffold:
- `cupertino_icons: ^1.0.8`

## Estrutura do projeto

```
lib/
  main.dart          # ponto de entrada (vazio — a implementar)
test/
  widget_test.dart   # teste padrão de scaffold
android/             # configuração Android
web/                 # configuração Web
windows/             # configuração Windows
```

## Comandos úteis

```bash
flutter run                  # rodar no dispositivo/emulador padrão
flutter run -d chrome        # rodar na web
flutter run -d windows       # rodar no Windows
flutter test                 # rodar testes
flutter analyze              # análise estática
flutter pub get              # instalar dependências
flutter pub add <package>    # adicionar dependência
```

## Contexto do jogo

> **TODO:** Preencher com as regras, mecânicas, telas e fluxos do jogo conforme o projeto evoluir.
>
> Exemplo do que adicionar aqui:
> - Objetivo e mecânica central do jogo
> - Fluxo de telas (onboarding, gameplay, resultados)
> - Entidades principais (jogadores, circuitos, componentes elétricos, etc.)
> - Regras de negócio relevantes

## Convenções de código

- Dart com null safety ativado
- `flutter_lints` para estilo — seguir as regras sem desativar salvo necessidade justificada
- Organizar em `lib/features/` conforme o projeto crescer (feature-first)
- Sem comentários redundantes; apenas quando o "porquê" não é óbvio

## Notas de desenvolvimento

- Projeto privado (`publish_to: none`)
- Repositório Git inicializado, branch principal: `main`
