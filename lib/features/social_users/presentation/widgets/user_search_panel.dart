import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/social_users/presentation/cubit/user_search_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_search_state.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Панель поиска пользователей (без [Scaffold]) — для встраивания во вкладку «Друзья».
class UserSearchPanel extends StatefulWidget {
  const UserSearchPanel({super.key});

  @override
  State<UserSearchPanel> createState() => _UserSearchPanelState();
}

class _UserSearchPanelState extends State<UserSearchPanel> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchBar(
            controller: _controller,
            hintText: l10n.userSearchHint,
            onChanged: (v) => context.read<UserSearchCubit>().onQueryChanged(v),
            leading: const Icon(Icons.search),
            trailing: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context.read<UserSearchCubit>().onQueryChanged('');
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocConsumer<UserSearchCubit, UserSearchState>(
              listener: (context, state) {
                final err = state.errorMessage;
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  context.read<UserSearchCubit>().clearError();
                }
              },
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.results.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.userSearchHint,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: state.results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = state.results[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          u.username.isNotEmpty
                              ? u.username[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(u.username),
                      subtitle: u.bio != null && u.bio!.isNotEmpty
                          ? Text(
                              u.bio!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () => pushUserProfilePage(context, u.userId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
