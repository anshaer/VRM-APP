import 'dart:async';
import 'package:flutter/material.dart';

/// 防誤觸按鈕：需長按 [holdDuration] 才會觸發 [onConfirmed]
/// 中途放開會立即取消，並重置進度（不是用 dialog 二次確認，
/// 長按手感更符合直播 App 的直覺操作，且不會被手滑誤點）
class HoldToConfirmButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onConfirmed;
  final Duration holdDuration;

  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onConfirmed,
    this.holdDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_triggered) {
        _triggered = true;
        widget.onConfirmed();
        // 觸發後輕微震動回饋？此處可接 HapticFeedback.mediumImpact()
        _resetSoon();
      }
    });
  }

  void _resetSoon() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reset();
        _triggered = false;
      }
    });
  }

  void _onPressStart(_) {
    if (_triggered) return;
    _controller.forward(from: 0);
  }

  void _onPressEnd(_) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onPressStart,
      onTapUp: _onPressEnd,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 底層按鈕本體
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                // 長按進度環
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 包裝好的開播/下播按鈕，含文字標籤與長按提示
class BroadcastControlButton extends StatelessWidget {
  final bool isLive;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const BroadcastControlButton({
    super.key,
    required this.isLive,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoldToConfirmButton(
          label: isLive ? '下播' : '開播',
          icon: isLive ? Icons.stop : Icons.videocam,
          color: isLive ? Colors.redAccent : Colors.green,
          onConfirmed: isLive ? onStop : onStart,
        ),
        const SizedBox(height: 6),
        Text(
          isLive ? '長按結束直播' : '長按開始直播',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
