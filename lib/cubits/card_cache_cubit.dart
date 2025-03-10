import 'package:apps_against_fellowship/models/models.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class CardCacheCubit extends HydratedCubit<List<CardSet>> {
  CardCacheCubit() : super(const []);

  void setCardSets(List<CardSet> cardSets) {
    emit(
      state,
    );
  }

  @override
  List<CardSet>? fromJson(Map<String, dynamic> json) {
    List<CardSet> cardSetList =
        (json['cardSets'] as List).map((cs) => cs as CardSet).toList();

    return cardSetList;
  }

  @override
  Map<String, dynamic>? toJson(List<CardSet> state) {
    return {
      'cardSets': state,
    };
  }
}
