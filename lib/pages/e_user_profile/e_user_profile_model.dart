import '/components/cardprofile_widget.dart';
import '/components/listchallenger_widget.dart';
import '/components/listtournamnet_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'e_user_profile_widget.dart' show EUserProfileWidget;
import 'package:flutter/material.dart';

class EUserProfileModel extends FlutterFlowModel<EUserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for cardprofile component.
  late CardprofileModel cardprofileModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for listtournamnet component.
  late ListtournamnetModel listtournamnetModel;
  // Model for listchallenger component.
  late ListchallengerModel listchallengerModel;

  @override
  void initState(BuildContext context) {
    cardprofileModel = createModel(context, () => CardprofileModel());
    listtournamnetModel = createModel(context, () => ListtournamnetModel());
    listchallengerModel = createModel(context, () => ListchallengerModel());
  }

  @override
  void dispose() {
    cardprofileModel.dispose();
    tabBarController?.dispose();
    listtournamnetModel.dispose();
    listchallengerModel.dispose();
  }
}
