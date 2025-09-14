import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserRelationshipsRecord extends FirestoreRecord {
  UserRelationshipsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "relationship_id" field.
  String? _relationshipId;
  String get relationshipId => _relationshipId ?? '';
  bool hasRelationshipId() => _relationshipId != null;

  // "follower_uid" field.
  String? _followerUid;
  String get followerUid => _followerUid ?? '';
  bool hasFollowerUid() => _followerUid != null;

  // "following_uid" field.
  String? _followingUid;
  String get followingUid => _followingUid ?? '';
  bool hasFollowingUid() => _followingUid != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _relationshipId = snapshotData['relationship_id'] as String?;
    _followerUid = snapshotData['follower_uid'] as String?;
    _followingUid = snapshotData['following_uid'] as String?;
    _status = snapshotData['status'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_relationships');

  static Stream<UserRelationshipsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserRelationshipsRecord.fromSnapshot(s));

  static Future<UserRelationshipsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => UserRelationshipsRecord.fromSnapshot(s));

  static UserRelationshipsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserRelationshipsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserRelationshipsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserRelationshipsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserRelationshipsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserRelationshipsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserRelationshipsRecordData({
  String? relationshipId,
  String? followerUid,
  String? followingUid,
  String? status,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'relationship_id': relationshipId,
      'follower_uid': followerUid,
      'following_uid': followingUid,
      'status': status,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserRelationshipsRecordDocumentEquality
    implements Equality<UserRelationshipsRecord> {
  const UserRelationshipsRecordDocumentEquality();

  @override
  bool equals(UserRelationshipsRecord? e1, UserRelationshipsRecord? e2) {
    return e1?.relationshipId == e2?.relationshipId &&
        e1?.followerUid == e2?.followerUid &&
        e1?.followingUid == e2?.followingUid &&
        e1?.status == e2?.status &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(UserRelationshipsRecord? e) => const ListEquality().hash([
        e?.relationshipId,
        e?.followerUid,
        e?.followingUid,
        e?.status,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is UserRelationshipsRecord;
}
