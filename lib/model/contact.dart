class Contact {
  String name;
  String phoneNumber;
  String email;
  //DateTime? birthday;
  //String? picture;

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.email,
    //this.birthday,
    //this.picture,
  });

  @override
  String toString() {
    return 'Contact{name: $name, email: $email, phoneNumber: $phoneNumber}';
  }
}