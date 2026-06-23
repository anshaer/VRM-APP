import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

/// 畫布最底層：顯示使用者載入的背景圖片
/// （影片背景之後可換成 video_player 套件處理，目前先支援圖片）
class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.backgroundPath == null) {
      // 沒有背景時顯示預設深色棚拍漸層，避免畫面全黑顯得像當機
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B1F3B), Color(0xFF0D0F1C)],
          ),
        ),
        child: const Center(
          child: Text('尚未載入背景', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    switch (state.backgroundType) {
      case BackgroundType.image:
        return Image.file(
          File(state.backgroundPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case BackgroundType.video:
        // TODO: 接 video_player 套件做循環播放背景影片
        return Container(
          color: Colors.black,
          child: const Center(
            child: Text('影片背景（待接 video_player）',
                style: TextStyle(color: Colors.white54)),
          ),
        );
      case BackgroundType.none:
        return const SizedBox.shrink();
    }
  }
}
