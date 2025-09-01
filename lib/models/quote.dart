class QuoteMode {
  final String id;
  final String text;
  final String writer;
  final List<String> tags;
  bool isFavorite;

  QuoteMode({
    required this.id,
    required this.text,
    required this.writer,
    this.tags = const [],
    this.isFavorite = false,
  });

  
  QuoteMode copyWith({
    String? id,
    String? text,
    String? writer,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return QuoteMode(
      id: id ?? this.id,
      text: text ?? this.text,
      writer: writer ?? this.writer,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory QuoteMode.fromMap(Map<String, dynamic> data, String documentId) {
    return QuoteMode(
      id: documentId,
      text: data['text'] ?? '',
      writer: data['writer'] ?? 'Not-Known',
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'writer': writer,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }
}