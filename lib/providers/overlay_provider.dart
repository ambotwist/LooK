import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayNotifier extends StateNotifier<OverlayPortalController> {
  OverlayNotifier() : super(OverlayPortalController());

  void show() {
    state.show();
  }

  void hide() {
    state.hide();
  }
}

final overlayProvider =
    StateNotifierProvider<OverlayNotifier, OverlayPortalController>((ref) {
  return OverlayNotifier();
});
