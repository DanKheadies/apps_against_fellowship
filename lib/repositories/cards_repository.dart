import 'package:apps_against_fellowship/cubits/cubits.dart';
import 'package:apps_against_fellowship/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardsRepository {
  final CardCacheCubit _cardCache;
  final FirebaseFirestore _firestore;

  CardsRepository({
    required CardCacheCubit cardCache,
    FirebaseFirestore? firestore,
  })  : _cardCache = cardCache,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the list of cardSets that you can use
  Future<List<CardSet>> getAvailableCardSets() async {
    final cachedSets = _cardCache.state;
    if (cachedSets.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      return cachedSets;
    } else {
      var snapshots = await _firestore.collection('cardSets').get();

      // print("${snapshots.docs.length} Card sets found");

      final cardSets = snapshots.docs.map((e) {
        var cardSet = CardSet.fromJson(e.data());
        cardSet.copyWith(
          id: e.id,
        );
        return cardSet;
      }).toList();

      _cardCache.setCardSets(cardSets);

      return cardSets;
    }
  }
}
