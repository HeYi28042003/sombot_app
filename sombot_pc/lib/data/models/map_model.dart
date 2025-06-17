class PlaceModel {
  final int? placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final double lat;
  final double lon;
  final String? category;
  final String? type;
  final int? placeRank;
  final double? importance;
  final String? addresstype;
  final String? name;
  final String? displayName;
  final Address? address;
  final List<String>? boundingbox;

  PlaceModel({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    required this.lat,
    required this.lon,
    this.category,
    this.type,
    this.placeRank,
    this.importance,
    this.addresstype,
    this.name,
    this.displayName,
    this.address,
    this.boundingbox,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final latRaw = json['lat'];
    final lonRaw = json['lon'];

    if (latRaw == null || lonRaw == null) {
      throw Exception("Latitude and longitude must not be null");
    }

    final lat = (latRaw is String) ? double.tryParse(latRaw) : latRaw.toDouble();
    final lon = (lonRaw is String) ? double.tryParse(lonRaw) : lonRaw.toDouble();

    if (lat == null || lon == null) {
      throw Exception("Invalid lat/lon format");
    }

    return PlaceModel(
      placeId: json['place_id'],
      licence: json['licence'],
      osmType: json['osm_type'],
      osmId: json['osm_id'],
      lat: lat,
      lon: lon,
      category: json['category'],
      type: json['type'],
      placeRank: json['place_rank'],
      importance: (json['importance'] ?? 0.0).toDouble(),
      addresstype: json['addresstype'],
      name: json['name'],
      displayName: json['display_name'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      boundingbox: json['boundingbox'] != null ? List<String>.from(json['boundingbox']) : null,
    );
  }

  factory PlaceModel.fromFirestore(Map<String, dynamic> json) {
    final lat = json['latitude'];
    final lon = json['longitude'];
    if (lat == null || lon == null) {
      throw Exception("Firestore missing lat/lon");
    }

    return PlaceModel(
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      displayName: json['address'] ?? '',
      address: Address(
        city: json['city'] ?? '',
        houseNumber: '',
        road: '',
        county: '',
        state: '',
        iso3166: '',
        postcode: '',
        country: '',
        countryCode: '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'licence': licence,
      'osm_type': osmType,
      'osm_id': osmId,
      'lat': lat,
      'lon': lon,
      'category': category,
      'type': type,
      'place_rank': placeRank,
      'importance': importance,
      'addresstype': addresstype,
      'name': name,
      'display_name': displayName,
      'address': address?.toJson(),
      'boundingbox': boundingbox,
    };
  }
}


class Address {
  final String? houseNumber;
  final String? road;
  final String? city;
  final String? county;
  final String? state;
  final String? iso3166;
  final String? postcode;
  final String? country;
  final String? countryCode;

  Address({
    this.houseNumber,
    this.road,
    this.city,
    this.county,
    this.state,
    this.iso3166,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      houseNumber: json['house_number'],
      road: json['road'],
      city: json['city'],
      county: json['county'],
      state: json['state'],
      iso3166: json['ISO3166-2-lvl4'],
      postcode: json['postcode'],
      country: json['country'],
      countryCode: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house_number': houseNumber,
      'road': road,
      'city': city,
      'county': county,
      'state': state,
      'ISO3166-2-lvl4': iso3166,
      'postcode': postcode,
      'country': country,
      'country_code': countryCode,
    };
  }
}
