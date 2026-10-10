import 'package:PixaMart/backend/sources/wallpaper.dart';
import 'package:PixaMart/backend/sources/wallpaper_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SourcePicker extends StatelessWidget {
  final ValueChanged<WallpaperSourceId> onChanged;
  const SourcePicker({required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final selected = WallpaperRepository.selected.value;
        return ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: WallpaperRepository.enabledSources.map((source) {
            final isSelected = source.id == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(sourceLabels[source.id]!),
                selected: isSelected,
                showCheckmark: false,
                side: BorderSide.none,
                backgroundColor: Colors.white12,
                selectedColor: Colors.greenAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  if (!isSelected) onChanged(source.id);
                },
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
