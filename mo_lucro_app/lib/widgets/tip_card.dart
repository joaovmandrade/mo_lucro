import 'package:flutter/material.dart';
import '../core/theme.dart';

/// "Dica do Dia" card — exact Figma spec:
/// • bg #1C2333, radius 12dp
/// • Blue LEFT border accent: 3dp wide, #3B6EF5, full card height
/// • Layout: lightbulb emoji | text column | vertical 3-dot menu
/// • "Dica do Dia" label: orange/yellow #F5A623, 13sp semibold
/// • Body: white 12sp, max 2 lines
/// Swipe gesture cycles through tips.
class TipCard extends StatefulWidget {
  const TipCard({super.key});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  int _index = 0;

  static const _tips = [
    _Tip(
      body: 'Reserve 6 meses de gastos como reserva de emergência antes de investir.',
    ),
    _Tip(
      body: 'Diversifique: distribua entre ações, FIIs e renda fixa para reduzir risco.',
    ),
    _Tip(
      body: 'Aportes mensais regulares, mesmo pequenos, superam grandes aportes esporádicos.',
    ),
    _Tip(
      body: 'Reinvista seus dividendos. O tempo é seu maior aliado com juros compostos.',
    ),
    _Tip(
      body: 'Conheça seu perfil de risco antes de investir: Conservador, Moderado ou Arrojado.',
    ),
  ];

  void _next() => setState(() => _index = (_index + 1) % _tips.length);
  void _prev() => setState(() => _index = (_index - 1 + _tips.length) % _tips.length);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity != null) {
          d.primaryVelocity! < 0 ? _next() : _prev();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _buildCard(key: ValueKey(_index)),
      ),
    );
  }

  Widget _buildCard({Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: AppColors.bg3, // #1C2333
        borderRadius: BorderRadius.circular(AppRadius.md), // 12dp
      ),
      // ClipRRect so the blue left border stays clipped to rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Blue left border accent: 3dp, #3B6EF5 ──────
              Container(
                width: 3,
                color: AppColors.primary,
              ),

              // ── Card content ─────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lightbulb emoji
                      const Text('💡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),

                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dica do Dia',
                              style: TextStyle(
                                // Orange/yellow #F5A623 per Figma
                                color: AppColors.warning,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _tips[_index].body,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                height: 1.45,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Vertical 3-dot menu icon
                      GestureDetector(
                        onTap: _next,
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip {
  final String body;
  const _Tip({required this.body});
}
