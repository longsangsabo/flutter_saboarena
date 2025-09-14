import '/components/cardclb_widget.dart';
import '/components/header_widget.dart';
import '/components/info_club_widget.dart';
import '/components/listchallenger_widget.dart';
import '/components/listclubs_widget.dart';
import '/components/listleaderboard_widget.dart';
import '/components/listmenber_widget.dart';
import '/components/listtournamnet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'd_club_profile_user_view_widget.dart' show DClubProfileUserViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DClubProfileUserViewModel
    extends FlutterFlowModel<DClubProfileUserViewWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController1;
  int get tabBarCurrentIndex1 =>
      tabBarController1 != null ? tabBarController1!.index : 0;
  int get tabBarPreviousIndex1 =>
      tabBarController1 != null ? tabBarController1!.previousIndex : 0;

  // Model for cardclb component.
  late CardclbModel cardclbModel;
  // Model for infoClub component.
  late InfoClubModel infoClubModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController2;
  int get tabBarCurrentIndex2 =>
      tabBarController2 != null ? tabBarController2!.index : 0;
  int get tabBarPreviousIndex2 =>
      tabBarController2 != null ? tabBarController2!.previousIndex : 0;

  // Model for listmenber component.
  late ListmenberModel listmenberModel;
  // Model for listtournamnet component.
  late ListtournamnetModel listtournamnetModel;
  // Model for listleaderboard component.
  late ListleaderboardModel listleaderboardModel;
  // Model for listchallenger component.
  late ListchallengerModel listchallengerModel;
  // Model for listclubs component.
  late ListclubsModel listclubsModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    cardclbModel = createModel(context, () => CardclbModel());
    infoClubModel = createModel(context, () => InfoClubModel());
    listmenberModel = createModel(context, () => ListmenberModel());
    listtournamnetModel = createModel(context, () => ListtournamnetModel());
    listleaderboardModel = createModel(context, () => ListleaderboardModel());
    listchallengerModel = createModel(context, () => ListchallengerModel());
    listclubsModel = createModel(context, () => ListclubsModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    tabBarController1?.dispose();
    cardclbModel.dispose();
    infoClubModel.dispose();
    tabBarController2?.dispose();
    listmenberModel.dispose();
    listtournamnetModel.dispose();
    listleaderboardModel.dispose();
    listchallengerModel.dispose();
    listclubsModel.dispose();
  }
}
