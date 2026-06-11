import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux_store.dart';

class ReduxScreen extends StatelessWidget {
  const ReduxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        title: const Text(
          "REDUX MANAGEMENT",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 3, fontSize: 14, color: Color(0xFFD4AF37)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: StoreConnector<ReduxState, _ViewModel>(
          converter: (Store<ReduxState> store) => _ViewModel.fromStore(store),
          builder: (context, vm) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Managed via Redux (Global State):',
                  style: TextStyle(fontSize: 16, color: Colors.greenAccent, letterSpacing: 1),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141115),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        vm.isTracking ? 'TRACKING: ACTIVE' : 'TRACKING: INACTIVE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: vm.isTracking ? Colors.cyanAccent : Colors.white30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Redux Events: ${vm.counter}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFFD4AF37)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C1619)),
                    onPressed: vm.onToggle,
                    child: const Text("TOGGLE GLOBAL TRACKING", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                    onPressed: vm.onIncrement,
                    child: const Text("INCREMENT REDUX COUNTER", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ViewModel to map store to UI
class _ViewModel {
  final int counter;
  final bool isTracking;
  final VoidCallback onIncrement;
  final VoidCallback onToggle;

  _ViewModel({
    required this.counter,
    required this.isTracking,
    required this.onIncrement,
    required this.onToggle,
  });

  static _ViewModel fromStore(Store<ReduxState> store) {
    return _ViewModel(
      counter: store.state.counter,
      isTracking: store.state.isTracking,
      onIncrement: () => store.dispatch(IncrementCounterAction()),
      onToggle: () => store.dispatch(ToggleTrackingReduxAction()),
    );
  }
}
