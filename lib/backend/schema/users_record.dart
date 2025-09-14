import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "total_matches" field.
  int? _totalMatches;
  int get totalMatches => _totalMatches ?? 0;
  bool hasTotalMatches() => _totalMatches != null;

  // "overall_ranking" field.
  int? _overallRanking;
  int get overallRanking => _overallRanking ?? 0;
  bool hasOverallRanking() => _overallRanking != null;

  // "win_rate" field.
  double? _winRate;
  double get winRate => _winRate ?? 0.0;
  bool hasWinRate() => _winRate != null;

  // "is_online" field.
  bool? _isOnline;
  bool get isOnline => _isOnline ?? false;
  bool hasIsOnline() => _isOnline != null;

  // "last_active" field.
  DateTime? _lastActive;
  DateTime? get lastActive => _lastActive;
  bool hasLastActive() => _lastActive != null;

  // "account_status" field.
  String? _accountStatus;
  String get accountStatus => _accountStatus ?? '';
  bool hasAccountStatus() => _accountStatus != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "full_name" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  bool hasFullName() => _fullName != null;

  // "rank" field.
  String? _rank;
  String get rank => _rank ?? '';
  bool hasRank() => _rank != null;

  // "elo_rating" field.
  int? _eloRating;
  int get eloRating => _eloRating ?? 0;
  bool hasEloRating() => _eloRating != null;

  // "spa_points" field.
  int? _spaPoints;
  int get spaPoints => _spaPoints ?? 0;
  bool hasSpaPoints() => _spaPoints != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "preferred_game_type" field.
  String? _preferredGameType;
  String get preferredGameType => _preferredGameType ?? '';
  bool hasPreferredGameType() => _preferredGameType != null;

  // "available_times" field.
  List<DateTime>? _availableTimes;
  List<DateTime> get availableTimes => _availableTimes ?? const [];
  bool hasAvailableTimes() => _availableTimes != null;

  // "followers_count" field.
  int? _followersCount;
  int get followersCount => _followersCount ?? 0;
  bool hasFollowersCount() => _followersCount != null;

  // "following_count" field.
  int? _followingCount;
  int get followingCount => _followingCount ?? 0;
  bool hasFollowingCount() => _followingCount != null;

  // "club_id" field.
  String? _clubId;
  String get clubId => _clubId ?? '';
  bool hasClubId() => _clubId != null;

  // "user_name" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _location = snapshotData['location'] as String?;
    _totalMatches = castToType<int>(snapshotData['total_matches']);
    _overallRanking = castToType<int>(snapshotData['overall_ranking']);
    _winRate = castToType<double>(snapshotData['win_rate']);
    _isOnline = snapshotData['is_online'] as bool?;
    _lastActive = snapshotData['last_active'] as DateTime?;
    _accountStatus = snapshotData['account_status'] as String?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _fullName = snapshotData['full_name'] as String?;
    _rank = snapshotData['rank'] as String?;
    _eloRating = castToType<int>(snapshotData['elo_rating']);
    _spaPoints = castToType<int>(snapshotData['spa_points']);
    _bio = snapshotData['bio'] as String?;
    _preferredGameType = snapshotData['preferred_game_type'] as String?;
    _availableTimes = getDataList(snapshotData['available_times']);
    _followersCount = castToType<int>(snapshotData['followers_count']);
    _followingCount = castToType<int>(snapshotData['following_count']);
    _clubId = snapshotData['club_id'] as String?;
    _userName = snapshotData['user_name'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? location,
  int? totalMatches,
  int? overallRanking,
  double? winRate,
  bool? isOnline,
  DateTime? lastActive,
  String? accountStatus,
  DateTime? updatedTime,
  String? fullName,
  String? rank,
  int? eloRating,
  int? spaPoints,
  String? bio,
  String? preferredGameType,
  int? followersCount,
  int? followingCount,
  String? clubId,
  String? userName,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'location': location,
      'total_matches': totalMatches,
      'overall_ranking': overallRanking,
      'win_rate': winRate,
      'is_online': isOnline,
      'last_active': lastActive,
      'account_status': accountStatus,
      'updated_time': updatedTime,
      'full_name': fullName,
      'rank': rank,
      'elo_rating': eloRating,
      'spa_points': spaPoints,
      'bio': bio,
      'preferred_game_type': preferredGameType,
      'followers_count': followersCount,
      'following_count': followingCount,
      'club_id': clubId,
      'user_name': userName,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.location == e2?.location &&
        e1?.totalMatches == e2?.totalMatches &&
        e1?.overallRanking == e2?.overallRanking &&
        e1?.winRate == e2?.winRate &&
        e1?.isOnline == e2?.isOnline &&
        e1?.lastActive == e2?.lastActive &&
        e1?.accountStatus == e2?.accountStatus &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.fullName == e2?.fullName &&
        e1?.rank == e2?.rank &&
        e1?.eloRating == e2?.eloRating &&
        e1?.spaPoints == e2?.spaPoints &&
        e1?.bio == e2?.bio &&
        e1?.preferredGameType == e2?.preferredGameType &&
        listEquality.equals(e1?.availableTimes, e2?.availableTimes) &&
        e1?.followersCount == e2?.followersCount &&
        e1?.followingCount == e2?.followingCount &&
        e1?.clubId == e2?.clubId &&
        e1?.userName == e2?.userName;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.location,
        e?.totalMatches,
        e?.overallRanking,
        e?.winRate,
        e?.isOnline,
        e?.lastActive,
        e?.accountStatus,
        e?.updatedTime,
        e?.fullName,
        e?.rank,
        e?.eloRating,
        e?.spaPoints,
        e?.bio,
        e?.preferredGameType,
        e?.availableTimes,
        e?.followersCount,
        e?.followingCount,
        e?.clubId,
        e?.userName
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
