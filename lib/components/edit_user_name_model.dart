import '/flutter_flow/flutter_flow_util.dart';
import 'edit_user_name_widget.dart' show EditUserNameWidget;
import 'package:flutter/material.dart';

class EditUserNameModel extends FlutterFlowModel<EditUserNameWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
