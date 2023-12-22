import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final bool acceptedTerms;
  final DateTime? updatedAt;
  final String avatarUrl;
  final String id;
  final String name;

  const User({
    required this.acceptedTerms,
    required this.avatarUrl,
    required this.id,
    required this.name,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        acceptedTerms,
        avatarUrl,
        id,
        name,
        updatedAt,
      ];

  User copyWith({
    bool? acceptedTerms,
    DateTime? updatedAt,
    String? avatarUrl,
    String? id,
    String? name,
  }) {
    return User(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();

    return User(
      acceptedTerms: data['acceptedTerms'] ?? false,
      avatarUrl: data['avatarUrl'] ?? '',
      id: snap.id,
      // id: json['id'] ?? '', // alt
      name: data['name'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json,
    // remove this array for alt
    [
    String? id,
  ]) {
    return User(
      acceptedTerms: json['acceptedTerms'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      id: id ?? '',
      // id: json['id'] ?? '', // alt
      name: json['name'] ?? '',
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acceptedTerms': acceptedTerms,
      'avatarUrl': avatarUrl,
      'id': id,
      // remove id for alt
      'name': name,
      'updatedAt': updatedAt.toString(),
    };
  }

  // static final emptyUser = User(
  static const emptyUser = User(
    acceptedTerms: false,
    avatarUrl: '',
    id: '',
    name: '',
    // updatedAt: DateTime.now(),
  );
}
