import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/edit_name_widget.dart';
import '/components/edit_user_name_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'fedit_user_profile_widget.dart' show FeditUserProfileWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeditUserProfileModel extends FlutterFlowModel<FeditUserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadAvatar = false;
  FFUploadedFile uploadedLocalFile_uploadAvatar =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadAvatar = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
