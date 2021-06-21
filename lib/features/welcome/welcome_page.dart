import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_template/features/welcome/welcome_event.dart';
import 'package:flutter_app_template/features/welcome/welcome_state.dart';
import 'package:flutter_app_template/widgets/animated_circle_transition_widget.dart';
import 'package:flutter_app_template/widgets/shadow_image.dart';
import 'package:rive/rive.dart' as rive;
import 'package:template_package/base_widget/base_widget.dart';
import 'package:template_package/template_package.dart';

class WelcomePage extends BaseWidget {
  WelcomePage(BaseBloc Function() getBloc) : super(getBloc);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends BaseState<WelcomePage, BaseBloc> with SingleTickerProviderStateMixin {
  final carouselLength = 3;
  late PageController pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _tabController = TabController(length: carouselLength, vsync: this);
    var currentPage = 0;
    pageController.addListener(() {
      final newPage = pageController.page!.round();
      if (newPage != currentPage) {
        currentPage = newPage;
        _tabController.animateTo(newPage);
      }
    });
    bloc.event.add(InitTabControllerEvent(pageController: pageController));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: null,
        builder: (context, AsyncSnapshot snapshot) {
          return getMainContent(context);
        });
  }

  Scaffold getMainContent(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [getBackground(), getBodyWidget()],
    ));
  }

  Widget getBodyWidget() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topCenter,
            child: Container(height: MediaQuery.of(context).size.height * 0.7, child: pageViewer())),
        Align(alignment: Alignment.bottomCenter, child: getBottomWidget())
      ],
    );
  }

  Widget pageViewer() {
    return Container(
      child: PageView(controller: pageController, children: [
           AnimatedCircleTransitionWidget(
            child: ShadowImage('assets/images/run_girl2.png')),
        ShadowImage('assets/images/run_girl.png'),
        ShadowImage('assets/images/gym_girl.png'),
      ]),
    );
  }

  Widget getBottomWidget() {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height * .4;
    return Stack(
      children: [
        _bottomBackgroundAnimation(),
        Container(
          height: height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height * 0.3),
              _getIntroTexts(),
              Flexible(child: horizontalActionsWidget()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getIntroTexts() {
    return StreamBuilder<PageIntrosDataState>(
        stream: bloc.getStreamOfType<PageIntrosDataState>(),
        builder: (context, AsyncSnapshot<PageIntrosDataState> snapshot) {
          if (snapshot.data == null) return Container();
          return Container(
              child: Column(children: [
            titleWidget(snapshot.data?.title ?? ''),
            subTitleWidget(snapshot.data?.subTitle ?? '')
          ]));
        });
  }

  Widget _bottomBackgroundAnimation() {
    return StreamBuilder(
        stream: bloc.getStreamOfType<PageIntrosDataState>(),
        builder: (context, AsyncSnapshot<PageIntrosDataState> snapshot) {
          return AnimatedContainer(
              duration: Duration(seconds: 2),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white10, snapshot.data?.color ?? Theme.of(context).backgroundColor])),
              height: MediaQuery.of(context).size.width,
              child: rive.RiveAnimation.asset('assets/rive/new_file.riv'));
        });
  }

  Widget titleWidget(String title) {
    return Text(translate(title).toUpperCase(), style: Theme.of(context).textTheme.headline5);
  }

  Widget subTitleWidget(String subtitle) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Text(
        translate(subtitle),
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget horizontalActionsWidget() {
    return StreamBuilder(
        stream: bloc.getStreamOfType<ActionAnimationDataState>(),
        builder: (context, AsyncSnapshot<ActionAnimationDataState> snapshot) {
          return Stack(
            children: [
              AnimatedPositioned(
                curve: Curves.decelerate,
                duration: Duration(milliseconds: 1500),
                right: snapshot.data?.edgePaddingRight ?? -100.0,
                left: (snapshot.data?.edgePaddingLeft ?? -100.0),
                top: 0.0,
                bottom: 0.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            TabPageSelector(controller: _tabController, indicatorSize: 7),
                            Spacer(),
                            InkWell(
                              onTap: () => bloc.event.add(NextTapEvent()),
                              borderRadius: BorderRadius.circular(50),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget getBackground() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
              child: Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
          )),
        ],
      ),
    );
  }
}
