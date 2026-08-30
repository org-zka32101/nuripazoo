import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';

/// 設定画面
/// ユーザー情報、通知設定、サウンド設定、ログアウト
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ユーザー情報セクション
          _buildSectionHeader('アカウント'),
          currentUserAsync.when(
            data: (user) => _buildUserCard(context, user),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('エラー: $error'),
            ),
          ),

          const Divider(),

          // 通知設定
          _buildSectionHeader('通知'),
          _buildNotificationSettings(),

          const Divider(),

          // サウンド設定
          _buildSectionHeader('サウンド'),
          _buildSoundSettings(),

          const Divider(),

          // データ管理
          _buildSectionHeader('データ管理'),
          _buildDataManagement(context),

          const Divider(),

          // ログアウト
          _buildLogoutButton(context, ref),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// セクションヘッダー
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// ユーザーカード
  Widget _buildUserCard(BuildContext context, dynamic user) {
    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('ユーザー情報を読み込めません'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ユーザーID',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.uid ?? '不明',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'プラン',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.plan?.toString().split('.').last ?? 'free',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '連続プレイ日数',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.streakDays ?? 0}日',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 通知設定
  Widget _buildNotificationSettings() {
    return Column(
      children: [
        _buildSettingsToggle(
          'なつき度低下リマインド',
          'あと1日で低下する動物がいるときに通知',
          true,
        ),
        _buildSettingsToggle(
          'デイリーチャレンジ',
          '毎日の交流をリマインド',
          false,
        ),
        _buildSettingsToggle(
          'イベント通知',
          'ゲームのお知らせをお送りします',
          true,
        ),
      ],
    );
  }

  /// サウンド設定
  Widget _buildSoundSettings() {
    return Column(
      children: [
        _buildSettingsToggle(
          'BGM',
          '背景音楽を再生',
          true,
        ),
        _buildSettingsToggle(
          'SE',
          '効果音を再生',
          true,
        ),
        _buildSettingsToggle(
          '動物の鳴き声',
          '交流時に動物の声を再生',
          true,
        ),
      ],
    );
  }

  /// トグル設定アイテム
  Widget _buildSettingsToggle(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {
              // TODO: 通知/サウンド設定を実装
            },
          ),
        ],
      ),
    );
  }

  /// データ管理
  Widget _buildDataManagement(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('キャッシュを削除しました')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('キャッシュを削除'),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('利用規約を開きました')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('利用規約'),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('プライバシーポリシーを開きました')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('プライバシーポリシー'),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ログアウトボタン
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          // 確認ダイアログ
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ログアウトしますか？'),
              content: const Text('ゲームを終了します。次回起動時は再度ログインが必要です。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // ログアウト実行
                    await ref.read(userSignOutProvider.future);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        '/onboarding',
                      );
                    }
                  },
                  child: const Text(
                    'ログアウト',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Text('ログアウト'),
      ),
    );
  }
}
