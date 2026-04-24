import 'package:flutter/material.dart';

import 'package:mobile_social_network/features/social_users/presentation/widgets/user_search_panel.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Полноэкранный поиск (например, при открытии отдельным маршрутом).
class UserSearchPage extends StatelessWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userSearchTitle)),
      body: const UserSearchPanel(),
    );
  }
}
