import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/live_canvas.dart';
import '../widgets/broadcast_button.dart';
import 'settings_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  @override
  void initState() {
    super.initState();
    // App 啟動後讀取上次儲存的金鑰/設定
    Future.microtask(() => context.read<AppState>().loadSavedSettings());
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _handleStart() {
    final state = context.read<AppState>();
    if (state.rtmpUrl == null) {
      _showSnack('請先到設定頁輸入 YouTube 串流金鑰');
      return;
    }
    // TODO: 接上實際 RTMP 推流模組（HaishinKit / FFmpeg）
    // 目前先切換狀態做 UI 流程驗證
    state.startLive();
    _showSnack('已開始直播（推流模組待接）');
  }

  void _handleStop() {
    context.read<AppState>().stopLive();
    _showSnack('已結束直播');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── 頂部狀態列 ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  if (state.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: _openSettings,
                  ),
                ],
              ),
            ),

            // ── 直播畫布（9:16）────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const LiveCanvas(),
              ),
            ),

            // ── 底部控制列 ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: BroadcastControlButton(
                isLive: state.isLive,
                onStart: _handleStart,
                onStop: _handleStop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
