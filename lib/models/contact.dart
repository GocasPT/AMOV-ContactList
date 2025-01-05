class Contact {
  String name;
  String phone;
  String email;
  DateTime? birthday;
  String? picture;
  double? latitude;
  double? longitude;
  DateTime lastEdited;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    this.birthday,
    this.picture,
    this.latitude,
    this.longitude,
    DateTime? lastEdited,
  }) : lastEdited = lastEdited ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'picture': picture,
      'latitude': latitude,
      'longitude': longitude,
      'lastEdited': lastEdited.toIso8601String(),
    };
  }

  static Contact fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      picture: json['picture'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastEdited: DateTime.parse(json['lastEdited']),
    );
  }
}
