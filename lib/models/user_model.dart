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
    DateTime updatedTime = data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp).toDate()
        : DateTime.now();

    return User(
      acceptedTerms: data['acceptedTerms'] ?? false,
      avatarUrl: data['avatarUrl'] ?? '',
      id: snap.id,
      name: data['name'] ?? '',
      updatedAt: updatedTime,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime updatedTime = json['updatedAt'] != null
        // ? (json['updatedAt'] as Timestamp).toDate()
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now();

    return User(
      acceptedTerms: json['acceptedTerms'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      // updatedAt: DateTime.parse(json['updatedAt']),
      updatedAt: updatedTime,
    );
  }

  Map<String, dynamic> toSnap() {
    return {
      'acceptedTerms': acceptedTerms,
      'avatarUrl': avatarUrl,
      'id': id,
      'name': name,
      'updatedAt': updatedAt?.toUtc(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'acceptedTerms': acceptedTerms,
      'avatarUrl': avatarUrl,
      'id': id,
      'name': name,
      'updatedAt': updatedAt?.toString(),
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
