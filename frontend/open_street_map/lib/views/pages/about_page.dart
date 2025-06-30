import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_street_map/views/pages/how_to_use_page.dart';
import 'package:open_street_map/data/notifiers.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('about.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            selectedPageNotifier.value = 0;
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'about.header'.tr(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'about.description'.tr(),
              style: TextStyle(fontSize: 16, height: 1.5, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 24),
            Text(
              'about.features_title'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'about.feature${i + 1}'.tr(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'about.extra_info'.tr(),
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: theme.hintColor),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.help_outline),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HowToUsePage()),
                  );
                },
                label: Text(
                  'about.how_to_use_button'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
