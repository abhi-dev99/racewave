class Driver {
  final String driverId;
  final String givenName;
  final String familyName;
  final String dateOfBirth;
  final String nationality;
  final String? number;
  final String? code;
  final String? wikipediaUrl;
  final int points;
  final int wins;
  final String constructor;
  final int position;

  Driver({
    required this.driverId,
    required this.givenName,
    required this.familyName,
    required this.dateOfBirth,
    required this.nationality,
    this.number,
    this.code,
    this.wikipediaUrl,
    this.points = 0,
    this.wins = 0,
    this.constructor = '',
    this.position = 0,
  });

  String get fullName => '$givenName $familyName';
  String get permanentNumber => number ?? '0';
  
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverId'] ?? '',
      givenName: json['givenName'] ?? '',
      familyName: json['familyName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      nationality: json['nationality'] ?? '',
      number: json['permanentNumber'],
      code: json['code'],
      wikipediaUrl: json['url'],
      points: int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['wins']?.toString() ?? '0') ?? 0,
      constructor: json['constructor'] ?? '',
      position: int.tryParse(json['position']?.toString() ?? '0') ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'givenName': givenName,
      'familyName': familyName,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'permanentNumber': number,
      'code': code,
      'url': wikipediaUrl,
      'points': points,
      'wins': wins,
      'constructor': constructor,
      'position': position,
    };
  }
}
