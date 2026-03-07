import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('ar'),
  ];

  static const _localizedValues = {
    'en': {
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'create_account': 'Create account',
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'logout': 'Logout',
      'predict': 'Predict',
      'pick_gallery': 'Pick from gallery',
      'take_picture': 'Take a picture',
      'confidence': 'Confidence',
      'result': 'Result',
      'predicted': 'Predicted',
      'unknown': 'Unknown',
      'ai_consultant': 'AI Medical Consultant',
      'language': 'Language',
      'brain_mri_classifier': 'Brain MRI Classifier',
      'analyzing': 'Analyzing...',
      'error': 'Error',
      'pick_failed': 'Failed to pick image',
      'select_mri_first': 'Please select an MRI image first',
      'logout_confirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'tip_clear_mri': 'Tip: Use a clear MRI image for best results',

      // MRI Labels
      'brain_menin': 'Meningioma',
      'brain_glioma': 'Glioma',
      'brain_tumor': 'Tumor',
      'normal': 'Normal',

      // Chat screen keys
      'mri_result': 'MRI Result',
      'ask_meaning': 'What does this result mean? Ask me anything about it.',
      'upload_mri_first': 'Please upload an MRI image first to start the consultation.',
      'ai_medical_consultant': 'AI Medical Consultant',
      'ask_mri_hint': 'Ask about your MRI results...',
      'send': 'Send',
    },

    'ru': {
      'sign_in': 'Войти',
      'sign_up': 'Регистрация',
      'email': 'Эл. почта',
      'password': 'Пароль',
      'full_name': 'Полное имя',
      'create_account': 'Создать аккаунт',
      'home': 'Главная',
      'history': 'История',
      'profile': 'Профиль',
      'logout': 'Выйти',
      'predict': 'Предсказать',
      'pick_gallery': 'Выбрать из галереи',
      'take_picture': 'Сделать фото',
      'confidence': 'Точность',
      'result': 'Результат',
      'predicted': 'Предсказано',
      'unknown': 'Неизвестно',
      'ai_consultant': 'ИИ Медицинский консультант',
      'language': 'Язык',
      'brain_mri_classifier': 'Классификатор МРТ мозга',
      'analyzing': 'Анализ...',
      'error': 'Ошибка',
      'pick_failed': 'Не удалось выбрать изображение',
      'select_mri_first': 'Сначала выберите изображение МРТ',
      'logout_confirmation': 'Вы уверены, что хотите выйти?',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'tip_clear_mri': 'Совет: используйте четкое изображение МРТ для лучших результатов',

      // MRI Labels
      'brain_menin': 'Менингиома',
      'brain_glioma': 'Глиома',
      'brain_tumor': 'Опухоль',
      'normal': 'Норма',

      // Chat screen keys
      'mri_result': 'Результат МРТ',
      'ask_meaning': 'Что означает этот результат? Спросите меня о нем.',
      'upload_mri_first': 'Сначала загрузите изображение МРТ, чтобы начать консультацию.',
      'ai_medical_consultant': 'ИИ Медицинский консультант',
      'ask_mri_hint': 'Спросите о результатах МРТ...',
      'send': 'Отправить',
    },

    'ar': {
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'create_account': 'إنشاء حساب',
      'home': 'الرئيسية',
      'history': 'السجل',
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'predict': 'تحليل',
      'pick_gallery': 'اختيار من المعرض',
      'take_picture': 'التقاط صورة',
      'confidence': 'الدقة',
      'result': 'النتيجة',
      'predicted': 'التشخيص',
      'unknown': 'غير معروف',
      'ai_consultant': 'المستشار الطبي الذكي',
      'language': 'اللغة',
      'brain_mri_classifier': 'تصنيف الرنين المغناطيسي للدماغ',
      'analyzing': 'جاري التحليل...',
      'error': 'خطأ',
      'pick_failed': 'فشل اختيار الصورة',
      'select_mri_first': 'الرجاء اختيار صورة الرنين المغناطيسي أولاً',
      'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'tip_clear_mri': 'نصيحة: استخدم صورة رنين مغناطيسي واضحة للحصول على أفضل النتائج',

      // MRI Labels
      'brain_menin': 'ورم سحائي',
      'brain_glioma': 'ورم دبقي',
      'brain_tumor': 'ورم',
      'normal': 'طبيعي',

      // Chat screen keys
      'mri_result': 'نتيجة الرنين المغناطيسي',
      'ask_meaning': 'ماذا تعني هذه النتيجة؟ اسألني أي شيء عنها.',
      'upload_mri_first': 'يرجى تحميل صورة الرنين المغناطيسي أولاً لبدء الاستشارة.',
      'ai_medical_consultant': 'المستشار الطبي الذكي',
      'ask_mri_hint': 'اسأل عن نتائج الرنين المغناطيسي...',
      'send': 'إرسال',
    },
  };

  String text(String key) {
    final languageMap = _localizedValues[locale.languageCode];

    if (languageMap == null) {
      return _localizedValues['en']?[key] ?? key;
    }

    final value = languageMap[key];

    if (value == null) {
      return _localizedValues['en']?[key] ?? key;
    }

    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_) => false;
}