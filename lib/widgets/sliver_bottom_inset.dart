import 'package:flutter/widgets.dart';

/// Хвост списка под плавающими мини-плеером и навигацией: тело оболочки
/// уходит под них, и Scaffold кладёт их высоту в нижний отступ.
class SliverBottomInset extends StatelessWidget {
  const SliverBottomInset({super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
  );
}
