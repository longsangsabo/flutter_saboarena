import '/components/actionbuton_challenger_widget.dart';
import '/components/actionbutton_interactive_widget.dart';
import '/components/cardprofile_widget.dart';
import '/components/clbavatar_widget.dart';
import '/components/header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'b_challenger_widget.dart' show BChallengerWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BChallengerModel extends FlutterFlowModel<BChallengerWidget> {
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
  late CardprofileModel cardprofileModel1;
  // Model for clbavatar component.
  late ClbavatarModel clbavatarModel1;
  // Model for actionbutton-interactive component.
  late ActionbuttonInteractiveModel actionbuttonInteractiveModel1;
  // Model for actionbuton-challenger component.
  late ActionbutonChallengerModel actionbutonChallengerModel1;
  // Model for cardprofile component.
  late CardprofileModel cardprofileModel2;
  // Model for clbavatar component.
  late ClbavatarModel clbavatarModel2;
  // Model for actionbutton-interactive component.
  late ActionbuttonInteractiveModel actionbuttonInteractiveModel2;
  // Model for actionbuton-challenger component.
  late ActionbutonChallengerModel actionbutonChallengerModel2;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    cardprofileModel1 = createModel(context, () => CardprofileModel());
    clbavatarModel1 = createModel(context, () => ClbavatarModel());
    actionbuttonInteractiveModel1 =
        createModel(context, () => ActionbuttonInteractiveModel());
    actionbutonChallengerModel1 =
        createModel(context, () => ActionbutonChallengerModel());
    cardprofileModel2 = createModel(context, () => CardprofileModel());
    clbavatarModel2 = createModel(context, () => ClbavatarModel());
    actionbuttonInteractiveModel2 =
        createModel(context, () => ActionbuttonInteractiveModel());
    actionbutonChallengerModel2 =
        createModel(context, () => ActionbutonChallengerModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    tabBarController?.dispose();
    cardprofileModel1.dispose();
    clbavatarModel1.dispose();
    actionbuttonInteractiveModel1.dispose();
    actionbutonChallengerModel1.dispose();
    cardprofileModel2.dispose();
    clbavatarModel2.dispose();
    actionbuttonInteractiveModel2.dispose();
    actionbutonChallengerModel2.dispose();
  }
}
