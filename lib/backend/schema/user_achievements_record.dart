import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserAchievementsRecord extends FirestoreRecord {
  UserAchievementsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "user_achievement_id" field.
  String? _userAchievementId;
  String get userAchievementId => _userAchievementId ?? '';
  bool hasUserAchievementId() => _userAchievementId != null;

  // "achievement_id" field.
  String? _achievementId;
  String get achievementId => _achievementId ?? '';
  bool hasAchievementId() => _achievementId != null;

  // "progress" field.
  int? _progress;
  int get progress => _progress ?? 0;
  bool hasProgress() => _progress != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "completed_time" field.
  DateTime? _completedTime;
  DateTime? get completedTime => _completedTime;
  bool hasCompletedTime() => _completedTime != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _userAchievementId = snapshotData['user_achievement_id'] as String?;
    _achievementId = snapshotData['achievement_id'] as String?;
    _progress = castToType<int>(snapshotData['progress']);
    _isCompleted = snapshotData['is_completed'] as bool?;
    _completedTime = snapshotData['completed_time'] as DateTime?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_achievements');

  static Stream<UserAchievementsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserAchievementsRecord.fromSnapshot(s));

  static Future<UserAchievementsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => UserAchievementsRecord.fromSnapshot(s));

  static UserAchievementsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserAchievementsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserAchievementsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserAchievementsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserAchievementsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserAchievementsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserAchievementsRecordData({
  String? userAchievementId,
  String? achievementId,
  int? progress,
  bool? isCompleted,
  DateTime? completedTime,
  DateTime? createdTime,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_achievement_id': userAchievementId,
      'achievement_id': achievementId,
      'progress': progress,
      'is_completed': isCompleted,
      'completed_time': completedTime,
      'created_time': createdTime,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserAchievementsRecordDocumentEquality
    implements Equality<UserAchievementsRecord> {
  const UserAchievementsRecordDocumentEquality();

  @override
  bool equals(UserAchievementsRecord? e1, UserAchievementsRecord? e2) {
    return e1?.userAchievementId == e2?.userAchievementId &&
        e1?.achievementId == e2?.achievementId &&
        e1?.progress == e2?.progress &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.completedTime == e2?.completedTime &&
        e1?.createdTime == e2?.createdTime &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(UserAchievementsRecord? e) => const ListEquality().hash([
        e?.userAchievementId,
        e?.achievementId,
        e?.progress,
        e?.isCompleted,
        e?.completedTime,
        e?.createdTime,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is UserAchievementsRecord;
}
