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

  // Circuit layout image
  String get circuitImageUrl {
    const map = {
      'bahrain': 'Bahrain',
      'jeddah': 'Saudi_Arabia',
      'albert_park': 'Australia',
      'suzuka': 'Japan',
      'shanghai': 'China',
      'miami': 'Miami',
      'imola': 'Emilia_Romagna',
      'monaco': 'Monaco',
      'villeneuve': 'Canada',
      'catalunya': 'Spain',
      'red_bull_ring': 'Austria',
      'silverstone': 'Great_Britain',
      'hungaroring': 'Hungary',
      'spa': 'Belgium',
      'zandvoort': 'Netherlands',
      'monza': 'Italy',
      'baku': 'Baku',
      'marina_bay': 'Singapore',
      'americas': 'USA',
      'rodriguez': 'Mexico',
      'interlagos': 'Brazil',
      'vegas': 'Las_Vegas',
      'losail': 'Qatar',
      'yas_marina': 'Abu_Dhabi',
    };
    
    final country = map[circuit.circuitId] ?? circuit.location.country.replaceAll(' ', '_');
    return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1677244985/content/dam/fom-website/2018-redesign-assets/Circuit%20maps%2016x9/${country}_Circuit.png';
  }

  // Example Track icons 
  String get trackImageUrl {
    const map = {
      'bahrain': 'Bahrain',
      'jeddah': 'Saudi%20Arabia',
      'albert_park': 'Australia',
      'suzuka': 'Japan',
      'shanghai': 'China',
      'miami': 'Miami',
      'imola': 'Emilia%20Romagna',
      'monaco': 'Monaco',
      'villeneuve': 'Canada',
      'catalunya': 'Spain',
      'red_bull_ring': 'Austria',
      'silverstone': 'Great%20Britain',
      'hungaroring': 'Hungary',
      'spa': 'Belgium',
      'zandvoort': 'Netherlands',
      'monza': 'Italy',
      'baku': 'Baku',
      'marina_bay': 'Singapore',
      'americas': 'USA',
      'rodriguez': 'Mexico',
      'interlagos': 'Brazil',
      'vegas': 'Las%20Vegas',
      'losail': 'Qatar',
      'yas_marina': 'Abu%20Dhabi',
    };
    final country = map[circuit.circuitId] ?? circuit.location.country.replaceAll(' ', '%20');
    return 'https://media.formula1.com/image/upload/f_auto/q_auto/v1677250050/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/$country.png';
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
