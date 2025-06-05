import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final baseUrl = "http://192.168.0.88:8080"; // 내 컴퓨터 IP

//로그인 되면, dio에 jwt 추가하기
//dio.options.headers['Authorization'] = 'Bearer $_accessToken';
final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl, // 내 IP 입력 <- localhost는 작동 안함
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => true, // 200 이 아니어도 예외 발생안하게 설정
  ),
);

const secureStorage = FlutterSecureStorage();
