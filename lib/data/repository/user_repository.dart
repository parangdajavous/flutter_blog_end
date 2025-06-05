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
}
