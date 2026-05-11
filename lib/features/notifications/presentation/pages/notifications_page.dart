import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile_social_network/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  bool _unreadOnly = false;
  String? _error;
  List<AppNotification> _items = const [];
  List<NotificationPreferenceItem> _preferences = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<NotificationsRepository>();
      final results = await Future.wait<Object>([
        repo.list(unreadOnly: _unreadOnly),
        repo.getPreferences(),
      ]);
      if (!mounted) return;
      setState(() {
        _items =
            (results[0] as ({List<AppNotification> items, int total})).items;
        _preferences = results[1] as List<NotificationPreferenceItem>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markRead(String id) async {
    await context.read<NotificationsRepository>().markRead(id);
    await _load();
  }

  Future<void> _markAllRead() async {
    await context.read<NotificationsRepository>().markAllRead();
    await _load();
  }

  Future<void> _updatePreference(NotificationPreferenceItem item) async {
    final next = [
      for (final current in _preferences)
        current.typeCode == item.typeCode ? item : current,
    ];
    final updated = await context
        .read<NotificationsRepository>()
        .updatePreferences(next);
    if (!mounted) return;
    setState(() => _preferences = updated);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(onPressed: _markAllRead, child: const Text('Read all')),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Inbox'),
              Tab(text: 'Preferences'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: TextButton(onPressed: _load, child: Text(_error!)),
              )
            : TabBarView(
                children: [
                  Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Unread only'),
                        value: _unreadOnly,
                        onChanged: (v) {
                          setState(() => _unreadOnly = v);
                          _load();
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return ListTile(
                                leading: Icon(
                                  item.isUnread
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 14,
                                ),
                                title: Text(item.title),
                                subtitle: Text(item.body ?? item.typeCode),
                                trailing: item.isUnread
                                    ? TextButton(
                                        onPressed: () =>
                                            _markRead(item.notificationId),
                                        child: const Text('Read'),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    itemCount: _preferences.length,
                    itemBuilder: (context, index) {
                      final item = _preferences[index];
                      return ExpansionTile(
                        title: Text(item.typeCode),
                        children: [
                          SwitchListTile(
                            title: const Text('Push'),
                            value: item.pushEnabled,
                            onChanged: (v) => _updatePreference(
                              item.copyWith(pushEnabled: v),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('In app'),
                            value: item.inAppEnabled,
                            onChanged: (v) => _updatePreference(
                              item.copyWith(inAppEnabled: v),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
