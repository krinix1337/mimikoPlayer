import '../core/prefs/prefs.dart';

/// Размытие читается виджетами без Riverpod: значение обновляется в
/// `MimikoApp.build` при каждой смене настроек, как и `currentMotion`.
final class BlurSettings {
  const BlurSettings({this.bottom = 16, this.top = 20, this.cover = 24});

  final double bottom;
  final double top;
  final double cover;

  bool get hasBottom => bottom > 0;
  bool get hasTop => top > 0;
  bool get hasCover => cover > 0;

  factory BlurSettings.fromPrefs(Prefs prefs) => BlurSettings(
    bottom: prefs.blurBottom,
    top: prefs.blurTop,
    cover: prefs.blurCover,
  );
}

BlurSettings currentBlur = const BlurSettings();
