import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClubStaffRecord extends FirestoreRecord {
  ClubStaffRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "staff_id" field.
  String? _staffId;
  String get staffId => _staffId ?? '';
  bool hasStaffId() => _staffId != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "can_confirm_matches" field.
  bool? _canConfirmMatches;
  bool get canConfirmMatches => _canConfirmMatches ?? false;
  bool hasCanConfirmMatches() => _canConfirmMatches != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _staffId = snapshotData['staff_id'] as String?;
    _clubId = snapshotData['club_id'] as String?;
    _role = snapshotData['role'] as String?;
    _canConfirmMatches = snapshotData['can_confirm_matches'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('club_staff');

  static Stream<ClubStaffRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClubStaffRecord.fromSnapshot(s));

  static Future<ClubStaffRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClubStaffRecord.fromSnapshot(s));

  static ClubStaffRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ClubStaffRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClubStaffRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClubStaffRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClubStaffRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClubStaffRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClubStaffRecordData({
  String? staffId,
  String? clubId,
  String? role,
  bool? canConfirmMatches,
  DateTime? createdTime,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'staff_id': staffId,
      'club_id': clubId,
      'role': role,
      'can_confirm_matches': canConfirmMatches,
      'created_time': createdTime,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClubStaffRecordDocumentEquality implements Equality<ClubStaffRecord> {
  const ClubStaffRecordDocumentEquality();

  @override
  bool equals(ClubStaffRecord? e1, ClubStaffRecord? e2) {
    return e1?.staffId == e2?.staffId &&
        e1?.clubId == e2?.clubId &&
        e1?.role == e2?.role &&
        e1?.canConfirmMatches == e2?.canConfirmMatches &&
        e1?.createdTime == e2?.createdTime &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(ClubStaffRecord? e) => const ListEquality().hash([
        e?.staffId,
        e?.clubId,
        e?.role,
        e?.canConfirmMatches,
        e?.createdTime,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is ClubStaffRecord;
}
