import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClubReviewsRecord extends FirestoreRecord {
  ClubReviewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "review_id" field.
  String? _reviewId;
  String get reviewId => _reviewId ?? '';
  bool hasReviewId() => _reviewId != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "reviewer_uid" field.
  String? _reviewerUid;
  String get reviewerUid => _reviewerUid ?? '';
  bool hasReviewerUid() => _reviewerUid != null;

  // "rating" field.
  int? _rating;
  int get rating => _rating ?? 0;
  bool hasRating() => _rating != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _reviewId = snapshotData['review_id'] as String?;
    _clubId = snapshotData['club_id'] as String?;
    _reviewerUid = snapshotData['reviewer_uid'] as String?;
    _rating = castToType<int>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('club_reviews');

  static Stream<ClubReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClubReviewsRecord.fromSnapshot(s));

  static Future<ClubReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClubReviewsRecord.fromSnapshot(s));

  static ClubReviewsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ClubReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClubReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClubReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClubReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClubReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClubReviewsRecordData({
  String? reviewId,
  String? clubId,
  String? reviewerUid,
  int? rating,
  String? comment,
  DateTime? createdTime,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'review_id': reviewId,
      'club_id': clubId,
      'reviewer_uid': reviewerUid,
      'rating': rating,
      'comment': comment,
      'created_time': createdTime,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClubReviewsRecordDocumentEquality implements Equality<ClubReviewsRecord> {
  const ClubReviewsRecordDocumentEquality();

  @override
  bool equals(ClubReviewsRecord? e1, ClubReviewsRecord? e2) {
    return e1?.reviewId == e2?.reviewId &&
        e1?.clubId == e2?.clubId &&
        e1?.reviewerUid == e2?.reviewerUid &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.createdTime == e2?.createdTime &&
        e1?.status == e2?.status;
  }

  @override
  int hash(ClubReviewsRecord? e) => const ListEquality().hash([
        e?.reviewId,
        e?.clubId,
        e?.reviewerUid,
        e?.rating,
        e?.comment,
        e?.createdTime,
        e?.status
      ]);

  @override
  bool isValidKey(Object? o) => o is ClubReviewsRecord;
}
