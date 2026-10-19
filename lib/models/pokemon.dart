/// Modelo para representar un Pokemon con su nombre, imagen, artwork, tipos,
/// stats, altura y peso.
class Pokemon {
  int id;
  String name;
  String image;
  String artwork;
  List<String> types;
  Map<String, int> stats;
  int height;
  int weight;

  // Constructor de la clase Pokemon con los atributos requeridos
  // esto se hace para que al crear una instancia de Pokemon, estos atributos sean obligatorios
  // se usa en el fromJson que es un metodo que convierte un JSON en una instancia de Pokemon
  Pokemon({
    required this.id,
    required this.name,
    required this.image,
    required this.artwork,
    required this.types,
    required this.stats,
    required this.height,
    required this.weight,
  });

  // Factory porque es un método que retorna una nueva instancia de la clase
  // este metodo se usa para convertir un JSON en una instancia de Pokemon
  // es null-safe: cualquier campo ausente cae a un valor por defecto sensato
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // se lee el bloque de sprites de forma defensiva (puede venir nulo)
    final sprites = json['sprites'] as Map<String, dynamic>?;
    // imagen clásica con fallback a cadena vacía
    final frontDefault = sprites?['front_default'] as String? ?? '';
    // artwork oficial con fallback a front_default y a ''
    final other = sprites?['other'] as Map<String, dynamic>?;
    final officialBlock = other?['official-artwork'] as Map<String, dynamic>?;
    final officialFront = officialBlock?['front_default'] as String?;
    final artwork = officialFront ?? frontDefault;

    // en types se guarda la lista de tipos del pokemon.
    // se usa List<String>.from para convertir la lista de tipos del JSON en una lista de Strings en Dart
    final rawTypes = json['types'] as List<dynamic>? ?? const [];
    final types = rawTypes
        .map((tp) => (tp as Map<String, dynamic>)['type']?['name'] as String?)
        .whereType<String>()
        .toList();

    // se construyen las stats base (hp, attack, ...) desde json['stats']
    final rawStats = json['stats'] as List<dynamic>? ?? const [];
    final parsedStats = <String, int>{};
    for (final entry in rawStats) {
      final map = entry as Map<String, dynamic>?;
      final statName = map?['stat']?['name'] as String?;
      final baseStat = map?['base_stat'] as int?;
      if (statName != null) {
        parsedStats[statName] = baseStat ?? 0;
      }
    }
    // se garantizan las 6 stats canónicas aunque la API no las traiga
    const statKeys = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];
    final stats = {for (final key in statKeys) key: parsedStats[key] ?? 0};

    return Pokemon(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      image: frontDefault,
      artwork: artwork,
      types: types,
      stats: stats,
      height: (json['height'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
    );
  }
}
