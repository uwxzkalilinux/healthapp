import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;
  final List<String> favorites;
  final List<String> searchHistory;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.favorites = const [],
    this.searchHistory = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId, {bool isAdmin = false}) {
    return AppUser(
      uid: documentId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      isAdmin: isAdmin,
      favorites: List<String>.from(map['favorites'] ?? []),
      searchHistory: List<String>.from(map['searchHistory'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'favorites': favorites,
      'searchHistory': searchHistory,
    };
  }

  @override
  List<Object?> get props => [uid, name, email, isAdmin, favorites, searchHistory];
}
