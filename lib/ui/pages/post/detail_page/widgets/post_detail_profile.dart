import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/constants/size.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/model/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailProfile extends ConsumerWidget {
  Post post;
  PostDetailProfile(this.post);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
        title: Text("${post.user.username}"),
        leading: ClipOval(
            child: CachedNetworkImage(
          imageUrl: "${baseUrl}${post.user.imgUrl}",
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        )),
        subtitle: Row(
          children: [
            Text("ssar@nate.com"), // api 서버 개발자에게 요청해야함
            const SizedBox(width: mediumGap),
            const Text("·"),
            const SizedBox(width: mediumGap),
            const Text("Written on "),
            Text("May 25 ${post.createdAt}"), // 나중에 유틸함수로 변환 필요
          ],
        ));
  }
}
