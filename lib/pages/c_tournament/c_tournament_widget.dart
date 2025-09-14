import '/components/actionbuton_tournament_widget.dart';
import '/components/actionbutton_interactive_widget.dart';
import '/components/clbavatar_widget.dart';
import '/components/header_widget.dart';
import '/components/thongtingiaidau_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'c_tournament_model.dart';
export 'c_tournament_model.dart';

/// Create a page Screen: Trang chủ SABO
/// Header
///
/// Logo: "SABO" (tím, bold)
/// Icons phải: Settings, Chat, Notifications
///
/// Navigation Tabs
///
/// Giao lưu (active - trắng)
/// Thách đấu (inactive - xám)
///
/// Main Profile Card
///
/// Background: Ảnh kiến trúc (blur overlay)
/// Profile image: "Anh Long Magic"
/// Rank badge: "RANK : G" (tím)
///
/// Action Buttons
/// Trái:
///
/// X icon: "Chọi thôm" (đỏ)
/// Fire icon: "Lên đót" (đỏ gradient)
///
/// Phải:
///
/// Avatar nhỏ: User indicator với dot xanh
/// Number: "328.7k"
/// Menu dots: "576"
///
/// Bottom Info Card
/// Club details:
///
/// "SABO Billiards" (title)
/// Location icon: "Vũng Tàu"
/// Time: "@longsang · 03:09"
/// Description: "Tìm đối thủ ngay"
/// Hashtag: "#sabo #frankG"
///
/// Right side:
///
/// "99" (large number)
/// Share icon
///
/// Design Elements
///
/// Color scheme: Tím SABO brand, đỏ accents
/// Layout: Card-based, overlay design
/// Background: Blurred profile image
/// Typography: Mix sizes, bold highlights
/// Interactive: Multiple CTA buttons
///
/// Chức năng: Trang chủ social để tìm đối thủ, thách đấu và giao lưu trong
/// community billiards.
class CTournamentWidget extends StatefulWidget {
  const CTournamentWidget({super.key});

  static String routeName = 'cTournament';
  static String routePath = '/cTournament';

  @override
  State<CTournamentWidget> createState() => _CTournamentWidgetState();
}

class _CTournamentWidgetState extends State<CTournamentWidget>
    with TickerProviderStateMixin {
  late CTournamentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CTournamentModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          title: wrapWithModel(
            model: _model.headerModel,
            updateCallback: () => safeSetState(() {}),
            child: const HeaderWidget(),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Stack(
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 1072.5,
                            height: 733.5,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Align(
                                      alignment: const Alignment(0.0, 0),
                                      child: TabBar(
                                        labelColor: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        unselectedLabelColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                        unselectedLabelStyle: FlutterFlowTheme
                                                .of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                        indicatorColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        tabs: const [
                                          Tab(
                                            text: 'Mở rộng ',
                                          ),
                                          Tab(
                                            text: 'Nội bộ',
                                          ),
                                        ],
                                        controller: _model.tabBarController,
                                        onTap: (i) async {
                                          [() async {}, () async {}][i]();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        controller: _model.tabBarController,
                                        children: [
                                          Stack(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 393.2,
                                                    height: 381.7,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    child: wrapWithModel(
                                                      model: _model
                                                          .thongtingiaidauModel1,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          const ThongtingiaidauWidget(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Align(
                                                alignment: const AlignmentDirectional(
                                                    0.0, 1.01),
                                                child: Container(
                                                  width: 393.3,
                                                  height: 256.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                0.0, 1.0),
                                                        child: Container(
                                                          width: 358.9,
                                                          height: 135.4,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              wrapWithModel(
                                                                model: _model
                                                                    .clbavatarModel1,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    const ClbavatarWidget(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    0.99, 1.0),
                                                            child: Container(
                                                              width: 70.1,
                                                              height: 254.3,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .actionbuttonInteractiveModel1,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    const ActionbuttonInteractiveWidget(),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 100.0,
                                                            height: 121.8,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .actionbutonTournamentModel1,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  const ActionbutonTournamentWidget(),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    -0.56,
                                                                    0.55),
                                                            child: Container(
                                                              width: 284.0,
                                                              height: 25.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    const AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Text(
                                                                  '@SABO Billiards',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    -0.63,
                                                                    0.99),
                                                            child: Container(
                                                              width: 266.0,
                                                              height: 50.9,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Text(
                                                                'Giải cuối tuần này \n#sabo\n',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Stack(
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 393.2,
                                                    height: 381.7,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    child: wrapWithModel(
                                                      model: _model
                                                          .thongtingiaidauModel2,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          const ThongtingiaidauWidget(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Align(
                                                alignment: const AlignmentDirectional(
                                                    0.0, 1.01),
                                                child: Container(
                                                  width: 393.3,
                                                  height: 256.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                0.0, 1.0),
                                                        child: Container(
                                                          width: 358.9,
                                                          height: 135.4,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              wrapWithModel(
                                                                model: _model
                                                                    .clbavatarModel2,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    const ClbavatarWidget(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    0.99, 1.0),
                                                            child: Container(
                                                              width: 70.1,
                                                              height: 254.3,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child:
                                                                  wrapWithModel(
                                                                model: _model
                                                                    .actionbuttonInteractiveModel2,
                                                                updateCallback: () =>
                                                                    safeSetState(
                                                                        () {}),
                                                                child:
                                                                    const ActionbuttonInteractiveWidget(),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 100.0,
                                                            height: 121.8,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .actionbutonTournamentModel2,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  const ActionbutonTournamentWidget(),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    -0.56,
                                                                    0.55),
                                                            child: Container(
                                                              width: 284.0,
                                                              height: 25.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    const AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Text(
                                                                  '@SABO Billiards',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                const AlignmentDirectional(
                                                                    -0.63,
                                                                    0.99),
                                                            child: Container(
                                                              width: 266.0,
                                                              height: 50.9,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Text(
                                                                'Giải cuối tuần này \n#sabo\n',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
