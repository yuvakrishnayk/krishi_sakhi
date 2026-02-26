class User {
  final String? id;
  final String name;
  final String mobile;
  final String? imageUrl;
  final String? farm; // optional farm name returned by profile

  User({
    this.id,
    required this.name,
    required this.mobile,
    this.imageUrl,
    this.farm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? null,
      farm: json['farm'] ?? json['farm_name'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'image_url': imageUrl,
    'farm': farm,
  };
}
