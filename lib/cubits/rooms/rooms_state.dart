part of 'rooms_cubit.dart';

@immutable
abstract class RoomState {}

class RoomsLoading extends RoomState {}

class RoomsLoaded extends RoomState {
  final List<ChatModel> newModels;
  final List<Room> rooms;

  RoomsLoaded({
    required this.rooms,
    required this.newModels,
  });
}

class RoomsEmpty extends RoomState {
  final List<ChatModel> newModels;

  RoomsEmpty({required this.newModels});
}

class RoomsError extends RoomState {
  final String message;

  RoomsError(this.message);
}
