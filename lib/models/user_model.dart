import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final bool acceptedTerms;
  final bool developerPackEnabled;
  final bool isDarkTheme;
  final DateTime? updatedAt;
  final int? playerLimit;
  final int? prizesToWin;
  final String avatarUrl;
  final String deviceId;
  final String id;
  final String name;
  final String? pushToken;

  const User({
    required this.acceptedTerms,
    required this.avatarUrl,
    required this.developerPackEnabled,
    required this.deviceId,
    required this.id,
    required this.isDarkTheme,
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
        id,
        isDarkTheme,
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
    String? id,
    String? name,
    String? pushToken,
  }) {
    return User(
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      developerPackEnabled: developerPackEnabled ?? this.developerPackEnabled,
      deviceId: deviceId ?? this.deviceId,
      id: id ?? this.id,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
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
      id: json['id'] ?? '',
      isDarkTheme: json['isDarkTheme'] ?? false,
      name: json['name'] ?? '',
      playerLimit: json['playerLimit'] ?? 0,
      prizesToWin: json['prizesToWin'] ?? 0,
      pushToken: json['pushToken'] ?? '',
      updatedAt: updatedTime,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    DateTime updatedTime = data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp).toDate()
        : DateTime.now();

    return User.fromJson(data).copyWith(
      id: snap.id,
      updatedAt: updatedTime,
    );

    // return User(
    //   acceptedTerms: data['acceptedTerms'] ?? false,
    //   avatarUrl: data['avatarUrl'] ?? '',
    //   id: snap.id,
    //   isDarkTheme: data['isDarkTheme'] ?? false,
    //   name: data['name'] ?? '',
    //   updatedAt: updatedTime,
    // );
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
      'id': id,
      'isDarkTheme': isDarkTheme,
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
    id: '',
    isDarkTheme: false,
    name: '',
  );
}
