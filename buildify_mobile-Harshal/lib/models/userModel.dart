

class Usermodel {
  int? id;
  String? name; // Changed 'Name' to 'name' for convention
  String? email;

  // Constructor
  Usermodel({
    this.id,
    this.name,
    this.email,
  });

  // Factory constructor to create a Usermodel instance from a JSON map
  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  // Method to convert a Usermodel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
