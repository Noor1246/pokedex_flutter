class PokemonEvolution {
  final String name;
  final int id;
  final String imageUrl;

  PokemonEvolution({
    required this.name,
    required this.id,
    required this.imageUrl,
  });
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> stats;

  final String description;
  final String category;
  final String gender;
  final List<String> weaknesses;
  final List<PokemonEvolution> evolutions;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.description,
    required this.category,
    required this.gender,
    required this.weaknesses,
    required this.evolutions,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map<String>((type) => type['type']['name'] as String)
        .toList();

    final abilities = (json['abilities'] as List)
        .map<String>((ability) => ability['ability']['name'] as String)
        .toList();

    final stats = <String, int>{};

    for (final stat in json['stats'] as List) {
      stats[stat['stat']['name'] as String] = stat['base_stat'] as int;
    }

    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl:
          (json['sprites']['other']['official-artwork']['front_default']
              as String?) ??
          '',
      types: types,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      abilities: abilities,
      stats: stats,
      description: '',
      category: '',
      gender: '',
      weaknesses: [],
      evolutions: [],
    );
  }

  PokemonDetail copyWith({
    String? description,
    String? category,
    String? gender,
    List<String>? weaknesses,
    List<PokemonEvolution>? evolutions,
  }) {
    return PokemonDetail(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
      height: height,
      weight: weight,
      abilities: abilities,
      stats: stats,
      description: description ?? this.description,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      weaknesses: weaknesses ?? this.weaknesses,
      evolutions: evolutions ?? this.evolutions,
    );
  }
}
