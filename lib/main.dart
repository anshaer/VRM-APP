import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/app_state.dart';
import 'screens/live_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 強制鎖定直式（портrait）────────────────────────────────
  // 同時鎖定 up 與 down，避免某些裝置倒拿手機時畫面跟著轉 180 度
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 沉浸式體驗：隱藏系統狀態列與導覽列（直播時畫面更乾淨）
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const LivestreamApp());
}

class LivestreamApp extends StatelessWidget {
  const LivestreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: '直播 App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF6C5CE7),
          useMaterial3: true,
        ),
        // 二次保險：在 App 層級也強制 portrait（搭配上面的系統層鎖定）
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        home: const LiveScreen(),
      ),
    );
  }
}
