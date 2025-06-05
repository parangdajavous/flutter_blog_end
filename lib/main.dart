import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/constants/theme.dart';
import 'package:flutter_blog/ui/pages/auth/join_page/join_page.dart';
import 'package:flutter_blog/ui/pages/auth/login_page/login_page.dart';
import 'package:flutter_blog/ui/pages/post/list_page/post_list_page.dart';
import 'package:flutter_blog/ui/pages/post/write_page/post_write_page.dart';
import 'package:flutter_blog/ui/pages/splash/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: 1. Stack의 가장 위 context를 알고 있다. <- 지금 몰라도 됨
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 화면이 아닌 곳에서 그림을 그릴 수 있다
      // context가 없는 곳에서 context를 사용할 수 있는 방법
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // 그림 보여주고 해야할 일들 다 끝낸 뒤에 화면이동되게 해야함 (RiverPod 사용하고 되도록이면 라이브러리는 사용하지말자)
      routes: {
        "/login": (context) => const LoginPage(),
        "/join": (context) => const JoinPage(),
        "/post/list": (context) => PostListPage(),
        "/post/write": (context) => const PostWritePage(),
      },
      theme: theme(),
    );
  }
}
