import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_blog/ui/pages/auth/join_page/join_fm.dart';
import 'package:flutter_blog/ui/pages/auth/login_page/login_fm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// 1. 창고 관리자
final sessionProvider = NotifierProvider<SessionGVM, SessionModel>(() {
  // SessionModel은 ?타입 필요없음
  /// 의존하는 VM
  return SessionGVM();
});

/// 2. 창고 (상태가 변경되어도 화면 갱신 안함 - watch XXXX)
class SessionGVM extends Notifier<SessionModel> {
  final mContext = navigatorKey.currentContext!; // 가장 위 화면의 context

  @override
  SessionModel build() {
    return SessionModel(); // 초기화
  }

  Future<void> join(String username, String email, String password) async {
    Logger().d("username : ${username}, email : ${email}, password : ${password}");
    bool isValid = ref.read(joinProvider.notifier).validate(); // 최종 유효성 검사
    if (!isValid) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("유효성 검사 실패입니다.")),
      );
      return; // 유효성 검사 실패의 경우 아무것도 하지 않도록
    }

    Map<String, dynamic> body =
        await UserRepository().join(username, email, password); // 나중에는 싱글톤으로 관리하기 <- 성공 실패 상관없이 다 들어온다

    if (!body["success"]) {
      // 토스트 띄우기
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("${body["errorMessage"]}")),
      );
      return; // 유저네임 중복검사 실패 시 아무것도 하지 않도록
    }

    // 성공 시 로그인 페이지로 이동
    Navigator.pushNamed(mContext, "/login"); // 기존 컨텍스트를 알아야함
  }

  Future<void> login(String username, String password) async {
    // 1. 유효성 검사
    Logger().d("username : ${username}, password : ${password}");
    bool isValid = ref.read(loginProvider.notifier).validate(); // 최종 유효성 검사
    if (!isValid) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("유효성 검사 실패입니다.")),
      );
      return; // 유효성 검사 실패의 경우 아무것도 하지 않도록
    }

    // 2. 통신
    Map<String, dynamic> body = await UserRepository().login(username, password);
    if (!body["success"]) {
      // 토스트 띄우기
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("${body["errorMessage"]}")),
      );
      return; // 유효성 검사 실패 시 아무것도 하지 않도록
    }

    // 3. Token을 디바이스에 저장 (앱을 껐다 켰을 때 디바이스에 저장 되있으면 토큰 확인 후 자동 로그인 가능)
    // 비동기함수이기 때문에 기다리다가 내려가도록 await
    await secureStorage.write(key: "accessToken", value: body["response"]["accessToken"]);

    // 4. 세션 모델 갱신
    // 나중에는 fromMap으로 파싱하는 걸 만들어야함
    state = SessionModel(
        id: body["response"]["id"],
        username: body["response"]["username"],
        imgUrl: body["response"]["imgUrl"],
        accessToken: body["response"]["accessToken"],
        isLogin: true);

    // 5. Dio의 header에 토큰 세팅
    dio.options.headers["Authorization"] = body["response"]["accessToken"];

    // 6. 게시글 목록 페이지로 이동
    // 화면 날리고 게시글 목록 페이지로 이동한다
    Navigator.pushNamed(mContext, "/post/list");
  }

  Future<void> logout() async {}
}

/// 3. 창고 데이터 타입
class SessionModel {
  int? id;
  String? username;
  String? imgUrl;
  String? accessToken;
  bool? isLogin;

  SessionModel(
      {this.id,
      this.username,
      this.imgUrl,
      this.accessToken,
      this.isLogin = false}); // 초기화될 때 id, username, accessToken은 null, isLogin은 false
}
