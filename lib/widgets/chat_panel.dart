import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

/// 直接把 YouTube 官方聊天室彈出頁（live_chat?is_popout=1&v=xxx）
/// 嵌入 WebView 顯示，不走 Data API 輪詢，即時性與視覺效果都跟瀏覽器版一致。
/// 限制：此頁面僅供「顯示」彈幕，無法在 App 內用自己帳號回覆留言
/// （除非額外讓使用者在 WebView 內登入 Google 帳號）。
class ChatPanel extends StatelessWidget {
  const ChatPanel({super.key});

  // 注入的 CSS：隱藏網頁版多餘的標頭/選單，讓畫面更貼合 App 風格
  static const _injectedCss = '''
    #header-row, ytd-live-chat-header-renderer, #show-hide-button { display: none !important; }
    body { background: transparent !important; }
  ''';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final url = state.chatPopoutUrl;

    if (url == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '請先到設定頁輸入直播影片網址/ID\n才能載入聊天室',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        javaScriptEnabled: true,
      ),
      onLoadStop: (controller, loadedUrl) async {
        // 注入 CSS 精簡介面
        await controller.evaluateJavascript(source: '''
          (function() {
            const style = document.createElement('style');
            style.innerHTML = `$_injectedCss`;
            document.head.appendChild(style);
          })();
        ''');
      },
    );
  }
}

/// 可收合的聊天室浮層，疊在直播畫布右側或下方
/// 預設半透明，方便看清楚底下的直播畫面
class CollapsibleChatOverlay extends StatefulWidget {
  const CollapsibleChatOverlay({super.key});

  @override
  State<CollapsibleChatOverlay> createState() => _CollapsibleChatOverlayState();
}

class _CollapsibleChatOverlayState extends State<CollapsibleChatOverlay> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 8,
      bottom: 90,
      width: _expanded ? 200 : 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _expanded ? Icons.chevron_right : Icons.chat_bubble_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          if (_expanded)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: const ChatPanel(),
              ),
            ),
        ],
      ),
    );
  }
}
