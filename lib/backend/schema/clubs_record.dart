import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClubsRecord extends FirestoreRecord {
  ClubsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "logo_url" field.
  String? _logoUrl;
  String get logoUrl => _logoUrl ?? '';
  bool hasLogoUrl() => _logoUrl != null;

  // "cover_image_url" field.
  String? _coverImageUrl;
  String get coverImageUrl => _coverImageUrl ?? '';
  bool hasCoverImageUrl() => _coverImageUrl != null;

  // "social_handle" field.
  String? _socialHandle;
  String get socialHandle => _socialHandle ?? '';
  bool hasSocialHandle() => _socialHandle != null;

  // "members_count" field.
  int? _membersCount;
  int get membersCount => _membersCount ?? 0;
  bool hasMembersCount() => _membersCount != null;

  // "tournaments_count" field.
  int? _tournamentsCount;
  int get tournamentsCount => _tournamentsCount ?? 0;
  bool hasTournamentsCount() => _tournamentsCount != null;

  // "chalengers_count" field.
  int? _chalengersCount;
  int get chalengersCount => _chalengersCount ?? 0;
  bool hasChalengersCount() => _chalengersCount != null;

  // "prize_pool_count" field.
  double? _prizePoolCount;
  double get prizePoolCount => _prizePoolCount ?? 0.0;
  bool hasPrizePoolCount() => _prizePoolCount != null;

  // "club_ranking" field.
  int? _clubRanking;
  int get clubRanking => _clubRanking ?? 0;
  bool hasClubRanking() => _clubRanking != null;

  // "total_tables" field.
  int? _totalTables;
  int get totalTables => _totalTables ?? 0;
  bool hasTotalTables() => _totalTables != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "verified" field.
  bool? _verified;
  bool get verified => _verified ?? false;
  bool hasVerified() => _verified != null;

  // "allow_tournaments" field.
  bool? _allowTournaments;
  bool get allowTournaments => _allowTournaments ?? false;
  bool hasAllowTournaments() => _allowTournaments != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "owner_uid" field.
  String? _ownerUid;
  String get ownerUid => _ownerUid ?? '';
  bool hasOwnerUid() => _ownerUid != null;

  void _initializeFields() {
    _clubId = snapshotData['club_id'] as String?;
    _name = snapshotData['name'] as String?;
    _address = snapshotData['address'] as String?;
    _phone = snapshotData['phone'] as String?;
    _description = snapshotData['description'] as String?;
    _logoUrl = snapshotData['logo_url'] as String?;
    _coverImageUrl = snapshotData['cover_image_url'] as String?;
    _socialHandle = snapshotData['social_handle'] as String?;
    _membersCount = castToType<int>(snapshotData['members_count']);
    _tournamentsCount = castToType<int>(snapshotData['tournaments_count']);
    _chalengersCount = castToType<int>(snapshotData['chalengers_count']);
    _prizePoolCount = castToType<double>(snapshotData['prize_pool_count']);
    _clubRanking = castToType<int>(snapshotData['club_ranking']);
    _totalTables = castToType<int>(snapshotData['total_tables']);
    _status = snapshotData['status'] as String?;
    _verified = snapshotData['verified'] as bool?;
    _allowTournaments = snapshotData['allow_tournaments'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _ownerUid = snapshotData['owner_uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('clubs');

  static Stream<ClubsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClubsRecord.fromSnapshot(s));

  static Future<ClubsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClubsRecord.fromSnapshot(s));

  static ClubsRecord fromSnapshot(DocumentSnapshot snapshot) => ClubsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClubsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClubsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClubsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClubsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClubsRecordData({
  String? clubId,
  String? name,
  String? address,
  String? phone,
  String? description,
  String? logoUrl,
  String? coverImageUrl,
  String? socialHandle,
  int? membersCount,
  int? tournamentsCount,
  int? chalengersCount,
  double? prizePoolCount,
  int? clubRanking,
  int? totalTables,
  String? status,
  bool? verified,
  bool? allowTournaments,
  DateTime? createdTime,
  DateTime? updatedTime,
  String? ownerUid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'club_id': clubId,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'social_handle': socialHandle,
      'members_count': membersCount,
      'tournaments_count': tournamentsCount,
      'chalengers_count': chalengersCount,
      'prize_pool_count': prizePoolCount,
      'club_ranking': clubRanking,
      'total_tables': totalTables,
      'status': status,
      'verified': verified,
      'allow_tournaments': allowTournaments,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'owner_uid': ownerUid,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClubsRecordDocumentEquality implements Equality<ClubsRecord> {
  const ClubsRecordDocumentEquality();

  @override
  bool equals(ClubsRecord? e1, ClubsRecord? e2) {
    return e1?.clubId == e2?.clubId &&
        e1?.name == e2?.name &&
        e1?.address == e2?.address &&
        e1?.phone == e2?.phone &&
        e1?.description == e2?.description &&
        e1?.logoUrl == e2?.logoUrl &&
        e1?.coverImageUrl == e2?.coverImageUrl &&
        e1?.socialHandle == e2?.socialHandle &&
        e1?.membersCount == e2?.membersCount &&
        e1?.tournamentsCount == e2?.tournamentsCount &&
        e1?.chalengersCount == e2?.chalengersCount &&
        e1?.prizePoolCount == e2?.prizePoolCount &&
        e1?.clubRanking == e2?.clubRanking &&
        e1?.totalTables == e2?.totalTables &&
        e1?.status == e2?.status &&
        e1?.verified == e2?.verified &&
        e1?.allowTournaments == e2?.allowTournaments &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.ownerUid == e2?.ownerUid;
  }

  @override
  int hash(ClubsRecord? e) => const ListEquality().hash([
        e?.clubId,
        e?.name,
        e?.address,
        e?.phone,
        e?.description,
        e?.logoUrl,
        e?.coverImageUrl,
        e?.socialHandle,
        e?.membersCount,
        e?.tournamentsCount,
        e?.chalengersCount,
        e?.prizePoolCount,
        e?.clubRanking,
        e?.totalTables,
        e?.status,
        e?.verified,
        e?.allowTournaments,
        e?.createdTime,
        e?.updatedTime,
        e?.ownerUid
      ]);

  @override
  bool isValidKey(Object? o) => o is ClubsRecord;
}
