import 'package:equatable/equatable.dart';

class ResponseCard extends Equatable {
  final String cardId;
  final String set;
  final String source;
  final String text;

  const ResponseCard({
    required this.cardId,
    required this.set,
    required this.source,
    required this.text,
  });

  @override
  List<Object> get props => [
        cardId,
        set,
        source,
        text,
      ];

  ResponseCard copyWith({
    String? cardId,
    String? set,
    String? source,
    String? text,
  }) {
    return ResponseCard(
      cardId: cardId ?? this.cardId,
      set: set ?? this.set,
      source: source ?? this.source,
      text: text ?? this.text,
    );
  }

  factory ResponseCard.fromJson(Map<String, dynamic> json) {
    return ResponseCard(
      cardId: json['cardId'] ?? '',
      set: json['set'] ?? '',
      source: json['source'] ?? '',
      text: json['text'] ?? '',
    );
  }

  // TBD - fromSnapshot

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'set': set,
      'source': source,
      'text': text,
    };
  }

  static const emptyResponseCard = ResponseCard(
    cardId: '',
    set: '',
    source: '',
    text: '',
  );
}
