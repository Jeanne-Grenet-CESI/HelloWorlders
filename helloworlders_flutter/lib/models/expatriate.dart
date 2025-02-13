class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final double latitude;
  final double longitude;
  final String country;
  final String imageRepository;
  final String imageFileName;
  final String gender;
  final int age;
  final String username;
  final String description;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.arrivalDate,
    required this.departureDate,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.imageRepository,
    required this.imageFileName,
    required this.gender,
    required this.age,
    required this.username,
    required this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      arrivalDate: DateTime.parse(json['arrivalDate']),
      departureDate: DateTime.parse(json['departureDate']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      country: json['country'],
      imageRepository: json['imageRepository'],
      imageFileName: json['imageFileName'],
      gender: json['gender'],
      age: json['age'],
      username: json['username'],
      description: json['description'],
    );
  }
}
