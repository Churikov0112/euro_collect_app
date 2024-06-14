import 'dart:async';
import 'dart:math';

import 'package:euro_collect_app/presentation/autoclicker_screen_1.dart';
import 'package:euro_collect_app/presentation/blocs/all_players_bloc/all_players_bloc.dart';
import 'package:euro_collect_app/presentation/blocs/saved_players_bloc/saved_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'data/repository.dart';
import 'presentation/autoclicker_screen_2.dart';

final playersRepository = PlayersRepository();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const RestartWidget(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer _changeAutoclickerPageTimer;
  Widget homeWidget = const AutoclickerScreen1();

  @override
  void initState() {
    _changeAutoclickerPageTimer = Timer.periodic(
      const Duration(seconds: 3),
      (tmr) {
        if (Random().nextBool()) {
          if (homeWidget is AutoclickerScreen1) {
            homeWidget = const AutoclickerScreen2();
          } else {
            homeWidget = const AutoclickerScreen1();
          }
        }
        setState(() {});
      },
    );
    super.initState();
    // Configure the user privacy data policy before init sdk
    MobileAds.setUserConsent(true);
    MobileAds.setAgeRestrictedUser(true);
    MobileAds.initialize();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticker Pack Animation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AllPlayersBloc(repository: playersRepository)),
          BlocProvider(create: (context) => SavedPlayersBloc(repository: playersRepository)),
        ],
        child: homeWidget,
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<RestartWidgetState>()?.restartApp();
  }

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
