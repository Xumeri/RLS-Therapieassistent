import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/data/profile_repository.dart';
import 'package:flutterapp/domain/profile.dart';

/// Provider, der das [Profile] des Benutzers asynchron bereitstellt.
///
/// Nutzt den [profileRepositoryProvider], um die Daten abzurufen.
final profileProvider = FutureProvider<Profile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchProfile();
});
