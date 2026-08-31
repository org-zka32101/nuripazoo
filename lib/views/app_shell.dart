import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';
import 'package:nuripazu/views/index.dart';

/// メインナビゲーション・シェル
/// ボトムナビゲーションバーで 動物園ホーム / 図鑑 / 設定 を切り替え
class AppShell extends ConsumerWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ボトムナビゲーション状態（ローカル状態管理）
    return AppShellContent();
  }
}

/// アプリシェルのコンテンツ（Stateを持つ）
/// Phase 6D: BGM 一元管理・画面切り替え時の音量制御
class AppShellContent extends StatefulWidget {
  const AppShellContent({Key? key}) : super(key: key);

  @override
  State<AppShellContent> createState() => _AppShellContentState();
}

class _AppShellContentState extends State<AppShellContent>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  // 各タブのスクリーン
  static const List<Widget> _screens = [
    HomeScreen(),
    CollectionScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // BGM アプリ起動時に初期化
    // TODO: audioplayers 統合後、ここで初期化
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // BGM クリーンアップ
    // TODO: audioplayers 統合後、ここで停止・リソース解放
    super.dispose();
  }

  /// アプリ状態変化時の BGM 制御
  /// フォアグラウンド ←→ バックグラウンド 切り替え時の音量管理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // TODO: audioplayers 統合後、実装
    // switch (state) {
    //   case AppLifecycleState.resumed:
    //     // アプリ復帰時：BGM 再開（音量復帰）
    //     break;
    //   case AppLifecycleState.paused:
    //     // アプリ一時停止時：BGM 音量低減または一時停止
    //     break;
    //   default:
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '動物園',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: '図鑑',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
