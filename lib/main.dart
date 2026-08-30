import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'views/onboarding_screen.dart';
import 'views/puzzle_screen.dart';
import 'views/home_screen.dart';
import 'views/animal_detail_screen.dart';
import 'views/app_shell.dart';
import 'views/herd_scene_screen.dart';
import 'viewmodels/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: NuripazuApp(),
    ),
  );
}

class NuripazuApp extends ConsumerWidget {
  const NuripazuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'ぬりパズ動物園',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) => user == null
            ? const OnboardingScreen()
            : const AppShell(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('エラー: $error'),
          ),
        ),
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/puzzle': (context) => const PuzzleScreen(),
        '/home': (context) => const AppShell(),
        '/animal_detail': (context) {
          final animalId = ModalRoute.of(context)?.settings.arguments as String?;
          return AnimalDetailScreen(
            animalId: animalId ?? 'unknown',
          );
        },
        '/herd_scene': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HerdSceneScreen(
            habitat: args?['habitat'] ?? 'unknown',
            animalIds: args?['animalIds'] ?? [],
          );
        },
      },
    );
  }
}
