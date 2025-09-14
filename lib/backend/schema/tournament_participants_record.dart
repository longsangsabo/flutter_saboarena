import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TournamentParticipantsRecord extends FirestoreRecord {
  TournamentParticipantsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "participant_id" field.
  String? _participantId;
  String get participantId => _participantId ?? '';
  bool hasParticipantId() => _participantId != null;

  // "tournament_id" field.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  // "user_rank" field.
  String? _userRank;
  String get userRank => _userRank ?? '';
  bool hasUserRank() => _userRank != null;

  // "registration_time" field.
  DateTime? _registrationTime;
  DateTime? get registrationTime => _registrationTime;
  bool hasRegistrationTime() => _registrationTime != null;

  // "payment_status" field.
  String? _paymentStatus;
  String get paymentStatus => _paymentStatus ?? '';
  bool hasPaymentStatus() => _paymentStatus != null;

  // "entry_fee_paid" field.
  int? _entryFeePaid;
  int get entryFeePaid => _entryFeePaid ?? 0;
  bool hasEntryFeePaid() => _entryFeePaid != null;

  // "current_round" field.
  int? _currentRound;
  int get currentRound => _currentRound ?? 0;
  bool hasCurrentRound() => _currentRound != null;

  // "bracket_position" field.
  int? _bracketPosition;
  int get bracketPosition => _bracketPosition ?? 0;
  bool hasBracketPosition() => _bracketPosition != null;

  // "wins" field.
  int? _wins;
  int get wins => _wins ?? 0;
  bool hasWins() => _wins != null;

  // "losses" field.
  int? _losses;
  int get losses => _losses ?? 0;
  bool hasLosses() => _losses != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "elimination_round" field.
  int? _eliminationRound;
  int get eliminationRound => _eliminationRound ?? 0;
  bool hasEliminationRound() => _eliminationRound != null;

  // "final_ranking" field.
  int? _finalRanking;
  int get finalRanking => _finalRanking ?? 0;
  bool hasFinalRanking() => _finalRanking != null;

  // "prize_amount" field.
  int? _prizeAmount;
  int get prizeAmount => _prizeAmount ?? 0;
  bool hasPrizeAmount() => _prizeAmount != null;

  // "prize_status" field.
  String? _prizeStatus;
  String get prizeStatus => _prizeStatus ?? '';
  bool hasPrizeStatus() => _prizeStatus != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _participantId = snapshotData['participant_id'] as String?;
    _tournamentId = snapshotData['tournament_id'] as String?;
    _userRank = snapshotData['user_rank'] as String?;
    _registrationTime = snapshotData['registration_time'] as DateTime?;
    _paymentStatus = snapshotData['payment_status'] as String?;
    _entryFeePaid = castToType<int>(snapshotData['entry_fee_paid']);
    _currentRound = castToType<int>(snapshotData['current_round']);
    _bracketPosition = castToType<int>(snapshotData['bracket_position']);
    _wins = castToType<int>(snapshotData['wins']);
    _losses = castToType<int>(snapshotData['losses']);
    _status = snapshotData['status'] as String?;
    _eliminationRound = castToType<int>(snapshotData['elimination_round']);
    _finalRanking = castToType<int>(snapshotData['final_ranking']);
    _prizeAmount = castToType<int>(snapshotData['prize_amount']);
    _prizeStatus = snapshotData['prize_status'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tournament_participants');

  static Stream<TournamentParticipantsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => TournamentParticipantsRecord.fromSnapshot(s));

  static Future<TournamentParticipantsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => TournamentParticipantsRecord.fromSnapshot(s));

  static TournamentParticipantsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TournamentParticipantsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TournamentParticipantsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TournamentParticipantsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TournamentParticipantsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TournamentParticipantsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTournamentParticipantsRecordData({
  String? participantId,
  String? tournamentId,
  String? userRank,
  DateTime? registrationTime,
  String? paymentStatus,
  int? entryFeePaid,
  int? currentRound,
  int? bracketPosition,
  int? wins,
  int? losses,
  String? status,
  int? eliminationRound,
  int? finalRanking,
  int? prizeAmount,
  String? prizeStatus,
  DateTime? createdTime,
  DateTime? updatedTime,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'participant_id': participantId,
      'tournament_id': tournamentId,
      'user_rank': userRank,
      'registration_time': registrationTime,
      'payment_status': paymentStatus,
      'entry_fee_paid': entryFeePaid,
      'current_round': currentRound,
      'bracket_position': bracketPosition,
      'wins': wins,
      'losses': losses,
      'status': status,
      'elimination_round': eliminationRound,
      'final_ranking': finalRanking,
      'prize_amount': prizeAmount,
      'prize_status': prizeStatus,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class TournamentParticipantsRecordDocumentEquality
    implements Equality<TournamentParticipantsRecord> {
  const TournamentParticipantsRecordDocumentEquality();

  @override
  bool equals(
      TournamentParticipantsRecord? e1, TournamentParticipantsRecord? e2) {
    return e1?.participantId == e2?.participantId &&
        e1?.tournamentId == e2?.tournamentId &&
        e1?.userRank == e2?.userRank &&
        e1?.registrationTime == e2?.registrationTime &&
        e1?.paymentStatus == e2?.paymentStatus &&
        e1?.entryFeePaid == e2?.entryFeePaid &&
        e1?.currentRound == e2?.currentRound &&
        e1?.bracketPosition == e2?.bracketPosition &&
        e1?.wins == e2?.wins &&
        e1?.losses == e2?.losses &&
        e1?.status == e2?.status &&
        e1?.eliminationRound == e2?.eliminationRound &&
        e1?.finalRanking == e2?.finalRanking &&
        e1?.prizeAmount == e2?.prizeAmount &&
        e1?.prizeStatus == e2?.prizeStatus &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(TournamentParticipantsRecord? e) => const ListEquality().hash([
        e?.participantId,
        e?.tournamentId,
        e?.userRank,
        e?.registrationTime,
        e?.paymentStatus,
        e?.entryFeePaid,
        e?.currentRound,
        e?.bracketPosition,
        e?.wins,
        e?.losses,
        e?.status,
        e?.eliminationRound,
        e?.finalRanking,
        e?.prizeAmount,
        e?.prizeStatus,
        e?.createdTime,
        e?.updatedTime,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is TournamentParticipantsRecord;
}
