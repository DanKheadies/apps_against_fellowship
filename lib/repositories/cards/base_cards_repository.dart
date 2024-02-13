// import 'package:flutter/material.dart';

import 'package:apps_against_fellowship/models/models.dart';

abstract class BaseCardsRepository {
  /// Get the list of cardSets that you can use
  Future<List<CardSet>> getAvailableCardSets(
      // {
      //   required BuildContext context,
      // }
      );
}
