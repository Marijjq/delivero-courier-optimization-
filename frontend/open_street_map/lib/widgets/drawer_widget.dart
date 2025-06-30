import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/notifiers.dart';
import '../views/pages/login.dart';
import '../services/auth_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  void _selectPage(BuildContext context, int index) {
    selectedPageNotifier.value = index;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
            ),
          ),

          _buildDrawerItem(
            context,
            Icons.home,
            'drawer.home'.tr(),
            0,
            theme.colorScheme.primary,
          ),
          _buildDrawerItem(
            context,
            Icons.person,
            'drawer.profile'.tr(),
            1,
            theme.colorScheme.secondary,
          ),
          _buildDrawerItem(
            context,
            Icons.location_on,
            'drawer.saved'.tr(),
            2,
            Colors.green,
          ),
          _buildDrawerItem(
            context,
            Icons.history,
            'drawer.history'.tr(),
            3,
            Colors.orangeAccent,
          ),
          _buildDrawerItem(
            context,
            Icons.settings,
            'drawer.settings'.tr(),
            4,
            Colors.grey,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            Icons.info_outline,
            'drawer.about'.tr(),
            5,
            Colors.teal,
          ),
          _buildDrawerItem(
            context,
            Icons.map_outlined,
            'drawer.assigned_routes'.tr(),
            6,
            Colors.purple,
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('drawer.logout'.tr()),
            onTap: () async {
              await AuthService.logout(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('profile.logged_out'.tr())),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () => _selectPage(context, index),
    );
  }
}
