import 'dart:async';

import 'package:apps_against_fellowship/widgets/widgets.dart';
import 'package:flutter/material.dart';

class JudgementController {
  static const double viewportFraction = 0.945;

  final PageController pageController = PageController(
    viewportFraction: viewportFraction,
  );
  final StreamController<int> _pageChanges = StreamController.broadcast();

  late PlayerResponse _currentPlayerResponse;

  PlayerResponse get currentPlayerResponse => _currentPlayerResponse;

  int _index = 0;
  int totalPageCount = 0;

  JudgementController() {
    _pageChanges.onListen = () => _pageChanges.add(_index);
  }

  void dispose() {
    pageController.dispose();
    _pageChanges.close();
  }

  void setCurrentResponse(PlayerResponse playerResponse, int index, int count) {
    _currentPlayerResponse = playerResponse;
    _index = index;
    totalPageCount = count;
    _pageChanges.add(_index);
  }

  void nextPage() {
    if (_index < totalPageCount - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void prevPage() {
    if (_index > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Stream<int> observePageChanges() => _pageChanges.stream;
}
