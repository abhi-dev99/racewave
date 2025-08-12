import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver.dart';
import '../models/race.dart';

class F1ApiService {
  static const String baseUrl = 'http://ergast.com/api/f1';
  
  // Get current season drivers
  Future<List<Driver>> getCurrentDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/drivers.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final drivers = data['MRData']['DriverTable']['Drivers'] as List;
        
        return drivers.map((driver) => Driver.fromJson(driver)).toList();
      } else {
        return _getSampleDrivers();
      }
    } catch (e) {
      // Return sample data if API fails
      return _getSampleDrivers();
    }
  }
  
  // Get current season race calendar
  Future<List<Race>> getCurrentRaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final races = data['MRData']['RaceTable']['Races'] as List;
        
        return races.map((race) => Race.fromJson(race)).toList();
      } else {
        return _getSampleRaces();
      }
    } catch (e) {
      // Return sample data if API fails
      return _getSampleRaces();
    }
  }
  
  // Get driver standings
  Future<List<Driver>> getDriverStandings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current/driverStandings.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final standings = data['MRData']['StandingsTable']['StandingsLists'][0]['DriverStandings'] as List;
        
        return standings.map((standing) {
          final driverData = standing['Driver'];
          final constructorData = standing['Constructors'][0];
          
          return Driver(
            driverId: driverData['driverId'] ?? '',
            givenName: driverData['givenName'] ?? '',
            familyName: driverData['familyName'] ?? '',
            dateOfBirth: driverData['dateOfBirth'] ?? '',
            nationality: driverData['nationality'] ?? '',
            number: driverData['permanentNumber'],
            code: driverData['code'],
            wikipediaUrl: driverData['url'],
            points: int.tryParse(standing['points']?.toString() ?? '0') ?? 0,
            wins: int.tryParse(standing['wins']?.toString() ?? '0') ?? 0,
            constructor: constructorData['name'] ?? '',
            position: int.tryParse(standing['position']?.toString() ?? '0') ?? 0,
          );
        }).toList();
      } else {
        return _getSampleStandings();
      }
    } catch (e) {
      // Return sample data if API fails
      return _getSampleStandings();
    }
  }
  
  // Get race results for a specific race
  Future<List<Map<String, dynamic>>> getRaceResults(String season, String round) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$season/$round/results.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['MRData']['RaceTable']['Races'][0]['Results'] as List;
        
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load race results');
      }
    } catch (e) {
      throw Exception('Error fetching race results: $e');
    }
  }
  
  // Get qualifying results
  Future<List<Map<String, dynamic>>> getQualifyingResults(String season, String round) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$season/$round/qualifying.json'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['MRData']['RaceTable']['Races'][0]['QualifyingResults'] as List;
        
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load qualifying results');
      }
    } catch (e) {
      throw Exception('Error fetching qualifying results: $e');
    }
  }
  
  // Sample data methods for when API is unavailable
  List<Driver> _getSampleDrivers() {
    return [
      Driver(
        driverId: 'verstappen',
        givenName: 'Max',
        familyName: 'Verstappen',
        dateOfBirth: '1997-09-30',
        nationality: 'Dutch',
        number: '1',
        code: 'VER',
        constructor: 'Red Bull Racing',
        points: 575,
        wins: 19,
        position: 1,
      ),
      Driver(
        driverId: 'perez',
        givenName: 'Sergio',
        familyName: 'Pérez',
        dateOfBirth: '1990-01-26',
        nationality: 'Mexican',
        number: '11',
        code: 'PER',
        constructor: 'Red Bull Racing',
        points: 285,
        wins: 2,
        position: 2,
      ),
      Driver(
        driverId: 'hamilton',
        givenName: 'Lewis',
        familyName: 'Hamilton',
        dateOfBirth: '1985-01-07',
        nationality: 'British',
        number: '44',
        code: 'HAM',
        constructor: 'Mercedes',
        points: 234,
        wins: 1,
        position: 3,
      ),
      Driver(
        driverId: 'russell',
        givenName: 'George',
        familyName: 'Russell',
        dateOfBirth: '1998-02-15',
        nationality: 'British',
        number: '63',
        code: 'RUS',
        constructor: 'Mercedes',
        points: 175,
        wins: 0,
        position: 4,
      ),
      Driver(
        driverId: 'leclerc',
        givenName: 'Charles',
        familyName: 'Leclerc',
        dateOfBirth: '1997-10-16',
        nationality: 'Monégasque',
        number: '16',
        code: 'LEC',
        constructor: 'Ferrari',
        points: 206,
        wins: 1,
        position: 5,
      ),
      Driver(
        driverId: 'sainz',
        givenName: 'Carlos',
        familyName: 'Sainz',
        dateOfBirth: '1994-09-01',
        nationality: 'Spanish',
        number: '55',
        code: 'SAI',
        constructor: 'Ferrari',
        points: 200,
        wins: 1,
        position: 6,
      ),
      Driver(
        driverId: 'norris',
        givenName: 'Lando',
        familyName: 'Norris',
        dateOfBirth: '1999-11-13',
        nationality: 'British',
        number: '4',
        code: 'NOR',
        constructor: 'McLaren',
        points: 113,
        wins: 0,
        position: 7,
      ),
      Driver(
        driverId: 'piastri',
        givenName: 'Oscar',
        familyName: 'Piastri',
        dateOfBirth: '2001-04-06',
        nationality: 'Australian',
        number: '81',
        code: 'PIA',
        constructor: 'McLaren',
        points: 87,
        wins: 0,
        position: 8,
      ),
      Driver(
        driverId: 'alonso',
        givenName: 'Fernando',
        familyName: 'Alonso',
        dateOfBirth: '1981-07-29',
        nationality: 'Spanish',
        number: '14',
        code: 'ALO',
        constructor: 'Aston Martin',
        points: 62,
        wins: 0,
        position: 9,
      ),
      Driver(
        driverId: 'stroll',
        givenName: 'Lance',
        familyName: 'Stroll',
        dateOfBirth: '1998-10-29',
        nationality: 'Canadian',
        number: '18',
        code: 'STR',
        constructor: 'Aston Martin',
        points: 47,
        wins: 0,
        position: 10,
      ),
    ];
  }
  
  List<Driver> _getSampleStandings() {
    return _getSampleDrivers();
  }
  
  List<Race> _getSampleRaces() {
    return [
      Race(
        season: '2024',
        round: '1',
        raceName: 'Bahrain Grand Prix',
        circuit: Circuit(
          circuitId: 'bahrain',
          circuitName: 'Bahrain International Circuit',
          location: Location(
            lat: '26.0325',
            long: '50.5106',
            locality: 'Sakhir',
            country: 'Bahrain',
          ),
        ),
        date: '2024-03-02',
        time: '15:00:00Z',
      ),
      Race(
        season: '2024',
        round: '2',
        raceName: 'Saudi Arabian Grand Prix',
        circuit: Circuit(
          circuitId: 'jeddah',
          circuitName: 'Jeddah Corniche Circuit',
          location: Location(
            lat: '21.6319',
            long: '39.1044',
            locality: 'Jeddah',
            country: 'Saudi Arabia',
          ),
        ),
        date: '2024-03-09',
        time: '17:00:00Z',
      ),
      Race(
        season: '2024',
        round: '3',
        raceName: 'Australian Grand Prix',
        circuit: Circuit(
          circuitId: 'albert_park',
          circuitName: 'Albert Park Grand Prix Circuit',
          location: Location(
            lat: '-37.8497',
            long: '144.968',
            locality: 'Melbourne',
            country: 'Australia',
          ),
        ),
        date: '2024-03-24',
        time: '05:00:00Z',
      ),
      Race(
        season: '2024',
        round: '4',
        raceName: 'Japanese Grand Prix',
        circuit: Circuit(
          circuitId: 'suzuka',
          circuitName: 'Suzuka Circuit',
          location: Location(
            lat: '34.8431',
            long: '136.541',
            locality: 'Suzuka',
            country: 'Japan',
          ),
        ),
        date: '2024-04-07',
        time: '05:00:00Z',
      ),
      Race(
        season: '2024',
        round: '5',
        raceName: 'Chinese Grand Prix',
        circuit: Circuit(
          circuitId: 'shanghai',
          circuitName: 'Shanghai International Circuit',
          location: Location(
            lat: '31.3389',
            long: '121.22',
            locality: 'Shanghai',
            country: 'China',
          ),
        ),
        date: '2024-04-21',
        time: '07:00:00Z',
      ),
      Race(
        season: '2024',
        round: '6',
        raceName: 'Miami Grand Prix',
        circuit: Circuit(
          circuitId: 'miami',
          circuitName: 'Miami International Autodrome',
          location: Location(
            lat: '25.9581',
            long: '-80.2389',
            locality: 'Miami',
            country: 'USA',
          ),
        ),
        date: '2024-05-05',
        time: '19:30:00Z',
      ),
      Race(
        season: '2024',
        round: '7',
        raceName: 'Emilia Romagna Grand Prix',
        circuit: Circuit(
          circuitId: 'imola',
          circuitName: 'Autodromo Enzo e Dino Ferrari',
          location: Location(
            lat: '44.3439',
            long: '11.7167',
            locality: 'Imola',
            country: 'Italy',
          ),
        ),
        date: '2024-05-19',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '8',
        raceName: 'Monaco Grand Prix',
        circuit: Circuit(
          circuitId: 'monaco',
          circuitName: 'Circuit de Monaco',
          location: Location(
            lat: '43.7347',
            long: '7.42056',
            locality: 'Monte-Carlo',
            country: 'Monaco',
          ),
        ),
        date: '2024-05-26',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '9',
        raceName: 'Canadian Grand Prix',
        circuit: Circuit(
          circuitId: 'villeneuve',
          circuitName: 'Circuit Gilles Villeneuve',
          location: Location(
            lat: '45.5',
            long: '-73.5228',
            locality: 'Montreal',
            country: 'Canada',
          ),
        ),
        date: '2024-06-09',
        time: '18:00:00Z',
      ),
      Race(
        season: '2024',
        round: '10',
        raceName: 'Spanish Grand Prix',
        circuit: Circuit(
          circuitId: 'catalunya',
          circuitName: 'Circuit de Barcelona-Catalunya',
          location: Location(
            lat: '41.57',
            long: '2.26111',
            locality: 'Montmeló',
            country: 'Spain',
          ),
        ),
        date: '2024-06-23',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '11',
        raceName: 'Austrian Grand Prix',
        circuit: Circuit(
          circuitId: 'red_bull_ring',
          circuitName: 'Red Bull Ring',
          location: Location(
            lat: '47.2197',
            long: '14.7647',
            locality: 'Spielberg',
            country: 'Austria',
          ),
        ),
        date: '2024-06-30',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '12',
        raceName: 'British Grand Prix',
        circuit: Circuit(
          circuitId: 'silverstone',
          circuitName: 'Silverstone Circuit',
          location: Location(
            lat: '52.0786',
            long: '-1.01694',
            locality: 'Silverstone',
            country: 'UK',
          ),
        ),
        date: '2024-07-07',
        time: '14:00:00Z',
      ),
      Race(
        season: '2024',
        round: '13',
        raceName: 'Hungarian Grand Prix',
        circuit: Circuit(
          circuitId: 'hungaroring',
          circuitName: 'Hungaroring',
          location: Location(
            lat: '47.5789',
            long: '19.2486',
            locality: 'Budapest',
            country: 'Hungary',
          ),
        ),
        date: '2024-07-21',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '14',
        raceName: 'Belgian Grand Prix',
        circuit: Circuit(
          circuitId: 'spa',
          circuitName: 'Circuit de Spa-Francorchamps',
          location: Location(
            lat: '50.4372',
            long: '5.97139',
            locality: 'Spa',
            country: 'Belgium',
          ),
        ),
        date: '2024-07-28',
        time: '13:00:00Z',
      ),
      Race(
        season: '2024',
        round: '15',
        raceName: 'Dutch Grand Prix',
        circuit: Circuit(
          circuitId: 'zandvoort',
          circuitName: 'Circuit Zandvoort',
          location: Location(
            lat: '52.3888',
            long: '4.54092',
            locality: 'Zandvoort',
            country: 'Netherlands',
          ),
        ),
        date: '2024-08-25',
        time: '13:00:00Z',
      ),
    ];
  }
}
