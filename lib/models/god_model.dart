// To test CRUD'n with Firebase, et al.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum AlignmentType {
  trueGood,
  trueNeutral,
  trueEvil,
  good,
  neutral,
  evil,
  chaoticGood,
  chaoticNeutral,
  chaoticEvil,
  unknown,
}

// Note: with more complicated objects that will contain sub-collections,
// it's better to build a custom toSnap workflow to facilitate CRUDing
// Firebase specific data. This will avoid creating empty null key-values
// and sub-collections. If it's simplier, e.g. Prayer, toJson is sufficient,
// and we can update still use the fromJson - fromSnap combo.
class God extends Equatable {
  final String id;
  final String name;
  final String origin;
  final AlignmentType alignment;
  final DateTime? firstMention;
  final int miraclesPerformed;
  final List<String> commandments;
  final List<Event>? majorActs;
  final List<Subscriber>? followers;
  final Map<String, List<Prayer>>? prayers;
  final Map<String, String> testamonies;

  const God({
    required this.id,
    required this.name,
    required this.origin,
    required this.alignment,
    required this.miraclesPerformed,
    required this.commandments,
    required this.testamonies,
    this.firstMention,
    this.majorActs,
    this.followers,
    this.prayers,
  });

  @override
  List<Object?> get props => [
        alignment,
        commandments,
        firstMention,
        followers,
        id,
        majorActs,
        miraclesPerformed,
        name,
        origin,
        prayers,
        testamonies,
      ];

  God copyWith({
    AlignmentType? alignment,
    DateTime? firstMention,
    int? miraclesPerformed,
    List<Event>? majorActs,
    List<String>? commandments,
    List<Subscriber>? followers,
    Map<String, List<Prayer>>? prayers,
    Map<String, String>? testamonies,
    String? id,
    String? name,
    String? origin,
  }) {
    return God(
      alignment: alignment ?? this.alignment,
      commandments: commandments ?? this.commandments,
      firstMention: firstMention ?? this.firstMention,
      followers: followers ?? this.followers,
      id: id ?? this.id,
      majorActs: majorActs ?? this.majorActs,
      miraclesPerformed: miraclesPerformed ?? this.miraclesPerformed,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      prayers: prayers ?? this.prayers,
      testamonies: testamonies ?? this.testamonies,
    );
  }

  factory God.fromJson(
    Map<String, dynamic> json, {
    bool? isTimestamp,
  }) {
    AlignmentType align = AlignmentType.values.firstWhere(
      (type) => type.name.toString() == json['alignment'],
    );
    DateTime? firstDT = json['firstMention'] != null && isTimestamp == null
        ? DateTime.parse(json['firstMention'])
        : null;
    List<Event>? actsList = json['majorActs'] != null
        ? (json['majorActs'] as List).map((act) => Event.fromJson(act)).toList()
        : null;
    List<Subscriber>? followersList = json['followers'] != null
        ? (json['followers'] as List)
            .map((fellow) => Subscriber.fromJson(fellow))
            .toList()
        : null;
    List<String> commandmentsList =
        (json['commandments'] as List).map((comm) => comm as String).toList();
    Map<String, List<Prayer>>? prayersMap = json['prayers'] != null
        ? (json['prayers'] as Map).map(
            (k, v) => MapEntry(
              k,
              (v as List)
                  .map((dynamic prayer) => Prayer.fromJson(prayer))
                  .toList(),
            ),
          )
        : null;
    // ? (json['prayers'] as Map<String, List<Event>>).map(
    //     (k, v) => MapEntry(
    //       k,
    //       v.map((dynamic prayer) => Prayer.fromJson(prayer)).toList(),
    //     ),
    //   )
    // : null;
    Map<String, String> testamoniesMap =
        (json['testamonies'] as Map<String, String>).map(
      (k, v) => MapEntry(
        AlignmentType.values
            .firstWhere(
              (status) => status.name.toString() == k,
            )
            .name,
        v,
      ),
    );

    return God(
      alignment: align,
      commandments: commandmentsList,
      firstMention: firstDT,
      followers: followersList,
      id: json['id'],
      majorActs: actsList,
      miraclesPerformed: json['miraclesPerformed'],
      name: json['name'],
      origin: json['origin'],
      prayers: prayersMap,
      testamonies: testamoniesMap,
    );
  }

  factory God.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    DateTime? firstDT = data['firstMention'] != null
        ? (data['firstMention'] as Timestamp).toDate()
        : null;

    return God.fromJson(
      data,
      isTimestamp: true,
    ).copyWith(
      id: snap.id,
      firstMention: firstDT,
    );
  }

  // TODO: a better way to send data toSnap that doesn't add null key-values
  // while still being able to utilize toJson (?)
  Map<String, dynamic> toJson({
    bool? isFirestore,
    // bool? isTimestamp,
  }) {
    print('toJson');
    if (isFirestore != null) {
      return {
        'alignment': alignment.name,
        'commandments': commandments,
        'firstMention': firstMention?.toUtc(),
        // 'firstMention': firstMention != null
        //     ? isFirestore != null
        //         ? firstMention!.toUtc()
        //         : firstMention.toString()
        //     : null,
        'id': id,
        'miraclesPerformed': miraclesPerformed,
        'name': name,
        'origin': origin,
        'testamonies': testamonies,
      };
    }
    return {
      'alignment': alignment.name,
      'commandments': commandments,
      // 'firstMention': firstMention != null
      //     ? isFirestore != null
      //         ? firstMention!.toUtc()
      //         : firstMention.toString()
      //     : null,
      'firstMention': firstMention?.toString(),
      // 'followers': isFirestore != null ? null : followers,
      'followers': followers,
      'id': id,
      // 'majorActs': isFirestore != null ? null : majorActs,
      'majorActs': majorActs,
      'miraclesPerformed': miraclesPerformed,
      'name': name,
      'origin': origin,
      // 'prayers': isFirestore != null ? null : prayers,
      'prayers': prayers,
      'testamonies': testamonies,
    };
  }

  static const emptyGod = God(
    alignment: AlignmentType.unknown,
    commandments: [],
    id: '',
    miraclesPerformed: 0,
    name: '',
    origin: '',
    testamonies: {},
  );
}

God godUsopp = God(
  alignment: AlignmentType.neutral,
  commandments: [
    'A dumbass is still a dumbass.',
    'Man or child, strong or weak, none of those matter once you are out at sea!',
    'I\'ll be brave.',
  ],
  id: Uuid().v4(),
  miraclesPerformed: 3,
  name: 'God Usopp',
  origin: 'East Blue',
  testamonies: {
    AlignmentType.chaoticGood.name:
        'He ate the extremely hot blueberry and TKO\'d whats her face.',
    AlignmentType.trueGood.name: 'He used his observation haki to save Luffy.',
  },
  firstMention: DateTime(1524, 4, 19, 16, 20, 6, 9),
  followers: [
    Subscriber(
      id: Uuid().v4(),
      name: 'Tony Tony Chopper',
      socialSecurityNumber: 666 - 66 - 5555,
      cardType: 'Visa',
      cardNumber: 012345678900,
      expirationDate: DateTime(1525, 12, 1),
      securityCode: 124,
      favoriteColor: Colors.pinkAccent,
    ),
    Subscriber(
      id: Uuid().v4(),
      name: 'Olaf',
      socialSecurityNumber: 222 - 33 - 4444,
      cardType: 'Mastercard',
      cardNumber: 012345678901,
      expirationDate: DateTime(1532, 2, 3),
      securityCode: 972,
      favoriteColor: Colors.red,
    ),
  ],
  majorActs: [
    Event(
      id: Uuid().v4(),
      description: 'Saved Dressrosa and all the little people.',
      title: 'Redeemed Dressrosa',
      occurance: DateTime(1524, 8, 19),
    ),
  ],
  prayers: {
    'a1b2c3d4e5f6-g7h8i9j0k': [
      Prayer(
        id: Uuid().v4(),
        prayer: 'Help me!',
        userId: 'a1b2c3d4e5f6-g7h8i9j0k',
        // when: DateTime(1524, 4, 19, 8, 10),
        where: 'Dressrosa',
      ),
      Prayer(
        id: Uuid().v4(),
        prayer: 'Save us, someone!',
        userId: 'a1b2c3d4e5f6-g7h8i9j0k',
        // when: DateTime(1524, 4, 19, 16, 20, 6, 9),
      ),
      Prayer(
        id: Uuid().v4(),
        prayer: 'Help the princess!',
        userId: 'a1b2c3d4e5f6-g7h8i9j0k',
        where: 'Dressrosa',
      ),
    ],
    'g7h8i9j0k-a1b2c3d4e5f6': [
      Prayer(
        id: Uuid().v4(),
        prayer: 'Fight!',
        userId: 'g7h8i9j0k-a1b2c3d4e5f6',
        // when: DateTime(1524, 4, 19),
        where: 'Dressrosa',
      ),
    ],
  },
);

class Subscriber extends Equatable {
  final String id;
  final String name;
  final int socialSecurityNumber;
  final String cardType;
  final int cardNumber;
  final DateTime? expirationDate;
  final int securityCode;
  final Color favoriteColor;

  const Subscriber({
    required this.id,
    required this.name,
    required this.socialSecurityNumber,
    required this.cardType,
    required this.cardNumber,
    this.expirationDate,
    required this.securityCode,
    required this.favoriteColor,
  });

  @override
  List<Object?> get props => [
        cardNumber,
        cardType,
        expirationDate,
        favoriteColor,
        id,
        name,
        securityCode,
        socialSecurityNumber,
      ];

  Subscriber copyWith({
    Color? favoriteColor,
    DateTime? expirationDate,
    int? cardNumber,
    int? securityCode,
    int? socialSecurityNumber,
    String? cardType,
    String? id,
    String? name,
  }) {
    return Subscriber(
      cardNumber: cardNumber ?? this.cardNumber,
      cardType: cardType ?? this.cardType,
      expirationDate: expirationDate ?? this.expirationDate,
      favoriteColor: favoriteColor ?? this.favoriteColor,
      id: id ?? this.id,
      name: name ?? this.name,
      securityCode: securityCode ?? this.securityCode,
      socialSecurityNumber: socialSecurityNumber ?? this.socialSecurityNumber,
    );
  }

  factory Subscriber.fromJson(
    Map<String, dynamic> json, {
    bool? isTimestamp,
  }) {
    DateTime? expirationDT =
        json['expirationDate'] != null && isTimestamp == null
            ? DateTime.parse(json['expirationDate'])
            : null;
    print('fromJson favColor: ${json['favoriteColor']}');

    return Subscriber(
      cardNumber: json['cardNumber'],
      cardType: json['cardType'],
      expirationDate: expirationDT,
      favoriteColor: json['favoriteColor'], // TODO: check
      id: json['id'],
      name: json['name'],
      securityCode: json['securityCode'],
      socialSecurityNumber: json['socialSecurityNumber'],
    );
  }

  factory Subscriber.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    DateTime? expirationDT = data['expirationDate'] != null
        ? (data['expirationDate'] as Timestamp).toDate()
        : null;

    return Subscriber.fromJson(
      data,
      isTimestamp: true,
    ).copyWith(
      id: snap.id,
      expirationDate: expirationDT,
    );
  }

  Map<String, dynamic> toJson({
    bool? isTimestamp,
  }) {
    print('sub toJson');
    print('favColor: $favoriteColor');

    return {
      'cardNumber': cardNumber,
      'cardType': cardType,
      'expirationDate': expirationDate != null
          ? isTimestamp != null
              ? expirationDate!.toUtc()
              : expirationDate.toString()
          : null,
      'favoriteColor': favoriteColor.toString(),
      'id': id,
      'name': name,
      'securityCode': securityCode,
      'socialSecurityNumber': socialSecurityNumber,
    };
  }

  static const emptySubsriber = Subscriber(
    id: '',
    name: '',
    socialSecurityNumber: 0,
    cardType: '',
    cardNumber: 0,
    securityCode: 0,
    favoriteColor: Colors.transparent,
  );
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? occurance;
  final Duration? duration;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.occurance,
    this.duration,
  });

  @override
  List<Object?> get props => [
        description,
        duration,
        id,
        occurance,
        title,
      ];

  Event copyWith({
    DateTime? occurance,
    Duration? duration,
    String? description,
    String? id,
    String? title,
  }) {
    return Event(
      description: description ?? this.description,
      duration: duration ?? this.duration,
      id: id ?? this.id,
      occurance: occurance ?? this.occurance,
      title: title ?? this.title,
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    bool? isTimestamp,
  }) {
    DateTime? occuranceDT = json['occurance'] != null && isTimestamp == null
        ? DateTime.parse(json['occurance'])
        : null;
    print('fromJson duration: ${json['duration']}');

    return Event(
      description: json['description'],
      duration: json['duration'], // TODO: this
      id: json['id'],
      occurance: occuranceDT,
      title: json['title'],
    );
  }

  factory Event.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    DateTime? occuranceDT = data['occurance'] != null
        ? (data['occurance'] as Timestamp).toDate()
        : null;

    return Event.fromJson(
      data,
      isTimestamp: true,
    ).copyWith(
      id: snap.id,
      occurance: occuranceDT,
    );
  }

  Map<String, dynamic> toJson({
    bool? isTimestamp,
  }) {
    return {
      'description': description,
      'duration': duration,
      'id': id,
      'occurance': occurance != null
          ? isTimestamp != null
              ? occurance!.toUtc()
              : occurance.toString()
          : null,
      'title': title,
    };
  }

  static const emptyEvent = Event(
    description: '',
    id: '',
    title: '',
  );
}

class Prayer extends Equatable {
  final String id;
  final String prayer;
  final String userId;
  // final DateTime? when;
  final String? where;

  const Prayer({
    required this.id,
    required this.prayer,
    required this.userId,
    // this.when,
    this.where,
  });

  @override
  List<Object?> get props => [
        id,
        prayer,
        userId,
        where,
        // when,
      ];

  Prayer copyWith({
    String? id,
    String? prayer,
    String? userId,
    String? where,
  }) {
    return Prayer(
      id: id ?? this.id,
      prayer: prayer ?? this.prayer,
      userId: userId ?? this.userId,
      where: where ?? this.where,
    );
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'],
      prayer: json['prayer'],
      userId: json['userId'],
      where: json['where'],
    );
  }

  factory Prayer.fromSnapshot(DocumentSnapshot snap) {
    dynamic data = snap.data();
    return Prayer.fromJson(data).copyWith(
      id: snap.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayer': prayer,
      'userId': userId,
      'where': where,
    };
  }

  static const emptyPrayer = Prayer(
    id: '',
    prayer: '',
    userId: '',
  );
}
