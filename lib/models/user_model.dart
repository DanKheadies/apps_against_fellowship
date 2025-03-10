import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final bool acceptedTerms;
  final bool developerPackEnabled;
  final DateTime? updatedAt;
  final int? playerLimit;
  final int? prizesToWin;
  final String avatarUrl;
  final String deviceId;
  final String id;
  final String email;
  final String name;
  final String? pushToken;

  const User({
    required this.acceptedTerms,
    required this.avatarUrl,
    required this.developerPackEnabled,
    required this.deviceId,
    required this.email,
    required this.id,
    required this.name,
    this.playerLimit,
    this.prizesToWin,
    this.pushToken,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        acceptedTerms,
        avatarUrl,
        developerPackEnabled,
        deviceId,
        email,
        id,
        name,
        playerLimit,
        prizesToWin,
        pushToken,
        updatedAt,
      ];

  User copyWith({
    bool? acceptedTerms,
    bool? developerPackEnabled,
    bool? isDarkTheme,
    DateTime? updatedAt,
    int? playerLimit,
    int? prizesToWin,
    String? avatarUrl,
    String? deviceId,
    String? email,
    String? id,
    String? name,
    String? pushToken,
  }) {
    return User(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      developerPackEnabled: developerPackEnabled ?? this.developerPackEnabled,
      deviceId: deviceId ?? this.deviceId,
      email: email ?? this.email,
      id: id ?? this.id,
      name: name ?? this.name,
      playerLimit: playerLimit ?? this.playerLimit,
      prizesToWin: prizesToWin ?? this.prizesToWin,
      pushToken: pushToken ?? this.pushToken,
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
      developerPackEnabled: json['developerPackEnabled'] ?? false,
      deviceId: json['deviceId'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      playerLimit: json['playerLimit'],
      prizesToWin: json['prizesToWin'],
      pushToken: json['pushToken'],
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
      developerPackEnabled: data['developerPackEnabled'] ?? false,
      deviceId: data['deviceId'] ?? '',
      email: data['email'] ?? '',
      id: snap.id,
      name: data['name'] ?? '',
      playerLimit: data['playerLimit'],
      prizesToWin: data['prizesToWin'],
      pushToken: data['pushToken'],
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
      'developerPackEnabled': developerPackEnabled,
      'deviceId': deviceId,
      'email': email,
      'id': id,
      'name': name,
      'playerLimit': playerLimit,
      'prizesToWin': prizesToWin,
      'pushToken': pushToken,
      'updatedAt': isFirebase ? updatedDT.toUtc() : updatedDT.toString(),
    };
  }

  static const emptyUser = User(
    acceptedTerms: false,
    avatarUrl: '',
    developerPackEnabled: false,
    deviceId: '',
    email: '',
    id: '',
    name: '',
  );
}
