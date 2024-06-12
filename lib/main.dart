import 'package:euro_collect_app/presentation/blocs/all_players_bloc/all_players_bloc.dart';
import 'package:euro_collect_app/presentation/blocs/saved_players_bloc/saved_players_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'data/repository.dart';
import 'presentation/album_screen.dart';

final playersRepository = PlayersRepository();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
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
        child: const AlbumScreen(),
      ),
    );
  }
}
