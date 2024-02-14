// import 'package:appsagainsthumanity/data/features/cards/model/response_card.dart';
// import 'package:meta/meta.dart';

import 'package:apps_against_fellowship/models/models.dart';

// @immutable
class PlayerResponse {
  final String playerId;
  final List<ResponseCard> responses;

  const PlayerResponse({
    required this.playerId,
    required this.responses,
  });
}
