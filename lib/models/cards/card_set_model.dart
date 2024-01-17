import 'package:equatable/equatable.dart';

class CardSet extends Equatable {
  final int prompt;
  final int responses;
  final String id;
  final String name;
  final String source;

  const CardSet({
    required this.id,
    required this.name,
    required this.prompt,
    required this.responses,
    required this.source,
  });

  @override
  List<Object> get props => [
        id,
        name,
        prompt,
        responses,
        source,
      ];

  CardSet copyWith({
    int? prompt,
    int? responses,
    String? id,
    String? name,
    String? source,
  }) {
    return CardSet(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      responses: responses ?? this.responses,
      source: source ?? this.source,
    );
  }

  factory CardSet.fromJson(Map<String, dynamic> json) {
    return CardSet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      prompt: json['prompt'] ?? 0,
      responses: json['responses'] ?? 0,
      source: json['source'] ?? '',
    );
  }

  // TBD - fromSnapshot

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prompt': prompt,
      'responses': responses,
      'source': source,
    };
  }

  static const emptyCardSet = CardSet(
    id: '',
    name: '',
    prompt: 0,
    responses: 0,
    source: '',
  );
}
