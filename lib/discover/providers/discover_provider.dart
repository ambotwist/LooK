import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoverNotifier extends StateNotifier<DiscoverState> {
  DiscoverNotifier() : super(DiscoverState());

  void nextCard() {
    state = state.copyWith(
      previousIndices: [...state.previousIndices, state.currentIndex],
      currentIndex: state.currentIndex + 1,
      currentImageIndex: 0,
    );
  }

  void rewindCard() {
    if (state.previousIndices.isEmpty) return;

    state = state.copyWith(
      currentIndex: state.previousIndices.last,
      previousIndices:
          state.previousIndices.sublist(0, state.previousIndices.length - 1),
      currentImageIndex: 0,
    );
  }

  void updateImageIndex(int index) {
    state = state.copyWith(currentImageIndex: index);
  }

  void updateState({
    int? currentIndex,
    int? currentImageIndex,
    List<int>? previousIndices,
  }) {
    state = state.copyWith(
      currentIndex: currentIndex,
      currentImageIndex: currentImageIndex,
      previousIndices: previousIndices,
    );
  }

  void resetState() {
    state = DiscoverState();
  }
}

class DiscoverState {
  final int currentIndex;
  final int currentImageIndex;
  final List<int> previousIndices;

  DiscoverState({
    this.currentIndex = 0,
    this.currentImageIndex = 0,
    this.previousIndices = const [],
  });

  DiscoverState copyWith({
    int? currentIndex,
    int? currentImageIndex,
    List<int>? previousIndices,
  }) {
    return DiscoverState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      previousIndices: previousIndices ?? this.previousIndices,
    );
  }
}

final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  return DiscoverNotifier();
});
