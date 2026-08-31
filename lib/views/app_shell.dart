import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class AppShellContent extends StatefulWidget {
  const AppShellContent({Key? key}) : super(key: key);

  @override
  State<AppShellContent> createState() => _AppShellContentState();
}

class _AppShellContentState extends State<AppShellContent> {
  int _currentIndex = 0;

  // 各タブのスクリーン
  static const List<Widget> _screens = [
    HomeScreen(),
    CollectionScreen(),
    SettingsScreen(),
  ];

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
