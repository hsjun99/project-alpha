import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/cubits/profiles/profiles_cubit.dart';
import 'package:project_alpha/models/chat_model.dart';
import 'package:project_alpha/models/profile.dart';
import 'package:project_alpha/models/message.dart';
import 'package:project_alpha/models/room.dart';
import 'package:project_alpha/utils/constants.dart';

part 'rooms_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomsLoading());

  final Map<String, StreamSubscription<Message?>> _messageSubscriptions = {};

  late final String _myUserId;

  /// List of new users of the app for the user to start talking to
  late final List<Profile> _newUsers;
  // late final List<ChatModel> _newModels;

  /// List of rooms
  List<Room> _rooms = [];
  StreamSubscription<List<Map<String, dynamic>>>? _rawRoomsSubscription;
  bool _haveCalledGetRooms = false;

  Future<void> initializeRooms(BuildContext context) async {
    log("INITIALIZE_ROOM!");
    if (_haveCalledGetRooms) {
      return;
    }
    _haveCalledGetRooms = true;

    _myUserId = supabase.auth.currentUser!.id;

    late final List data;

    try {
      data = await supabase.from('chat_models').select().order('created_at').limit(12);
      // log(data.toString());
    } catch (_) {
      emit(RoomsError('Error loading new users'));
    }

    final List<Room> _rooms =
        (await supabase.from('rooms').select().match({'profile_id': _myUserId}))
            .map<Room>((e) => Room.fromModel(e))
            .toList();

    emit(RoomsLoaded(rooms: _rooms));

    // _rawRoomsSubscription = supabase.from('rooms').stream(
    //   primaryKey: ['room_id', 'profile_id'],
    // ).listen((participantMaps) async {
    //   if (participantMaps.isEmpty) {
    //     emit(RoomsEmpty(newModels: _newUsers));
    //     return;
    //   }

    //   _rooms = participantMaps
    //       .map(Room.fromRoomParticipants)
    //       .where((room) => room.otherUserId != _myUserId)
    //       .toList();
    //   for (final room in _rooms) {
    //     _getNewestMessage(context: context, roomId: room.id);
    //     BlocProvider.of<ProfilesCubit>(context).getProfile(room.otherUserId);
    //   }
    //   emit(RoomsLoaded(
    //     newUsers: _newUsers,
    //     rooms: _rooms,
    //   ));
    // }, onError: (error) {
    //   emit(RoomsError('Error loading rooms'));
    // });

    /// Get realtime updates on rooms that the user is in
    // _rawRoomsSubscription = supabase.from('room_participants').stream(
    //   primaryKey: ['room_id', 'profile_id'],
    // ).listen((participantMaps) async {
    // if (participantMaps.isEmpty) {
    //   emit(RoomsEmpty(newModels: _newUsers));
    //   return;
    // }

    //   _rooms = participantMaps
    //       .map(Room.fromRoomParticipants)
    //       .where((room) => room.otherUserId != _myUserId)
    //       .toList();
    //   for (final room in _rooms) {
    //     _getNewestMessage(context: context, roomId: room.id);
    //     BlocProvider.of<ProfilesCubit>(context).getProfile(room.otherUserId);
    //   }
    //   emit(RoomsLoaded(
    //     newUsers: _newUsers,
    //     rooms: _rooms,
    //   ));
    // }, onError: (error) {
    //   emit(RoomsError('Error loading rooms'));
    // });
  }

  // Setup listeners to listen to the most recent message in each room
  void _getNewestMessage({
    required BuildContext context,
    required String roomId,
  }) {
    _messageSubscriptions[roomId] = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .limit(1)
        .map<Message?>(
          (data) => data.isEmpty
              ? null
              : Message.fromMap(
                  map: data.first,
                  myUserId: _myUserId,
                ),
        )
        .listen((message) {
          final index = _rooms.indexWhere((room) => room.id == roomId);
          _rooms[index] = _rooms[index].copyWith(lastMessage: message);
          _rooms.sort((a, b) {
            /// Sort according to the last message
            /// Use the room createdAt when last message is not available
            final aTimeStamp = a.lastMessage != null ? a.lastMessage!.createdAt : a.createdAt;
            final bTimeStamp = b.lastMessage != null ? b.lastMessage!.createdAt : b.createdAt;
            return bTimeStamp.compareTo(aTimeStamp);
          });
          if (!isClosed) {
            emit(RoomsLoaded(
              rooms: _rooms,
            ));
          }
        });
  }

  /// Creates or returns an existing roomID of both participants
  Future<String> createRoom(String chatModelId, String profileId) async {
    try {
      log("create room");
      final rooms = await supabase
          .from('rooms')
          .select()
          .match({'profile_id': profileId, 'chat_model_id': chatModelId});

      if (rooms.length == 0) {
        final data = await supabase
            .from('rooms')
            .insert({'profile_id': profileId, 'chat_model_id': chatModelId});
        emit(RoomsLoaded(rooms: _rooms));
        return data as String;
      }

      emit(RoomsLoaded(rooms: _rooms));

      return rooms[0]['id'] as String;
    } catch (e) {
      log(e.toString());
    }
    return '';
  }

  @override
  Future<void> close() {
    _rawRoomsSubscription?.cancel();
    return super.close();
  }
}
