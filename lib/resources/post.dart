class Post {
  final String body;

  Post({this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      body: json['body'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["body"] = body;
    return map;
  }
}
