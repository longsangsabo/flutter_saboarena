import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClubMembersRecord extends FirestoreRecord {
  ClubMembersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "member_id" field.
  String? _memberId;
  String get memberId => _memberId ?? '';
  bool hasMemberId() => _memberId != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "joined_time" field.
  DateTime? _joinedTime;
  DateTime? get joinedTime => _joinedTime;
  bool hasJoinedTime() => _joinedTime != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _memberId = snapshotData['member_id'] as String?;
    _clubId = snapshotData['club_id'] as String?;
    _role = snapshotData['role'] as String?;
    _joinedTime = snapshotData['joined_time'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('club_members');

  static Stream<ClubMembersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClubMembersRecord.fromSnapshot(s));

  static Future<ClubMembersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClubMembersRecord.fromSnapshot(s));

  static ClubMembersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ClubMembersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClubMembersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClubMembersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClubMembersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClubMembersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClubMembersRecordData({
  String? memberId,
  String? clubId,
  String? role,
  DateTime? joinedTime,
  String? status,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'member_id': memberId,
      'club_id': clubId,
      'role': role,
      'joined_time': joinedTime,
      'status': status,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClubMembersRecordDocumentEquality implements Equality<ClubMembersRecord> {
  const ClubMembersRecordDocumentEquality();

  @override
  bool equals(ClubMembersRecord? e1, ClubMembersRecord? e2) {
    return e1?.memberId == e2?.memberId &&
        e1?.clubId == e2?.clubId &&
        e1?.role == e2?.role &&
        e1?.joinedTime == e2?.joinedTime &&
        e1?.status == e2?.status &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(ClubMembersRecord? e) => const ListEquality().hash(
      [e?.memberId, e?.clubId, e?.role, e?.joinedTime, e?.status, e?.uid]);

  @override
  bool isValidKey(Object? o) => o is ClubMembersRecord;
}
