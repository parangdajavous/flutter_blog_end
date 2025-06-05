// 정보 더 필요하면 채워넣으면 됨

class User {
  int? id;
  String? username;
  String? imgUrl;
  String? accessToken;

  User({
    this.id,
    this.username,
    this.imgUrl,
    this.accessToken,
  });

  User.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        username = data['username'],
        imgUrl = data['imgUrl'],
        accessToken = data['accessToken'];

  @override
  String toString() {
    return 'User(id: $id, username: $username, imgUrl: $imgUrl, accessToken: $accessToken)';
  }
}
