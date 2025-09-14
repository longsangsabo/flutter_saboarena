import '/components/actionbuton_tournament_widget.dart';
import '/components/actionbutton_interactive_widget.dart';
import '/components/clbavatar_widget.dart';
import '/components/header_widget.dart';
import '/components/thongtingiaidau_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'c_tournament_widget.dart' show CTournamentWidget;
import 'package:flutter/material.dart';

class CTournamentModel extends FlutterFlowModel<CTournamentWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for thongtingiaidau component.
  late ThongtingiaidauModel thongtingiaidauModel1;
  // Model for clbavatar component.
  late ClbavatarModel clbavatarModel1;
  // Model for actionbutton-interactive component.
  late ActionbuttonInteractiveModel actionbuttonInteractiveModel1;
  // Model for actionbuton-tournament component.
  late ActionbutonTournamentModel actionbutonTournamentModel1;
  // Model for thongtingiaidau component.
  late ThongtingiaidauModel thongtingiaidauModel2;
  // Model for clbavatar component.
  late ClbavatarModel clbavatarModel2;
  // Model for actionbutton-interactive component.
  late ActionbuttonInteractiveModel actionbuttonInteractiveModel2;
  // Model for actionbuton-tournament component.
  late ActionbutonTournamentModel actionbutonTournamentModel2;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    thongtingiaidauModel1 = createModel(context, () => ThongtingiaidauModel());
    clbavatarModel1 = createModel(context, () => ClbavatarModel());
    actionbuttonInteractiveModel1 =
        createModel(context, () => ActionbuttonInteractiveModel());
    actionbutonTournamentModel1 =
        createModel(context, () => ActionbutonTournamentModel());
    thongtingiaidauModel2 = createModel(context, () => ThongtingiaidauModel());
    clbavatarModel2 = createModel(context, () => ClbavatarModel());
    actionbuttonInteractiveModel2 =
        createModel(context, () => ActionbuttonInteractiveModel());
    actionbutonTournamentModel2 =
        createModel(context, () => ActionbutonTournamentModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    tabBarController?.dispose();
    thongtingiaidauModel1.dispose();
    clbavatarModel1.dispose();
    actionbuttonInteractiveModel1.dispose();
    actionbutonTournamentModel1.dispose();
    thongtingiaidauModel2.dispose();
    clbavatarModel2.dispose();
    actionbuttonInteractiveModel2.dispose();
    actionbutonTournamentModel2.dispose();
  }
}
