import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RankingsRecord extends FirestoreRecord {
  RankingsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "ranking_id" field.
  String? _rankingId;
  String get rankingId => _rankingId ?? '';
  bool hasRankingId() => _rankingId != null;

  // "rank_type" field.
  String? _rankType;
  String get rankType => _rankType ?? '';
  bool hasRankType() => _rankType != null;

  // "position" field.
  int? _position;
  int get position => _position ?? 0;
  bool hasPosition() => _position != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  bool hasScore() => _score != null;

  // "period" field.
  String? _period;
  String get period => _period ?? '';
  bool hasPeriod() => _period != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "ranking_criteria" field.
  String? _rankingCriteria;
  String get rankingCriteria => _rankingCriteria ?? '';
  bool hasRankingCriteria() => _rankingCriteria != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _rankingId = snapshotData['ranking_id'] as String?;
    _rankType = snapshotData['rank_type'] as String?;
    _position = castToType<int>(snapshotData['position']);
    _score = castToType<int>(snapshotData['score']);
    _period = snapshotData['period'] as String?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _clubId = snapshotData['club_id'] as String?;
    _rankingCriteria = snapshotData['ranking_criteria'] as String?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rankings');

  static Stream<RankingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RankingsRecord.fromSnapshot(s));

  static Future<RankingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RankingsRecord.fromSnapshot(s));

  static RankingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RankingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RankingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RankingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RankingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RankingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRankingsRecordData({
  String? rankingId,
  String? rankType,
  int? position,
  int? score,
  String? period,
  DateTime? updatedTime,
  String? clubId,
  String? rankingCriteria,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ranking_id': rankingId,
      'rank_type': rankType,
      'position': position,
      'score': score,
      'period': period,
      'updated_time': updatedTime,
      'club_id': clubId,
      'ranking_criteria': rankingCriteria,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class RankingsRecordDocumentEquality implements Equality<RankingsRecord> {
  const RankingsRecordDocumentEquality();

  @override
  bool equals(RankingsRecord? e1, RankingsRecord? e2) {
    return e1?.rankingId == e2?.rankingId &&
        e1?.rankType == e2?.rankType &&
        e1?.position == e2?.position &&
        e1?.score == e2?.score &&
        e1?.period == e2?.period &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.clubId == e2?.clubId &&
        e1?.rankingCriteria == e2?.rankingCriteria &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(RankingsRecord? e) => const ListEquality().hash([
        e?.rankingId,
        e?.rankType,
        e?.position,
        e?.score,
        e?.period,
        e?.updatedTime,
        e?.clubId,
        e?.rankingCriteria,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is RankingsRecord;
}
