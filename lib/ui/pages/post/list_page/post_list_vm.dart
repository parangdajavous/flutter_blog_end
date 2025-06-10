import 'package:flutter/material.dart';
import 'package:flutter_blog/data/model/post.dart';
import 'package:flutter_blog/data/repository/post_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 1. 창고 관리자
final postListProvider = AutoDisposeNotifierProvider<PostListVM, PostListModel?>(() {
  return PostListVM();
});

/// 2. 창고 (상태가 변경되어도, 화면 갱신 안함 - watch 하지마)
class PostListVM extends AutoDisposeNotifier<PostListModel?> {
  final mContext = navigatorKey.currentContext!;
  final refreshCtrl = RefreshController(); // 상태로 등록

  @override
  PostListModel? build() {
    init();

    // 2. VM 파괴
    ref.onDispose(() {
      refreshCtrl.dispose();
      Logger().d("PostListModel 파괴됨");
    });

    return null;
  }

  void notifyUpdate(Post post) {
    List<Post> nextPosts = state!.posts.map((p) {
      if (p.id == post.id) {
        return post; // 바뀐 post
      } else {
        return p; // 기존 post
      }
    }).toList();
    state = state!.copyWith(posts: nextPosts);
  }

  void notifyDeleteOne(int postId) {
    PostListModel model = state!;

    model.posts = model.posts.where((p) => p.id != postId).toList();

    state = state!.copyWith(posts: model.posts);
  }

  // 트랜잭션 - 일의 최소 단위
  Future<void> write(String title, String content) async {
    // 1. postRepository 함수 호출
    Map<String, dynamic> body = await PostRepository().write(title, content);
    // 2. 성공 여부 확인
    if (!body["success"]) {
      ScaffoldMessenger.of(mContext!).showSnackBar(
        SnackBar(content: Text("게시글 쓰기 실패 : ${body["errorMessage"]}")),
      );
      return;
    }

    // 3. 파싱 (post로 파싱)
    Post post = Post.fromMap(body["response"]);

    // 4. List 상태 갱신
    List<Post> nextPosts = [post, ...state!.posts]; // ... -> 전개연산자
    state = state!.copyWith(posts: nextPosts);

    // 5. 글쓰기 화면 pop
    Navigator.pop(mContext);
  }

  Future<void> init({int page = 0}) async {
    Map<String, dynamic> body = await PostRepository().getList(page: page);
    if (!body["success"]) {
      ScaffoldMessenger.of(mContext!).showSnackBar(
        SnackBar(content: Text("게시글 목록보기 실패 : ${body["errorMessage"]}")),
      );
      return;
    }
    state = PostListModel.fromMap(body["response"]);

    refreshCtrl.refreshCompleted(); // 마지막 트랜잭션
  }

  Future<void> nextList() async {
    // 1. 초기화 -> 0페이지에 1페이지를 uppand
    PostListModel prevModel = state!;

    // 마지막 페이지일 때
    if (prevModel.isLast) {
      await Future.delayed(Duration(milliseconds: 500)); // 없으면 끌어올릴 때 도는게 보이지 않음 - 되고있는지 알 수 없다
      refreshCtrl.loadComplete();
      return;
    }

    // 마지막 페이지가 아니면
    Map<String, dynamic> body = await PostRepository()
        .getList(page: prevModel.pageNumber + 1); // prevModel.pageNumber -> 현재 페이지  +1을 해줘야 다음 페이지로 넘어간다
    if (!body["success"]) {
      ScaffoldMessenger.of(mContext!).showSnackBar(
        SnackBar(content: Text("게시글 로드 실패 : ${body["errorMessage"]}")),
      );
      refreshCtrl.loadComplete();
      return;
    }

    // 파싱
    PostListModel nextModel = PostListModel.fromMap(body["response"]);

    // state에 갱신 (prevModel과 nextModel을 합친다)
    state = nextModel.copyWith(posts: [...prevModel.posts, ...nextModel.posts]);
    refreshCtrl.loadComplete();
  }
}

/// 3. 창고 데이터 타입 (불변 아님)
class PostListModel {
  bool isFirst;
  bool isLast;
  int pageNumber;
  int size;
  int totalPage;
  List<Post> posts;

  PostListModel(this.isFirst, this.isLast, this.pageNumber, this.size, this.totalPage, this.posts);

  PostListModel.fromMap(Map<String, dynamic> data)
      : isFirst = data['isFirst'],
        isLast = data['isLast'],
        pageNumber = data['pageNumber'],
        size = data['size'],
        totalPage = data['totalPage'],
        posts = (data['posts'] as List).map((e) => Post.fromMap(e)).toList();

  PostListModel copyWith({
    bool? isFirst,
    bool? isLast,
    int? pageNumber,
    int? size,
    int? totalPage,
    List<Post>? posts,
  }) {
    return PostListModel(
      isFirst ?? this.isFirst,
      isLast ?? this.isLast,
      pageNumber ?? this.pageNumber,
      size ?? this.size,
      totalPage ?? this.totalPage,
      posts ?? this.posts,
    );
  }

  @override
  String toString() {
    return 'PostListModel{isFirst: $isFirst, isLast: $isLast, pageNumber: $pageNumber, size: $size, totalPage: $totalPage, posts: $posts}';
  }
}
