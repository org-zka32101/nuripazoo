import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuripazu/models/index.dart';

/// Firestore データベース操作の統一インターフェース
///
/// 規則:
/// - ユーザーデータ・所持動物・なつき度は直接書込み禁止（Cloud Functions経由に統一）
/// - 交流ロジックは Cloud Functions でサーバー検証
/// - オフライン対応: enablePersistence() で有効化
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ユーザー情報を取得
  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー情報を作成・初期化（Cloud Functions経由が推奨）
  Future<void> createUser(String uid, User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// 動物マスタを取得
  Future<AnimalMaster?> getAnimal(String animalId) async {
    try {
      final doc = await _firestore.collection('animals_master').doc(animalId).get();
      if (!doc.exists) return null;
      return AnimalMaster.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// 全動物マスタをリスト（ページング対応）
  Stream<List<AnimalMaster>> listAnimals({int limit = 20}) {
    try {
      return _firestore
          .collection('animals_master')
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AnimalMaster.fromJson(doc.data()))
              .toList());
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザー所持動物を取得
  Future<UserAnimal?> getUserAnimal(String uid, String animalId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();
      if (!doc.exists) return null;
      return UserAnimal.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// ユーザーの所持動物一覧を取得
  Stream<List<UserAnimal>> listUserAnimals(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => UserAnimal.fromJson(doc.data())).toList());
    } catch (e) {
      rethrow;
    }
  }

  /// なつき度情報を取得（読み取り専用）
  Future<int> getAffectionLevel(String uid, String animalId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();
      if (!doc.exists) return 1;
      final animal = UserAnimal.fromJson(doc.data()!);
      return animal.affectionLevel;
    } catch (e) {
      rethrow;
    }
  }

  /// パズルセッションを記録（オフライン後の同期対応）
  Future<void> recordPuzzleSession(PuzzleSession session) async {
    try {
      await _firestore
          .collection('users')
          .doc(session.uid)
          .collection('puzzle_sessions')
          .doc(session.id)
          .set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// 群れボーナス情報を取得
  Future<HerdBonus?> getHerdBonus(String uid, String habitat) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('herd_bonuses')
          .doc(habitat)
          .get();
      if (!doc.exists) return null;
      return HerdBonus.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// シェアアセットを保存
  Future<void> saveShareAsset(ShareAsset asset) async {
    try {
      await _firestore
          .collection('share_assets')
          .doc(asset.id)
          .set(asset.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// エラーハンドリング: タイムアウト設定
  static const Duration timeoutDuration = Duration(seconds: 10);
}
