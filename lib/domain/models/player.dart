class PlayerModel {
  final int id;
  final int number;
  final String countryName;
  final String name;
  final String position;
  final String photoUrl;

  const PlayerModel({
    required this.id,
    required this.number,
    required this.countryName,
    required this.name,
    required this.position,
    required this.photoUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      countryName: json['country'],
      name: json['name'],
      number: json['number'],
      position: json['position'],
      photoUrl: json['photo'],
    );
  }
}
