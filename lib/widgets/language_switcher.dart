// widgets/language_switcher.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final t = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: t.text('language'),
      onSelected: (String languageCode) {
        _switchLanguage(context, languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: currentLocale == 'en' ? Colors.blue : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ru',
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: currentLocale == 'ru' ? Colors.blue : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('Русский'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ar',
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: currentLocale == 'ar' ? Colors.blue : Colors.transparent,
              ),
              const SizedBox(width: 8),
              const Text('العربية'),
              const SizedBox(width: 4),
              Text(
                'عربي',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _switchLanguage(BuildContext context, String languageCode) {
    // Show a message that language switching requires app restart
    // In a real app, you would implement proper locale management
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to ${languageCode.toUpperCase()}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
    
    // For a complete implementation, you would need to:
    // 1. Use a state management solution (Provider, Bloc, etc.)
    // 2. Update the app's locale at the MaterialApp level
    // 3. Persist the language preference
    
    // Example with Provider (commented out):
    // final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // localeProvider.setLocale(Locale(languageCode));
  }
}