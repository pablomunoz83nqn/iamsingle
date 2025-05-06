import 'package:flutter/material.dart';

void showRadarIntroModal(
  BuildContext context,
  void Function(String radarMood) onActivateRadar,
) {
  showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _RadarIntroSheet(),
  ).then((value) {
    if (value != null) {
      onActivateRadar(value); // Pasamos el selectedMood a la función
    }
  });
}

class _RadarIntroSheet extends StatefulWidget {
  const _RadarIntroSheet();

  @override
  State<_RadarIntroSheet> createState() => _RadarIntroSheetState();
}

class _RadarIntroSheetState extends State<_RadarIntroSheet> {
  String? selectedMood;

  final moods = [
    {'key': 'connect', 'emoji': '❤️', 'label': 'Conectar'},
    {'key': 'chat', 'emoji': '💬', 'label': 'Charlar'},
    {'key': 'support', 'emoji': '🫂', 'label': 'Necesito apoyo'},
    {'key': 'celebrate', 'emoji': '🎉', 'label': 'Quiero celebrar'},
    {'key': 'chill', 'emoji': '☕', 'label': 'Relajado'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.radar, size: 64, color: Colors.greenAccent),
          const SizedBox(height: 24),
          const Text(
            '¿Listo para una conexión real?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Activa tu radar durante 1 hora.\n\nSelecciona tu estado emocional actual para que los demás puedan sentir tu intención.',
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Selector de moods con emojis
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood['key'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood['emoji']!, style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(mood['label']!),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedMood = mood['key'];
                  });
                },
                selectedColor: Colors.greenAccent,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: selectedMood != null
                ? () => Navigator.of(context).pop(selectedMood)
                : null,
            icon: const Icon(Icons.radar, color: Colors.black),
            label: const Text(
              'Activar Radar Ahora',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            'Podés desactivarlo cuando quieras.\nTu radar se apaga automáticamente después de 1 hora.',
            style: TextStyle(fontSize: 13, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
