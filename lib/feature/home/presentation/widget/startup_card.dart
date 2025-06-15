import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class StartupCard extends StatelessWidget {
  final int index;

  const StartupCard(this.index);

  @override
  Widget build(BuildContext context) {
    final startups = [
      {
        'name': 'Magicstore',
        'logo': 'assets/magicstore_logo.png',
        'bgColor': const Color(0xFF6366F1),
      },
      {
        'name': 'DOCTOR ALI',
        'logo': 'assets/doctor_ali_logo.png',
        'bgColor': const Color(0xFFF59E0B),
      },
      {
        'name': 'MEHRIGIYO',
        'logo': 'assets/mehrigiyo_logo.png',
        'bgColor': const Color(0xFF10B981),
      },
      {
        'name': 'AloqaBank',
        'logo': 'assets/aloqabank_logo.png',
        'bgColor': const Color(0xFF3B82F6),
      },
      {
        'name': 'PULSE',
        'logo': 'assets/pulse_logo.png',
        'bgColor': const Color(0xFF10B981),
      },
      {
        'name': 'Zingo',
        'logo': 'assets/zingo_logo.png',
        'bgColor': const Color(0xFFEF4444),
      },
      {
        'name': 'AliPost',
        'logo': 'assets/alipost_logo.png',
        'bgColor': const Color(0xFF8B5CF6),
      },
      {
        'name': 'RomChi',
        'logo': 'assets/romchi_logo.png',
        'bgColor': const Color(0xFF059669),
      },
      {
        'name': 'OYGUL',
        'logo': 'assets/oygul_logo.png',
        'bgColor': const Color(0xFF374151),
      },
      {
        'name': 'Bito',
        'logo': 'assets/bito_logo.png',
        'bgColor': const Color(0xFF3B82F6),
      },
      {
        'name': 'TOKCHA',
        'logo': 'assets/tokcha_logo.png',
        'bgColor': const Color(0xFF6366F1),
      },
      {
        'name': 'Edu Tizim',
        'logo': 'assets/edu_tizim_logo.png',
        'bgColor': const Color(0xFF059669),
      },
      {
        'name': 'inter-AI',
        'logo': 'assets/inter_ai_logo.png',
        'bgColor': const Color(0xFF8B5CF6),
      },
      {
        'name': 'SpaceAgro',
        'logo': 'assets/space_agro_logo.png',
        'bgColor': const Color(0xFFF59E0B),
      },
      {
        'name': 'DETECTING-AI',
        'logo': 'assets/detecting_ai_logo.png',
        'bgColor': const Color(0xFF374151),
      },
    ];

    final startup = startups[index % startups.length];

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ChessColors.greyG800.withOpacity(0.8),
        borderRadius: ChessRadius.radiusMd,
        border: Border.all(
          color: ChessColors.primaryDefault.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ChessColors.greyG900.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo container with company colors
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: ChessRadius.radiusSm,
              boxShadow: [
                BoxShadow(
                  color: (startup['bgColor'] as Color).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getLogoText(startup['name']! as String),
                style: TextStyle(
                  color: startup['bgColor'] as Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Company name
          Text(
            startup['name']! as String,
            style: context.textTheme.bodyMedium.copyWith(
              color: ChessColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getLogoText(String companyName) {
    switch (companyName) {
      case 'DOCTOR ALI':
        return 'DR\nALI';
      case 'MEHRIGIYO':
        return 'MG';
      case 'AloqaBank':
        return 'AB';
      case 'Magicstore':
        return 'MS';
      case 'inter-AI':
        return 'iAI';
      case 'SpaceAgro':
        return 'SA';
      case 'DETECTING-AI':
        return 'DAI';
      default:
        return companyName.length > 6
            ? companyName.substring(0, 4).toUpperCase()
            : companyName.toUpperCase();
    }
  }
}