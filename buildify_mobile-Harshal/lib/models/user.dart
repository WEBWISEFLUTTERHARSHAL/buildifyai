class CurrentUser {
  String id;
  String name;
  String email;
  String? profilePicture;

  CurrentUser(
      {required this.id,
      required this.name,
      required this.email,
      this.profilePicture});
  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      profilePicture: json['image'],
    );
  }

  // Method to convert a Usermodel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': profilePicture,
    };
  }
}
