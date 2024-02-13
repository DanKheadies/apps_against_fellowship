import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:apps_against_fellowship/repositories/repositories.dart';

class CardsRepository extends BaseCardsRepository {
  // final CardCacheState _cardCache;
  final CardCacheCubit _cardCache;
  final FirebaseFirestore _firestore;

  CardsRepository({
    // required CardCacheState cardCache,
    required CardCacheCubit cardCache,
    FirebaseFirestore? firestore,
  })  : _cardCache = cardCache,
        _firestore = firestore ?? FirebaseFirestore.instance;
  // GameRepository({
  //   FirebaseFirestore? firestore,
  //   required UserRepository userRepository,
  // })  :
  //       // assert(userRepository != null),
  //       _firestore = firestore ?? FirebaseFirestore.instance,
  //       _userRepository = userRepository;

  @override
  Future<List<CardSet>> getAvailableCardSets(
      // {
      //   required BuildContext context,
      // }
      ) async {
    // final cachedSets = _cardCache.cardSets;
    final cachedSets = _cardCache.state;
    // final cacheContext = context.read<CardCacheCubit>();
    // final cachedSets = cacheContext.state;
    if (cachedSets.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      return cachedSets;
    } else {
      var snapshots = await _firestore.collection('cardSets').get();

      print("${snapshots.docs.length} Card sets found");

      final cardSets = snapshots.docs.map((e) {
        var cardSet = CardSet.fromJson(e.data());
        // cardSet.id = e.id;
        cardSet.copyWith(
          id: e.id,
        );
        return cardSet;
      }).toList();

      // _cardCache.copyWith(
      //   cardSets: cardSets,
      // );
      _cardCache.setCardSets(cardSets);
      // cacheContext.setCardSets(cardSets);

      return cardSets;
    }
  }
}
