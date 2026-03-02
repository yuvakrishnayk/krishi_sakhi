class User {
  final String? id;
  final String name;
  final String mobile;
  final String? imageUrl;
  final String? farm; // optional farm name returned by profile
  final String? username; // optional username/handle returned by profile

  User({
    this.id,
    required this.name,
    required this.mobile,
    this.imageUrl,
    this.farm,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? null,
      farm: json['farm'] ?? json['farm_name'] ?? null,
      username: json['username'] ?? json['user_name'] ?? json['handle'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'image_url': imageUrl,
    'farm': farm,
    'username': username,
  };
}
