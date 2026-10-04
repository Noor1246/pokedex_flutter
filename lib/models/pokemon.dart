class Pokemon {
  final String name;
  final String url;
  final List<String> types;

  Pokemon({required this.name, required this.url, required this.types});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
      types: List<String>.from(json['types'] ?? []),
    );
  }

  int get id {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }
}
