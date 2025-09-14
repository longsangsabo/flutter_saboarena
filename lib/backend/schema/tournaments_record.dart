import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TournamentsRecord extends FirestoreRecord {
  TournamentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "tournament_id" field.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "tournament_type" field.
  String? _tournamentType;
  String get tournamentType => _tournamentType ?? '';
  bool hasTournamentType() => _tournamentType != null;

  // "game_format" field.
  String? _gameFormat;
  String get gameFormat => _gameFormat ?? '';
  bool hasGameFormat() => _gameFormat != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "max_participants" field.
  int? _maxParticipants;
  int get maxParticipants => _maxParticipants ?? 0;
  bool hasMaxParticipants() => _maxParticipants != null;

  // "current_participants" field.
  int? _currentParticipants;
  int get currentParticipants => _currentParticipants ?? 0;
  bool hasCurrentParticipants() => _currentParticipants != null;

  // "tournament_format" field.
  String? _tournamentFormat;
  String get tournamentFormat => _tournamentFormat ?? '';
  bool hasTournamentFormat() => _tournamentFormat != null;

  // "rank_requirement_min" field.
  String? _rankRequirementMin;
  String get rankRequirementMin => _rankRequirementMin ?? '';
  bool hasRankRequirementMin() => _rankRequirementMin != null;

  // "rank_requirement_max" field.
  String? _rankRequirementMax;
  String get rankRequirementMax => _rankRequirementMax ?? '';
  bool hasRankRequirementMax() => _rankRequirementMax != null;

  // "entry_fee" field.
  int? _entryFee;
  int get entryFee => _entryFee ?? 0;
  bool hasEntryFee() => _entryFee != null;

  // "total_prize" field.
  int? _totalPrize;
  int get totalPrize => _totalPrize ?? 0;
  bool hasTotalPrize() => _totalPrize != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  bool hasCurrency() => _currency != null;

  // "start_time" field.
  DateTime? _startTime;
  DateTime? get startTime => _startTime;
  bool hasStartTime() => _startTime != null;

  // "registration_deadline" field.
  DateTime? _registrationDeadline;
  DateTime? get registrationDeadline => _registrationDeadline;
  bool hasRegistrationDeadline() => _registrationDeadline != null;

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

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  void _initializeFields() {
    _tournamentId = snapshotData['tournament_id'] as String?;
    _name = snapshotData['name'] as String?;
    _tournamentType = snapshotData['tournament_type'] as String?;
    _gameFormat = snapshotData['game_format'] as String?;
    _description = snapshotData['description'] as String?;
    _maxParticipants = castToType<int>(snapshotData['max_participants']);
    _currentParticipants =
        castToType<int>(snapshotData['current_participants']);
    _tournamentFormat = snapshotData['tournament_format'] as String?;
    _rankRequirementMin = snapshotData['rank_requirement_min'] as String?;
    _rankRequirementMax = snapshotData['rank_requirement_max'] as String?;
    _entryFee = castToType<int>(snapshotData['entry_fee']);
    _totalPrize = castToType<int>(snapshotData['total_prize']);
    _currency = snapshotData['currency'] as String?;
    _startTime = snapshotData['start_time'] as DateTime?;
    _registrationDeadline = snapshotData['registration_deadline'] as DateTime?;
    _clubId = snapshotData['club_id'] as String?;
    _location = snapshotData['location'] as String?;
    _status = snapshotData['status'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tournaments');

  static Stream<TournamentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TournamentsRecord.fromSnapshot(s));

  static Future<TournamentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TournamentsRecord.fromSnapshot(s));

  static TournamentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TournamentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TournamentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TournamentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TournamentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TournamentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTournamentsRecordData({
  String? tournamentId,
  String? name,
  String? tournamentType,
  String? gameFormat,
  String? description,
  int? maxParticipants,
  int? currentParticipants,
  String? tournamentFormat,
  String? rankRequirementMin,
  String? rankRequirementMax,
  int? entryFee,
  int? totalPrize,
  String? currency,
  DateTime? startTime,
  DateTime? registrationDeadline,
  String? clubId,
  String? location,
  String? status,
  DateTime? createdTime,
  DateTime? updatedTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'tournament_id': tournamentId,
      'name': name,
      'tournament_type': tournamentType,
      'game_format': gameFormat,
      'description': description,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'tournament_format': tournamentFormat,
      'rank_requirement_min': rankRequirementMin,
      'rank_requirement_max': rankRequirementMax,
      'entry_fee': entryFee,
      'total_prize': totalPrize,
      'currency': currency,
      'start_time': startTime,
      'registration_deadline': registrationDeadline,
      'club_id': clubId,
      'location': location,
      'status': status,
      'created_time': createdTime,
      'updated_time': updatedTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class TournamentsRecordDocumentEquality implements Equality<TournamentsRecord> {
  const TournamentsRecordDocumentEquality();

  @override
  bool equals(TournamentsRecord? e1, TournamentsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.name == e2?.name &&
        e1?.tournamentType == e2?.tournamentType &&
        e1?.gameFormat == e2?.gameFormat &&
        e1?.description == e2?.description &&
        e1?.maxParticipants == e2?.maxParticipants &&
        e1?.currentParticipants == e2?.currentParticipants &&
        e1?.tournamentFormat == e2?.tournamentFormat &&
        e1?.rankRequirementMin == e2?.rankRequirementMin &&
        e1?.rankRequirementMax == e2?.rankRequirementMax &&
        e1?.entryFee == e2?.entryFee &&
        e1?.totalPrize == e2?.totalPrize &&
        e1?.currency == e2?.currency &&
        e1?.startTime == e2?.startTime &&
        e1?.registrationDeadline == e2?.registrationDeadline &&
        e1?.clubId == e2?.clubId &&
        e1?.location == e2?.location &&
        e1?.status == e2?.status &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime;
  }

  @override
  int hash(TournamentsRecord? e) => const ListEquality().hash([
        e?.tournamentId,
        e?.name,
        e?.tournamentType,
        e?.gameFormat,
        e?.description,
        e?.maxParticipants,
        e?.currentParticipants,
        e?.tournamentFormat,
        e?.rankRequirementMin,
        e?.rankRequirementMax,
        e?.entryFee,
        e?.totalPrize,
        e?.currency,
        e?.startTime,
        e?.registrationDeadline,
        e?.clubId,
        e?.location,
        e?.status,
        e?.createdTime,
        e?.updatedTime
      ]);

  @override
  bool isValidKey(Object? o) => o is TournamentsRecord;
}
