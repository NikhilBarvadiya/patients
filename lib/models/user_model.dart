class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String address;
  final String avatar;
  final LocationModel location;

  UserModel({required this.id, required this.name, required this.email, required this.mobile, required this.password, required this.address, required this.avatar, required this.location});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      password: '********',
      address: json['location'] != null ? json['location']['address'] ?? '' : '',
      avatar: json['avatar'] ?? '',
      location: LocationModel(
        address: json['location'] != null ? json['location']['address'] ?? '' : '',
        coordinates: json['location'] != null ? List<double>.from(json['location']['coordinates'] ?? [0.0, 0.0]) : [0.0, 0.0],
      ),
    );
  }

  UserModel copyWith({String? id, String? name, String? email, String? mobile, String? password, String? specialty, String? address, String? avatar, LocationModel? location}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      location: location ?? this.location,
    );
  }
}

class LocationModel {
  final String address;
  final List<double> coordinates;

  LocationModel({required this.address, required this.coordinates});
}
