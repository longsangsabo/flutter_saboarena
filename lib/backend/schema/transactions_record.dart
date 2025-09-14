import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "transaction_id" field.
  String? _transactionId;
  String get transactionId => _transactionId ?? '';
  bool hasTransactionId() => _transactionId != null;

  // "transaction_type" field.
  String? _transactionType;
  String get transactionType => _transactionType ?? '';
  bool hasTransactionType() => _transactionType != null;

  // "elo_change" field.
  int? _eloChange;
  int get eloChange => _eloChange ?? 0;
  bool hasEloChange() => _eloChange != null;

  // "spa_change" field.
  int? _spaChange;
  int get spaChange => _spaChange ?? 0;
  bool hasSpaChange() => _spaChange != null;

  // "old_elo" field.
  int? _oldElo;
  int get oldElo => _oldElo ?? 0;
  bool hasOldElo() => _oldElo != null;

  // "new_elo" field.
  int? _newElo;
  int get newElo => _newElo ?? 0;
  bool hasNewElo() => _newElo != null;

  // "old_spa" field.
  int? _oldSpa;
  int get oldSpa => _oldSpa ?? 0;
  bool hasOldSpa() => _oldSpa != null;

  // "new_spa" field.
  int? _newSpa;
  int get newSpa => _newSpa ?? 0;
  bool hasNewSpa() => _newSpa != null;

  // "source_type" field.
  String? _sourceType;
  String get sourceType => _sourceType ?? '';
  bool hasSourceType() => _sourceType != null;

  // "source_id" field.
  String? _sourceId;
  String get sourceId => _sourceId ?? '';
  bool hasSourceId() => _sourceId != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "processed_time" field.
  DateTime? _processedTime;
  DateTime? get processedTime => _processedTime;
  bool hasProcessedTime() => _processedTime != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "requires_confirmation" field.
  bool? _requiresConfirmation;
  bool get requiresConfirmation => _requiresConfirmation ?? false;
  bool hasRequiresConfirmation() => _requiresConfirmation != null;

  // "confirmed_by" field.
  String? _confirmedBy;
  String get confirmedBy => _confirmedBy ?? '';
  bool hasConfirmedBy() => _confirmedBy != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _transactionId = snapshotData['transaction_id'] as String?;
    _transactionType = snapshotData['transaction_type'] as String?;
    _eloChange = castToType<int>(snapshotData['elo_change']);
    _spaChange = castToType<int>(snapshotData['spa_change']);
    _oldElo = castToType<int>(snapshotData['old_elo']);
    _newElo = castToType<int>(snapshotData['new_elo']);
    _oldSpa = castToType<int>(snapshotData['old_spa']);
    _newSpa = castToType<int>(snapshotData['new_spa']);
    _sourceType = snapshotData['source_type'] as String?;
    _sourceId = snapshotData['source_id'] as String?;
    _description = snapshotData['description'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _processedTime = snapshotData['processed_time'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _requiresConfirmation = snapshotData['requires_confirmation'] as bool?;
    _confirmedBy = snapshotData['confirmed_by'] as String?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('transactions');

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsRecordData({
  String? transactionId,
  String? transactionType,
  int? eloChange,
  int? spaChange,
  int? oldElo,
  int? newElo,
  int? oldSpa,
  int? newSpa,
  String? sourceType,
  String? sourceId,
  String? description,
  DateTime? createdTime,
  DateTime? processedTime,
  String? status,
  bool? requiresConfirmation,
  String? confirmedBy,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'elo_change': eloChange,
      'spa_change': spaChange,
      'old_elo': oldElo,
      'new_elo': newElo,
      'old_spa': oldSpa,
      'new_spa': newSpa,
      'source_type': sourceType,
      'source_id': sourceId,
      'description': description,
      'created_time': createdTime,
      'processed_time': processedTime,
      'status': status,
      'requires_confirmation': requiresConfirmation,
      'confirmed_by': confirmedBy,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsRecordDocumentEquality
    implements Equality<TransactionsRecord> {
  const TransactionsRecordDocumentEquality();

  @override
  bool equals(TransactionsRecord? e1, TransactionsRecord? e2) {
    return e1?.transactionId == e2?.transactionId &&
        e1?.transactionType == e2?.transactionType &&
        e1?.eloChange == e2?.eloChange &&
        e1?.spaChange == e2?.spaChange &&
        e1?.oldElo == e2?.oldElo &&
        e1?.newElo == e2?.newElo &&
        e1?.oldSpa == e2?.oldSpa &&
        e1?.newSpa == e2?.newSpa &&
        e1?.sourceType == e2?.sourceType &&
        e1?.sourceId == e2?.sourceId &&
        e1?.description == e2?.description &&
        e1?.createdTime == e2?.createdTime &&
        e1?.processedTime == e2?.processedTime &&
        e1?.status == e2?.status &&
        e1?.requiresConfirmation == e2?.requiresConfirmation &&
        e1?.confirmedBy == e2?.confirmedBy &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(TransactionsRecord? e) => const ListEquality().hash([
        e?.transactionId,
        e?.transactionType,
        e?.eloChange,
        e?.spaChange,
        e?.oldElo,
        e?.newElo,
        e?.oldSpa,
        e?.newSpa,
        e?.sourceType,
        e?.sourceId,
        e?.description,
        e?.createdTime,
        e?.processedTime,
        e?.status,
        e?.requiresConfirmation,
        e?.confirmedBy,
        e?.uid
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsRecord;
}
