import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_app/constants.dart';
import 'package:music_app/screens/controller.dart';
import 'package:music_app/screens/keep_library.dart';
import 'package:music_app/screens/library.dart';
import 'package:flutter/services.dart';

import 'package:music_app/screens/slpash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Controller(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Matcot Play',
          theme: ThemeData(primaryColor: cwhite),
          initialRoute: '/splash',
          routes: {
            '/': (context) => Library(),
            '/splash': (context) => const SplashScreen(),
            '/keep':(context) => KeepLibrary()
          },
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) => Library(),
            );
          }
          ),
    );
  }
}
