import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon_detail.dart';
import '../providers/favorites_provider.dart';
import '../services/pokemon_api.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final int pokemonId;

  const PokemonDetailScreen({super.key, required this.pokemonId});

  @override
  ConsumerState<PokemonDetailScreen> createState() =>
      _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> {
  final PokemonApi _pokemonApi = PokemonApi();

  PokemonDetail? _pokemon;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPokemonDetail();
  }

  Future<void> _loadPokemonDetail() async {
    try {
      final pokemon = await _pokemonApi.fetchPokemonDetail(widget.pokemonId);

      if (!mounted) return;

      setState(() {
        _pokemon = pokemon;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load Pokémon details';
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return const Color(0xFFFF984D);
      case 'water':
        return const Color(0xFF4D95DD);
      case 'grass':
        return const Color(0xFF61BE5C);
      case 'electric':
        return const Color(0xFFE8B83D);
      case 'psychic':
        return const Color(0xFFD8619A);
      case 'ice':
        return const Color(0xFF62C7D4);
      case 'dragon':
        return const Color(0xFF1777C8);
      case 'dark':
        return const Color(0xFF65525A);
      case 'fairy':
        return const Color(0xFFE58BA5);
      case 'fighting':
        return const Color(0xFFC94C43);
      case 'poison':
        return const Color(0xFFB044B5);
      case 'ground':
        return const Color(0xFFC29A45);
      case 'rock':
        return const Color(0xFFA89442);
      case 'bug':
        return const Color(0xFF8BC72A);
      case 'ghost':
        return const Color(0xFF8065A5);
      case 'flying':
        return const Color(0xFF78A9E8);
      case 'steel':
        return const Color(0xFF969DB7);
      case 'normal':
        return const Color(0xFFA8A878);
      default:
        return const Color(0xFFA8A878);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.grass;
      case 'electric':
        return Icons.bolt;
      case 'psychic':
        return Icons.auto_awesome;
      case 'ice':
        return Icons.ac_unit;
      case 'dragon':
        return Icons.auto_awesome;
      case 'dark':
        return Icons.nightlight_round;
      case 'fairy':
        return Icons.auto_awesome;
      case 'fighting':
        return Icons.sports_martial_arts;
      case 'poison':
        return Icons.science;
      case 'ground':
        return Icons.landscape;
      case 'rock':
        return Icons.terrain;
      case 'bug':
        return Icons.bug_report;
      case 'ghost':
        return Icons.visibility_off;
      case 'flying':
        return Icons.air;
      case 'steel':
        return Icons.shield;
      default:
        return Icons.circle;
    }
  }

  String _formatName(String value) {
    return value
        .split('-')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_pokemon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokémon')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage ?? 'Something went wrong'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadPokemonDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final pokemon = _pokemon!;
    final primaryType = pokemon.types.isNotEmpty
        ? pokemon.types.first
        : 'normal';
    final primaryColor = _getTypeColor(primaryType);

    final isFavorite = ref.watch(
      favoritesProvider.select((favorites) => favorites.contains(pokemon.id)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(pokemon.id);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned(
                    right: -25,
                    bottom: 20,
                    child: Icon(
                      _getTypeIcon(primaryType),
                      size: 240,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 82,
                        left: 28,
                        right: 28,
                        bottom: 18,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              pokemon.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.catching_pokemon,
                                  color: Colors.white70,
                                  size: 110,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatName(pokemon.name),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 7,
                            children: pokemon.types.map((type) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatName(type),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pokemon.description.isEmpty
                        ? 'No description available.'
                        : pokemon.description,
                    style: const TextStyle(
                      color: Color(0xFF6E6E6E),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Informações',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'PESO',
                          '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoCard(
                          'ALTURA',
                          '${(pokemon.height / 10).toStringAsFixed(1)} m',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'CATEGORIA',
                          pokemon.category.isEmpty
                              ? 'Unknown'
                              : pokemon.category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoCard(
                          'HABILIDADE',
                          pokemon.abilities.isEmpty
                              ? 'Unknown'
                              : pokemon.abilities.map(_formatName).join(', '),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Gênero'),
                  const SizedBox(height: 10),
                  _buildWhiteCard(
                    child: Text(
                      pokemon.gender.isEmpty ? 'Genderless' : pokemon.gender,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Fraquezas'),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pokemon.weaknesses.map((type) {
                      final color = _getTypeColor(type);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(type),
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatName(type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Evoluções'),
                  const SizedBox(height: 10),

                  if (pokemon.evolutions.isEmpty)
                    _buildWhiteCard(
                      child: const Text(
                        'No evolutions available.',
                        style: TextStyle(color: Color(0xFF777777)),
                      ),
                    )
                  else
                    SizedBox(
                      height: 135,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: pokemon.evolutions.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 10);
                        },
                        itemBuilder: (context, index) {
                          final evolution = pokemon.evolutions[index];

                          return Container(
                            width: 125,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    evolution.imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatName(evolution.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 28),

                  _buildSectionTitle('Base Stats'),
                  const SizedBox(height: 14),

                  ...pokemon.stats.entries.map(
                    (entry) => _buildStatRow(
                      _formatStat(entry.key),
                      entry.value,
                      primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _buildStatRow(String name, int value, Color color) {
    final progress = (value / 150).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFEAEAEA),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStat(String value) {
    switch (value) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Attack';
      case 'special-defense':
        return 'Sp. Defense';
      case 'speed':
        return 'Speed';
      default:
        return _formatName(value);
    }
  }
}
