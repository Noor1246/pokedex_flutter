import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_detail.dart';
import '../providers/favorites_provider.dart';
import '../services/pokemon_api.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final PokemonApi _pokemonApi = PokemonApi();
  final ScrollController _scrollController = ScrollController();

  List<Pokemon> _pokemon = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;
  String? _nextUrl;

  String _searchQuery = '';
  String _selectedType = 'All Types';
  String _selectedSort = 'Lowest Number';

  @override
  void initState() {
    super.initState();

    _loadPokemon();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_searchQuery.isNotEmpty || _selectedType != 'All Types') {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMorePokemon();
    }
  }

  Future<void> _loadPokemon() async {
    try {
      final page = await _pokemonApi.fetchPokemonPage();

      if (!mounted) return;

      setState(() {
        _pokemon = page.pokemon;
        _nextUrl = page.nextUrl;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load Pokémon';
      });
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_nextUrl == null || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final page = await _pokemonApi.fetchPokemonPage(url: _nextUrl);

      if (!mounted) return;

      setState(() {
        _pokemon.addAll(page.pokemon);
        _nextUrl = page.nextUrl;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _showTypeFilter() {
    final types = <String>{
      'All Types',
      ..._pokemon.expand((pokemon) => pokemon.types),
    }.toList();

    types.sort();

    if (types.remove('All Types')) {
      types.insert(0, 'All Types');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              shrinkWrap: true,
              children: types.map((type) {
                final isSelected = type == _selectedType;

                return ListTile(
                  title: Text(
                    type == 'All Types' ? 'Todos os tipos' : _formatName(type),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    const options = ['Lowest Number', 'Highest Number', 'A-Z', 'Z-A'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              shrinkWrap: true,
              children: options.map((option) {
                final isSelected = option == _selectedSort;

                return ListTile(
                  title: Text(
                    _formatSort(option),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _selectedSort = option;
                    });

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
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
        return const Color(0xFF333333);
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

  String _formatSort(String value) {
    switch (value) {
      case 'Lowest Number':
        return 'Menor número';
      case 'Highest Number':
        return 'Maior número';
      case 'A-Z':
        return 'A-Z';
      case 'Z-A':
        return 'Z-A';
      default:
        return value;
    }
  }

  Widget _buildFilterButton({
    required VoidCallback onPressed,
    required Widget leading,
    required String label,
    Color? backgroundColor,
  }) {
    final color = backgroundColor ?? const Color(0xFF333333);

    return SizedBox(
      height: 40,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillIcon() {
    return const Icon(Icons.filter_list, size: 17, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      body: SafeArea(child: _buildCurrentScreen()),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildPokedexScreen();

      case 1:
        return _buildRegionsScreen();

      case 2:
        return _buildFavoritesScreen();

      case 3:
        return _buildProfileScreen();

      default:
        return _buildPokedexScreen();
    }
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      height: 82,
      backgroundColor: const Color(0xFFF8F0FC),
      indicatorColor: const Color(0xFFE7D5FF),

      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.catching_pokemon_outlined),
          selectedIcon: Icon(Icons.catching_pokemon),
          label: 'Pokédex',
        ),
        NavigationDestination(
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on),
          label: 'Regiões',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildPokedexScreen() {
    final selectedTypeColor = _selectedType == 'All Types'
        ? const Color(0xFF333333)
        : _getTypeColor(_selectedType);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pokédex',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 20),

          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase().trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Procurar Pokémon...',
              hintStyle: const TextStyle(color: Color(0xFF777777)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF555555)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  onPressed: _showTypeFilter,
                  leading: _buildPillIcon(),
                  label: _selectedType == 'All Types'
                      ? 'Todos os tipos'
                      : _formatName(_selectedType),
                  backgroundColor: selectedTypeColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildFilterButton(
                  onPressed: _showSortOptions,
                  leading: _buildPillIcon(),
                  label: _formatSort(_selectedSort),
                  backgroundColor: const Color(0xFF333333),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Pokémon',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          Expanded(child: _buildPokemonList()),
        ],
      ),
    );
  }

  Widget _buildPokemonList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadPokemon, child: const Text('Retry')),
          ],
        ),
      );
    }

    final displayedPokemon = _pokemon.where((pokemon) {
      final matchesSearch = pokemon.name.contains(_searchQuery);

      final matchesType =
          _selectedType == 'All Types' || pokemon.types.contains(_selectedType);

      return matchesSearch && matchesType;
    }).toList();

    switch (_selectedSort) {
      case 'Lowest Number':
        displayedPokemon.sort((a, b) => a.id.compareTo(b.id));
        break;

      case 'Highest Number':
        displayedPokemon.sort((a, b) => b.id.compareTo(a.id));
        break;

      case 'A-Z':
        displayedPokemon.sort((a, b) => a.name.compareTo(b.name));
        break;

      case 'Z-A':
        displayedPokemon.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    if (displayedPokemon.isEmpty) {
      return const Center(
        child: Text(
          'No Pokémon found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: displayedPokemon.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        if (index >= displayedPokemon.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final pokemon = displayedPokemon[index];

        final formattedName =
            pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

        return PokemonCard(
          name: formattedName,
          id: pokemon.id.toString().padLeft(3, '0'),
          types: pokemon.types,
          imageUrl: pokemon.imageUrl,
          backgroundColor: _getTypeColor(pokemon.types.first),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PokemonDetailScreen(pokemonId: pokemon.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesScreen() {
    final favoriteIds = ref.watch(favoritesProvider);

    if (favoriteIds.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Color(0xFF9B91A7),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Favoritos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Você ainda não possui nenhum Pokémon favorito.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Explorar Pokédex',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favoritos',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${favoriteIds.length} Pokémon favorito${favoriteIds.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: favoriteIds.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                final pokemonId = favoriteIds.elementAt(index);

                Pokemon? loadedPokemon;

                for (final pokemon in _pokemon) {
                  if (pokemon.id == pokemonId) {
                    loadedPokemon = pokemon;
                    break;
                  }
                }

                if (loadedPokemon != null) {
                  final pokemon = loadedPokemon;

                  return PokemonCard(
                    name: _formatName(pokemon.name),
                    id: pokemon.id.toString().padLeft(3, '0'),
                    types: pokemon.types,
                    imageUrl: pokemon.imageUrl,
                    backgroundColor: _getTypeColor(pokemon.types.first),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PokemonDetailScreen(pokemonId: pokemon.id),
                        ),
                      );
                    },
                  );
                }

                return FutureBuilder<PokemonDetail>(
                  future: _pokemonApi.fetchPokemonDetail(pokemonId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Failed to load Pokémon'),
                        ),
                      );
                    }

                    final pokemon = snapshot.data!;

                    return PokemonCard(
                      name: _formatName(pokemon.name),
                      id: pokemon.id.toString().padLeft(3, '0'),
                      types: pokemon.types,
                      imageUrl: pokemon.imageUrl,
                      backgroundColor: _getTypeColor(pokemon.types.first),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PokemonDetailScreen(pokemonId: pokemon.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsScreen() {
    final regions = [
      {
        'name': 'Kanto',
        'generation': '1ª GERAÇÃO',
        'background': const Color(0xFF536F4E),
        'pokemon': [1, 4, 7],
      },
      {
        'name': 'Johto',
        'generation': '2ª GERAÇÃO',
        'background': const Color(0xFF80634C),
        'pokemon': [152, 155, 158],
      },
      {
        'name': 'Hoenn',
        'generation': '3ª GERAÇÃO',
        'background': const Color(0xFF477A73),
        'pokemon': [252, 255, 258],
      },
      {
        'name': 'Sinnoh',
        'generation': '4ª GERAÇÃO',
        'background': const Color(0xFF536879),
        'pokemon': [387, 390, 393],
      },
      {
        'name': 'Unova',
        'generation': '5ª GERAÇÃO',
        'background': const Color(0xFF5B626B),
        'pokemon': [495, 498, 501],
      },
      {
        'name': 'Kalos',
        'generation': '6ª GERAÇÃO',
        'background': const Color(0xFF65704F),
        'pokemon': [650, 653, 656],
      },
      {
        'name': 'Alola',
        'generation': '7ª GERAÇÃO',
        'background': const Color(0xFF3F7C89),
        'pokemon': [722, 725, 728],
      },
      {
        'name': 'Galar',
        'generation': '8ª GERAÇÃO',
        'background': const Color(0xFF60705E),
        'pokemon': [810, 813, 816],
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regiões',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: regions.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final region = regions[index];

                final pokemonIds = region['pokemon'] as List<int>;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 94,
                    color: region['background'] as Color,
                    child: Stack(
                      children: [
                        // Dark gradient for text readability.
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.60),
                                  Colors.black.withValues(alpha: 0.08),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Small Pokémon silhouettes/artwork.
                        Positioned(
                          right: 34,
                          bottom: -8,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: pokemonIds.map((id) {
                              return Image.network(
                                'https://raw.githubusercontent.com/'
                                'PokeAPI/sprites/master/sprites/pokemon/'
                                'other/official-artwork/$id.png',
                                width: 54,
                                height: 54,
                                fit: BoxFit.contain,
                              );
                            }).toList(),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      region['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      region['generation'] as String,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFE6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF8055C8),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Pokémon Trainer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 6),

                const Text('Seu perfil', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 36),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
