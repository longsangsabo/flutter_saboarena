import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MessagesRecord extends FirestoreRecord {
  MessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "message_id" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  bool hasMessageId() => _messageId != null;

  // "conversation_id" field.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  bool hasConversationId() => _conversationId != null;

  // "sender_uid" field.
  String? _senderUid;
  String get senderUid => _senderUid ?? '';
  bool hasSenderUid() => _senderUid != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "message_type" field.
  String? _messageType;
  String get messageType => _messageType ?? '';
  bool hasMessageType() => _messageType != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _messageId = snapshotData['message_id'] as String?;
    _conversationId = snapshotData['conversation_id'] as String?;
    _senderUid = snapshotData['sender_uid'] as String?;
    _content = snapshotData['content'] as String?;
    _messageType = snapshotData['message_type'] as String?;
    _isRead = snapshotData['is_read'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('messages');

  static Stream<MessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MessagesRecord.fromSnapshot(s));

  static Future<MessagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MessagesRecord.fromSnapshot(s));

  static MessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMessagesRecordData({
  String? messageId,
  String? conversationId,
  String? senderUid,
  String? content,
  String? messageType,
  bool? isRead,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_uid': senderUid,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class MessagesRecordDocumentEquality implements Equality<MessagesRecord> {
  const MessagesRecordDocumentEquality();

  @override
  bool equals(MessagesRecord? e1, MessagesRecord? e2) {
    return e1?.messageId == e2?.messageId &&
        e1?.conversationId == e2?.conversationId &&
        e1?.senderUid == e2?.senderUid &&
        e1?.content == e2?.content &&
        e1?.messageType == e2?.messageType &&
        e1?.isRead == e2?.isRead &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(MessagesRecord? e) => const ListEquality().hash([
        e?.messageId,
        e?.conversationId,
        e?.senderUid,
        e?.content,
        e?.messageType,
        e?.isRead,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is MessagesRecord;
}
