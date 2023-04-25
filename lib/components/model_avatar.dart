import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/cubits/profiles/profiles_cubit.dart';
import 'package:project_alpha/utils/constants.dart';

/// Widget that will display a user's avatar
class ModelAvatar extends StatelessWidget {
  const ModelAvatar({
    Key? key,
    required this.modelId,
  }) : super(key: key);

  // final String userId;
  final String modelId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatModelsCubit, ChatModelsState>(
      builder: (context, state) {
        if (state is ChatModelsLoaded) {
          final model = state.models[modelId];
          return CircleAvatar(
            child: model == null ? preloader : Text(model.name.substring(0, 2)),
          );
        } else {
          return const CircleAvatar(child: preloader);
        }
      },
    );
  }
}
