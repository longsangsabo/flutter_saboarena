import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AchievementsRecord extends FirestoreRecord {
  AchievementsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "achievement_id" field.
  String? _achievementId;
  String get achievementId => _achievementId ?? '';
  bool hasAchievementId() => _achievementId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "badge_icon" field.
  String? _badgeIcon;
  String get badgeIcon => _badgeIcon ?? '';
  bool hasBadgeIcon() => _badgeIcon != null;

  // "requirement_type" field.
  String? _requirementType;
  String get requirementType => _requirementType ?? '';
  bool hasRequirementType() => _requirementType != null;

  // "requirement_value" field.
  int? _requirementValue;
  int get requirementValue => _requirementValue ?? 0;
  bool hasRequirementValue() => _requirementValue != null;

  // "spa_reward" field.
  int? _spaReward;
  int get spaReward => _spaReward ?? 0;
  bool hasSpaReward() => _spaReward != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _achievementId = snapshotData['achievement_id'] as String?;
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _badgeIcon = snapshotData['badge_icon'] as String?;
    _requirementType = snapshotData['requirement_type'] as String?;
    _requirementValue = castToType<int>(snapshotData['requirement_value']);
    _spaReward = castToType<int>(snapshotData['spa_reward']);
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('achievements');

  static Stream<AchievementsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AchievementsRecord.fromSnapshot(s));

  static Future<AchievementsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AchievementsRecord.fromSnapshot(s));

  static AchievementsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AchievementsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AchievementsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AchievementsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AchievementsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AchievementsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAchievementsRecordData({
  String? achievementId,
  String? name,
  String? description,
  String? badgeIcon,
  String? requirementType,
  int? requirementValue,
  int? spaReward,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'achievement_id': achievementId,
      'name': name,
      'description': description,
      'badge_icon': badgeIcon,
      'requirement_type': requirementType,
      'requirement_value': requirementValue,
      'spa_reward': spaReward,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class AchievementsRecordDocumentEquality
    implements Equality<AchievementsRecord> {
  const AchievementsRecordDocumentEquality();

  @override
  bool equals(AchievementsRecord? e1, AchievementsRecord? e2) {
    return e1?.achievementId == e2?.achievementId &&
        e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.badgeIcon == e2?.badgeIcon &&
        e1?.requirementType == e2?.requirementType &&
        e1?.requirementValue == e2?.requirementValue &&
        e1?.spaReward == e2?.spaReward &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(AchievementsRecord? e) => const ListEquality().hash([
        e?.achievementId,
        e?.name,
        e?.description,
        e?.badgeIcon,
        e?.requirementType,
        e?.requirementValue,
        e?.spaReward,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is AchievementsRecord;
}
