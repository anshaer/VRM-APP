# 直播 App 專案骨架

## ⚠️ 重要：第一次使用前必須做的事

這個資料夾包含的是**程式邏輯與設定檔**，但 Flutter 專案需要的「原生平台殼」
（android/、ios/ 資料夾本身）需要在你本機用 Flutter CLI 產生，因為這些
檔案內含編譯用的二進位設定，不適合手動寫出來。請依序執行：

```bash
# 1. 安裝 Flutter SDK（若尚未安裝）：https://docs.flutter.dev/get-started/install

# 2. 在這個資料夾內執行，會自動補上 android/ ios/ 等原生殼資料夾
#    （不會覆蓋我們已經寫好的 lib/、pubspec.yaml）
flutter create . --org com.yourcompany.livestreamapp --project-name livestream_app

# 3. 安裝套件
flutter pub get

# 4. 本機測試跑起來看看
flutter run
```

## 資料夾結構

```
livestream_app/
├── lib/
│   ├── main.dart                  # 進入點，強制鎖定直式
│   ├── screens/
│   │   ├── live_screen.dart       # 主直播畫面
│   │   └── settings_screen.dart   # 設定頁（金鑰/背景/VRM）
│   ├── widgets/
│   │   ├── live_canvas.dart       # 9:16 畫布容器
│   │   ├── background_layer.dart  # 背景層
│   │   ├── vrm_stage.dart         # VRM WebView 渲染層
│   │   ├── chat_panel.dart        # YT聊天室 WebView
│   │   └── broadcast_button.dart  # 防誤觸開播/下播鈕
│   └── services/
│       ├── app_state.dart         # 全域狀態
│       └── vrm_loader.dart        # VRM zip 解壓縮
├── assets/web/vrm_viewer.html     # Three.js + three-vrm 渲染頁
└── .github/workflows/build.yml    # CI 自動打包 APK/AAB/IPA
```

## 強制鎖定直式 —— 還需要補的原生設定

`main.dart` 內已用 `SystemChrome.setPreferredOrientations` 在 Dart 層鎖定，
但 Android 建議在原生層也加上雙重保險（`flutter create` 產生 android/ 後）：

`android/app/src/main/AndroidManifest.xml` 的 `<activity>` 標籤加上：
```xml
android:screenOrientation="portrait"
```

iOS 則在 `ios/Runner/Info.plist` 確認只保留：
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

## 已完成（這次骨架）

- [x] 強制直式鎖定（Dart 層）
- [x] 9:16 直播畫布容器
- [x] 背景載入（圖片）
- [x] VRM 載入流程（zip 解壓 + WebView 渲染頁雛形）
- [x] YouTube 金鑰/影片ID 設定頁
- [x] YouTube 聊天室直接嵌入彈出頁 WebView
- [x] 開播/下播防誤觸（長按確認）
- [x] GitHub Actions 三平台打包 workflow（iOS 暫未簽署）

## 還沒做、下一階段要補的

1. **iOS 原生鎖定 portrait**（上方步驟，需要 `ios/` 產生後才能改）
2. **人臉追蹤模組**：Android 接 MediaPipe Face Landmarker、iOS 接 ARKit，
   再透過 `VrmStage.updateFaceParams()` 把數值丟進 VRM
3. **RTMP 實際推流**：目前 `_handleStart()` 只是切換 UI 狀態，
   需要接 HaishinKit（iOS）/ 對應 Android 推流套件，把畫面（背景+VRM合成
   畫面）實際編碼推到 `state.rtmpUrl`
4. **影片背景播放**：接 `video_player` 套件
5. **iOS 簽署設定**：補上 GitHub Secrets（憑證、Provisioning Profile），
   讓 IPA 可以真正安裝/上架，目前 workflow 只能產出未簽署版本
6. **VRM 模型 .zip 規格**：目前假設 zip 內任何一個 `.vrm` 檔即可，
   之後可視需要規範附帶的設定檔格式（如預設表情、姿勢）
