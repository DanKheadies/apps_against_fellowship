import 'package:equatable/equatable.dart';

class PromptCard extends Equatable {
  final String cardId;
  final String set;
  final String special;
  final String source;
  final String text;

  const PromptCard({
    required this.cardId,
    required this.set,
    required this.special,
    required this.source,
    required this.text,
  });

  @override
  List<Object> get props => [
        cardId,
        set,
        special,
        source,
        text,
      ];

  PromptCard copyWith({
    String? cardId,
    String? set,
    String? special,
    String? source,
    String? text,
  }) {
    return PromptCard(
      cardId: cardId ?? this.cardId,
      set: set ?? this.set,
      special: special ?? this.special,
      source: source ?? this.source,
      text: text ?? this.text,
    );
  }

  factory PromptCard.fromJson(Map<String, dynamic> json) {
    return PromptCard(
      cardId: json['cardId'] ?? '',
      set: json['set'] ?? '',
      special: json['special'] ?? '',
      source: json['source'] ?? '',
      text: json['text'] ?? '',
    );
  }

  // TBD - fromSnapshot

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'set': set,
      'special': special,
      'source': source,
      'text': text,
    };
  }

  static const emptyPromptCard = PromptCard(
    cardId: '',
    set: '',
    special: '',
    source: '',
    text: '',
  );
}
