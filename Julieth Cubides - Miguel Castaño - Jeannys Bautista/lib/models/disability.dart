class Disability {
  final String id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final String iconEmoji;
  final List<String> characteristics;
  final List<PedagogicalStrategy> strategies;

  const Disability({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.iconEmoji,
    required this.characteristics,
    required this.strategies,
  });
}

class PedagogicalStrategy {
  final String title;
  final String description;
  final String iconEmoji;

  const PedagogicalStrategy({
    required this.title,
    required this.description,
    required this.iconEmoji,
  });
}
