import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class PokemonDetailPage extends StatelessWidget {
  final Map<String, dynamic> pokemonData;
  final Map<String, dynamic> evolutionChain;

  PokemonDetailPage({required this.pokemonData, required this.evolutionChain});

  @override
  Widget build(BuildContext context) {
    final spriteUrl = pokemonData['sprite'];
    final name = pokemonData['name'];
    final types = pokemonData['types']?.join(', ') ?? 'Unknown';
    final height = pokemonData['height'] ?? 'Unknown';
    final weight = pokemonData['weight'] ?? 'Unknown';
    final abilities = pokemonData['abilities']?.map((ability) => ability['ability']['name']).join(', ') ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text('Pokémon Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              spriteUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 100),
            ),
            SizedBox(height: 20),
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Custom style for name
            ),
            SizedBox(height: 10),
            Text(
              'Types: $types',
              style: TextStyle(fontSize: 18), // Custom style for types
            ),
            SizedBox(height: 10),
            Text(
              'Height: $height',
              style: TextStyle(fontSize: 18), // Custom style for height
            ),
            SizedBox(height: 10),
            Text(
              'Weight: $weight',
              style: TextStyle(fontSize: 18), // Custom style for weight
            ),
            SizedBox(height: 10),
            Text(
              'Abilities: $abilities',
              style: TextStyle(fontSize: 18), // Custom style for abilities
            ),
            SizedBox(height: 20),
            Text(
              'Evolution Chain:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Custom style for evolution chain heading
            ),
            if (evolutionChain.isNotEmpty)
              _buildEvolutionChain(evolutionChain),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Recursive method to display evolution chain
  Widget _buildEvolutionChain(Map<String, dynamic> chain) {
    List<Widget> evolutionWidgets = [];

    var currentChain = chain['chain'];
    while (currentChain != null) {
      final species = currentChain['species']['name'];
      evolutionWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(species, style: TextStyle(fontSize: 18)), // Custom style for evolution species
      ));
      currentChain = currentChain['evolves_to']?.isNotEmpty == true ? currentChain['evolves_to'][0] : null;
    }

    return Column(
      children: evolutionWidgets,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> pokemonList = [];

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    const String apiUrl = 'https://pokeapi.co/api/v2/pokemon?limit=20';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pokemonList = data['results'] as List;
        });
        await fetchPokemonImagesAndTypes();
      } else {
        print('Failed to fetch Pokémon. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching Pokémon: $error');
    }
  }

  Future<void> fetchPokemonImagesAndTypes() async {
    for (var pokemon in pokemonList) {
      final pokemonUrl = pokemon['url'];
      final response = await http.get(Uri.parse(pokemonUrl));
      if (response.statusCode == 200) {
        final pokemonData = json.decode(response.body);
        setState(() {
          pokemon['sprite'] = pokemonData['sprites']['front_default'] ?? '';
          pokemon['types'] = pokemonData['types']?.map((type) => type['type']['name']).toList() ?? [];
          pokemon['species_url'] = pokemonData['species']['url'] ?? ''; // Ensure URL exists
          pokemon['height'] = pokemonData['height'] ?? 'Unknown';
          pokemon['weight'] = pokemonData['weight'] ?? 'Unknown';
          pokemon['abilities'] = pokemonData['abilities'] ?? [];
        });
      }
    }
  }

  Color getTypeColor(List<String> types) {
    Map<String, Color> typeColors = {
      'fire': Colors.red,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow,
      'bug': Colors.brown,
      'ghost': Colors.purple,
      'psychic': Colors.pink,
      'normal': Colors.grey,
      'dragon': Colors.deepPurple,
      'fairy': Colors.pinkAccent,
      'dark': Colors.black,
      'fighting': Colors.orange,
      'ice': Colors.cyan,
      'rock': Colors.grey,
      'poison': Colors.purpleAccent,
      'steel': Colors.blueGrey,
      'flying': Colors.blue,
    };

    Color color = Colors.grey;
    for (var type in types) {
      if (typeColors.containsKey(type)) {
        color = typeColors[type]!; // First match will be used
        break;
      }
    }
    return color;
  }

  Future<Map<String, dynamic>> fetchEvolutionChain(String speciesUrl) async {
    try {
      final response = await http.get(Uri.parse(speciesUrl));
      if (response.statusCode == 200) {
        final speciesData = json.decode(response.body);
        final evolutionChainUrl = speciesData['evolution_chain']['url'];
        final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
        if (evolutionResponse.statusCode == 200) {
          return json.decode(evolutionResponse.body);
        } else {
          throw Exception('Failed to load evolution chain');
        }
      } else {
        throw Exception('Failed to load species data');
      }
    } catch (error) {
      print('Error fetching evolution chain: $error');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokémon List')),
      body: pokemonList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = pokemonList[index];
          final spriteUrl = pokemon['sprite'];
          final types = List<String>.from(pokemon['types'] ?? []);

          return ElevatedButton(
            onPressed: () async {
              final speciesUrl = pokemon['species_url'];
              final evolutionChain = await fetchEvolutionChain(speciesUrl);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailPage(
                    pokemonData: pokemon,
                    evolutionChain: evolutionChain,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: getTypeColor(types),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(0),
              elevation: 5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (spriteUrl.isNotEmpty)
                  Image.network(
                    spriteUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: 100),
                  ),
                SizedBox(height: 8),
                Text(
                  pokemon['name'] ?? 'Unknown',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
