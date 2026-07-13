/// Constantes dos sprite sheets dos personagens-guia (poses por coluna).
///
/// Os sheets são horizontais (poses lado a lado, mesma largura) e exibidos
/// via `SheetSprite`.
library;

/// Poses do Link (`AppAssets.linkSprite`). O sheet tem folga lateral entre
/// as poses (sideTrim 0), mas o desenho ocupa as linhas ~18%–67% da célula —
/// repassar [topTrim]/[bottomTrim] ao `SheetSprite`/`CutsceneFrame`.
abstract final class LinkPose {
  static const int columns = 3;

  static const int acenando = 0;
  static const int pensativo = 1;
  static const int apresentando = 2;

  static const double topTrim = 0.17;
  static const double bottomTrim = 0.31;
}

/// Poses da Lina (`AppAssets.linaSprite`). As células são justas (folga
/// ≤ 3,5% em todas as bordas) — não precisam de trims.
abstract final class LinaPose {
  static const int columns = 6;

  static const int acenando = 0;
  static const int surpresa = 1;
  static const int comemorando = 2;
  static const int neutra = 3;
  static const int rindo = 4;
  static const int explicando = 5;
}
