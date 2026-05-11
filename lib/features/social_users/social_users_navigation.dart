import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friends_list_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_search_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/friends_tab_page.dart';

void pushFriendRequestsPage(BuildContext context) {
  final repo = context.read<SocialUsersRepository>();
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<FriendRequestsCubit>(
            create: (_) => FriendRequestsCubit(repo),
          ),
          BlocProvider<FriendsListCubit>(create: (_) => FriendsListCubit(repo)),
          BlocProvider<UserSearchCubit>(create: (_) => UserSearchCubit(repo)),
        ],
        child: const FriendsTabPage(),
      ),
    ),
  );
}
