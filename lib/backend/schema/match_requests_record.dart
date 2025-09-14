import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchRequestsRecord extends FirestoreRecord {
  MatchRequestsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "request_id" field.
  String? _requestId;
  String get requestId => _requestId ?? '';
  bool hasRequestId() => _requestId != null;

  // "creator_uid" field.
  String? _creatorUid;
  String get creatorUid => _creatorUid ?? '';
  bool hasCreatorUid() => _creatorUid != null;

  // "request_type" field.
  String? _requestType;
  String get requestType => _requestType ?? '';
  bool hasRequestType() => _requestType != null;

  // "game_type" field.
  String? _gameType;
  String get gameType => _gameType ?? '';
  bool hasGameType() => _gameType != null;

  // "race_to" field.
  int? _raceTo;
  int get raceTo => _raceTo ?? 0;
  bool hasRaceTo() => _raceTo != null;

  // "handicap" field.
  double? _handicap;
  double get handicap => _handicap ?? 0.0;
  bool hasHandicap() => _handicap != null;

  // "spa_bet" field.
  int? _spaBet;
  int get spaBet => _spaBet ?? 0;
  bool hasSpaBet() => _spaBet != null;

  // "table_number" field.
  int? _tableNumber;
  int get tableNumber => _tableNumber ?? 0;
  bool hasTableNumber() => _tableNumber != null;

  // "scheduled_time" field.
  DateTime? _scheduledTime;
  DateTime? get scheduledTime => _scheduledTime;
  bool hasScheduledTime() => _scheduledTime != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "opponent_uid" field.
  String? _opponentUid;
  String get opponentUid => _opponentUid ?? '';
  bool hasOpponentUid() => _opponentUid != null;

  // "expires_at" field.
  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;
  bool hasExpiresAt() => _expiresAt != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  void _initializeFields() {
    _requestId = snapshotData['request_id'] as String?;
    _creatorUid = snapshotData['creator_uid'] as String?;
    _requestType = snapshotData['request_type'] as String?;
    _gameType = snapshotData['game_type'] as String?;
    _raceTo = castToType<int>(snapshotData['race_to']);
    _handicap = castToType<double>(snapshotData['handicap']);
    _spaBet = castToType<int>(snapshotData['spa_bet']);
    _tableNumber = castToType<int>(snapshotData['table_number']);
    _scheduledTime = snapshotData['scheduled_time'] as DateTime?;
    _clubId = snapshotData['club_id'] as String?;
    _location = snapshotData['location'] as String?;
    _status = snapshotData['status'] as String?;
    _opponentUid = snapshotData['opponent_uid'] as String?;
    _expiresAt = snapshotData['expires_at'] as DateTime?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('match_requests');

  static Stream<MatchRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchRequestsRecord.fromSnapshot(s));

  static Future<MatchRequestsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchRequestsRecord.fromSnapshot(s));

  static MatchRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchRequestsRecordData({
  String? requestId,
  String? creatorUid,
  String? requestType,
  String? gameType,
  int? raceTo,
  double? handicap,
  int? spaBet,
  int? tableNumber,
  DateTime? scheduledTime,
  String? clubId,
  String? location,
  String? status,
  String? opponentUid,
  DateTime? expiresAt,
  String? title,
  String? description,
  DateTime? createdTime,
  DateTime? updatedTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'request_id': requestId,
      'creator_uid': creatorUid,
      'request_type': requestType,
      'game_type': gameType,
      'race_to': raceTo,
      'handicap': handicap,
      'spa_bet': spaBet,
      'table_number': tableNumber,
      'scheduled_time': scheduledTime,
      'club_id': clubId,
      'location': location,
      'status': status,
      'opponent_uid': opponentUid,
      'expires_at': expiresAt,
      'title': title,
      'description': description,
      'created_time': createdTime,
      'updated_time': updatedTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchRequestsRecordDocumentEquality
    implements Equality<MatchRequestsRecord> {
  const MatchRequestsRecordDocumentEquality();

  @override
  bool equals(MatchRequestsRecord? e1, MatchRequestsRecord? e2) {
    return e1?.requestId == e2?.requestId &&
        e1?.creatorUid == e2?.creatorUid &&
        e1?.requestType == e2?.requestType &&
        e1?.gameType == e2?.gameType &&
        e1?.raceTo == e2?.raceTo &&
        e1?.handicap == e2?.handicap &&
        e1?.spaBet == e2?.spaBet &&
        e1?.tableNumber == e2?.tableNumber &&
        e1?.scheduledTime == e2?.scheduledTime &&
        e1?.clubId == e2?.clubId &&
        e1?.location == e2?.location &&
        e1?.status == e2?.status &&
        e1?.opponentUid == e2?.opponentUid &&
        e1?.expiresAt == e2?.expiresAt &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime;
  }

  @override
  int hash(MatchRequestsRecord? e) => const ListEquality().hash([
        e?.requestId,
        e?.creatorUid,
        e?.requestType,
        e?.gameType,
        e?.raceTo,
        e?.handicap,
        e?.spaBet,
        e?.tableNumber,
        e?.scheduledTime,
        e?.clubId,
        e?.location,
        e?.status,
        e?.opponentUid,
        e?.expiresAt,
        e?.title,
        e?.description,
        e?.createdTime,
        e?.updatedTime
      ]);

  @override
  bool isValidKey(Object? o) => o is MatchRequestsRecord;
}
