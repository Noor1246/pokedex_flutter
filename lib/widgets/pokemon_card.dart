import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';

class PokemonCard extends ConsumerWidget {
  final String name;
  final String id;
  final List<String> types;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.name,
    required this.id,
    required this.types,
    required this.imageUrl,
    required this.backgroundColor,
    this.onTap,
  });

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

  Color _getLightTypeColor(Color color) {
    return Color.lerp(Colors.white, color, 0.20)!;
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

  String _formatType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonId = int.parse(id);

    final isFavorite = ref.watch(
      favoritesProvider.select((favorites) => favorites.contains(pokemonId)),
    );

    final primaryType = types.isNotEmpty ? types.first : 'normal';

    final typeColor = _getTypeColor(primaryType);
    final lightColor = _getLightTypeColor(typeColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#$id',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 25,
                      child: Row(
                        children: types.map((type) {
                          final pillColor = _getTypeColor(type);

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: pillColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getTypeIcon(type),
                                      size: 10,
                                      color: pillColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatType(type),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 118,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Strong type-colored panel.
                  Positioned.fill(child: ColoredBox(color: typeColor)),

                  // Large translucent Figma-style motif.
                  // Large Figma-style translucent type motif.
                  Positioned(
                    right: -18,
                    bottom: -18,
                    child: Icon(
                      _getTypeIcon(primaryType),
                      size: 125,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),

                  // Soft translucent circular layer behind the artwork.
                  Positioned(
                    right: 4,
                    top: 12,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ),

                  // Pokémon artwork.
                  Center(
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.catching_pokemon,
                          size: 52,
                          color: Colors.white70,
                        );
                      },
                    ),
                  ),

                  // Favorite.
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(pokemonId);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.60),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
