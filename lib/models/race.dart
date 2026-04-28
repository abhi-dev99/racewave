// Add import for time manipulation if needed, but core works
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

  // Calculate IST time from UTC
  DateTime? get localRaceTimeIst {
    if (time == null) return null;
    try {
      final utcTime = DateTime.parse('${date}T${time!.endsWith('Z') ? time : time! + 'Z'}');
      return utcTime.add(const Duration(hours: 5, minutes: 30));
    } catch (_) {
      return null;
    }
  }

  // Example circuit layout image matching Miami details and beyond
  String get circuitImageUrl {
    final slug = raceName.toLowerCase();
    if (slug.contains('miami')) {
      return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632433/common/f1/2026/track/2026trackmiamidetailed.png';
    }
    if (slug.contains('canada')) return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632441/common/f1/2026/track/2026trackmontrealdetailed.png';
    if (slug.contains('japan')) return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632474/common/f1/2026/track/2026tracksuzukadetailed.png';
    final cleanSlug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return 'https://media.formula1.com/image/upload/f_auto/q_auto/common/f1/2026/track/2026track${cleanSlug}detailed.png';
  }

  // Example Track icons 
  String get trackImageUrl {
    final slug = raceName.toLowerCase();
    if (slug.contains('miami')) return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1677250050/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Miami.png';
    // Add default behavior for generic testing
    final cleanSlug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '').replaceFirst(RegExp(r'^[a-z]'), slug.isNotEmpty ? slug[0].toUpperCase() : '');
    return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1677250050/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/$cleanSlug.png';
  }

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
