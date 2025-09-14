import '/components/actionbuton_challenger_widget.dart';
import '/components/actionbutton_interactive_widget.dart';
import '/components/cardprofile_widget.dart';
import '/components/clbavatar_widget.dart';
import '/components/header_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'a_home_widget.dart' show AHomeWidget;
import 'package:flutter/material.dart';

class AHomeModel extends FlutterFlowModel<AHomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for cardprofile component.
  late CardprofileModel cardprofileModel;
  // Model for clbavatar component.
  late ClbavatarModel clbavatarModel;
  // Model for actionbutton-interactive component.
  late ActionbuttonInteractiveModel actionbuttonInteractiveModel;
  // Model for actionbuton-challenger component.
  late ActionbutonChallengerModel actionbutonChallengerModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    cardprofileModel = createModel(context, () => CardprofileModel());
    clbavatarModel = createModel(context, () => ClbavatarModel());
    actionbuttonInteractiveModel =
        createModel(context, () => ActionbuttonInteractiveModel());
    actionbutonChallengerModel =
        createModel(context, () => ActionbutonChallengerModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    tabBarController?.dispose();
    cardprofileModel.dispose();
    clbavatarModel.dispose();
    actionbuttonInteractiveModel.dispose();
    actionbutonChallengerModel.dispose();
  }
}
