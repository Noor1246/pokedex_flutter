import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import '../models/pokemon_detail.dart';
import '../models/pokemon_page.dart';

class PokemonApi {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokemonPage> fetchPokemonPage({String? url}) async {
    final response = await http.get(
      Uri.parse(url ?? '$baseUrl/pokemon?limit=20&offset=0'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }

    final data = jsonDecode(response.body);

    final results = data['results'] as List;

    final pokemon = await Future.wait<Pokemon>(
      results.map((item) => _fetchPokemonDetails(item as Map<String, dynamic>)),
    );

    return PokemonPage(pokemon: pokemon, nextUrl: data['next'] as String?);
  }

  Future<Pokemon> _fetchPokemonDetails(Map<String, dynamic> pokemon) async {
    final response = await http.get(Uri.parse(pokemon['url'] as String));

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon details');
    }

    final data = jsonDecode(response.body);

    final types = (data['types'] as List)
        .map<String>((type) => type['type']['name'] as String)
        .toList();

    return Pokemon(
      name: pokemon['name'] as String,
      url: pokemon['url'] as String,
      types: types,
    );
  }

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final pokemonResponse = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

    if (pokemonResponse.statusCode != 200) {
      throw Exception('Failed to load Pokémon details');
    }

    final pokemonData =
        jsonDecode(pokemonResponse.body) as Map<String, dynamic>;

    var detail = PokemonDetail.fromJson(pokemonData);

    final speciesUrl = pokemonData['species']['url'] as String;

    final speciesResponse = await http.get(Uri.parse(speciesUrl));

    if (speciesResponse.statusCode != 200) {
      return detail;
    }

    final speciesData =
        jsonDecode(speciesResponse.body) as Map<String, dynamic>;

    // Description
    String description = 'No description available.';

    for (final entry in speciesData['flavor_text_entries'] as List) {
      final language = entry['language']['name'];

      if (language == 'en') {
        description = (entry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
        break;
      }
    }

    // Category
    String category = 'Unknown';

    for (final genus in speciesData['genera'] as List) {
      if (genus['language']['name'] == 'en') {
        category = genus['genus'] as String;
        break;
      }
    }

    // Gender
    final genderRate = speciesData['gender_rate'] as int;

    String gender;

    if (genderRate == -1) {
      gender = 'Genderless';
    } else {
      final femalePercentage = (genderRate / 8) * 100;
      final malePercentage = 100 - femalePercentage;

      gender =
          '♂ ${_formatPercentage(malePercentage)}  '
          '♀ ${_formatPercentage(femalePercentage)}';
    }

    // Weaknesses
    final weaknesses = <String>{};

    for (final type in detail.types) {
      final typeResponse = await http.get(Uri.parse('$baseUrl/type/$type'));

      if (typeResponse.statusCode != 200) {
        continue;
      }

      final typeData = jsonDecode(typeResponse.body) as Map<String, dynamic>;

      final doubleDamageFrom =
          typeData['damage_relations']['double_damage_from'] as List;

      for (final weakness in doubleDamageFrom) {
        weaknesses.add(weakness['name'] as String);
      }
    }

    // Evolutions
    final evolutions = <PokemonEvolution>[];

    final evolutionChain = speciesData['evolution_chain'];

    if (evolutionChain != null) {
      final evolutionUrl = evolutionChain['url'] as String;

      final evolutionResponse = await http.get(Uri.parse(evolutionUrl));

      if (evolutionResponse.statusCode == 200) {
        final evolutionData =
            jsonDecode(evolutionResponse.body) as Map<String, dynamic>;

        _extractEvolutions(
          evolutionData['chain'] as Map<String, dynamic>,
          evolutions,
        );
      }
    }

    detail = detail.copyWith(
      description: description,
      category: category,
      gender: gender,
      weaknesses: weaknesses.toList(),
      evolutions: evolutions,
    );

    return detail;
  }

  void _extractEvolutions(
    Map<String, dynamic> chain,
    List<PokemonEvolution> evolutions,
  ) {
    final species = chain['species'] as Map<String, dynamic>;

    final speciesUrl = species['url'] as String;
    final id = _extractIdFromUrl(speciesUrl);

    evolutions.add(
      PokemonEvolution(
        name: species['name'] as String,
        id: id,
        imageUrl:
            'https://raw.githubusercontent.com/'
            'PokeAPI/sprites/master/sprites/pokemon/'
            'other/official-artwork/$id.png',
      ),
    );

    final nextStages = chain['evolves_to'] as List;

    for (final next in nextStages) {
      _extractEvolutions(next as Map<String, dynamic>, evolutions);
    }
  }

  int _extractIdFromUrl(String url) {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  String _formatPercentage(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }

    return '${value.toStringAsFixed(1)}%';
  }
}
