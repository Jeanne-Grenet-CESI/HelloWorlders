class Expatriate {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime arrivalDate;
  final DateTime? departureDate;
  final double latitude;
  final double longitude;
  final String country;
  final String? imageRepository;
  final String? imageFileName;
  final String? gender;
  final int age;
  final String username;
  final String? description;

  Expatriate({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.arrivalDate,
    this.departureDate,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.imageRepository,
    this.imageFileName,
    this.gender,
    required this.age,
    required this.username,
    this.description,
  });

  factory Expatriate.fromJson(Map<String, dynamic> json) {
    return Expatriate(
      id: json['Id'].toString(),
      firstName: json['Firstname'],
      lastName: json['Lastname'],
      email: json['Email'],
      arrivalDate: DateTime.parse(json['ArrivalDate']),
      departureDate: json['DepartureDate'] != null
          ? DateTime.tryParse(json['DepartureDate'])
          : null,
      latitude: json['Latitude'].toDouble(),
      longitude: json['Longitude'].toDouble(),
      country: json['Country'],
      imageRepository: json['ImageRepository'],
      imageFileName: json['ImageFileName'],
      gender: json['Gender'],
      age: json['Age'],
      username: json['Username'],
      description: json['Description'],
    );
  }

  static List<Expatriate> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Expatriate.fromJson(json)).toList();
  }
}
