import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Firebase Admin SDK を初期化
admin.initializeApp();

const db = admin.firestore();

// ==================== Constants ====================
const MAX_AFFECTION_LEVEL = 4;
const MIN_AFFECTION_LEVEL = 1;
const DAYS_TO_DECLINE = 3;

// ==================== Types ====================
interface InteractionRequest {
  uid: string;
  animalId: string;
  interactionType: 'feed' | 'pet' | 'play';
}

interface InteractionResponse {
  success: boolean;
  newAffectionLevel?: number;
  message?: string;
  error?: string;
}

// ==================== Helper Functions ====================

/**
 * なつき度を1段階上昇させる（1日1回制限付き）
 */
async function increaseAffectionLevel(
  uid: string,
  animalId: string,
  interactionType: string
): Promise<InteractionResponse> {
  try {
    const animalRef = db.collection('users').doc(uid).collection('animals').doc(animalId);
    const animalDoc = await animalRef.get();

    if (!animalDoc.exists) {
      return {
        success: false,
        error: 'Animal not found',
      };
    }

    const animalData = animalDoc.data()!;
    const currentLevel = animalData.affectionLevel || 1;
    const lastInteractedAt = animalData.lastInteractedAt?.toDate() || new Date(0);

    // 1日1回制限チェック
    if (hasInteractedToday(lastInteractedAt)) {
      return {
        success: false,
        message: 'Already interacted today. Try again tomorrow.',
        newAffectionLevel: currentLevel,
      };
    }

    // なつき度を1段階上昇（最大Lv4）
    const newLevel = Math.min(currentLevel + 1, MAX_AFFECTION_LEVEL);

    // Firestore に更新（サーバー側で改ざん対策）
    await animalRef.update({
      affectionLevel: newLevel,
      lastInteractedAt: admin.firestore.Timestamp.now(),
      lastInteractionType: interactionType,
    });

    // Firebase Analytics へイベント記録
    await recordAnalyticsEvent(uid, 'animal_interacted', {
      animalId,
      interactionType,
      newLevel,
    });

    return {
      success: true,
      newAffectionLevel: newLevel,
      message: `Affection level increased to ${newLevel}`,
    };
  } catch (error) {
    console.error('Error in increaseAffectionLevel:', error);
    return {
      success: false,
      error: String(error),
    };
  }
}

/**
 * 本日の交流済みかどうかを判定
 */
function hasInteractedToday(lastInteractedAt: Date): boolean {
  const now = new Date();
  return (
    now.getFullYear() === lastInteractedAt.getFullYear() &&
    now.getMonth() === lastInteractedAt.getMonth() &&
    now.getDate() === lastInteractedAt.getDate()
  );
}

/**
 * なつき度低下をチェック（3日未交流）
 */
async function checkAndDeclineAffection(uid: string, animalId: string): Promise<void> {
  try {
    const animalRef = db.collection('users').doc(uid).collection('animals').doc(animalId);
    const animalDoc = await animalRef.get();

    if (!animalDoc.exists) return;

    const animalData = animalDoc.data()!;
    const lastInteractedAt = animalData.lastInteractedAt?.toDate() || new Date(0);
    const currentLevel = animalData.affectionLevel || 1;

    // 3日以上未交流かチェック
    const daysDifference = Math.floor(
      (Date.now() - lastInteractedAt.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (daysDifference >= DAYS_TO_DECLINE && currentLevel > MIN_AFFECTION_LEVEL) {
      const newLevel = Math.max(currentLevel - 1, MIN_AFFECTION_LEVEL);
      await animalRef.update({
        affectionLevel: newLevel,
        lastDeclinedAt: admin.firestore.Timestamp.now(),
      });

      // 低下通知イベント
      await recordAnalyticsEvent(uid, 'affection_declined', {
        animalId,
        previousLevel: currentLevel,
        newLevel,
      });
    }
  } catch (error) {
    console.error('Error in checkAndDeclineAffection:', error);
  }
}

/**
 * Firebase Analytics へイベント記録
 */
async function recordAnalyticsEvent(
  uid: string,
  eventName: string,
  eventData: Record<string, any>
): Promise<void> {
  try {
    await db.collection('analytics').add({
      uid,
      eventName,
      eventData,
      timestamp: admin.firestore.Timestamp.now(),
    });
  } catch (error) {
    console.error('Error recording analytics event:', error);
  }
}

/**
 * 群れボーナスをチェック（生息地3体揃い）
 */
async function checkHerdBonus(uid: string, habitat: string): Promise<boolean> {
  try {
    const animalsSnapshot = await db
      .collection('users')
      .doc(uid)
      .collection('animals')
      .where('habitat', '==', habitat)
      .get();

    const completedCount = animalsSnapshot.size;

    // 3体揃ったかチェック
    if (completedCount >= 3) {
      const herdRef = db
        .collection('users')
        .doc(uid)
        .collection('herd_bonuses')
        .doc(habitat);

      const herdDoc = await herdRef.get();
      const isNewUnlock = !herdDoc.exists;

      if (isNewUnlock) {
        await herdRef.set({
          uid,
          habitat,
          completedCount,
          sceneUnlockedAt: admin.firestore.Timestamp.now(),
        });

        // 群れボーナス解放イベント
        await recordAnalyticsEvent(uid, 'herd_bonus_unlocked', {
          habitat,
          animalCount: completedCount,
        });
      }

      return isNewUnlock;
    }

    return false;
  } catch (error) {
    console.error('Error checking herd bonus:', error);
    return false;
  }
}

// ==================== Cloud Functions ====================

/**
 * 動物と交流（なつき度を上昇させる）
 * Callable function: client からセキュアに呼び出し可能
 */
export const interactWithAnimal = functions.https.onCall(
  async (data: InteractionRequest, context) => {
    // 認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { uid, animalId, interactionType } = data;

    // ユーザーIDの一致チェック（改ざん対策）
    if (context.auth.uid !== uid) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Unauthorized access to other user data'
      );
    }

    // バリデーション
    if (!animalId || !interactionType) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields: animalId, interactionType'
      );
    }

    if (!['feed', 'pet', 'play'].includes(interactionType)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid interactionType'
      );
    }

    // なつき度を上昇させる
    const result = await increaseAffectionLevel(uid, animalId, interactionType);

    if (!result.success) {
      throw new functions.https.HttpsError('failed-precondition', result.error || result.message);
    }

    return result;
  }
);

/**
 * ユーザー初期化（新規ユーザー作成時）
 * Auth trigger: ユーザー登録時に自動実行
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  try {
    const uid = user.uid;
    const userRef = db.collection('users').doc(uid);

    await userRef.set(
      {
        uid,
        email: user.email || '',
        displayName: user.displayName || 'Player',
        plan: 'free',
        streakDays: 0,
        lastVisitAt: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.now(),
      },
      { merge: true }
    );

    console.log(`User ${uid} created successfully`);

    // Analytics イベント
    await recordAnalyticsEvent(uid, 'user_created', {
      email: user.email,
      displayName: user.displayName,
    });
  } catch (error) {
    console.error('Error creating user:', error);
  }
});

/**
 * なつき度低下チェック（定期実行 - Pub/Sub）
 * Scheduled function: 毎日夜間に実行
 */
export const checkAffectionDecline = functions.pubsub
  .schedule('every day 02:00')
  .timeZone('Asia/Tokyo')
  .onRun(async () => {
    try {
      const usersSnapshot = await db.collection('users').get();

      for (const userDoc of usersSnapshot.docs) {
        const uid = userDoc.id;
        const animalsSnapshot = await db
          .collection('users')
          .doc(uid)
          .collection('animals')
          .get();

        for (const animalDoc of animalsSnapshot.docs) {
          await checkAndDeclineAffection(uid, animalDoc.id);
        }
      }

      console.log('Affection decline check completed');
    } catch (error) {
      console.error('Error in checkAffectionDecline:', error);
    }
  });

/**
 * ユーザーの最終訪問日を更新
 * Callable function: アプリ起動時に呼び出し
 */
export const updateLastVisit = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const uid = context.auth.uid;
    const userRef = db.collection('users').doc(uid);

    await userRef.update({
      lastVisitAt: admin.firestore.Timestamp.now(),
    });

    return { success: true };
  } catch (error) {
    console.error('Error updating last visit:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update last visit');
  }
});

/**
 * ゲーム完成時の処理（新動物ゲット）
 * Callable function: パズル完成時に呼び出し
 */
export const completeAnimal = functions.https.onCall(
  async (data: { uid: string; animalId: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { uid, animalId } = data;

    if (context.auth.uid !== uid) {
      throw new functions.https.HttpsError('permission-denied', 'Unauthorized access');
    }

    try {
      const animalRef = db.collection('users').doc(uid).collection('animals').doc(animalId);

      // 既に所有していないかチェック
      const existingAnimal = await animalRef.get();
      if (existingAnimal.exists) {
        return { success: false, message: 'Already own this animal' };
      }

      // 新規動物を登録（Lv1から開始）
      await animalRef.set({
        uid,
        animalId,
        unlockedAt: admin.firestore.Timestamp.now(),
        affectionLevel: 1,
        lastInteractedAt: admin.firestore.Timestamp.now(),
        isDeclineWarned: false,
      });

      // Analytics: Aha Moment イベント
      await recordAnalyticsEvent(uid, 'aha_moment_reached', {
        animalId,
      });

      // 群れボーナスをチェック
      const animalMaster = await db.collection('animals_master').doc(animalId).get();
      if (animalMaster.exists) {
        const habitat = animalMaster.data()?.habitat;
        const isNewHerd = await checkHerdBonus(uid, habitat);
        return {
          success: true,
          newAnimal: true,
          newHerdBonus: isNewHerd,
          habitat,
        };
      }

      return { success: true, newAnimal: true };
    } catch (error) {
      console.error('Error completing animal:', error);
      throw new functions.https.HttpsError('internal', 'Failed to complete animal');
    }
  }
);

console.log('ぬりパズ動物園 Cloud Functions initialized');
