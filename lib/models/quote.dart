class QuoteMode {
  final String id;
  final String text;
  final List<String> tags;
  bool isFavorite;

  QuoteMode({
    required this.id,
    required this.text,
    this.tags = const [],
    this.isFavorite = false,
  });

  
  QuoteMode copyWith({
    String? id,
    String? text,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return QuoteMode(
      id: id ?? this.id,
      text: text ?? this.text,

      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory QuoteMode.fromMap(Map<String, dynamic> data, String documentId) {
    return QuoteMode(
      id: documentId,
      text: data['text'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }
}