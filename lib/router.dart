import 'package:go_router/go_router.dart';
import 'package:object_detection_ssd_mobilenet_v2/screen/camera_screen.dart';
import 'package:object_detection_ssd_mobilenet_v2/screen/home_screen.dart';
import 'package:object_detection_ssd_mobilenet_v2/screen/photo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

GoRouter generateRoute() => GoRouter(
      redirect: (context, state) {
        final token = prefs?.getString("session");

        // if (token?.isEmpty ?? true) {
        //   print("Token not found. Redirect to login..");
        //   return '/login';
        // }

        return null;
      },
      // initialLocation: (prefs?.getString("introduction")?.isNotEmpty ?? false)
      //     ? "/"
      //     : "/introduction",
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraScreen(),
        ),
        GoRoute(
          path: '/photo',
          builder: (context, state) => const PhotoScreen(),
        ),
      ],
    );
