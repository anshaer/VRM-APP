import 'package:flutter/material.dart';
import 'background_layer.dart';
import 'vrm_stage.dart';
import 'chat_panel.dart';

/// 直播畫布：強制鎖定 9:16（寬9:高16）比例
/// 不論裝置實際螢幕比例為何，畫布內容永遠維持這個比例，
/// 多餘空間以黑邊填滿，確保錄製/推流出去的畫面是乾淨的固定比例。
class LiveCanvas extends StatelessWidget {
  final bool showChatOverlay;

  const LiveCanvas({super.key, this.showChatOverlay = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // 黑邊
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 第1層：背景
                const BackgroundLayer(),
                // 第2層：VRM 虛擬主播渲染
                const VrmStage(),
                // 第3層：聊天室浮層（可收合）
                if (showChatOverlay) const CollapsibleChatOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
