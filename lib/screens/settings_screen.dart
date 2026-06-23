import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/vrm_loader.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _streamKeyController = TextEditingController();
  final _videoIdController = TextEditingController();
  bool _vrmLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _streamKeyController.text = state.youtubeStreamKey ?? '';
    _videoIdController.text = state.youtubeVideoId ?? '';
  }

  Future<void> _pickBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;
    context.read<AppState>().setBackground(
          result.files.single.path!,
          BackgroundType.image,
        );
  }

  Future<void> _pickVrmZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _vrmLoading = true;
      _errorText = null;
    });

    try {
      final vrmPath = await VrmLoaderService.extractVrmFromZip(
        result.files.single.path!,
      );
      if (!mounted) return;
      context.read<AppState>().setVrmModel(vrmPath);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _vrmLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('背景'),
          ListTile(
            tileColor: Colors.white.withOpacity(0.05),
            leading: const Icon(Icons.image_outlined),
            title: Text(state.backgroundPath == null ? '尚未載入背景' : '已載入背景圖片'),
            subtitle: state.backgroundPath != null
                ? Text(state.backgroundPath!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickBackgroundImage,
          ),

          const SizedBox(height: 24),
          _sectionTitle('VRM 虛擬主播模型'),
          ListTile(
            tileColor: Colors.white.withOpacity(0.05),
            leading: _vrmLoading
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.person_outline),
            title: Text(state.vrmLoaded ? '已載入 VRM 模型' : '載入 VRM 模型（.zip）'),
            subtitle: _errorText != null
                ? Text(_errorText!, style: const TextStyle(color: Colors.redAccent))
                : (state.vrmFilePath != null
                    ? Text(state.vrmFilePath!, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : const Text('zip 內需包含一個 .vrm 檔案')),
            trailing: const Icon(Icons.chevron_right),
            onTap: _vrmLoading ? null : _pickVrmZip,
          ),
          SwitchListTile(
            tileColor: Colors.white.withOpacity(0.05),
            title: const Text('人臉追蹤控制模型'),
            subtitle: const Text('開啟後使用前鏡頭偵測表情/頭部動作'),
            value: state.faceTrackingEnabled,
            onChanged: state.vrmLoaded
                ? (v) => context.read<AppState>().toggleFaceTracking(v)
                : null,
          ),

          const SizedBox(height: 24),
          _sectionTitle('YouTube 直播設定'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '串流金鑰請到 YouTube Studio → 進階直播功能 取得。\n'
              '影片ID 是直播網址 watch?v= 後面那段字串，用於載入聊天室。',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _streamKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'YouTube 串流金鑰',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => context.read<AppState>().setYoutubeStreamKey(v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _videoIdController,
            decoration: const InputDecoration(
              labelText: '直播影片 ID（聊天室用）',
              border: OutlineInputBorder(),
              hintText: '例如 oJA72vP2-ZM',
            ),
            onChanged: (v) => context.read<AppState>().setYoutubeVideoId(v),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      );
}
