import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<Set<int>> {
  static const String _favoritesKey = 'favorite_pokemon_ids';

  @override
  Set<int> build() {
    _loadFavorites();

    return {};
  }

  Future<void> _loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();

    final savedFavorites = preferences.getStringList(_favoritesKey) ?? [];

    state = savedFavorites.map(int.parse).toSet();
  }

  Future<void> toggleFavorite(int pokemonId) async {
    final updatedFavorites = {...state};

    if (updatedFavorites.contains(pokemonId)) {
      updatedFavorites.remove(pokemonId);
    } else {
      updatedFavorites.add(pokemonId);
    }

    // Update UI immediately
    state = updatedFavorites;

    // Save to device
    final preferences = await SharedPreferences.getInstance();

    await preferences.setStringList(
      _favoritesKey,
      updatedFavorites.map((id) => id.toString()).toList(),
    );
  }

  bool isFavorite(int pokemonId) {
    return state.contains(pokemonId);
  }
}
