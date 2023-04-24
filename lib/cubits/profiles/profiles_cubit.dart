import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_alpha/models/profile.dart';
import 'package:project_alpha/utils/constants.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  ProfilesCubit() : super(ProfilesInitial());

  late final Profile? myProfile;

  /// Map of app users cache in memory with profile_id as the key
  final Map<String, Profile?> _profiles = {};

  Future<void> setMyProfile() async {
    final data = await supabase
        .from('profiles')
        .select()
        .match({'id': supabase.auth.currentUser!.id}).single();
    if (data == null) {
      return;
    }
    myProfile = Profile.fromMap(data);
  }

  Future<void> getProfile(String userId) async {
    if (_profiles[userId] != null) {
      return;
    }

    final data = await supabase.from('profiles').select().match({'id': userId}).single();

    if (data == null) {
      return;
    }
    _profiles[userId] = Profile.fromMap(data);

    emit(ProfilesLoaded(profiles: _profiles));
  }
}
