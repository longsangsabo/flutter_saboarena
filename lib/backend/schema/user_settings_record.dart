import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserSettingsRecord extends FirestoreRecord {
  UserSettingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "notification_match" field.
  bool? _notificationMatch;
  bool get notificationMatch => _notificationMatch ?? false;
  bool hasNotificationMatch() => _notificationMatch != null;

  // "notification_tournament" field.
  bool? _notificationTournament;
  bool get notificationTournament => _notificationTournament ?? false;
  bool hasNotificationTournament() => _notificationTournament != null;

  // "privacy_profile" field.
  String? _privacyProfile;
  String get privacyProfile => _privacyProfile ?? '';
  bool hasPrivacyProfile() => _privacyProfile != null;

  // "language" field.
  String? _language;
  String get language => _language ?? '';
  bool hasLanguage() => _language != null;

  // "theme" field.
  String? _theme;
  String get theme => _theme ?? '';
  bool hasTheme() => _theme != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _notificationMatch = snapshotData['notification_match'] as bool?;
    _notificationTournament = snapshotData['notification_tournament'] as bool?;
    _privacyProfile = snapshotData['privacy_profile'] as String?;
    _language = snapshotData['language'] as String?;
    _theme = snapshotData['theme'] as String?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_settings');

  static Stream<UserSettingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserSettingsRecord.fromSnapshot(s));

  static Future<UserSettingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserSettingsRecord.fromSnapshot(s));

  static UserSettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserSettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserSettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserSettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserSettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserSettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserSettingsRecordData({
  bool? notificationMatch,
  bool? notificationTournament,
  String? privacyProfile,
  String? language,
  String? theme,
  DateTime? updatedTime,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'notification_match': notificationMatch,
      'notification_tournament': notificationTournament,
      'privacy_profile': privacyProfile,
      'language': language,
      'theme': theme,
      'updated_time': updatedTime,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserSettingsRecordDocumentEquality
    implements Equality<UserSettingsRecord> {
  const UserSettingsRecordDocumentEquality();

  @override
  bool equals(UserSettingsRecord? e1, UserSettingsRecord? e2) {
    return e1?.notificationMatch == e2?.notificationMatch &&
        e1?.notificationTournament == e2?.notificationTournament &&
        e1?.privacyProfile == e2?.privacyProfile &&
        e1?.language == e2?.language &&
        e1?.theme == e2?.theme &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(UserSettingsRecord? e) => const ListEquality().hash([
        e?.notificationMatch,
        e?.notificationTournament,
        e?.privacyProfile,
        e?.language,
        e?.theme,
        e?.updatedTime,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is UserSettingsRecord;
}
