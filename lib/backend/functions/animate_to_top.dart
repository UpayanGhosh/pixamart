import 'package:flutter/material.dart';

void animateToTop(ScrollController scrollController, double height) {
  scrollController.animateTo(height,
      duration: const Duration(
          milliseconds: 400),
      curve: Curves
          .easeOutSine); // easeinexpo, easeoutsine
} // function to scroll to top of page