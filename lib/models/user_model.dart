import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final bool acceptedTerms;
  final bool isDarkTheme;
  final DateTime? updatedAt;
  final String avatarUrl;
  final String id;
  final String name;
  // final bool developerPackEnabled;
  // final bool isDarkMode;
  // final int playerLimit;
  // final int prizesToWin;
  // final String deviceId;
  // final String pushToken;

  const User({
    required this.acceptedTerms,
    required this.avatarUrl,
    required this.id,
    required this.isDarkTheme,
    required this.name,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        acceptedTerms,
        avatarUrl,
        id,
        isDarkTheme,
        name,
        updatedAt,
      ];

  User copyWith({
    bool? acceptedTerms,
    bool? isDarkTheme,
    DateTime? updatedAt,
    String? avatarUrl,
    String? id,
    String? name,
  }) {
    return User(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      id: id ?? this.id,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime updatedTime = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now();

    return User(
      acceptedTerms: json['acceptedTerms'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      id: json['id'] ?? '',
      isDarkTheme: json['isDarkTheme'] ?? false,
      name: json['name'] ?? '',
      updatedAt: updatedTime,
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
      isDarkTheme: data['isDarkTheme'] ?? false,
      name: data['name'] ?? '',
      updatedAt: updatedTime,
    );
  }

  Map<String, dynamic> toJson({
    required bool isFirebase,
  }) {
    DateTime updatedDT = updatedAt ?? DateTime.now();

    return {
      'acceptedTerms': acceptedTerms,
      'avatarUrl': avatarUrl,
      'id': id,
      'isDarkTheme': isDarkTheme,
      'name': name,
      'updatedAt': isFirebase ? updatedDT.toUtc() : updatedDT.toString(),
    };
  }

  static const emptyUser = User(
    acceptedTerms: false,
    avatarUrl: '',
    id: '',
    isDarkTheme: false,
    name: '',
  );
}
