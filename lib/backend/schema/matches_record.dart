import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MatchesRecord extends FirestoreRecord {
  MatchesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "match_id" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "match_type" field.
  String? _matchType;
  String get matchType => _matchType ?? '';
  bool hasMatchType() => _matchType != null;

  // "game_type" field.
  String? _gameType;
  String get gameType => _gameType ?? '';
  bool hasGameType() => _gameType != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "player1_uid" field.
  String? _player1Uid;
  String get player1Uid => _player1Uid ?? '';
  bool hasPlayer1Uid() => _player1Uid != null;

  // "player2_uid" field.
  String? _player2Uid;
  String get player2Uid => _player2Uid ?? '';
  bool hasPlayer2Uid() => _player2Uid != null;

  // "player1_rank" field.
  String? _player1Rank;
  String get player1Rank => _player1Rank ?? '';
  bool hasPlayer1Rank() => _player1Rank != null;

  // "player2_rank" field.
  String? _player2Rank;
  String get player2Rank => _player2Rank ?? '';
  bool hasPlayer2Rank() => _player2Rank != null;

  // "race_to" field.
  int? _raceTo;
  int get raceTo => _raceTo ?? 0;
  bool hasRaceTo() => _raceTo != null;

  // "handicap" field.
  double? _handicap;
  double get handicap => _handicap ?? 0.0;
  bool hasHandicap() => _handicap != null;

  // "table_number" field.
  int? _tableNumber;
  int get tableNumber => _tableNumber ?? 0;
  bool hasTableNumber() => _tableNumber != null;

  // "spa_bet" field.
  int? _spaBet;
  int get spaBet => _spaBet ?? 0;
  bool hasSpaBet() => _spaBet != null;

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

  // "winner_uid" field.
  String? _winnerUid;
  String get winnerUid => _winnerUid ?? '';
  bool hasWinnerUid() => _winnerUid != null;

  // "final_score" field.
  String? _finalScore;
  String get finalScore => _finalScore ?? '';
  bool hasFinalScore() => _finalScore != null;

  // "completed_time" field.
  DateTime? _completedTime;
  DateTime? get completedTime => _completedTime;
  bool hasCompletedTime() => _completedTime != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "club_confirmed" field.
  bool? _clubConfirmed;
  bool get clubConfirmed => _clubConfirmed ?? false;
  bool hasClubConfirmed() => _clubConfirmed != null;

  // "club_confirmed_by" field.
  String? _clubConfirmedBy;
  String get clubConfirmedBy => _clubConfirmedBy ?? '';
  bool hasClubConfirmedBy() => _clubConfirmedBy != null;

  // "club_confirmed_time" field.
  DateTime? _clubConfirmedTime;
  DateTime? get clubConfirmedTime => _clubConfirmedTime;
  bool hasClubConfirmedTime() => _clubConfirmedTime != null;

  // "requires_club_confirmation" field.
  bool? _requiresClubConfirmation;
  bool get requiresClubConfirmation => _requiresClubConfirmation ?? false;
  bool hasRequiresClubConfirmation() => _requiresClubConfirmation != null;

  void _initializeFields() {
    _matchId = snapshotData['match_id'] as String?;
    _matchType = snapshotData['match_type'] as String?;
    _gameType = snapshotData['game_type'] as String?;
    _status = snapshotData['status'] as String?;
    _player1Uid = snapshotData['player1_uid'] as String?;
    _player2Uid = snapshotData['player2_uid'] as String?;
    _player1Rank = snapshotData['player1_rank'] as String?;
    _player2Rank = snapshotData['player2_rank'] as String?;
    _raceTo = castToType<int>(snapshotData['race_to']);
    _handicap = castToType<double>(snapshotData['handicap']);
    _tableNumber = castToType<int>(snapshotData['table_number']);
    _spaBet = castToType<int>(snapshotData['spa_bet']);
    _scheduledTime = snapshotData['scheduled_time'] as DateTime?;
    _clubId = snapshotData['club_id'] as String?;
    _location = snapshotData['location'] as String?;
    _winnerUid = snapshotData['winner_uid'] as String?;
    _finalScore = snapshotData['final_score'] as String?;
    _completedTime = snapshotData['completed_time'] as DateTime?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _clubConfirmed = snapshotData['club_confirmed'] as bool?;
    _clubConfirmedBy = snapshotData['club_confirmed_by'] as String?;
    _clubConfirmedTime = snapshotData['club_confirmed_time'] as DateTime?;
    _requiresClubConfirmation =
        snapshotData['requires_club_confirmation'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('matches');

  static Stream<MatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchesRecord.fromSnapshot(s));

  static Future<MatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchesRecord.fromSnapshot(s));

  static MatchesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MatchesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MatchesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchesRecordData({
  String? matchId,
  String? matchType,
  String? gameType,
  String? status,
  String? player1Uid,
  String? player2Uid,
  String? player1Rank,
  String? player2Rank,
  int? raceTo,
  double? handicap,
  int? tableNumber,
  int? spaBet,
  DateTime? scheduledTime,
  String? clubId,
  String? location,
  String? winnerUid,
  String? finalScore,
  DateTime? completedTime,
  DateTime? createdTime,
  DateTime? updatedTime,
  bool? clubConfirmed,
  String? clubConfirmedBy,
  DateTime? clubConfirmedTime,
  bool? requiresClubConfirmation,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'match_id': matchId,
      'match_type': matchType,
      'game_type': gameType,
      'status': status,
      'player1_uid': player1Uid,
      'player2_uid': player2Uid,
      'player1_rank': player1Rank,
      'player2_rank': player2Rank,
      'race_to': raceTo,
      'handicap': handicap,
      'table_number': tableNumber,
      'spa_bet': spaBet,
      'scheduled_time': scheduledTime,
      'club_id': clubId,
      'location': location,
      'winner_uid': winnerUid,
      'final_score': finalScore,
      'completed_time': completedTime,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'club_confirmed': clubConfirmed,
      'club_confirmed_by': clubConfirmedBy,
      'club_confirmed_time': clubConfirmedTime,
      'requires_club_confirmation': requiresClubConfirmation,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchesRecordDocumentEquality implements Equality<MatchesRecord> {
  const MatchesRecordDocumentEquality();

  @override
  bool equals(MatchesRecord? e1, MatchesRecord? e2) {
    return e1?.matchId == e2?.matchId &&
        e1?.matchType == e2?.matchType &&
        e1?.gameType == e2?.gameType &&
        e1?.status == e2?.status &&
        e1?.player1Uid == e2?.player1Uid &&
        e1?.player2Uid == e2?.player2Uid &&
        e1?.player1Rank == e2?.player1Rank &&
        e1?.player2Rank == e2?.player2Rank &&
        e1?.raceTo == e2?.raceTo &&
        e1?.handicap == e2?.handicap &&
        e1?.tableNumber == e2?.tableNumber &&
        e1?.spaBet == e2?.spaBet &&
        e1?.scheduledTime == e2?.scheduledTime &&
        e1?.clubId == e2?.clubId &&
        e1?.location == e2?.location &&
        e1?.winnerUid == e2?.winnerUid &&
        e1?.finalScore == e2?.finalScore &&
        e1?.completedTime == e2?.completedTime &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.clubConfirmed == e2?.clubConfirmed &&
        e1?.clubConfirmedBy == e2?.clubConfirmedBy &&
        e1?.clubConfirmedTime == e2?.clubConfirmedTime &&
        e1?.requiresClubConfirmation == e2?.requiresClubConfirmation;
  }

  @override
  int hash(MatchesRecord? e) => const ListEquality().hash([
        e?.matchId,
        e?.matchType,
        e?.gameType,
        e?.status,
        e?.player1Uid,
        e?.player2Uid,
        e?.player1Rank,
        e?.player2Rank,
        e?.raceTo,
        e?.handicap,
        e?.tableNumber,
        e?.spaBet,
        e?.scheduledTime,
        e?.clubId,
        e?.location,
        e?.winnerUid,
        e?.finalScore,
        e?.completedTime,
        e?.createdTime,
        e?.updatedTime,
        e?.clubConfirmed,
        e?.clubConfirmedBy,
        e?.clubConfirmedTime,
        e?.requiresClubConfirmation
      ]);

  @override
  bool isValidKey(Object? o) => o is MatchesRecord;
}
