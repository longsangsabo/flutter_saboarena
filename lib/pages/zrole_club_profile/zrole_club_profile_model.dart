import '/components/listchallenger_widget.dart';
import '/components/listleaderboard_widget.dart';
import '/components/listmenber_widget.dart';
import '/components/listtournamnet_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'zrole_club_profile_widget.dart' show ZroleClubProfileWidget;
import 'package:flutter/material.dart';

class ZroleClubProfileModel extends FlutterFlowModel<ZroleClubProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for listmenber component.
  late ListmenberModel listmenberModel;
  // Model for listtournamnet component.
  late ListtournamnetModel listtournamnetModel;
  // Model for listleaderboard component.
  late ListleaderboardModel listleaderboardModel;
  // Model for listchallenger component.
  late ListchallengerModel listchallengerModel;

  @override
  void initState(BuildContext context) {
    listmenberModel = createModel(context, () => ListmenberModel());
    listtournamnetModel = createModel(context, () => ListtournamnetModel());
    listleaderboardModel = createModel(context, () => ListleaderboardModel());
    listchallengerModel = createModel(context, () => ListchallengerModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    listmenberModel.dispose();
    listtournamnetModel.dispose();
    listleaderboardModel.dispose();
    listchallengerModel.dispose();
  }
}
