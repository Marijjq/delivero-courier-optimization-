import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('how.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // ✅ Fix applied here
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'how.header'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              7,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'how.step${i + 1}'.tr(),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'how.tips_title'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'how.tips'.tr(),
              style: TextStyle(fontSize: 14, height: 1.5, color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }
}
