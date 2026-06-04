class User {
  String name;

  User({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] ?? '');
}
