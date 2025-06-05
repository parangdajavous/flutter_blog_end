import 'package:flutter/material.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_blog/ui/pages/auth/join_page/join_fm.dart';
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

    // 통신 실패
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

  Future<void> login(String username, String email) async {}

  Future<void> logout() async {}
}

/// 3. 창고 데이터 타입
class SessionModel {
  int? id;
  String? username;
  String? accessToken;
  bool? isLogin;

  SessionModel(
      {this.id,
      this.username,
      this.accessToken,
      this.isLogin = false}); // 초기화될 때 id, username, accessToken은 null, isLogin은 false
}
