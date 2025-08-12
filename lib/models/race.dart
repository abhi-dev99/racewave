class Race {
  final String season;
  final String round;
  final String raceName;
  final Circuit circuit;
  final String date;
  final String? time;

  Race({
    required this.season,
    required this.round,
    required this.raceName,
    required this.circuit,
    required this.date,
    this.time,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      season: json['season'] ?? '',
      round: json['round'] ?? '',
      raceName: json['raceName'] ?? '',
      circuit: Circuit.fromJson(json['Circuit'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'round': round,
      'raceName': raceName,
      'Circuit': circuit.toJson(),
      'date': date,
      'time': time,
    };
  }
}

class Circuit {
  final String circuitId;
  final String circuitName;
  final Location location;

  Circuit({
    required this.circuitId,
    required this.circuitName,
    required this.location,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      circuitId: json['circuitId'] ?? '',
      circuitName: json['circuitName'] ?? '',
      location: Location.fromJson(json['Location'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'circuitId': circuitId,
      'circuitName': circuitName,
      'Location': location.toJson(),
    };
  }
}

class Location {
  final String lat;
  final String long;
  final String locality;
  final String country;

  Location({
    required this.lat,
    required this.long,
    required this.locality,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'] ?? '',
      long: json['long'] ?? '',
      locality: json['locality'] ?? '',
      country: json['country'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
      'locality': locality,
      'country': country,
    };
  }
}
