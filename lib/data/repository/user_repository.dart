import 'package:dio/dio.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:logger/logger.dart';

class UserRepository {
  // 통신을 위한 코드
  Future<Map<String, dynamic>> join(String username, String email, String password) async {
    final requestBody = {
      "username": username,
      "email": email,
      "password": password,
    };

    Response response = await dio.post("/join", data: requestBody); // Response<T> 타입
    //Map<String, dynamic> responseBody = response.data; // header + body data

    // Logger 확인하기
    final responseBody = response.data;
    Logger().d(responseBody);
    return responseBody; // responseBody 안에 정보가 다 있다
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    // 1. Map 변환
    final requestBody = {
      "username": username,
      "password": password,
    };

    // 2. 통신
    Response response = await dio.post("/login", data: requestBody); // Response<T> 타입
    Map<String, dynamic> responseBody = response.data; // final 사용 안 하고 타입 정확하게 명시하기
    Logger().d(responseBody);

    // 3. Header에서 Token 꺼내기 (body만 보내므로 / record 사용하면 Header랑 같이 보낼 수 있음)
    String accessToken = "";
    try {
      accessToken = response.headers["Authorization"]![0]; // null이 절대 아니다
      responseBody["response"]["accessToken"] = accessToken;
    } catch (e) {
      // null이면 accessToken은 비어있음
    }
    Logger().d(responseBody);
    return responseBody; // responseBody 안에 정보가 다 있다
  }
}
