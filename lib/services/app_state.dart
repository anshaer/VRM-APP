import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BackgroundType { none, image, video }

/// App 全域狀態，集中管理背景／VRM模型／金鑰／直播狀態
/// 後續若規模變大，可拆成多個 Provider，目前先合併方便維護
class AppState extends ChangeNotifier {
  // ── 背景 ─────────────────────────────────────────
  String? backgroundPath;
  BackgroundType backgroundType = BackgroundType.none;

  void setBackground(String path, BackgroundType type) {
    backgroundPath = path;
    backgroundType = type;
    notifyListeners();
  }

  void clearBackground() {
    backgroundPath = null;
    backgroundType = BackgroundType.none;
    notifyListeners();
  }

  // ── VRM 模型 ──────────────────────────────────────
  // 解壓縮後指向資料夾內 .vrm 檔案的路徑
  String? vrmFilePath;
  bool vrmLoaded = false;

  void setVrmModel(String path) {
    vrmFilePath = path;
    vrmLoaded = true;
    notifyListeners();
  }

  void clearVrmModel() {
    vrmFilePath = null;
    vrmLoaded = false;
    notifyListeners();
  }

  // ── 人臉追蹤開關 ───────────────────────────────────
  bool faceTrackingEnabled = false;

  void toggleFaceTracking(bool value) {
    faceTrackingEnabled = value;
    notifyListeners();
  }

  // ── YouTube 推流設定 ───────────────────────────────
  String? youtubeStreamKey; // RTMP 串流金鑰（建議之後改用安全儲存加密）
  String? youtubeVideoId;   // 用於組成聊天室彈出網址 v= 參數

  static const _kStreamKeyPref = 'yt_stream_key';
  static const _kVideoIdPref = 'yt_video_id';

  Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    youtubeStreamKey = prefs.getString(_kStreamKeyPref);
    youtubeVideoId = prefs.getString(_kVideoIdPref);
    notifyListeners();
  }

  Future<void> setYoutubeStreamKey(String key) async {
    youtubeStreamKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStreamKeyPref, key);
    notifyListeners();
  }

  Future<void> setYoutubeVideoId(String id) async {
    youtubeVideoId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVideoIdPref, id);
    notifyListeners();
  }

  /// 組成 YouTube 聊天室彈出頁網址
  String? get chatPopoutUrl {
    if (youtubeVideoId == null || youtubeVideoId!.isEmpty) return null;
    return 'https://www.youtube.com/live_chat?is_popout=1&v=$youtubeVideoId';
  }

  /// 組成 RTMP 推流位址（YouTube 固定 ingest 位址 + 串流金鑰）
  String? get rtmpUrl {
    if (youtubeStreamKey == null || youtubeStreamKey!.isEmpty) return null;
    return 'rtmp://a.rtmp.youtube.com/live2/$youtubeStreamKey';
  }

  // ── 直播狀態 ──────────────────────────────────────
  bool isLive = false;

  void startLive() {
    isLive = true;
    notifyListeners();
  }

  void stopLive() {
    isLive = false;
    notifyListeners();
  }
}
