import 'package:flutter_test/flutter_test.dart';
import 'package:nuripazu/services/animation_service.dart';

void main() {
  group('AnimationService', () {
    /// 性格別なつき度リアクション - sweetTooth
    test('getAffectionReactionPath returns correct path for sweetTooth Lv1 increase',
        () {
      final path = AnimationService.getAffectionReactionPath(
        'sweetTooth',
        1,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/sweettooth_happy_lv1.json',
      );
    });

    test('getAffectionReactionPath returns correct path for sweetTooth Lv4 increase',
        () {
      final path = AnimationService.getAffectionReactionPath(
        'sweetTooth',
        4,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/sweettooth_happy_lv4.json',
      );
    });

    test('getAffectionReactionPath returns decline path for sweetTooth decrease', () {
      final path = AnimationService.getAffectionReactionPath(
        'sweetTooth',
        0,
        false,
      );
      expect(
        path,
        'assets/lottie/reactions/sweettooth_sad_decline.json',
      );
    });

    /// 性格別なつき度リアクション - independent
    test('getAffectionReactionPath returns correct path for independent Lv2 increase',
        () {
      final path = AnimationService.getAffectionReactionPath(
        'independent',
        2,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/independent_cool_lv2.json',
      );
    });

    test('getAffectionReactionPath returns decline path for independent', () {
      final path = AnimationService.getAffectionReactionPath(
        'independent',
        0,
        false,
      );
      expect(
        path,
        'assets/lottie/reactions/independent_distant_decline.json',
      );
    });

    /// 性格別なつき度リアクション - shy
    test('getAffectionReactionPath returns correct path for shy Lv3 increase', () {
      final path = AnimationService.getAffectionReactionPath(
        'shy',
        3,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/shy_bashful_lv3.json',
      );
    });

    test('getAffectionReactionPath returns decline path for shy', () {
      final path = AnimationService.getAffectionReactionPath(
        'shy',
        0,
        false,
      );
      expect(
        path,
        'assets/lottie/reactions/shy_scared_decline.json',
      );
    });

    /// 性格別なつき度リアクション - playful
    test('getAffectionReactionPath returns correct path for playful Lv1 increase',
        () {
      final path = AnimationService.getAffectionReactionPath(
        'playful',
        1,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/playful_energetic_lv1.json',
      );
    });

    test('getAffectionReactionPath returns decline path for playful', () {
      final path = AnimationService.getAffectionReactionPath(
        'playful',
        0,
        false,
      );
      expect(
        path,
        'assets/lottie/reactions/playful_sulky_decline.json',
      );
    });

    /// 性格別なつき度リアクション - calm
    test('getAffectionReactionPath returns correct path for calm Lv4 increase',
        () {
      final path = AnimationService.getAffectionReactionPath(
        'calm',
        4,
        true,
      );
      expect(
        path,
        'assets/lottie/reactions/calm_peaceful_lv4.json',
      );
    });

    test('getAffectionReactionPath returns decline path for calm', () {
      final path = AnimationService.getAffectionReactionPath(
        'calm',
        0,
        false,
      );
      expect(
        path,
        'assets/lottie/reactions/calm_worried_decline.json',
      );
    });

    /// 交流アクション別リアクション
    group('getInteractionReactionPath', () {
      test('returns correct path for sweetTooth + feed', () {
        final path =
            AnimationService.getInteractionReactionPath('sweetTooth', 'feed');
        expect(path, 'assets/lottie/interactions/sweettooth_eating_happy.json');
      });

      test('returns correct path for sweetTooth + pet', () {
        final path =
            AnimationService.getInteractionReactionPath('sweetTooth', 'pet');
        expect(path, 'assets/lottie/interactions/sweettooth_nuzzle.json');
      });

      test('returns correct path for sweetTooth + play', () {
        final path =
            AnimationService.getInteractionReactionPath('sweetTooth', 'play');
        expect(
          path,
          'assets/lottie/interactions/sweettooth_playful_excited.json',
        );
      });

      test('returns correct path for independent + feed', () {
        final path =
            AnimationService.getInteractionReactionPath('independent', 'feed');
        expect(path, 'assets/lottie/interactions/independent_eating_coolly.json');
      });

      test('returns correct path for shy + pet', () {
        final path =
            AnimationService.getInteractionReactionPath('shy', 'pet');
        expect(path, 'assets/lottie/interactions/shy_flinches.json');
      });

      test('returns correct path for playful + play', () {
        final path =
            AnimationService.getInteractionReactionPath('playful', 'play');
        expect(
          path,
          'assets/lottie/interactions/playful_boundless_energy.json',
        );
      });

      test('returns correct path for calm + pet', () {
        final path = AnimationService.getInteractionReactionPath('calm', 'pet');
        expect(path, 'assets/lottie/interactions/calm_content_purr.json');
      });
    });

    /// 群れボーナス演出
    group('getHerdBonusAnimation', () {
      test('returns correct path for forest habitat', () {
        final path = AnimationService.getHerdBonusAnimation('forest');
        expect(path, 'assets/lottie/herd_bonus/forest_celebration.json');
      });

      test('returns correct path for ocean habitat', () {
        final path = AnimationService.getHerdBonusAnimation('ocean');
        expect(path, 'assets/lottie/herd_bonus/ocean_celebration.json');
      });

      test('returns correct path for grassland habitat', () {
        final path = AnimationService.getHerdBonusAnimation('grassland');
        expect(path, 'assets/lottie/herd_bonus/grassland_celebration.json');
      });

      test('returns correct path for mountain habitat', () {
        final path = AnimationService.getHerdBonusAnimation('mountain');
        expect(path, 'assets/lottie/herd_bonus/mountain_celebration.json');
      });

      test('returns correct path for sky habitat', () {
        final path = AnimationService.getHerdBonusAnimation('sky');
        expect(path, 'assets/lottie/herd_bonus/sky_celebration.json');
      });

      test('returns default path for unknown habitat', () {
        final path = AnimationService.getHerdBonusAnimation('unknown');
        expect(path, 'assets/lottie/herd_bonus/default_celebration.json');
      });
    });

    /// Lv4特別ポーズ
    group('getSpecialPoseAnimation', () {
      test('returns correct path for sweetTooth special pose', () {
        final path = AnimationService.getSpecialPoseAnimation('sweetTooth');
        expect(path, 'assets/lottie/special_poses/sweettooth_princess.json');
      });

      test('returns correct path for independent special pose', () {
        final path = AnimationService.getSpecialPoseAnimation('independent');
        expect(path, 'assets/lottie/special_poses/independent_majestic.json');
      });

      test('returns correct path for shy special pose', () {
        final path = AnimationService.getSpecialPoseAnimation('shy');
        expect(path, 'assets/lottie/special_poses/shy_confident.json');
      });

      test('returns correct path for playful special pose', () {
        final path = AnimationService.getSpecialPoseAnimation('playful');
        expect(path, 'assets/lottie/special_poses/playful_superhero.json');
      });

      test('returns correct path for calm special pose', () {
        final path = AnimationService.getSpecialPoseAnimation('calm');
        expect(path, 'assets/lottie/special_poses/calm_zen_master.json');
      });
    });

    /// 効果音パス
    group('getSoundEffectPath', () {
      test('returns correct path for tap sound', () {
        expect(
          AnimationService.getSoundEffectPath('tap'),
          'assets/sounds/ui/tap.mp3',
        );
      });

      test('returns correct path for success sound', () {
        expect(
          AnimationService.getSoundEffectPath('success'),
          'assets/sounds/ui/success.mp3',
        );
      });

      test('returns correct path for failure sound', () {
        expect(
          AnimationService.getSoundEffectPath('failure'),
          'assets/sounds/ui/failure.mp3',
        );
      });

      test('returns correct path for level_up sound', () {
        expect(
          AnimationService.getSoundEffectPath('level_up'),
          'assets/sounds/affection/level_up.mp3',
        );
      });

      test('returns correct path for level_down sound', () {
        expect(
          AnimationService.getSoundEffectPath('level_down'),
          'assets/sounds/affection/level_down.mp3',
        );
      });

      test('returns correct path for completion sound', () {
        expect(
          AnimationService.getSoundEffectPath('completion'),
          'assets/sounds/puzzle/completion.mp3',
        );
      });
    });

    /// 動物音声パス
    group('getAnimalVoicePath', () {
      test('returns correct path for animal happy voice', () {
        expect(
          AnimationService.getAnimalVoicePath('animal_001', 'happy'),
          'assets/sounds/animals/animal_001/happy_cry.mp3',
        );
      });

      test('returns correct path for animal sad voice', () {
        expect(
          AnimationService.getAnimalVoicePath('animal_001', 'sad'),
          'assets/sounds/animals/animal_001/sad_cry.mp3',
        );
      });

      test('returns correct path for animal neutral voice', () {
        expect(
          AnimationService.getAnimalVoicePath('animal_001', 'neutral'),
          'assets/sounds/animals/animal_001/neutral_cry.mp3',
        );
      });
    });

    /// パズル完成・動物出現演出
    test('returns correct path for puzzle completion animation', () {
      expect(
        AnimationService.puzzleCompletionCelebration,
        'assets/lottie/completion/celebration_confetti.json',
      );
    });

    test('returns correct path for animal appear animation', () {
      expect(
        AnimationService.animalAppear,
        'assets/lottie/completion/animal_appear.json',
      );
    });

    /// BGM パス
    test('returns correct path for BGM', () {
      expect(
        AnimationService.bgmPath,
        'assets/sounds/bgm/zoo_ambient_loop.mp3',
      );
    });
  });
}
