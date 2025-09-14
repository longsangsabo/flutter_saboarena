import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "notification_id" field.
  String? _notificationId;
  String get notificationId => _notificationId ?? '';
  bool hasNotificationId() => _notificationId != null;

  // "recipient_uid" field.
  String? _recipientUid;
  String get recipientUid => _recipientUid ?? '';
  bool hasRecipientUid() => _recipientUid != null;

  // "sender_uid" field.
  String? _senderUid;
  String get senderUid => _senderUid ?? '';
  bool hasSenderUid() => _senderUid != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "action_text" field.
  String? _actionText;
  String get actionText => _actionText ?? '';
  bool hasActionText() => _actionText != null;

  // "match_id" field.
  String? _matchId;
  String get matchId => _matchId ?? '';
  bool hasMatchId() => _matchId != null;

  // "tournament_id" field.
  String? _tournamentId;
  String get tournamentId => _tournamentId ?? '';
  bool hasTournamentId() => _tournamentId != null;

  // "request_id" field.
  String? _requestId;
  String get requestId => _requestId ?? '';
  bool hasRequestId() => _requestId != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "is_clicked" field.
  bool? _isClicked;
  bool get isClicked => _isClicked ?? false;
  bool hasIsClicked() => _isClicked != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "expires_at" field.
  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;
  bool hasExpiresAt() => _expiresAt != null;

  void _initializeFields() {
    _notificationId = snapshotData['notification_id'] as String?;
    _recipientUid = snapshotData['recipient_uid'] as String?;
    _senderUid = snapshotData['sender_uid'] as String?;
    _type = snapshotData['type'] as String?;
    _title = snapshotData['title'] as String?;
    _message = snapshotData['message'] as String?;
    _actionText = snapshotData['action_text'] as String?;
    _matchId = snapshotData['match_id'] as String?;
    _tournamentId = snapshotData['tournament_id'] as String?;
    _requestId = snapshotData['request_id'] as String?;
    _isRead = snapshotData['is_read'] as bool?;
    _isClicked = snapshotData['is_clicked'] as bool?;
    _status = snapshotData['status'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _expiresAt = snapshotData['expires_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsRecordData({
  String? notificationId,
  String? recipientUid,
  String? senderUid,
  String? type,
  String? title,
  String? message,
  String? actionText,
  String? matchId,
  String? tournamentId,
  String? requestId,
  bool? isRead,
  bool? isClicked,
  String? status,
  DateTime? createdTime,
  DateTime? expiresAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'notification_id': notificationId,
      'recipient_uid': recipientUid,
      'sender_uid': senderUid,
      'type': type,
      'title': title,
      'message': message,
      'action_text': actionText,
      'match_id': matchId,
      'tournament_id': tournamentId,
      'request_id': requestId,
      'is_read': isRead,
      'is_clicked': isClicked,
      'status': status,
      'created_time': createdTime,
      'expires_at': expiresAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    return e1?.notificationId == e2?.notificationId &&
        e1?.recipientUid == e2?.recipientUid &&
        e1?.senderUid == e2?.senderUid &&
        e1?.type == e2?.type &&
        e1?.title == e2?.title &&
        e1?.message == e2?.message &&
        e1?.actionText == e2?.actionText &&
        e1?.matchId == e2?.matchId &&
        e1?.tournamentId == e2?.tournamentId &&
        e1?.requestId == e2?.requestId &&
        e1?.isRead == e2?.isRead &&
        e1?.isClicked == e2?.isClicked &&
        e1?.status == e2?.status &&
        e1?.createdTime == e2?.createdTime &&
        e1?.expiresAt == e2?.expiresAt;
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.notificationId,
        e?.recipientUid,
        e?.senderUid,
        e?.type,
        e?.title,
        e?.message,
        e?.actionText,
        e?.matchId,
        e?.tournamentId,
        e?.requestId,
        e?.isRead,
        e?.isClicked,
        e?.status,
        e?.createdTime,
        e?.expiresAt
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
