import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

/// VRM 模型渲染層
/// 透過 InAppWebView 載入本地 assets/web/vrm_viewer.html，
/// 該頁面用 Three.js + @pixiv/three-vrm 渲染模型。
/// Flutter 端透過 JS bridge（callAsyncJavaScript / evaluateJavascript）
/// 把人臉追蹤數值丟進去控制骨架與表情。
class VrmStage extends StatefulWidget {
  const VrmStage({super.key});

  @override
  State<VrmStage> createState() => _VrmStageState();
}

class _VrmStageState extends State<VrmStage> {
  InAppWebViewController? _webViewController;
  bool _pageReady = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Stack(
      children: [
        InAppWebView(
          initialFile: 'assets/web/vrm_viewer.html',
          initialSettings: InAppWebViewSettings(
            transparentBackground: true, // 讓畫布的背景層能透出來
            mediaPlaybackRequiresUserGesture: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            setState(() => _pageReady = true);
            if (state.vrmFilePath != null) {
              _loadVrmIntoWebView(state.vrmFilePath!);
            }
          },
        ),
        if (!_pageReady)
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        if (_pageReady && !state.vrmLoaded)
          const Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '尚未載入 VRM 模型',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  /// 通知網頁端載入指定路徑的 .vrm 檔案
  Future<void> _loadVrmIntoWebView(String vrmPath) async {
    if (_webViewController == null) return;
    // vrm_viewer.html 內需實作 window.loadVrmFromPath(path)
    await _webViewController!.evaluateJavascript(
      source: "window.loadVrmFromPath && window.loadVrmFromPath('$vrmPath');",
    );
  }

  /// 之後人臉追蹤模組會呼叫這個方法，把追蹤到的參數丟給 Three.js
  /// 範例 params: { headYaw, headPitch, headRoll, eyeBlinkL, eyeBlinkR, mouthOpen }
  // ignore: unused_element
  Future<void> updateFaceParams(Map<String, double> params) async {
    if (_webViewController == null) return;
    final jsonStr = params.entries
        .map((e) => '"${e.key}":${e.value}')
        .join(',');
    await _webViewController!.evaluateJavascript(
      source: "window.updateFaceParams && window.updateFaceParams({$jsonStr});",
    );
  }
}
