import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchRatingsRecord extends FirestoreRecord {
  MatchRatingsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "rating_id" field.
  String? _ratingId;
  String get ratingId => _ratingId ?? '';
  bool hasRatingId() => _ratingId != null;

  // "match_id" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "rater_uid" field.
  String? _raterUid;
  String get raterUid => _raterUid ?? '';
  bool hasRaterUid() => _raterUid != null;

  // "rated_uid" field.
  String? _ratedUid;
  String get ratedUid => _ratedUid ?? '';
  bool hasRatedUid() => _ratedUid != null;

  // "rating" field.
  int? _rating;
  int get rating => _rating ?? 0;
  bool hasRating() => _rating != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "rating_type" field.
  String? _ratingType;
  String get ratingType => _ratingType ?? '';
  bool hasRatingType() => _ratingType != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _ratingId = snapshotData['rating_id'] as String?;
    _matchId = snapshotData['match_id'] as String?;
    _raterUid = snapshotData['rater_uid'] as String?;
    _ratedUid = snapshotData['rated_uid'] as String?;
    _rating = castToType<int>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _ratingType = snapshotData['rating_type'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('match_ratings');

  static Stream<MatchRatingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchRatingsRecord.fromSnapshot(s));

  static Future<MatchRatingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchRatingsRecord.fromSnapshot(s));

  static MatchRatingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchRatingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchRatingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchRatingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchRatingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchRatingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchRatingsRecordData({
  String? ratingId,
  String? matchId,
  String? raterUid,
  String? ratedUid,
  int? rating,
  String? comment,
  String? ratingType,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'rating_id': ratingId,
      'match_id': matchId,
      'rater_uid': raterUid,
      'rated_uid': ratedUid,
      'rating': rating,
      'comment': comment,
      'rating_type': ratingType,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchRatingsRecordDocumentEquality
    implements Equality<MatchRatingsRecord> {
  const MatchRatingsRecordDocumentEquality();

  @override
  bool equals(MatchRatingsRecord? e1, MatchRatingsRecord? e2) {
    return e1?.ratingId == e2?.ratingId &&
        e1?.matchId == e2?.matchId &&
        e1?.raterUid == e2?.raterUid &&
        e1?.ratedUid == e2?.ratedUid &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.ratingType == e2?.ratingType &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(MatchRatingsRecord? e) => const ListEquality().hash([
        e?.ratingId,
        e?.matchId,
        e?.raterUid,
        e?.ratedUid,
        e?.rating,
        e?.comment,
        e?.ratingType,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is MatchRatingsRecord;
}
