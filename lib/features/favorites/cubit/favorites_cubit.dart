import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesCubit extends Cubit<List<String>> {
  StreamSubscription? _subscription;

  FavoritesCubit() : super([]);

  void init(String userId) {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final favorites = List<String>.from(snapshot.data()?['favorites'] ?? []);
        emit(favorites);
      }
    });
  }

  bool isFavorite(String itemId) {
    return state.contains(itemId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
