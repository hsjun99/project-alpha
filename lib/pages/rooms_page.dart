import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/cubits/profiles/profiles_cubit.dart';

import 'package:project_alpha/cubits/rooms/rooms_cubit.dart';
import 'package:project_alpha/models/chat_model.dart';
import 'package:project_alpha/models/profile.dart';
import 'package:project_alpha/pages/chat_page.dart';
import 'package:project_alpha/pages/register_page.dart';
import 'package:project_alpha/utils/constants.dart';
import 'package:timeago/timeago.dart';

/// Displays the list of chat threads
class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) => RoomCubit()..initializeRooms(context),
        child: const RoomsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ProfilesCubit>(context).setMyProfile();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                RegisterPage.route(),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return preloader;
          } else if (state is RoomsLoaded) {
            // final newUsers = state.new;
            final newModels = state.newModels;
            final rooms = state.rooms;
            log(newModels[0].name);
            return BlocBuilder<ChatModelsCubit, ChatModelsState>(
              builder: (context, state) {
                if (state is ChatModelsLoaded) {
                  log("chatmodelsloaded");
                  final models = state.models;
                  // final profiles = state.profiles;
                  return Column(
                    children: [
                      _NewModels(newModels: newModels),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final model = models[room.modelId];
                            // final otherUser = profiles[room.otherUserId];

                            return ListTile(
                              onTap: () => Navigator.of(context).push(ChatPage.route(room.id)),
                              leading: CircleAvatar(
                                child: model == null ? preloader : Text(model.name.substring(0, 2)),
                              ),
                              title: Text(model == null ? 'Loading...' : model.name),
                              subtitle: room.lastMessage != null
                                  ? Text(
                                      room.lastMessage!.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const Text('Room created'),
                              trailing: Text(format(room.lastMessage?.createdAt ?? room.createdAt,
                                  locale: 'en_short')),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return preloader;
                }
              },
            );
          } else if (state is RoomsEmpty) {
            // final newUsers = state.newUsers;
            final newModels = state.newModels;
            return Column(
              children: [
                _NewModels(newModels: newModels),
                const Expanded(
                  child: Center(
                    child: Text('Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          } else if (state is RoomsError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class _NewModels extends StatelessWidget {
  const _NewModels({
    Key? key,
    required this.newModels,
  }) : super(key: key);

  final List<ChatModel> newModels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: newModels
            .map<Widget>((model) => InkWell(
                  onTap: () async {
                    try {
                      final roomId = await BlocProvider.of<RoomCubit>(context).createRoom(
                          model.id, BlocProvider.of<ProfilesCubit>(context).myProfile?.id ?? '');
                      Navigator.of(context).push(ChatPage.route(roomId));
                    } catch (_) {
                      context.showErrorSnackBar(message: 'Failed creating a new room');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          CircleAvatar(
                            child: Text(model.name.substring(0, 2)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            model.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
