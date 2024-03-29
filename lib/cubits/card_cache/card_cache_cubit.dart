// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:apps_against_fellowship/models/models.dart';

// part 'card_cache_state.dart';

// class CardCacheCubit extends Cubit<CardCacheState> {
class CardCacheCubit extends HydratedCubit<List<CardSet>> {
  // CardCacheCubit() : super(const CardCacheState());
  CardCacheCubit() : super(const []);

  // void getCardSets() async {
  //   emit(
  //     state,
  //   );
  // }

  void setCardSets(List<CardSet> cardSets) {
    emit(
      // state.copyWith(
      //   cardSets: cardSets,
      // ),
      state,
    );
  }

  @override
  List<CardSet>? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    // throw UnimplementedError();
    List<CardSet> cardSetList =
        (json['cardSets'] as List).map((cs) => cs as CardSet).toList();

    return cardSetList;
  }

  @override
  Map<String, dynamic>? toJson(List<CardSet> state) {
    // TODO: implement toJson
    // throw UnimplementedError();
    return {
      'cardSets': state,
    };
  }
}
