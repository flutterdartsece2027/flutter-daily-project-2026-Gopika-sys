import 'package:redux/redux.dart';

// 1. The State
class ReduxState {
  final int counter;
  final bool isTracking;

  ReduxState({this.counter = 0, this.isTracking = false});

  // Helper method to copy state with changes (Immutability)
  ReduxState copyWith({int? counter, bool? isTracking}) {
    return ReduxState(
      counter: counter ?? this.counter,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

// 2. The Actions
class IncrementCounterAction {}
class ToggleTrackingReduxAction {}

// 3. The Reducer (Pure Function)
ReduxState appReducer(ReduxState state, dynamic action) {
  if (action is IncrementCounterAction) {
    return state.copyWith(counter: state.counter + 1);
  } else if (action is ToggleTrackingReduxAction) {
    return state.copyWith(isTracking: !state.isTracking);
  }
  return state;
}

// 4. Store Factory
Store<ReduxState> createReduxStore() {
  return Store<ReduxState>(
    appReducer,
    initialState: ReduxState(),
  );
}
