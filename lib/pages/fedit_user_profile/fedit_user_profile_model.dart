import '/flutter_flow/flutter_flow_util.dart';
import 'fedit_user_profile_widget.dart' show FeditUserProfileWidget;
import 'package:flutter/material.dart';

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
