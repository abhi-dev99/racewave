import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/driver.dart';
import '../models/race.dart';

class F1ApiService {
  static const String baseUrl = 'https://api.jolpi.ca/ergast/f1';

  String _resolveSeasonPath(String? season) {
    if (season == null || season.trim().isEmpty) {
      return 'current';
    }
    return season.trim();
  }

  Future<Map<String, dynamic>> _getJsonWithFallback(List<Uri> candidates) async {
    Exception? lastError;

    for (final uri in candidates) {
      try {
        final response = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }

        lastError = Exception('Status ${response.statusCode} from $uri');
      } catch (e) {
        lastError = Exception('Request failed for $uri: $e');
      }
    }

    if (kIsWeb && candidates.isNotEmpty) {
      final raw = Uri.encodeComponent(candidates.first.toString());
      final proxyUri = Uri.parse('https://api.allorigins.win/raw?url=$raw');
      try {
        final response = await http.get(proxyUri).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        // Ignore proxy failures and fall through to final error.
      }
    }

    throw lastError ?? Exception('All API requests failed');
  }
  
  // Driver photo URLs - using Formula 1 official photos where available.
  static String getDriverPhotoUrl(String driverId) {
    final normalizedId = driverId.trim().toLowerCase();

    final Map<String, String> driverPhotos = {
      // 2026 official Formula1.com driver pages
      'albon': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:1868db/q_auto/v1740000001/common/f1/2026/williams/alealb01/2026williamsalealb01right.jpg',
      'arvid_lindblad': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:6692ff/q_auto/v1740000001/common/f1/2026/racingbulls/arvlin01/2026racingbullsarvlin01right.jpg',
      'sainz': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:1868db/q_auto/v1740000001/common/f1/2026/williams/carsai01/2026williamscarsai01right.jpg',
      'leclerc': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:e8002d/q_auto/v1740000001/common/f1/2026/ferrari/chalec01/2026ferrarichalec01right.jpg',
      'ocon': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:dee1e2/q_auto/v1740000001/common/f1/2026/haas/estoco01/2026haasestoco01right.jpg',
      'alonso': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:229971/q_auto/v1740000001/common/f1/2026/astonmartin/feralo01/2026astonmartinferalo01right.jpg',
      'colapinto': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:00a1e8/q_auto/v1740000001/common/f1/2026/alpine/fracol01/2026alpinefracol01right.jpg',
      'bortoleto': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:ff2d00/q_auto/v1740000001/common/f1/2026/audi/gabbor01/2026audigabbor01right.jpg',
      'russell': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:27f4d2/q_auto/v1740000001/common/f1/2026/mercedes/georus01/2026mercedesgeorus01right.jpg',
      'hadjar': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:3671c6/q_auto/v1740000001/common/f1/2026/redbullracing/isahad01/2026redbullracingisahad01right.jpg',
      'antonelli': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:27f4d2/q_auto/v1740000001/common/f1/2026/mercedes/andant01/2026mercedesandant01right.jpg',
      'stroll': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:229971/q_auto/v1740000001/common/f1/2026/astonmartin/lanstr01/2026astonmartinlanstr01right.jpg',
      'norris': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:ff8000/q_auto/v1740000001/common/f1/2026/mclaren/lannor01/2026mclarenlannor01right.jpg',
      'hamilton': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:e8002d/q_auto/v1740000001/common/f1/2026/ferrari/lewham01/2026ferrarilewham01right.jpg',
      'lawson': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:6692ff/q_auto/v1740000001/common/f1/2026/racingbulls/lialaw01/2026racingbullslialaw01right.jpg',
      'max_verstappen': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:3671c6/q_auto/v1740000001/common/f1/2026/redbullracing/maxver01/2026redbullracingmaxver01right.jpg',
      'hulkenberg': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:ff2d00/q_auto/v1740000001/common/f1/2026/audi/nichul01/2026audinichul01right.jpg',
      'bearman': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:dee1e2/q_auto/v1740000001/common/f1/2026/haas/olibea01/2026haasolibea01right.jpg',
      'piastri': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:ff8000/q_auto/v1740000001/common/f1/2026/mclaren/oscpia01/2026mclarenoscpia01right.jpg',
      'gasly': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:00a1e8/q_auto/v1740000001/common/f1/2026/alpine/piegas01/2026alpinepiegas01right.jpg',
      'perez': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:aaaaad/q_auto/v1740000001/common/f1/2026/cadillac/serper01/2026cadillacserper01right.jpg',
      'bottas': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:aaaaad/q_auto/v1740000001/common/f1/2026/cadillac/valbot01/2026cadillacvalbot01right.jpg',

      // Legacy aliases and alternates
      'verstappen': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:3671c6/q_auto/v1740000001/common/f1/2026/redbullracing/maxver01/2026redbullracingmaxver01right.jpg',
      'kimi_antonelli': 'https://media.formula1.com/image/upload/c_fill,w_840,h_630,g_north/c_pad,w_1200,h_630/b_rgb:27f4d2/q_auto/v1740000001/common/f1/2026/mercedes/andant01/2026mercedesandant01right.jpg',
      'jak_crawford': 'https://www.formula1.com/etc/designs/fom-website/social/f1-default-share.jpg',
      'crawford': 'https://www.formula1.com/etc/designs/fom-website/social/f1-default-share.jpg',
      'zhou': 'https://www.formula1.com/etc/designs/fom-website/social/f1-default-share.jpg',
    };

    if (driverPhotos.containsKey(normalizedId)) {
      return driverPhotos[normalizedId]!;
    }

    // Ergast/Jolpica API does not expose profile photos.
    // Keep an official Formula1 fallback instead of broken image placeholders.
    return 'https://www.formula1.com/etc/designs/fom-website/social/f1-default-share.jpg';
  }

  static String _raceSlug(String raceName) {
    final normalized = raceName.toLowerCase();

    if (normalized.contains('australia')) return 'australia';
    if (normalized.contains('china')) return 'china';
    if (normalized.contains('japan')) return 'japan';
    if (normalized.contains('bahrain')) return 'bahrain';
    if (normalized.contains('saudi')) return 'saudi-arabia';
    if (normalized.contains('emilia') || normalized.contains('imola')) return 'emilia-romagna';
    if (normalized.contains('spain') || normalized.contains('barcelona')) return 'spain';
    if (normalized.contains('miami')) return 'miami';
    if (normalized.contains('canada')) return 'canada';
    if (normalized.contains('monaco')) return 'monaco';
    if (normalized.contains('austria')) return 'austria';
    if (normalized.contains('great britain') || normalized.contains('british')) return 'great-britain';
    if (normalized.contains('hungary')) return 'hungary';
    if (normalized.contains('netherlands') || normalized.contains('dutch')) return 'netherlands';
    if (normalized.contains('belgium')) return 'belgium';
    if (normalized.contains('italy')) return 'italy';
    if (normalized.contains('azerbaijan')) return 'azerbaijan';
    if (normalized.contains('singapore')) return 'singapore';
    if (normalized.contains('united states')) return 'united-states';
    if (normalized.contains('mexico city') || normalized.contains('mexico')) return 'mexico';
    if (normalized.contains('brazil') || normalized.contains('sao paulo')) return 'brazil';
    if (normalized.contains('las vegas')) return 'las-vegas';
    if (normalized.contains('qatar')) return 'qatar';
    if (normalized.contains('abu dhabi') || normalized.contains('united arab emirates')) return 'united-arab-emirates';

    return normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // Official Formula1 race card art used on the race calendar.
  static String getRaceCardImageUrl({required String raceName}) {
    final slug = _raceSlug(raceName);
    return 'https://media.formula1.com/image/upload/c_lfill,w_1296/q_auto/v1740000001/fom-website/static-assets/2026/races/card/$slug.webp';
  }

  // Official circuit map / track layout used on race pages.
  static String getRaceCircuitMapUrl({required String raceName}) {
    final slug = _raceSlug(raceName);

    final mapUrls = <String, String>{
      'miami': 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632433/common/f1/2026/track/2026trackmiamidetailed.png',
      'canada': 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632441/common/f1/2026/track/2026trackmontrealdetailed.png',
      'japan': 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632474/common/f1/2026/track/2026tracksuzukadetailed.png',
      'monaco': 'https://media.formula1.com/image/upload/f_auto/q_auto/v1751632482/common/f1/2026/track/2026trackmontecarlodetailed.png',
    };

    if (mapUrls.containsKey(slug)) {
      return mapUrls[slug]!;
    }

    return 'https://media.formula1.com/image/upload/f_auto/q_auto/common/f1/2026/track/2026track${slug}detailed.png';
  }

  static Map<String, String> getOfficialTrackStats({required String raceName}) {
    final slug = _raceSlug(raceName);

    final allStats = {
      'bahrain': {
        'Circuit Length': '5.412km',
        'Number of Laps': '57',
        'Race Distance': '308.238km',
        'Fastest Lap': '1:31.447',
      },
      'saudi-arabia': {
        'Circuit Length': '6.174km',
        'Number of Laps': '50',
        'Race Distance': '308.450km',
        'Fastest Lap': '1:30.734',
      },
      'emilia-romagna': {
        'Circuit Length': '4.909km',
        'Number of Laps': '63',
        'Race Distance': '309.049km',
        'Fastest Lap': '1:15.484',
      },
      'spain': {
        'Circuit Length': '4.657km',
        'Number of Laps': '66',
        'Race Distance': '307.236km',
        'Fastest Lap': '1:18.183',
      },
      'miami': {
        'Circuit Length': '5.412km',
        'Number of Laps': '57',
        'Race Distance': '308.326km',
        'Fastest Lap': '1:29.708',
      },
      'canada': {
        'Circuit Length': '4.361km',
        'Number of Laps': '70',
        'Race Distance': '305.270km',
        'Fastest Lap': '1:13.622',
      },
      'japan': {
        'Circuit Length': '5.807km',
        'Number of Laps': '53',
        'Race Distance': '307.471km',
        'Fastest Lap': '1:27.064',
      },
      'monaco': {
        'Circuit Length': '3.337km',
        'Number of Laps': '78',
        'Race Distance': '260.286km',
        'Fastest Lap': '1:12.909',
      },
      'australia': {
        'Circuit Length': '5.303km',
        'Number of Laps': '58',
        'Race Distance': '307.574km',
        'Fastest Lap': '1:19.110',
      },
      'china': {
        'Circuit Length': '5.451km',
        'Number of Laps': '56',
        'Race Distance': '305.256km',
        'Fastest Lap': '1:32.238',
      },
      'british': {
        'Circuit Length': '5.891km',
        'Number of Laps': '52',
        'Race Distance': '306.198km',
        'Fastest Lap': '1:27.369',
      },
      'austrian': {
        'Circuit Length': '4.318km',
        'Number of Laps': '71',
        'Race Distance': '306.978km',
        'Fastest Lap': '1:05.619',
      },
      'hungary': {
        'Circuit Length': '4.381km',
        'Number of Laps': '70',
        'Race Distance': '306.630km',
        'Fastest Lap': '1:16.627',
      },
      'netherlands': {
        'Circuit Length': '4.259km',
        'Number of Laps': '72',
        'Race Distance': '306.587km',
        'Fastest Lap': '1:11.097',
      },
      'belgian': {
        'Circuit Length': '7.004km',
        'Number of Laps': '44',
        'Race Distance': '308.052km',
        'Fastest Lap': '1:44.323',
      },
      'singapore': {
        'Circuit Length': '4.940km',
        'Number of Laps': '62',
        'Race Distance': '306.143km',
        'Fastest Lap': '1:41.905',
      },
      'azerbaijan': {
        'Circuit Length': '6.003km',
        'Number of Laps': '51',
        'Race Distance': '306.049km',
        'Fastest Lap': '1:43.009',
      },
      'italian': {
        'Circuit Length': '5.793km',
        'Number of Laps': '53',
        'Race Distance': '307.038km',
        'Fastest Lap': '1:21.971',
      },
      'united-states': {
        'Circuit Length': '5.513km',
        'Number of Laps': '56',
        'Race Distance': '308.405km',
        'Fastest Lap': '1:36.169',
      },
      'mexico': {
        'Circuit Length': '4.304km',
        'Number of Laps': '71',
        'Race Distance': '305.354km',
        'Fastest Lap': '1:17.774',
      },
      'brazil': {
        'Circuit Length': '4.309km',
        'Number of Laps': '71',
        'Race Distance': '305.879km',
        'Fastest Lap': '1:10.540',
      },
      'las-vegas': {
        'Circuit Length': '6.201km',
        'Number of Laps': '50',
        'Race Distance': '310.050km',
        'Fastest Lap': '1:35.490',
      },
      'qatar': {
        'Circuit Length': '5.419km',
        'Number of Laps': '57',
        'Race Distance': '308.611km',
        'Fastest Lap': '1:23.196',
      },
      'united-arab-emirates': {
        'Circuit Length': '5.281km',
        'Number of Laps': '58',
        'Race Distance': '306.183km',
        'Fastest Lap': '1:26.103',
      },
    };

    return allStats[slug] ?? {};
  }

  // Official race hero visuals from Formula1 2026 race pages.
  static String getRaceHeroImageUrl({required String raceName}) {
    return getRaceCardImageUrl(raceName: raceName);
  }
  
  // Team colors for visual appeal
  static Color getTeamColor(String constructor) {
    final Map<String, Color> teamColors = {
      'Red Bull': const Color(0xFF1E41FF),
      'Red Bull Racing': const Color(0xFF1E41FF),
      'Mercedes': const Color(0xFF00D2BE),
      'Ferrari': const Color(0xFFDC0000),
      'McLaren': const Color(0xFFFF8700),
      'Aston Martin': const Color(0xFF006F62),
      'Alpine': const Color(0xFF0090FF),
      'AlphaTauri': const Color(0xFF2B4562),
      'RB': const Color(0xFF2B4562),
      'Racing Bulls': const Color(0xFF2B4562),
      'Visa Cash App RB': const Color(0xFF2B4562),
      'RB F1 Team': const Color(0xFF2B4562),
      'Alfa Romeo': const Color(0xFF900000),
      'Sauber': const Color(0xFF52E252),
      'Kick Sauber': const Color(0xFF52E252),
      'Haas F1 Team': const Color(0xFFFFFFFF),
      'Haas': const Color(0xFFFFFFFF),
      'Williams': const Color(0xFF005AFF),
    };
    
    return teamColors[constructor] ?? const Color(0xFF999999);
  }
  
  // Get drivers for current season (or a specific legacy season)
  Future<List<Driver>> getCurrentDrivers({String? season}) async {
    final seasonPath = _resolveSeasonPath(season);
    try {
      final data = await _getJsonWithFallback([
        Uri.parse('$baseUrl/$seasonPath/drivers.json'),
      ]);
      final drivers = data['MRData']['DriverTable']['Drivers'] as List;
      final parsedDrivers = drivers.map((driver) => Driver.fromJson(driver)).toList();

      // Enrich base driver list with team and championship stats when available.
      try {
        final standings = await getDriverStandings(season: season);
        final standingsById = {
          for (final standing in standings) standing.driverId: standing,
        };

        final enrichedDrivers = parsedDrivers.map((driver) {
          final standing = standingsById[driver.driverId];
          if (standing == null) {
            return driver;
          }

          return Driver(
            driverId: driver.driverId,
            givenName: driver.givenName,
            familyName: driver.familyName,
            dateOfBirth: driver.dateOfBirth,
            nationality: driver.nationality,
            number: driver.number,
            code: driver.code,
            wikipediaUrl: driver.wikipediaUrl,
            points: standing.points,
            wins: standing.wins,
            constructor: standing.constructor,
            position: standing.position,
          );
        }).toList();

        // Prefer championship order when available, fallback to alphabetical.
        enrichedDrivers.sort((a, b) {
          if (a.position > 0 && b.position > 0) {
            return a.position.compareTo(b.position);
          }
          if (a.position > 0) return -1;
          if (b.position > 0) return 1;
          return a.fullName.compareTo(b.fullName);
        });

        return enrichedDrivers;
      } catch (_) {
        return parsedDrivers;
      }
    } catch (e) {
      throw Exception('Error fetching drivers for $seasonPath: $e');
    }
  }
  
  // Get race calendar for current season (or a specific legacy season)
  Future<List<Race>> getCurrentRaces({String? season}) async {
    final seasonPath = _resolveSeasonPath(season);
    try {
      final data = await _getJsonWithFallback([
        Uri.parse('$baseUrl/$seasonPath.json'),
      ]);
      final races = data['MRData']['RaceTable']['Races'] as List;
      return races.map((race) => Race.fromJson(race)).toList();
    } catch (e) {
      throw Exception('Error fetching races for $seasonPath: $e');
    }
  }
  
  // Get driver standings for current season (or a specific legacy season)
  Future<List<Driver>> getDriverStandings({String? season}) async {
    final seasonPath = _resolveSeasonPath(season);
    try {
      final data = await _getJsonWithFallback([
        Uri.parse('$baseUrl/$seasonPath/driverstandings.json'),
        Uri.parse('$baseUrl/$seasonPath/driverStandings.json'),
      ]);

      final standingsLists = data['MRData']['StandingsTable']['StandingsLists'] as List;
      if (standingsLists.isEmpty) {
        return [];
      }

      final standings = standingsLists[0]['DriverStandings'] as List;
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
    } catch (e) {
      throw Exception('Error fetching standings for $seasonPath: $e');
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
