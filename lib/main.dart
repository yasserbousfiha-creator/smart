import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> globalThemeNotifier = ValueNotifier(
  ThemeMode.dark,
);
final ValueNotifier<String> globalLangNotifier = ValueNotifier('ar');
final ValueNotifier<String> globalCurrencyNotifier = ValueNotifier('🇸🇦 SAR');
String globalUserName = '';

// ==========================================
// خدمة الحفظ المحلي - StorageService
// ==========================================
class StorageService {
  static SharedPreferences? _prefs;

  // تهيئة الخدمة (يُستدعى مرة واحدة عند بدء التطبيق)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── حفظ وتحميل اسم المستخدم ───
  static Future<void> saveUserName(String name) async {
    await _prefs?.setString('userName', name);
  }

  static String loadUserName() {
    return _prefs?.getString('userName') ?? '';
  }

  // ─── حفظ وتحميل اللغة ───
  static Future<void> saveLang(String lang) async {
    await _prefs?.setString('lang', lang);
  }

  static String loadLang() {
    return _prefs?.getString('lang') ?? 'ar';
  }

  // ─── حفظ وتحميل العملة ───
  static Future<void> saveCurrency(String currency) async {
    await _prefs?.setString('currency', currency);
  }

  static String loadCurrency() {
    return _prefs?.getString('currency') ?? '🇸🇦 SAR';
  }

  // ─── حفظ وتحميل الثيم ───
  static Future<void> saveTheme(String theme) async {
    await _prefs?.setString('theme', theme);
  }

  static String loadTheme() {
    return _prefs?.getString('theme') ?? 'dark';
  }

  // ─── حفظ وتحميل المهام المنجزة ───
  static Future<void> saveCompletedTasks(
    List<Map<String, dynamic>> tasks,
  ) async {
    final list = tasks.map((task) {
      final copy = Map<String, dynamic>.from(task);
      if (copy['deadline'] is DateTime) {
        copy['deadline'] = (copy['deadline'] as DateTime).toIso8601String();
      }
      if (copy['completedAt'] is DateTime) {
        copy['completedAt'] = (copy['completedAt'] as DateTime)
            .toIso8601String();
      }
      if (copy['calendarDate'] is DateTime) {
        copy['calendarDate'] = (copy['calendarDate'] as DateTime)
            .toIso8601String();
      }
      if (copy['calendarTime'] is TimeOfDay) {
        final t = copy['calendarTime'] as TimeOfDay;
        copy['calendarTime'] = '${t.hour}:${t.minute}';
      }
      return copy;
    }).toList();
    await _prefs?.setString('completedTasks', jsonEncode(list));
  }

  static List<Map<String, dynamic>> loadCompletedTasks() {
    final data = _prefs?.getString('completedTasks');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['deadline'] is String) {
        map['deadline'] = DateTime.parse(map['deadline']);
      }
      if (map['completedAt'] is String) {
        try {
          map['completedAt'] = DateTime.parse(map['completedAt']);
        } catch (_) {}
      }
      if (map['calendarDate'] is String) {
        try {
          map['calendarDate'] = DateTime.parse(map['calendarDate']);
        } catch (_) {
          map['calendarDate'] = null;
        }
      }
      if (map['calendarTime'] is String) {
        final parts = (map['calendarTime'] as String).split(':');
        if (parts.length == 2) {
          map['calendarTime'] = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      return map;
    }).toList();
  }

  // ─── حفظ وتحميل المهام العملية ───
  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final list = tasks.map((task) {
      final copy = Map<String, dynamic>.from(task);
      // تحويل DateTime إلى String للتخزين
      if (copy['deadline'] is DateTime) {
        copy['deadline'] = (copy['deadline'] as DateTime).toIso8601String();
      }
      // --- جديد: حفظ calendarDate و calendarTime ---
      if (copy['calendarDate'] is DateTime) {
        copy['calendarDate'] = (copy['calendarDate'] as DateTime)
            .toIso8601String();
      }
      if (copy['calendarTime'] is TimeOfDay) {
        final t = copy['calendarTime'] as TimeOfDay;
        copy['calendarTime'] = '${t.hour}:${t.minute}';
      }
      return copy;
    }).toList();
    await _prefs?.setString('tasks', jsonEncode(list));
  }

  static List<Map<String, dynamic>> loadTasks() {
    final data = _prefs?.getString('tasks');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item);
      // استعادة DateTime من String
      if (map['deadline'] is String) {
        map['deadline'] = DateTime.parse(map['deadline']);
      }
      // --- جديد: استعادة calendarDate و calendarTime ---
      if (map['calendarDate'] is String) {
        try {
          map['calendarDate'] = DateTime.parse(map['calendarDate']);
        } catch (_) {
          map['calendarDate'] = null;
        }
      }
      if (map['calendarTime'] is String) {
        final parts = (map['calendarTime'] as String).split(':');
        if (parts.length == 2) {
          map['calendarTime'] = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      return map;
    }).toList();
  }

  // ─── حفظ وتحميل المصروفات ───
  static Future<void> saveExpenses(List<Map<String, dynamic>> expenses) async {
    await _prefs?.setString('expenses', jsonEncode(expenses));
  }

  static List<Map<String, dynamic>> loadExpenses() {
    final data = _prefs?.getString('expenses');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // ─── حفظ وتحميل المديونيات ───
  static Future<void> saveDebts(List<Map<String, dynamic>> debts) async {
    await _prefs?.setString('debts', jsonEncode(debts));
  }

  static List<Map<String, dynamic>> loadDebts() {
    final data = _prefs?.getString('debts');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // ─── حفظ وتحميل الملاحظات ───
  static Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    await _prefs?.setString('notes', jsonEncode(notes));
  }

  static List<Map<String, dynamic>> loadNotes() {
    final data = _prefs?.getString('notes');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // ─── حفظ وتحميل سلة المهملات ───
  static Future<void> saveTrash(List<Map<String, dynamic>> trash) async {
    final list = trash.map((item) {
      final copy = Map<String, dynamic>.from(item);
      // تحويل data داخل السلة إذا كانت تحتوي على DateTime
      if (copy['data'] is Map) {
        final dataCopy = Map<String, dynamic>.from(copy['data']);
        if (dataCopy['deadline'] is DateTime) {
          dataCopy['deadline'] = (dataCopy['deadline'] as DateTime)
              .toIso8601String();
        }
        if (dataCopy['date'] is DateTime) {
          dataCopy['date'] = (dataCopy['date'] as DateTime).toIso8601String();
        }
        if (dataCopy['time'] is TimeOfDay) {
          final t = dataCopy['time'] as TimeOfDay;
          dataCopy['time'] = '${t.hour}:${t.minute}';
        }
        copy['data'] = dataCopy;
      }
      return copy;
    }).toList();
    await _prefs?.setString('trash', jsonEncode(list));
  }

  static List<Map<String, dynamic>> loadTrash() {
    final data = _prefs?.getString('trash');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['data'] is Map) {
        final dataCopy = Map<String, dynamic>.from(map['data']);
        if (dataCopy['deadline'] is String) {
          dataCopy['deadline'] = DateTime.parse(dataCopy['deadline']);
        }
        if (dataCopy['date'] is String) {
          try {
            dataCopy['date'] = DateTime.parse(dataCopy['date']);
          } catch (_) {}
        }
        if (dataCopy['time'] is String) {
          final parts = (dataCopy['time'] as String).split(':');
          if (parts.length == 2) {
            dataCopy['time'] = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 9,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
        map['data'] = dataCopy;
      }
      return map;
    }).toList();
  }

  // ─── حفظ وتحميل مواعيد التقويم ───
  static Future<void> saveCalendarEvents(
    List<Map<String, dynamic>> events,
  ) async {
    final list = events.map((event) {
      final copy = Map<String, dynamic>.from(event);
      if (copy['date'] is DateTime) {
        copy['date'] = (copy['date'] as DateTime).toIso8601String();
      }
      if (copy['time'] is TimeOfDay) {
        final t = copy['time'] as TimeOfDay;
        copy['time'] = '${t.hour}:${t.minute}';
      }
      return copy;
    }).toList();
    await _prefs?.setString('calendarEvents', jsonEncode(list));
  }

  static List<Map<String, dynamic>> loadCalendarEvents() {
    final data = _prefs?.getString('calendarEvents');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['date'] is String) {
        map['date'] = DateTime.parse(map['date']);
      }
      if (map['time'] is String) {
        final parts = (map['time'] as String).split(':');
        if (parts.length == 2) {
          map['time'] = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      return map;
    }).toList();
  }
}

// ==========================================
// نظام الترجمة الشامل
// ==========================================
class T {
  static final Map<String, Map<String, String>> _data = {
    'ar': {
      'appTitle': 'منظم المهام الذكي',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'add': 'إضافة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'confirm': 'تأكيد',
      'open': 'فتح',
      'language': 'اللغة',
      'goHome': 'الرئيسية',
      'welcome': 'مرحباً بك!',
      'enterName': 'ما هو اسمك؟',
      'startUsing': 'بدء الاستخدام',
      'homeWelcome': 'الرئيسية الترحيبية',
      'practicalTasksFull': 'المهام العملية والتوقيت',
      'walletFull': 'المحفظة والمديونيات',
      'notesFull': 'المفكرة والملاحظات',
      'manage': 'إدارة المهام والوقت بكفاءة',
      'home': 'الرئيسية',
      'practicalTasks': 'المهام العملية',
      'wallet': 'المحفظة والمديونيات',
      'notes': 'المفكرة الشخصية',
      'trash': 'سلة المهملات',
      'helloUser': 'أهلاً بك',
      'helloUserName': 'أهلاً بك يا',
      'smartOrganizer': 'منظمك الذكي',
      'todayWisdom': 'حكمة اليوم للإنجاز',
      'practicalTasksCount': 'المهام العملية',
      'financialSummary': 'الملخص المالي',
      'notesCount': 'الملاحظات',
      'addTask': 'إضافة مهمة عملية جديدة',
      'noTasks': 'لا توجد مهام عملية حالياً',
      'addTaskTitle': 'إضافة مهمة عملية',
      'editTaskTitle': 'تعديل مهمة عملية',
      'taskName': 'عنوان المهمة',
      'taskDesc': 'الوصف أو التفاصيل',
      'duration': 'المدة الزمنية للإنجاز:',
      'hour': 'ساعة',
      'day': 'يوم',
      'timeExpired': 'انتهى الوقت!',
      'remaining': 'متبقي:',
      'daysUnit': 'يوم',
      'hoursUnit': 'ساعة',
      'minutesUnit': 'دقيقة',
      'walletLog': 'سجل المحفظة',
      'debtsManage': 'إدارة المديونيات',
      'netBalance': 'صافي الرصيد المتبقي',
      'currency': 'ريال',
      'credit': 'دائن',
      'debit': 'مدين',
      'type': 'النوع:',
      'statement': 'البيان...',
      'amount': 'المبلغ',
      'cat1': 'صافي الراتب',
      'cat2': 'أموال أخرى (دخل)',
      'cat3': 'أقساط ومديونيات',
      'cat4': 'مصروف عادي',
      'debtLabel': 'المديونية:',
      'debtHint': 'اختر ليتم الخصم منها',
      'editEntry': 'تعديل القيد',
      'statementLabel': 'البيان',
      'amountLabel': 'المبلغ',
      'installmentPaid': 'تم تسجيل القسط وخصمه من المديونية',
      'totalRemaining': 'إجمالي الديون المتبقية',
      'totalDebts': 'إجمالي الديون',
      'totalPaid': 'المسدد',
      'addDebt': 'إضافة مديونية جديدة',
      'addDebtTitle': 'إضافة مديونية جديدة',
      'editDebtTitle': 'تعديل مديونية',
      'debtName': 'اسم الجهة أو الدين (مثال: قسط سيارة)',
      'debtTotal': 'إجمالي مبلغ الدين',
      'debtRemain': 'المتبقي:',
      'debtPaid': 'المسدد:',
      'payNow': 'سداد قسط الآن',
      'payInstallment': 'سداد قسط:',
      'payAmountNow': 'المبلغ المسدد الآن',
      'confirmPay': 'تأكيد السداد',
      'debtCleared': 'تم سداد المديونية بالكامل 🎉',
      'paySuccess': 'تم سداد القسط وخصمه من المديونية وإضافته للمحفظة بنجاح.',
      'newNote': 'ملاحظة جديدة',
      'sortByImportance': 'فرز حسب الأهمية',
      'newNoteTitle': 'ملاحظة جديدة',
      'editNoteTitle': 'تعديل الملاحظة',
      'noteTitle': 'العنوان...',
      'noteContent': 'الملاحظة...',
      'setPassword': 'تعيين كلمة المرور',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'passwordMismatch': 'كلمة المرور غير متطابقة!',
      'noteLocked': 'الملاحظة مقفلة',
      'enterPassword': 'أدخل كلمة المرور',
      'wrongPassword': 'كلمة المرور خاطئة!',
      'emptyTrash': 'تفريغ السلة',
      'trashEmpty': 'سلة المهملات فارغة',
      'noTitle': '(بدون عنوان)',
      'itemType': 'النوع:',
      'restore': 'استرجاع فوري',
      'deletePermanent': 'حذف نهائي',
      'restoreSuccess': 'تم استرجاع العنصر إلى قسمه بنجاح ودون تأخير!',
      'typeTask': 'مهمة عملية',
      'typeNote': 'ملاحظة',
      'typeExpense': 'عملية مالية',
      'typeDebt': 'مديونية',
      'q1': 'إن لم تبدأ اليوم، فلن تنتهي غداً. السر يكمن دائماً في البداية.',
      'q2': 'إنجازك اليوم هو الحجر الأساس لبناء نجاحات الغد العظيمة.',
      'q3': 'لا تنتظر الظروف المثالية لتنجز، اصنع ظروفك الخاصة وانطلق.',
      'q4': 'التخطيط الجيد والخطوات الصغيرة المستمرة تصنع فارقاً مهولاً.',
      'q5': 'المفاتيح الأساسية للإنتاجية: التركيز المطلق وتحديد الأولويات.',
      'installmentPrefix': 'قسط:',
      'installmentPayPrefix': 'سداد قسط:',
      'calendar': 'التقويم الذكي',
      'calendarFull': 'التقويم والمواعيد',
      'addEvent': 'إضافة موعد جديد',
      'addEventTitle': 'إضافة موعد',
      'editEventTitle': 'تعديل الموعد',
      'eventName': 'عنوان الموعد',
      'eventDesc': 'الوصف أو الملاحظات',
      'eventDate': 'تاريخ الموعد',
      'eventTime': 'وقت الموعد',
      'eventType': 'نوع الموعد',
      'noEvents': 'لا توجد مواعيد لهذا اليوم',
      'noEventsMonth': 'لا توجد مواعيد لهذا الشهر',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'upcoming': 'القادمة',
      'allEvents': 'جميع المواعيد',
      'evtMeeting': 'اجتماع',
      'evtAppointment': 'موعد طبي',
      'evttask': 'مهمة',
      'evtReminder': 'تذكير',
      'evtPersonal': 'شخصي',
      'evtOther': 'أخرى',
      'selectDate': 'اختر التاريخ',
      'selectTime': 'اختر الوقت',
      'calendarWidget': 'التقويم',
      'eventsToday': 'مواعيد اليوم',
      'nextEvent': 'الموعد القادم',
      'mon': 'اث',
      'tue': 'ثل',
      'wed': 'أر',
      'thu': 'خم',
      'fri': 'جم',
      'sat': 'سب',
      'sun': 'أح',
      'jan': 'يناير',
      'feb': 'فبراير',
      'mar': 'مارس',
      'apr': 'أبريل',
      'may': 'مايو',
      'jun': 'يونيو',
      'jul': 'يوليو',
      'aug': 'أغسطس',
      'sep': 'سبتمبر',
      'oct': 'أكتوبر',
      'nov': 'نوفمبر',
      'dec': 'ديسمبر',
      'typeCalendar': 'موعد تقويم',
      'deleteEventConfirmTitle': 'تأكيد الحذف',
      'deleteEventConfirmMsg':
          'هل تريد حذف هذا الموعد؟ سيُنقل إلى سلة المهملات.',
      'deleteConfirmYes': 'حذف',
      'eventDone': 'تم إنجاز الموعد',
      'markDone': 'تحديد كمنجز',
      'addToCalendar': 'إضافة للتقويم',
      'taskDeadlineDate': 'تاريخ الموعد في التقويم',
      'taskDeadlineTime': 'وقت الموعد في التقويم',
      'taskAddedToCalendar': 'تمت إضافة المهمة للتقويم ✅',
      'completedTasks': 'المهام المنجزة',
      'completedTasksFull': 'قائمة المهام المنجزة',
      'noCompletedTasks': 'لا توجد مهام منجزة بعد',
      'markComplete': 'تحديد كمنجزة',
      'restoreTask': 'إرجاع للمهام النشطة',
      'completedAt': 'أُنجزت في:',
      'taskCompleted': 'تم إنجاز المهمة ✅',
      'completedTasksCount': 'المنجزة',
    },
    'fr': {
      'appTitle': 'Organisateur Intelligent',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'add': 'Ajouter',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'confirm': 'Confirmer',
      'open': 'Ouvrir',
      'language': 'Langue',
      'goHome': 'Accueil',
      'welcome': 'Bienvenue !',
      'enterName': 'Quel est votre nom ?',
      'startUsing': 'Commencer',
      'homeWelcome': 'Accueil principal',
      'practicalTasksFull': 'Tâches & Horaires',
      'walletFull': 'Portefeuille & Dettes',
      'notesFull': 'Notes & Mémos',
      'manage': 'Gérer les tâches efficacement',
      'home': 'Accueil',
      'practicalTasks': 'Tâches pratiques',
      'wallet': 'Portefeuille & Dettes',
      'notes': 'Carnet personnel',
      'trash': 'Corbeille',
      'helloUser': 'Bonjour',
      'helloUserName': 'Bonjour',
      'smartOrganizer': 'Votre organisateur',
      'todayWisdom': 'Sagesse du jour',
      'practicalTasksCount': 'Tâches',
      'financialSummary': 'Résumé financier',
      'notesCount': 'Notes',
      'addTask': 'Ajouter une nouvelle tâche',
      'noTasks': 'Aucune tâche pour le moment',
      'addTaskTitle': 'Ajouter une tâche',
      'editTaskTitle': 'Modifier la tâche',
      'taskName': 'Titre de la tâche',
      'taskDesc': 'Description ou détails',
      'duration': 'Durée de réalisation :',
      'hour': 'heure',
      'day': 'jour',
      'timeExpired': 'Temps écoulé !',
      'remaining': 'Restant :',
      'daysUnit': 'j',
      'hoursUnit': 'h',
      'minutesUnit': 'min',
      'walletLog': 'Registre',
      'debtsManage': 'Gestion des dettes',
      'netBalance': 'Solde net restant',
      'currency': '€',
      'credit': 'Crédit',
      'debit': 'Débit',
      'type': 'Type :',
      'statement': 'Libellé...',
      'amount': 'Montant',
      'cat1': 'Salaire net',
      'cat2': 'Autres revenus',
      'cat3': 'Versements & dettes',
      'cat4': 'Dépense courante',
      'debtLabel': 'Dette :',
      'debtHint': 'Choisir pour déduire',
      'editEntry': 'Modifier l\'entrée',
      'statementLabel': 'Libellé',
      'amountLabel': 'Montant',
      'installmentPaid': 'Versement enregistré et déduit de la dette',
      'totalRemaining': 'Total des dettes restantes',
      'totalDebts': 'Total des dettes',
      'totalPaid': 'Payé',
      'addDebt': 'Ajouter une nouvelle dette',
      'addDebtTitle': 'Ajouter une dette',
      'editDebtTitle': 'Modifier la dette',
      'debtName': 'Nom de la dette (ex: prêt auto)',
      'debtTotal': 'Montant total de la dette',
      'debtRemain': 'Restant :',
      'debtPaid': 'Payé :',
      'payNow': 'Payer un versement',
      'payInstallment': 'Versement :',
      'payAmountNow': 'Montant versé maintenant',
      'confirmPay': 'Confirmer le paiement',
      'debtCleared': 'Dette entièrement remboursée 🎉',
      'paySuccess': 'Versement confirmé et déduit de la dette avec succès.',
      'newNote': 'Nouvelle note',
      'sortByImportance': 'Trier par importance',
      'newNoteTitle': 'Nouvelle note',
      'editNoteTitle': 'Modifier la note',
      'noteTitle': 'Titre...',
      'noteContent': 'Note...',
      'setPassword': 'Définir un mot de passe',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'passwordMismatch': 'Les mots de passe ne correspondent pas !',
      'noteLocked': 'Note verrouillée',
      'enterPassword': 'Entrer le mot de passe',
      'wrongPassword': 'Mot de passe incorrect !',
      'emptyTrash': 'Vider la corbeille',
      'trashEmpty': 'La corbeille est vide',
      'noTitle': '(sans titre)',
      'itemType': 'Type :',
      'restore': 'Restaurer',
      'deletePermanent': 'Supprimer définitivement',
      'restoreSuccess': 'Élément restauré avec succès !',
      'typeTask': 'Tâche pratique',
      'typeNote': 'Note',
      'typeExpense': 'Transaction financière',
      'typeDebt': 'Dette',
      'q1':
          'Si vous ne commencez pas aujourd\'hui, vous ne finirez pas demain.',
      'q2':
          'Votre accomplissement d\'aujourd\'hui est la base du succès de demain.',
      'q3': 'N\'attendez pas les conditions idéales, créez les vôtres.',
      'q4':
          'Une bonne planification et de petites étapes régulières font une grande différence.',
      'q5':
          'Les clés de la productivité : concentration totale et priorisation.',
      'installmentPrefix': 'Versement :',
      'installmentPayPrefix': 'Paiement :',
      'calendar': 'Calendrier',
      'calendarFull': 'Calendrier & Rendez-vous',
      'addEvent': 'Ajouter un événement',
      'addEventTitle': 'Ajouter un événement',
      'editEventTitle': 'Modifier l\'événement',
      'eventName': 'Titre de l\'événement',
      'eventDesc': 'Description ou notes',
      'eventDate': 'Date de l\'événement',
      'eventTime': 'Heure de l\'événement',
      'eventType': 'Type d\'événement',
      'noEvents': 'Aucun événement pour ce jour',
      'noEventsMonth': 'Aucun événement ce mois',
      'today': 'Aujourd\'hui',
      'tomorrow': 'Demain',
      'upcoming': 'À venir',
      'allEvents': 'Tous les événements',
      'evtMeeting': 'Réunion',
      'evtAppointment': 'Rendez-vous médical',
      'evttask': 'Tâche',
      'evtReminder': 'Rappel',
      'evtPersonal': 'Personnel',
      'evtOther': 'Autre',
      'selectDate': 'Choisir la date',
      'selectTime': 'Choisir l\'heure',
      'calendarWidget': 'Calendrier',
      'eventsToday': 'Événements du jour',
      'nextEvent': 'Prochain événement',
      'mon': 'Lu',
      'tue': 'Ma',
      'wed': 'Me',
      'thu': 'Je',
      'fri': 'Ve',
      'sat': 'Sa',
      'sun': 'Di',
      'jan': 'Janvier',
      'feb': 'Février',
      'mar': 'Mars',
      'apr': 'Avril',
      'may': 'Mai',
      'jun': 'Juin',
      'jul': 'Juillet',
      'aug': 'Août',
      'sep': 'Septembre',
      'oct': 'Octobre',
      'nov': 'Novembre',
      'dec': 'Décembre',
      'typeCalendar': 'Événement calendrier',
      'deleteEventConfirmTitle': 'Confirmer la suppression',
      'deleteEventConfirmMsg':
          'Voulez-vous supprimer cet événement ? Il sera déplacé vers la corbeille.',
      'deleteConfirmYes': 'Supprimer',
      'eventDone': 'Événement terminé',
      'markDone': 'Marquer comme terminé',
      'addToCalendar': 'Ajouter au calendrier',
      'taskDeadlineDate': 'Date dans le calendrier',
      'taskDeadlineTime': 'Heure dans le calendrier',
      'taskAddedToCalendar': 'Tâche ajoutée au calendrier ✅',
      'completedTasks': 'Tâches terminées',
      'completedTasksFull': 'Liste des tâches terminées',
      'noCompletedTasks': 'Aucune tâche terminée pour l\'instant',
      'markComplete': 'Marquer comme terminée',
      'restoreTask': 'Restaurer dans les tâches actives',
      'completedAt': 'Terminée le :',
      'taskCompleted': 'Tâche accomplie ✅',
      'completedTasksCount': 'Terminées',
    },
    'en': {
      'appTitle': 'Smart Task Manager',
      'cancel': 'Cancel',
      'save': 'Save',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'open': 'Open',
      'language': 'Language',
      'goHome': 'Home',
      'welcome': 'Welcome!',
      'enterName': 'What is your name?',
      'startUsing': 'Get Started',
      'homeWelcome': 'Home Screen',
      'practicalTasksFull': 'Tasks & Schedule',
      'walletFull': 'Wallet & Debts',
      'notesFull': 'Notes & Memos',
      'manage': 'Manage tasks & time efficiently',
      'home': 'Home',
      'practicalTasks': 'Practical Tasks',
      'wallet': 'Wallet & Debts',
      'notes': 'Personal Notebook',
      'trash': 'Trash',
      'helloUser': 'Hello',
      'helloUserName': 'Hello',
      'smartOrganizer': 'Your Smart Organizer',
      'todayWisdom': "Today's Wisdom",
      'practicalTasksCount': 'Tasks',
      'financialSummary': 'Financial Summary',
      'notesCount': 'Notes',
      'addTask': 'Add New Task',
      'noTasks': 'No practical tasks yet',
      'addTaskTitle': 'Add Practical Task',
      'editTaskTitle': 'Edit Practical Task',
      'taskName': 'Task Title',
      'taskDesc': 'Description or Details',
      'duration': 'Completion Duration:',
      'hour': 'hour',
      'day': 'day',
      'timeExpired': 'Time Expired!',
      'remaining': 'Remaining:',
      'daysUnit': 'd',
      'hoursUnit': 'h',
      'minutesUnit': 'min',
      'walletLog': 'Wallet Log',
      'debtsManage': 'Manage Debts',
      'netBalance': 'Net Remaining Balance',
      'currency': '\$',
      'credit': 'Credit',
      'debit': 'Debit',
      'type': 'Type:',
      'statement': 'Description...',
      'amount': 'Amount',
      'cat1': 'Net Salary',
      'cat2': 'Other Income',
      'cat3': 'Installments & Debts',
      'cat4': 'Regular Expense',
      'debtLabel': 'Debt:',
      'debtHint': 'Select to deduct from',
      'editEntry': 'Edit Entry',
      'statementLabel': 'Description',
      'amountLabel': 'Amount',
      'installmentPaid': 'Installment recorded and deducted from debt',
      'totalRemaining': 'Total Remaining Debts',
      'totalDebts': 'Total Debts',
      'totalPaid': 'Paid',
      'addDebt': 'Add New Debt',
      'addDebtTitle': 'Add New Debt',
      'editDebtTitle': 'Edit Debt',
      'debtName': 'Debt name (e.g. car loan)',
      'debtTotal': 'Total Debt Amount',
      'debtRemain': 'Remaining:',
      'debtPaid': 'Paid:',
      'payNow': 'Pay Installment Now',
      'payInstallment': 'Pay Installment:',
      'payAmountNow': 'Amount Paid Now',
      'confirmPay': 'Confirm Payment',
      'debtCleared': 'Debt fully repaid 🎉',
      'paySuccess': 'Installment paid and deducted from debt successfully.',
      'newNote': 'New Note',
      'sortByImportance': 'Sort by Importance',
      'newNoteTitle': 'New Note',
      'editNoteTitle': 'Edit Note',
      'noteTitle': 'Title...',
      'noteContent': 'Note...',
      'setPassword': 'Set Password',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'passwordMismatch': 'Passwords do not match!',
      'noteLocked': 'Note Locked',
      'enterPassword': 'Enter Password',
      'wrongPassword': 'Wrong password!',
      'emptyTrash': 'Empty Trash',
      'trashEmpty': 'Trash is empty',
      'noTitle': '(no title)',
      'itemType': 'Type:',
      'restore': 'Restore',
      'deletePermanent': 'Delete Permanently',
      'restoreSuccess': 'Item restored to its section successfully!',
      'typeTask': 'Practical Task',
      'typeNote': 'Note',
      'typeExpense': 'Financial Transaction',
      'typeDebt': 'Debt',
      'q1': 'If you don\'t start today, you won\'t finish tomorrow.',
      'q2':
          'Today\'s achievement is the foundation for tomorrow\'s great successes.',
      'q3':
          'Don\'t wait for perfect conditions, create your own and move forward.',
      'q4': 'Good planning and consistent small steps make a huge difference.',
      'q5': 'The keys to productivity: absolute focus and setting priorities.',
      'installmentPrefix': 'Installment:',
      'installmentPayPrefix': 'Payment:',
      'calendar': 'Smart Calendar',
      'calendarFull': 'Calendar & Appointments',
      'addEvent': 'Add New Event',
      'addEventTitle': 'Add Event',
      'editEventTitle': 'Edit Event',
      'eventName': 'Event Title',
      'eventDesc': 'Description or Notes',
      'eventDate': 'Event Date',
      'eventTime': 'Event Time',
      'eventType': 'Event Type',
      'noEvents': 'No events for this day',
      'noEventsMonth': 'No events this month',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'upcoming': 'Upcoming',
      'allEvents': 'All Events',
      'evtMeeting': 'Meeting',
      'evtAppointment': 'Medical Appointment',
      'evttask': 'Task',
      'evtReminder': 'Reminder',
      'evtPersonal': 'Personal',
      'evtOther': 'Other',
      'selectDate': 'Select Date',
      'selectTime': 'Select Time',
      'calendarWidget': 'Calendar',
      'eventsToday': 'Today\'s Events',
      'nextEvent': 'Next Event',
      'mon': 'Mo',
      'tue': 'Tu',
      'wed': 'We',
      'thu': 'Th',
      'fri': 'Fr',
      'sat': 'Sa',
      'sun': 'Su',
      'jan': 'January',
      'feb': 'February',
      'mar': 'March',
      'apr': 'April',
      'may': 'May',
      'jun': 'June',
      'jul': 'July',
      'aug': 'August',
      'sep': 'September',
      'oct': 'October',
      'nov': 'November',
      'dec': 'December',
      'typeCalendar': 'Calendar Event',
      'deleteEventConfirmTitle': 'Confirm Delete',
      'deleteEventConfirmMsg': 'Delete this event? It will be moved to trash.',
      'deleteConfirmYes': 'Delete',
      'eventDone': 'Event completed',
      'markDone': 'Mark as done',
      'addToCalendar': 'Add to Calendar',
      'taskDeadlineDate': 'Calendar Date',
      'taskDeadlineTime': 'Calendar Time',
      'taskAddedToCalendar': 'Task added to calendar ✅',
      'completedTasks': 'Completed Tasks',
      'completedTasksFull': 'Completed Tasks List',
      'noCompletedTasks': 'No completed tasks yet',
      'markComplete': 'Mark as Completed',
      'restoreTask': 'Restore to Active Tasks',
      'completedAt': 'Completed at:',
      'taskCompleted': 'Task completed ✅',
      'completedTasksCount': 'Completed',
    },
  };

  static String s(String key) {
    final lang = globalLangNotifier.value;
    return _data[lang]?[key] ?? _data['ar']?[key] ?? key;
  }

  static List<String> get quotes => [
    s('q1'),
    s('q2'),
    s('q3'),
    s('q4'),
    s('q5'),
  ];
  static List<String> get categories => [
    s('cat1'),
    s('cat2'),
    s('cat3'),
    s('cat4'),
  ];
}

// ==========================================
// دالة الحفظ العامة - تُستدعى بعد كل تغيير
// ==========================================
void saveAllData() {
  StorageService.saveTasks(globalPracticalTasks);
  StorageService.saveCompletedTasks(globalCompletedTasks);
  StorageService.saveExpenses(globalExpenses);
  StorageService.saveDebts(globalDebts);
  StorageService.saveNotes(globalNotes);
  StorageService.saveTrash(globalTrash);
  StorageService.saveCalendarEvents(globalCalendarEvents);
}

// ==========================================
// main - نقطة البداية مع تهيئة التخزين
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  globalUserName = StorageService.loadUserName();
  globalLangNotifier.value = StorageService.loadLang();
  globalCurrencyNotifier.value = StorageService.loadCurrency();
  globalThemeNotifier.value = StorageService.loadTheme() == 'light'
      ? ThemeMode.light
      : ThemeMode.dark;

  globalPracticalTasks.addAll(StorageService.loadTasks());
  globalCompletedTasks.addAll(StorageService.loadCompletedTasks());
  globalExpenses.addAll(StorageService.loadExpenses());
  globalDebts.addAll(StorageService.loadDebts());
  globalNotes.addAll(StorageService.loadNotes());
  globalTrash.addAll(StorageService.loadTrash());
  globalCalendarEvents.addAll(StorageService.loadCalendarEvents());

  globalLangNotifier.addListener(() {
    StorageService.saveLang(globalLangNotifier.value);
    globalCurrencyNotifier.addListener(() {
      StorageService.saveCurrency(globalCurrencyNotifier.value);
    });
  });
  globalThemeNotifier.addListener(() {
    StorageService.saveTheme(
      globalThemeNotifier.value == ThemeMode.light ? 'light' : 'dark',
    );
  });

  runApp(const MyTasksApp());
}

String getCurrentFormattedDate() {
  final now = DateTime.now();
  final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
  final period = now.hour >= 12 ? 'م' : 'ص';
  final minute = now.minute.toString().padLeft(2, '0');
  return '${now.year}/${now.month}/${now.day} - $hour:$minute $period';
}

final List<Map<String, dynamic>> globalPracticalTasks = [];
final List<Map<String, dynamic>> globalCompletedTasks = [];
final List<Map<String, dynamic>> globalExpenses = [];
final List<Map<String, dynamic>> globalDebts = [];
final List<Map<String, dynamic>> globalNotes = [];
final List<Map<String, dynamic>> globalTrash = [];
final List<Map<String, dynamic>> globalCalendarEvents = [];

class MyTasksApp extends StatelessWidget {
  const MyTasksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLangNotifier,
      builder: (context, lang, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: globalThemeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: T.s('appTitle'),
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                primaryColor: const Color(0xFF0284C7),
                cardColor: Colors.white,
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0284C7),
                  secondary: Color(0xFF10B981),
                  surface: Colors.white,
                  background: Color(0xFFF8FAFC),
                ),
                fontFamily: 'Cairo',
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                primaryColor: const Color(0xFF6366F1),
                cardColor: const Color(0xFF1E293B),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF6366F1),
                  secondary: Color(0xFF34D399),
                  surface: Color(0xFF1E293B),
                  background: Color(0xFF0F172A),
                ),
                fontFamily: 'Cairo',
              ),
              home: const DashboardScreen(),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// الشاشة الرئيسية (Dashboard)
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalUserName.isEmpty) _showNameDialog();
    });
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  Future<void> _showNameDialog() async {
    TextEditingController nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: globalLangNotifier,
        builder: (ctx, lang, _) => Directionality(
          textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              T.s('welcome'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF0284C7),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: lang,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.language,
                          color: Color(0xFF0284C7),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(
                              'العربية 🇸🇦',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              'English 🇺🇸',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'fr',
                            child: Text(
                              'Français 🇫🇷',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) globalLangNotifier.value = value;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: T.s('enterName'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() => globalUserName = nameCtrl.text.trim());
                    StorageService.saveUserName(globalUserName);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  T.s('startUsing'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) => setState(() => _selectedIndex = index);

  List<String> get _titles => [
    T.s('home'),
    T.s('calendar'),
    T.s('practicalTasks'),
    T.s('wallet'),
    T.s('notes'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> tabs = [
      WelcomeTab(onNavigate: _navigateToTab),
      const SmartCalendarTab(),
      const PracticalTasksTab(),
      const FinancesTab(),
      const NotesTab(),
    ];

    return Directionality(
      textDirection: globalLangNotifier.value == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFF0284C7),
          actions: [
            if (_selectedIndex != 0)
              Tooltip(
                message: T.s('goHome'),
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 0),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.home_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            T.s('goHome'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => globalThemeNotifier.value = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            ),
          ],
        ),
        drawer: _buildDrawer(isDark),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            final isArabic = globalLangNotifier.value == 'ar';
            // Arabic (RTL): swipe left-to-right (positive velocity) opens drawer from right
            // Other (LTR): swipe right-to-left (negative velocity) opens drawer from left
            if (isArabic) {
              // RTL: drawer is on the right, open with swipe from right edge (velocity.x < 0 in screen coords)
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -200) {
                _scaffoldKey.currentState?.openDrawer();
              }
            } else {
              // LTR: drawer is on the left, open with swipe from left edge (velocity.x > 0)
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 200) {
                _scaffoldKey.currentState?.openDrawer();
              }
            }
          },
          child: tabs[_selectedIndex],
        ),
        floatingActionButton: _selectedIndex >= 1 && _selectedIndex <= 4
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر المهام المنجزة
                  if (_selectedIndex == 2)
                    FloatingActionButton.small(
                      heroTag: 'completedFab',
                      backgroundColor: isDark
                          ? const Color(0xFF134E3A)
                          : const Color(0xFFD1FAE5),
                      elevation: 3,
                      tooltip: T.s('completedTasks'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Directionality(
                              textDirection: globalLangNotifier.value == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: Text(
                                    T.s('completedTasksFull'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  centerTitle: true,
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                                body: const CompletedTasksTab(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.task_alt,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                      ),
                    ),
                  if (_selectedIndex == 2) const SizedBox(height: 8),
                  // زر سلة المهملات
                  FloatingActionButton.small(
                    heroTag: 'trashFab',
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    elevation: 3,
                    tooltip: T.s('trash'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Directionality(
                            textDirection: globalLangNotifier.value == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  T.s('trash'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                centerTitle: true,
                                elevation: 0,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF0284C7),
                              ),
                              body: const TrashTab(),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: isDark
                          ? Colors.redAccent.shade100
                          : Colors.redAccent,
                    ),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                    : [const Color(0xFF0284C7), const Color(0xFF0EA5E9)],
              ),
            ),
            accountName: Text(
              globalUserName.isEmpty ? T.s('helloUser') : globalUserName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              T.s('manage'),
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                // التعديل الجديد: اللوغو الدائري بدلاً من الأيقونة السابقة
                image: const DecorationImage(
                  image: AssetImage('assets/logo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          _buildDrawerItem(0, T.s('homeWelcome'), Icons.dashboard, isDark),
          _buildDrawerItem(
            1,
            T.s('calendarFull'),
            Icons.calendar_month,
            isDark,
          ),
          _buildDrawerItem(
            2,
            T.s('practicalTasksFull'),
            Icons.business_center,
            isDark,
          ),
          _buildDrawerItem(
            3,
            T.s('walletFull'),
            Icons.account_balance_wallet,
            isDark,
          ),
          _buildDrawerItem(4, T.s('notesFull'), Icons.note_alt, isDark),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF0284C7),
                ),
                const SizedBox(width: 8),
                Text(
                  T.s('language'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<String>(
            valueListenable: globalLangNotifier,
            builder: (context, currentLang, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildLangChip('ar', 'ع', 'عربي', currentLang, isDark),
                  const SizedBox(width: 8),
                  _buildLangChip('fr', 'Fr', 'Français', currentLang, isDark),
                  const SizedBox(width: 8),
                  _buildLangChip('en', 'En', 'English', currentLang, isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon, bool isDark) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF0284C7);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? activeColor
            : (isDark ? Colors.white60 : Colors.black54),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? activeColor : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        _navigateToTab(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLangChip(
    String code,
    String symbol,
    String label,
    String currentLang,
    bool isDark,
  ) {
    final bool isActive = currentLang == code;
    final Color activeColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF0284C7);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          globalLangNotifier.value = code;
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white24 : Colors.grey.shade300),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white70
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. شاشة الترحيب
// ==========================================
class WelcomeTab extends StatefulWidget {
  final Function(int) onNavigate;
  const WelcomeTab({Key? key, required this.onNavigate}) : super(key: key);
  @override
  State<WelcomeTab> createState() => _WelcomeTabState();
}

class _WelcomeTabState extends State<WelcomeTab> {
  late String selectedQuote;

  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
    _pickQuote();
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() {
    setState(() => _pickQuote());
  }

  void _pickQuote() {
    final q = List<String>.from(T.quotes)..shuffle();
    selectedQuote = q.first;
  }

  double _calculateNetTotal() {
    double credit = globalExpenses
        .where((i) => i['isCredit'] == true)
        .fold(0.0, (s, i) => s + i['amount']);
    double debit = globalExpenses
        .where((i) => i['isCredit'] == false)
        .fold(0.0, (s, i) => s + i['amount']);
    return credit - debit;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final netTotal = _calculateNetTotal();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: isDark
          ? const BoxDecoration(color: Color(0xFF0F172A))
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
              ),
            ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    globalUserName.isEmpty
                        ? T.s('helloUser')
                        : '${T.s('helloUserName')} $globalUserName',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFF0284C7).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFF0284C7).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          T.s('todayWisdom'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"$selectedQuote"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(1),
                            child: _buildStatCard(
                              T.s('calendarWidget'),
                              '${globalCalendarEvents.where((e) {
                                final d = e['date'] as DateTime;
                                final now = DateTime.now();
                                return d.year == now.year && d.month == now.month && d.day == now.day;
                              }).length}',
                              Icons.calendar_month,
                              const Color(0xFF6366F1),
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(2),
                            child: _buildStatCard(
                              T.s('practicalTasksCount'),
                              '${globalPracticalTasks.length}',
                              Icons.business_center,
                              const Color(0xFF0284C7),
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(2),
                            child: _buildStatCard(
                              T.s('completedTasksCount'),
                              '${globalCompletedTasks.length}',
                              Icons.task_alt,
                              const Color(0xFF10B981),
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(3),
                            child: _buildStatCard(
                              T.s('financialSummary'),
                              '${netTotal.toStringAsFixed(0)}',
                              Icons.account_balance_wallet,
                              const Color(0xFFF43F5E),
                              isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(4),
                            child: _buildStatCard(
                              T.s('notesCount'),
                              '${globalNotes.length}',
                              Icons.note_alt,
                              const Color(0xFFF59E0B),
                              isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Created by Yasser ثابت في أسفل الشاشة دائماً ──
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(
              '@Created by Yasser. since 2026',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 16,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. شاشة المهام العملية
// ==========================================
class PracticalTasksTab extends StatefulWidget {
  const PracticalTasksTab({Key? key}) : super(key: key);
  @override
  State<PracticalTasksTab> createState() => _PracticalTasksTabState();
}

class _PracticalTasksTabState extends State<PracticalTasksTab> {
  Timer? _timer;
  final Color navyBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    _timer?.cancel();
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  Map<String, dynamic> _calculateRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (difference.isNegative)
      return {'text': T.s('timeExpired'), 'isUrgent': true, 'expired': true};

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    String text = '';
    if (days > 0) text += '$days ${T.s('daysUnit')} ';
    if (hours > 0) text += '$hours ${T.s('hoursUnit')} ';
    if (minutes > 0 || text.isEmpty) text += '$minutes ${T.s('minutesUnit')}';
    return {
      'text': '${T.s('remaining')} $text',
      'isUrgent': difference.inMinutes <= 60,
      'expired': false,
    };
  }

  void _openAddTaskDialog({Map<String, dynamic>? existingTask, int? index}) {
    final titleCtrl = TextEditingController(text: existingTask?['title'] ?? '');
    final descCtrl = TextEditingController(text: existingTask?['desc'] ?? '');
    int durationValue = 1;
    String durationType = T.s('hour');

    // --- جديد: متغيرات الدمج مع التقويم ---
    DateTime? calendarDate;
    TimeOfDay? calendarTime;
    bool addToCalendar = false;

    if (existingTask != null) {
      if (existingTask['calendarDate'] != null) {
        calendarDate = existingTask['calendarDate'] as DateTime;
        addToCalendar = true;
      }
      if (existingTask['calendarTime'] != null) {
        calendarTime = existingTask['calendarTime'] as TimeOfDay;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: globalLangNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              existingTask == null ? T.s('addTaskTitle') : T.s('editTaskTitle'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: T.s('taskName')),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(labelText: T.s('taskDesc')),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: globalLangNotifier.value == 'ar'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      T.s('duration'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: durationValue,
                          isExpanded: true,
                          items: List.generate(30, (i) => i + 1)
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text('$val'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => durationValue = val ?? 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: durationType,
                          isExpanded: true,
                          items: [T.s('hour'), T.s('day')]
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setDialogState(
                            () => durationType = val ?? T.s('hour'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ─── قسم الدمج مع التقويم (جديد) ───
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: [
                      Switch(
                        value: addToCalendar,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (val) => setDialogState(() {
                          addToCalendar = val;
                          if (!val) {
                            calendarDate = null;
                            calendarTime = null;
                          }
                        }),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          T.s('addToCalendar'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF6366F1),
                        size: 18,
                      ),
                    ],
                  ),
                  if (addToCalendar) ...[
                    const SizedBox(height: 8),
                    // زر اختيار التاريخ
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: calendarDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => calendarDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              calendarDate != null
                                  ? '${calendarDate!.day}/${calendarDate!.month}/${calendarDate!.year}'
                                  : T.s('taskDeadlineDate'),
                              style: TextStyle(
                                color: calendarDate != null
                                    ? null
                                    : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // زر اختيار الوقت
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              calendarTime ??
                              const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) {
                          setDialogState(() => calendarTime = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              calendarTime != null
                                  ? '${calendarTime!.hour.toString().padLeft(2, '0')}:${calendarTime!.minute.toString().padLeft(2, '0')}'
                                  : T.s('taskDeadlineTime'),
                              style: TextStyle(
                                color: calendarTime != null
                                    ? null
                                    : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // ─── نهاية قسم التقويم ───
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(T.s('cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: navyBlue),
                onPressed: () {
                  if (titleCtrl.text.isEmpty) return;
                  final now = DateTime.now();
                  DateTime deadline = durationType == T.s('hour')
                      ? now.add(Duration(hours: durationValue))
                      : now.add(Duration(days: durationValue));
                  setState(() {
                    final taskData = {
                      'title': titleCtrl.text,
                      'desc': descCtrl.text,
                      'deadline': deadline,
                      'dateTime':
                          existingTask?['dateTime'] ??
                          getCurrentFormattedDate(),
                      // --- جديد: حفظ بيانات التقويم ---
                      'calendarDate': addToCalendar ? calendarDate : null,
                      'calendarTime': addToCalendar ? calendarTime : null,
                    };
                    if (index == null)
                      globalPracticalTasks.add(taskData);
                    else
                      globalPracticalTasks[index] = taskData;
                  });
                  StorageService.saveTasks(globalPracticalTasks);

                  // --- جديد: إضافة حدث للتقويم تلقائياً ---
                  if (addToCalendar && calendarDate != null) {
                    final eventTime =
                        calendarTime ?? const TimeOfDay(hour: 9, minute: 0);

                    // حذف الحدث القديم إذا كان تعديلاً
                    if (index != null) {
                      globalCalendarEvents.removeWhere(
                        (e) =>
                            e['sourceTaskTitle'] == existingTask?['title'] &&
                            e['isFromTask'] == true,
                      );
                    }

                    globalCalendarEvents.add({
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'title': titleCtrl.text,
                      'desc': descCtrl.text,
                      'date': calendarDate!,
                      'time': eventTime,
                      'type': 'task',
                      'done': false,
                      'isDone': false,
                      'isFromTask': true,
                      'sourceTaskTitle': titleCtrl.text,
                    });
                    StorageService.saveCalendarEvents(globalCalendarEvents);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(T.s('taskAddedToCalendar')),
                        backgroundColor: const Color(0xFF10B981),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  existingTask == null ? T.s('add') : T.s('save'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: navyBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDark ? 0 : 3,
            ),
            icon: const Icon(Icons.add_task, color: Colors.white),
            label: Text(
              T.s('addTask'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _openAddTaskDialog(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: globalPracticalTasks.isEmpty
                ? Center(child: Text(T.s('noTasks')))
                : ListView.builder(
                    itemCount: globalPracticalTasks.length,
                    itemBuilder: (context, index) {
                      final task = globalPracticalTasks[index];
                      final DateTime deadline = task['deadline'];
                      final timeInfo = _calculateRemainingTime(deadline);
                      bool isUrgent = timeInfo['isUrgent'];
                      final bool isDone = task['done'] == true;

                      return GestureDetector(
                        onTap: () {
                          // تحديد المهمة كمنجزة عند الضغط عليها
                          setState(() {
                            final completedTask = Map<String, dynamic>.from(
                              task,
                            );
                            completedTask['done'] = true;
                            completedTask['completedAt'] = DateTime.now();
                            globalCompletedTasks.insert(0, completedTask);
                            globalPracticalTasks.removeAt(index);
                          });
                          StorageService.saveTasks(globalPracticalTasks);
                          StorageService.saveCompletedTasks(
                            globalCompletedTasks,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(T.s('taskCompleted')),
                              backgroundColor: const Color(0xFF10B981),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDone
                                ? (isDark
                                      ? const Color(0xFF134E3A)
                                      : const Color(0xFFD1FAE5))
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : isUrgent
                                  ? Colors.red.shade400
                                  : (isDark
                                        ? Colors.white12
                                        : navyBlue.withOpacity(0.2)),
                              width: isUrgent ? 2 : 1,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: isUrgent
                                          ? Colors.red.withOpacity(0.05)
                                          : navyBlue.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Icon(
                              isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade400,
                              size: 26,
                            ),
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone
                                    ? (isDark
                                          ? Colors.white54
                                          : Colors.grey.shade500)
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task['desc'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    task['desc'],
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUrgent
                                        ? Colors.red.shade50
                                        : (isDark
                                              ? Colors.white10
                                              : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        size: 14,
                                        color: isUrgent ? Colors.red : navyBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        timeInfo['text'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isUrgent
                                              ? Colors.red
                                              : (isDark
                                                    ? Colors.white70
                                                    : navyBlue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // --- شارة التقويم ---
                                if (task['calendarDate'] != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.event_available,
                                          size: 13,
                                          color: Color(0xFF6366F1),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          () {
                                            final d =
                                                task['calendarDate']
                                                    as DateTime;
                                            final t =
                                                task['calendarTime']
                                                    as TimeOfDay?;
                                            String dateStr =
                                                '${d.day}/${d.month}/${d.year}';
                                            if (t != null) {
                                              dateStr +=
                                                  '  ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                                            }
                                            return dateStr;
                                          }(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6366F1),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: navyBlue),
                                  onPressed: () => _openAddTaskDialog(
                                    existingTask: task,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => setState(() {
                                    globalTrash.add({
                                      'type': T.s('typeTask'),
                                      'title': task['title'],
                                      'data': globalPracticalTasks.removeAt(
                                        index,
                                      ),
                                    });
                                    StorageService.saveTasks(
                                      globalPracticalTasks,
                                    );
                                    StorageService.saveTrash(globalTrash);
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. شاشة المحفظة والمديونيات
// ==========================================
class FinancesTab extends StatefulWidget {
  const FinancesTab({Key? key}) : super(key: key);
  @override
  State<FinancesTab> createState() => _FinancesTabState();
}

class _FinancesTabState extends State<FinancesTab> {
  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicatorColor: const Color(0xFF0284C7),
              labelColor: const Color(0xFF0284C7),
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: T.s('walletLog')),
                Tab(text: T.s('debtsManage')),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [WalletView(), DebtsView()]),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3.1 شاشة المحفظة (WalletView)
// ==========================================
class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);
  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late String _selectedCategory;
  int? _selectedDebtId;

  @override
  void initState() {
    super.initState();
    _selectedCategory = T.categories[3];
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {
    _selectedCategory = T.categories[3];
  });

  bool _isCredit(String cat) => cat == T.s('cat1') || cat == T.s('cat2');

  void _addTransaction() {
    if (_titleController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty)
      return;
    double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;
    setState(() {
      if (_selectedCategory == T.s('cat3') && _selectedDebtId != null) {
        int di = globalDebts.indexWhere((d) => d['id'] == _selectedDebtId);
        if (di != -1) {
          globalDebts[di]['paid'] += amount;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(T.s('installmentPaid'))));
        }
      }
      globalExpenses.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': _titleController.text.trim(),
        'amount': amount,
        'category': _selectedCategory,
        'isCredit': _isCredit(_selectedCategory),
        'date': getCurrentFormattedDate(),
      });
      _titleController.clear();
      _amountController.clear();
      _selectedDebtId = null;
    });
    StorageService.saveExpenses(globalExpenses);
    StorageService.saveDebts(globalDebts);
    FocusScope.of(context).unfocus();
  }

  void _editTransaction(Map<String, dynamic> item, int index) {
    final editTitleCtrl = TextEditingController(text: item['title']);
    final editAmountCtrl = TextEditingController(
      text: item['amount'].toString(),
    );
    String editCategory = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) => Directionality(
          textDirection: globalLangNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            title: Text(T.s('editEntry')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: editCategory,
                    isExpanded: true,
                    items: T.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setDS(() => editCategory = val!),
                  ),
                  TextField(
                    controller: editTitleCtrl,
                    decoration: InputDecoration(
                      labelText: T.s('statementLabel'),
                    ),
                  ),
                  TextField(
                    controller: editAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: T.s('amountLabel')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(T.s('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    globalExpenses[index]['title'] = editTitleCtrl.text;
                    globalExpenses[index]['amount'] =
                        double.tryParse(editAmountCtrl.text) ?? item['amount'];
                    globalExpenses[index]['category'] = editCategory;
                    globalExpenses[index]['isCredit'] = _isCredit(editCategory);
                    globalExpenses[index]['date'] = getCurrentFormattedDate();
                  });
                  StorageService.saveExpenses(globalExpenses);
                  Navigator.pop(context);
                },
                child: Text(T.s('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCredit = globalExpenses
        .where((i) => i['isCredit'] == true)
        .fold(0.0, (s, i) => s + i['amount']);
    double totalDebit = globalExpenses
        .where((i) => i['isCredit'] == false)
        .fold(0.0, (s, i) => s + i['amount']);
    double netBalance = totalCredit - totalDebit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const mainColor = Color(0xFF0284C7);

    return ValueListenableBuilder<String>(
      valueListenable: globalCurrencyNotifier,
      builder: (context, currentCurrency, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF0F172A),
                                    mainColor.withOpacity(0.25),
                                  ]
                                : [Colors.white, mainColor.withOpacity(0.15)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: mainColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  T.s('netBalance'),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // --- محدد العملة ---
                                Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: currentCurrency,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white70
                                            : mainColor,
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                      dropdownColor: Theme.of(
                                        context,
                                      ).cardColor,
                                      items:
                                          [
                                                '🇸🇦 SAR',
                                                '🇺🇸 USD',
                                                '🇪🇺 EUR',
                                                '🇦🇪 AED',
                                                '🇲🇦 MAD',
                                                '🇪🇬 EGP',
                                                '🇩🇿 DZD',
                                                '🇯🇴 JOD',
                                                '🇴🇲 OMR',
                                                '🇰🇼 KWD',
                                                '🇶🇦 QAR',
                                                '🇧🇭 BHD',
                                              ]
                                              .map(
                                                (c) => DropdownMenuItem(
                                                  value: c,
                                                  child: Text(c),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null)
                                          globalCurrencyNotifier.value = val;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${netBalance.toStringAsFixed(2)} $currentCurrency',
                              style: TextStyle(
                                color: netBalance >= 0
                                    ? Colors.green
                                    : Colors.redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 20, color: Colors.black12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      T.s('credit'),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '+${totalCredit.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      T.s('debit'),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '-${totalDebit.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  T.s('type'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: Theme.of(context).cardColor,
                                    items: T.categories
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) => setState(() {
                                      _selectedCategory = val!;
                                      if (_selectedCategory != T.s('cat3'))
                                        _selectedDebtId = null;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedCategory == T.s('cat3') &&
                                globalDebts.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      T.s('debtLabel'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: DropdownButton<int>(
                                        value: _selectedDebtId,
                                        isExpanded: true,
                                        hint: Text(
                                          T.s('debtHint'),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        items: globalDebts
                                            .map(
                                              (d) => DropdownMenuItem<int>(
                                                value: d['id'],
                                                child: Text(
                                                  d['title'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(() {
                                          _selectedDebtId = val;
                                          if (_titleController.text.isEmpty)
                                            _titleController.text =
                                                '${T.s('installmentPrefix')} ${globalDebts.firstWhere((d) => d['id'] == val)['title']}';
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      hintText: T.s('statement'),
                                      hintStyle: const TextStyle(fontSize: 12),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: T.s('amount'),
                                      hintStyle: const TextStyle(fontSize: 12),
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: mainColor,
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: _addTransaction,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = globalExpenses[index];
                    final isCredit = item['isCredit'] ?? false;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCredit
                              ? Colors.green.withOpacity(0.1)
                              : Colors.redAccent.withOpacity(0.1),
                          child: Icon(
                            isCredit
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isCredit ? Colors.green : Colors.redAccent,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item['category']} | ${item['date']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${isCredit ? "+" : "-"}${item['amount']}',
                              style: TextStyle(
                                color: isCredit
                                    ? Colors.green
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 18,
                              ),
                              onPressed: () => _editTransaction(item, index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              onPressed: () => setState(() {
                                globalTrash.add({
                                  'type': T.s('typeExpense'),
                                  'title': item['title'],
                                  'data': globalExpenses.removeAt(index),
                                });
                                StorageService.saveExpenses(globalExpenses);
                                StorageService.saveTrash(globalTrash);
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: globalExpenses.length),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 3.2 شاشة المديونيات (DebtsView)
// ==========================================
class DebtsView extends StatefulWidget {
  const DebtsView({Key? key}) : super(key: key);
  @override
  State<DebtsView> createState() => _DebtsViewState();
}

class _DebtsViewState extends State<DebtsView> {
  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  void _openAddDebtDialog({Map<String, dynamic>? existingDebt, int? index}) {
    final titleCtrl = TextEditingController(text: existingDebt?['title'] ?? '');
    final totalCtrl = TextEditingController(
      text: existingDebt?['total']?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: globalLangNotifier.value == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            existingDebt == null ? T.s('addDebtTitle') : T.s('editDebtTitle'),
            style: const TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: T.s('debtName')),
                ),
                TextField(
                  controller: totalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: T.s('debtTotal')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(T.s('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || totalCtrl.text.isEmpty) return;
                double? total = double.tryParse(totalCtrl.text);
                if (total == null) return;
                setState(() {
                  if (index == null) {
                    globalDebts.add({
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'title': titleCtrl.text,
                      'total': total,
                      'paid': 0.0,
                      'date': getCurrentFormattedDate(),
                    });
                  } else {
                    globalDebts[index]['title'] = titleCtrl.text;
                    globalDebts[index]['total'] = total;
                  }
                });
                StorageService.saveDebts(globalDebts);
                Navigator.pop(context);
              },
              child: Text(existingDebt == null ? T.s('add') : T.s('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _payInstallmentDialog(int index) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: globalLangNotifier.value == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            '${T.s('payInstallment')} ${globalDebts[index]['title']}',
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: T.s('payAmountNow')),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(T.s('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (amountCtrl.text.isEmpty) return;
                double? paidAmount = double.tryParse(amountCtrl.text);
                if (paidAmount == null || paidAmount <= 0) return;
                setState(() {
                  globalDebts[index]['paid'] += paidAmount;
                  globalExpenses.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'title':
                        '${T.s('installmentPayPrefix')} ${globalDebts[index]['title']}',
                    'amount': paidAmount,
                    'category': T.s('cat3'),
                    'isCredit': false,
                    'date': getCurrentFormattedDate(),
                  });
                });
                StorageService.saveDebts(globalDebts);
                StorageService.saveExpenses(globalExpenses);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(T.s('paySuccess'))));
              },
              child: Text(
                T.s('confirmPay'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalDebts = globalDebts.fold(0.0, (s, i) => s + i['total']);
    double totalPaid = globalDebts.fold(0.0, (s, i) => s + i['paid']);
    double remainingDebts = totalDebts - totalPaid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: globalCurrencyNotifier,
      builder: (context, currentCurrency, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        T.s('totalRemaining'),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${remainingDebts.toStringAsFixed(2)} $currentCurrency', // تم ربط العملة هنا
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                T.s('totalDebts'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${totalDebts.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                T.s('totalPaid'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${totalPaid.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    T.s('addDebt'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _openAddDebtDialog(),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: globalDebts.length,
                  itemBuilder: (context, index) {
                    final debt = globalDebts[index];
                    double total = debt['total'];
                    double paid = debt['paid'];
                    double remain = total - paid;
                    double progress = total > 0
                        ? (paid / total).clamp(0.0, 1.0)
                        : 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  debt['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () => _openAddDebtDialog(
                                        existingDebt: debt,
                                        index: index,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() {
                                        globalTrash.add({
                                          'type': T.s('typeDebt'),
                                          'title': debt['title'],
                                          'data': globalDebts.removeAt(index),
                                        });
                                        StorageService.saveDebts(globalDebts);
                                        StorageService.saveTrash(globalTrash);
                                      }),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                              color: progress >= 1.0
                                  ? Colors.green
                                  : Colors.redAccent,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${T.s('debtRemain')} ${remain.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Text(
                                  '${T.s('debtPaid')} ${paid.toStringAsFixed(1)}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (remain > 0)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                onPressed: () => _payInstallmentDialog(index),
                                child: Text(
                                  T.s('payNow'),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  T.s('debtCleared'),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// ==========================================
// 4. شاشة الملاحظات
// ==========================================
class NotesTab extends StatefulWidget {
  const NotesTab({Key? key}) : super(key: key);
  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  List<Color> _getPalette(bool isDark) {
    if (isDark)
      return [
        Colors.blueGrey.shade100,
        Colors.red.shade100,
        Colors.teal.shade100,
        Colors.orange.shade100,
        Colors.purple.shade100,
      ];
    return [
      const Color(0xFF1E293B),
      Colors.red.shade900,
      Colors.teal.shade900,
      Colors.orange.shade900,
      Colors.purple.shade900,
    ];
  }

  Future<String?> _showSetPasswordDialog() async {
    final p1 = TextEditingController();
    final p2 = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: globalLangNotifier.value == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          title: Text(T.s('setPassword'), style: const TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: p1,
                  obscureText: true,
                  decoration: InputDecoration(hintText: T.s('password')),
                ),
                TextField(
                  controller: p2,
                  obscureText: true,
                  decoration: InputDecoration(hintText: T.s('confirmPassword')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(T.s('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (p1.text.isEmpty) return;
                if (p1.text == p2.text) {
                  Navigator.pop(ctx, p1.text);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(T.s('passwordMismatch'))),
                  );
                }
              },
              child: Text(T.s('confirm')),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showUnlockDialog(String correctPassword) async {
    final p = TextEditingController();
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: globalLangNotifier.value == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: AlertDialog(
              title: Text(
                T.s('noteLocked'),
                style: const TextStyle(fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: TextField(
                  controller: p,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(hintText: T.s('enterPassword')),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(T.s('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (p.text == correctPassword) {
                      Navigator.pop(ctx, true);
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(T.s('wrongPassword'))),
                      );
                    }
                  },
                  child: Text(T.s('open')),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _openNoteViewDialog({
    required Map<String, dynamic> note,
    required int index,
  }) {
    final bool isAppDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> palette = _getPalette(isAppDark);
    final int colorIndex = note['colorIndex'] ?? 0;
    final Color bgColor = palette[colorIndex];
    final Color textColor = isAppDark ? Colors.black87 : Colors.white;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: globalLangNotifier.value == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Dialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        note['title'] ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (note['important'] == true)
                      Icon(Icons.star, color: Colors.amber, size: 22),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: textColor.withOpacity(0.7),
                        size: 22,
                      ),
                      tooltip: T.s('edit'),
                      onPressed: () {
                        Navigator.pop(context);
                        _openNoteDialog(existingNote: note, index: index);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: textColor.withOpacity(0.7),
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: textColor.withOpacity(0.2), height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    note['content'] ?? '',
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNoteDialog({Map<String, dynamic>? existingNote, int? index}) {
    final bool isAppDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> currentPalette = _getPalette(isAppDark);
    int selectedColorIndex = existingNote?['colorIndex'] ?? 0;
    final titleCtrl = TextEditingController(text: existingNote?['title'] ?? '');
    final contentCtrl = TextEditingController(
      text: existingNote?['content'] ?? '',
    );
    bool isImportant = existingNote?['important'] ?? false;
    bool isLocked = existingNote?['isLocked'] ?? false;
    String password = existingNote?['password'] ?? '';
    Color textColor = isAppDark ? Colors.black87 : Colors.white;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: globalLangNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: currentPalette[selectedColorIndex],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  existingNote == null
                      ? T.s('newNoteTitle')
                      : T.s('editNoteTitle'),
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        color: textColor,
                      ),
                      onPressed: () async {
                        if (isLocked) {
                          setDialogState(() {
                            isLocked = false;
                            password = '';
                          });
                        } else {
                          final pwd = await _showSetPasswordDialog();
                          if (pwd != null)
                            setDialogState(() {
                              isLocked = true;
                              password = pwd;
                            });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isImportant ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () =>
                          setDialogState(() => isImportant = !isImportant),
                    ),
                  ],
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      hintText: T.s('noteTitle'),
                      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: textColor.withOpacity(0.2)),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: T.s('noteContent'),
                      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      currentPalette.length,
                      (i) => GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedColorIndex = i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: currentPalette[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColorIndex == i
                                  ? textColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  T.s('cancel'),
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                ),
                onPressed: () {
                  if (titleCtrl.text.isEmpty && contentCtrl.text.isEmpty)
                    return;
                  setState(() {
                    final noteData = {
                      'title': titleCtrl.text,
                      'content': contentCtrl.text,
                      'colorIndex': selectedColorIndex,
                      'important': isImportant,
                      'dateTime':
                          existingNote?['dateTime'] ??
                          getCurrentFormattedDate(),
                      'isLocked': isLocked,
                      'password': password,
                    };
                    if (index == null)
                      globalNotes.insert(0, noteData);
                    else
                      globalNotes[index] = noteData;
                  });
                  StorageService.saveNotes(globalNotes);
                  Navigator.pop(context);
                },
                child: Text(
                  T.s('save'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sortNotes() {
    setState(() {
      globalNotes.sort((a, b) {
        if (a['important'] == b['important']) return 0;
        return (a['important'] == true) ? -1 : 1;
      });
    });
    StorageService.saveNotes(globalNotes);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAppDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> currentPalette = _getPalette(isAppDark);
    Color textColor = isAppDark ? Colors.black87 : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note, color: Colors.black),
                  label: Text(
                    T.s('newNote'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _openNoteDialog(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: T.s('sortByImportance'),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                icon: const Icon(Icons.sort),
                onPressed: _sortNotes,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: globalNotes.length,
              itemBuilder: (context, index) {
                final note = globalNotes[index];
                final bool isLocked = note['isLocked'] ?? false;
                final int colorIdx = note['colorIndex'] ?? 0;
                final Color noteColor = currentPalette[colorIdx];

                // التعديل هنا: تغليف الحاوية بالكامل بـ GestureDetector للاستجابة للضغط
                return GestureDetector(
                  onTap: () async {
                    if (isLocked) {
                      bool unlocked = await _showUnlockDialog(note['password']);
                      if (!unlocked) return;
                    }
                    _openNoteViewDialog(note: note, index: index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: noteColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: note['important'] == true
                            ? Colors.amber
                            : textColor.withOpacity(0.1),
                        width: note['important'] == true ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                note['title'],
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLocked)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.lock,
                                      size: 16,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                if (note['important'] == true)
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Divider(color: textColor.withOpacity(0.2)),
                        Expanded(
                          child: isLocked
                              ? Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: textColor.withOpacity(0.3),
                                    size: 40,
                                  ),
                                )
                              : Text(
                                  note['content'],
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.fade,
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              note['dateTime'].toString().split('-')[0],
                              style: TextStyle(
                                color: textColor.withOpacity(0.5),
                                fontSize: 8,
                              ),
                            ),
                            // التعديل هنا: إزالة أيقونة العين، والإبقاء على أيقونة الحذف فقط
                            GestureDetector(
                              onTap: () => setState(() {
                                globalTrash.add({
                                  'type': T.s('typeNote'),
                                  'title': note['title'],
                                  'data': globalNotes.removeAt(index),
                                });
                                StorageService.saveNotes(globalNotes);
                                StorageService.saveTrash(globalTrash);
                              }),
                              child: const Icon(
                                Icons.delete_sweep,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5.A شاشة المهام المنجزة
// ==========================================
class CompletedTasksTab extends StatefulWidget {
  const CompletedTasksTab({Key? key}) : super(key: key);
  @override
  State<CompletedTasksTab> createState() => _CompletedTasksTabState();
}

class _CompletedTasksTabState extends State<CompletedTasksTab> {
  final Color navyBlue = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  void _openEditDialog(Map<String, dynamic> task, int index) {
    final titleCtrl = TextEditingController(text: task['title'] ?? '');
    final descCtrl = TextEditingController(text: task['desc'] ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: globalLangNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              T.s('editTaskTitle'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: T.s('taskName')),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(labelText: T.s('taskDesc')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(T.s('cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: () {
                  if (titleCtrl.text.isEmpty) return;
                  setState(() {
                    globalCompletedTasks[index] = {
                      ...globalCompletedTasks[index],
                      'title': titleCtrl.text,
                      'desc': descCtrl.text,
                    };
                  });
                  StorageService.saveCompletedTasks(globalCompletedTasks);
                  Navigator.pop(context);
                },
                child: Text(
                  T.s('save'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // رأس الصفحة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  '${T.s('completedTasksFull')} (${globalCompletedTasks.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: globalCompletedTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          T.s('noCompletedTasks'),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: globalCompletedTasks.length,
                    itemBuilder: (context, index) {
                      final task = globalCompletedTasks[index];
                      final completedAt = task['completedAt'] as DateTime?;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF134E3A)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                          title: Text(
                            task['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((task['desc'] ?? '')
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task['desc'],
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              if (completedAt != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 13,
                                      color: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${T.s('completedAt')} ${completedAt.day}/${completedAt.month}/${completedAt.year}  ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // زر التعديل
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: navyBlue,
                                  size: 20,
                                ),
                                tooltip: T.s('edit'),
                                onPressed: () => _openEditDialog(task, index),
                              ),
                              // زر الإرجاع للمهام النشطة
                              IconButton(
                                icon: const Icon(
                                  Icons.undo_rounded,
                                  color: Color(0xFF0284C7),
                                  size: 22,
                                ),
                                tooltip: T.s('restoreTask'),
                                onPressed: () {
                                  setState(() {
                                    final restored = Map<String, dynamic>.from(
                                      globalCompletedTasks.removeAt(index),
                                    );
                                    restored.remove('completedAt');
                                    restored['done'] = false;
                                    // إعادة حساب الـ deadline من الآن إذا انتهى
                                    final dl = restored['deadline'] as DateTime;
                                    if (dl.isBefore(DateTime.now())) {
                                      restored['deadline'] = DateTime.now().add(
                                        const Duration(hours: 1),
                                      );
                                    }
                                    globalPracticalTasks.insert(0, restored);
                                  });
                                  StorageService.saveTasks(
                                    globalPracticalTasks,
                                  );
                                  StorageService.saveCompletedTasks(
                                    globalCompletedTasks,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(T.s('restoreSuccess')),
                                      backgroundColor: const Color(0xFF0284C7),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // زر الحذف النهائي
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    globalCompletedTasks.removeAt(index);
                                  });
                                  StorageService.saveCompletedTasks(
                                    globalCompletedTasks,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. شاشة سلة المهملات
// ==========================================
class TrashTab extends StatefulWidget {
  const TrashTab({Key? key}) : super(key: key);
  @override
  State<TrashTab> createState() => _TrashTabState();
}

class _TrashTabState extends State<TrashTab> {
  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  String _getLocalizedType(String type) {
    if (type == 'مهمة عملية' ||
        type == 'Tâche pratique' ||
        type == 'Practical Task')
      return T.s('typeTask');
    if (type == 'ملاحظة' || type == 'Note') return T.s('typeNote');
    if (type == 'عملية مالية' ||
        type == 'Transaction financière' ||
        type == 'Financial Transaction')
      return T.s('typeExpense');
    if (type == 'مديونية' || type == 'Dette' || type == 'Debt')
      return T.s('typeDebt');
    if (type == 'موعد تقويم' ||
        type == 'Événement calendrier' ||
        type == 'Calendar Event')
      return T.s('typeCalendar');
    return type;
  }

  IconData _typeIcon(String type) {
    if (type == 'مهمة عملية' ||
        type == 'Tâche pratique' ||
        type == 'Practical Task')
      return Icons.business_center;
    if (type == 'ملاحظة' || type == 'Note') return Icons.note_alt;
    if (type == 'عملية مالية' ||
        type == 'Transaction financière' ||
        type == 'Financial Transaction')
      return Icons.account_balance_wallet;
    if (type == 'مديونية' || type == 'Dette' || type == 'Debt')
      return Icons.credit_card;
    if (type == 'موعد تقويم' ||
        type == 'Événement calendrier' ||
        type == 'Calendar Event')
      return Icons.calendar_month;
    return Icons.delete;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (globalTrash.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: Text(
                  T.s('emptyTrash'),
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () => setState(() {
                  globalTrash.clear();
                  StorageService.saveTrash(globalTrash);
                }),
              ),
            ),
          Expanded(
            child: globalTrash.isEmpty
                ? Center(child: Text(T.s('trashEmpty')))
                : ListView.builder(
                    itemCount: globalTrash.length,
                    itemBuilder: (context, index) {
                      final item = globalTrash[index];
                      final localType = _getLocalizedType(item['type']);
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            child: Icon(
                              _typeIcon(item['type']),
                              size: 20,
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          title: Text(
                            item['title'] ?? T.s('noTitle'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${T.s('itemType')} $localType',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.restore,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    final restoredItem = globalTrash.removeAt(
                                      index,
                                    );
                                    final type = restoredItem['type'];
                                    final data = restoredItem['data'];

                                    if (type == T.s('typeTask')) {
                                      globalPracticalTasks.add(data);
                                      StorageService.saveTasks(
                                        globalPracticalTasks,
                                      );
                                    } else if (type == T.s('typeExpense')) {
                                      globalExpenses.add(data);
                                      StorageService.saveExpenses(
                                        globalExpenses,
                                      );
                                    } else if (type == T.s('typeDebt')) {
                                      globalDebts.add(data);
                                      StorageService.saveDebts(globalDebts);
                                    } else if (type == T.s('typeNote')) {
                                      globalNotes.add(data);
                                      StorageService.saveNotes(globalNotes);
                                    } else if (type == T.s('typeCalendar')) {
                                      globalCalendarEvents.add(data);
                                      StorageService.saveCalendarEvents(
                                        globalCalendarEvents,
                                      );
                                    }
                                    StorageService.saveTrash(globalTrash);
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    globalTrash.removeAt(index);
                                    StorageService.saveTrash(globalTrash);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. شاشة التقويم الذكي
// ==========================================
class SmartCalendarTab extends StatefulWidget {
  const SmartCalendarTab({Key? key}) : super(key: key);
  @override
  State<SmartCalendarTab> createState() => _SmartCalendarTabState();
}

class _SmartCalendarTabState extends State<SmartCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isWeekView = true; // يبدأ بعرض الأسبوع الحالي فقط
  @override
  void initState() {
    super.initState();
    globalLangNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    globalLangNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});
  String _monthName(int month) {
    const keys = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return T.s(keys[month - 1]);
  }

  String _weekdayShort(int wd) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return T.s(keys[wd - 1]);
  }

  List<Map<String, dynamic>> _eventsForDay(DateTime day) {
    return globalCalendarEvents.where((e) {
      final d = e['date'] as DateTime;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList()..sort((a, b) {
      final ta = a['time'] as TimeOfDay;
      final tb = b['time'] as TimeOfDay;
      return (ta.hour * 60 + ta.minute).compareTo(tb.hour * 60 + tb.minute);
    });
  }

  List<Map<String, dynamic>> _upcomingEvents() {
    final now = DateTime.now();
    return globalCalendarEvents.where((e) {
      final d = e['date'] as DateTime;
      final t = e['time'] as TimeOfDay;
      final eventDt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      return eventDt.isAfter(now);
    }).toList()..sort((a, b) {
      final da = a['date'] as DateTime;
      final ta = a['time'] as TimeOfDay;
      final db = b['date'] as DateTime;
      final tb = b['time'] as TimeOfDay;
      final dtA = DateTime(da.year, da.month, da.day, ta.hour, ta.minute);
      final dtB = DateTime(db.year, db.month, db.day, tb.hour, tb.minute);
      return dtA.compareTo(dtB);
    });
  }

  Color _eventTypeColor(String type) {
    switch (type) {
      case 'meeting':
        return const Color(0xFF0284C7);
      case 'medical':
        return const Color(0xFFF43F5E);
      case 'task':
        return const Color(0xFF10B981);
      case 'reminder':
        return const Color(0xFFF59E0B);
      case 'personal':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _eventTypeIcon(String type) {
    switch (type) {
      case 'meeting':
        return Icons.groups;
      case 'medical':
        return Icons.local_hospital;
      case 'task':
        return Icons.task_alt;
      case 'reminder':
        return Icons.notifications_active;
      case 'personal':
        return Icons.person;
      default:
        return Icons.event;
    }
  }

  String _eventTypeLabel(String type) {
    switch (type) {
      case 'meeting':
        return T.s('evtMeeting');
      case 'medical':
        return T.s('evtAppointment');
      case 'task':
        return T.s('evttask');
      case 'reminder':
        return T.s('evtReminder');
      case 'personal':
        return T.s('evtPersonal');
      default:
        return T.s('evtOther');
    }
  }

  void _openAddEventDialog({Map<String, dynamic>? existingEvent, int? index}) {
    final titleCtrl = TextEditingController(
      text: existingEvent?['title'] ?? '',
    );
    final descCtrl = TextEditingController(text: existingEvent?['desc'] ?? '');
    DateTime selectedDate = existingEvent?['date'] ?? _selectedDay;
    TimeOfDay selectedTime =
        existingEvent?['time'] ?? const TimeOfDay(hour: 9, minute: 0);
    String selectedType = existingEvent?['type'] ?? 'meeting';

    final typeOptions = [
      {
        'value': 'meeting',
        'label': T.s('evtMeeting'),
        'icon': Icons.groups,
        'color': const Color(0xFF0284C7),
      },
      {
        'value': 'medical',
        'label': T.s('evtAppointment'),
        'icon': Icons.local_hospital,
        'color': const Color(0xFFF43F5E),
      },
      {
        'value': 'task',
        'label': T.s('evttask'),
        'icon': Icons.task_alt,
        'color': const Color(0xFF10B981),
      },
      {
        'value': 'reminder',
        'label': T.s('evtReminder'),
        'icon': Icons.notifications_active,
        'color': const Color(0xFFF59E0B),
      },
      {
        'value': 'personal',
        'label': T.s('evtPersonal'),
        'icon': Icons.person,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'value': 'other',
        'label': T.s('evtOther'),
        'icon': Icons.event,
        'color': const Color(0xFF64748B),
      },
    ];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) => Directionality(
          textDirection: globalLangNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  existingEvent == null
                      ? T.s('addEventTitle')
                      : T.s('editEventTitle'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: T.s('eventName'),
                        prefixIcon: const Icon(
                          Icons.title,
                          color: Color(0xFF6366F1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: T.s('eventDesc'),
                        prefixIcon: const Icon(
                          Icons.notes,
                          color: Color(0xFF6366F1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setDS(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) setDS(() => selectedTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      T.s('eventType'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: typeOptions.map((opt) {
                        final isSelected = selectedType == opt['value'];
                        final color = opt['color'] as Color;
                        return GestureDetector(
                          onTap: () => setDS(
                            () => selectedType = opt['value'] as String,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color
                                  : color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 14,
                                  color: isSelected ? Colors.white : color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(T.s('cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  setState(() {
                    final eventData = {
                      'id':
                          existingEvent?['id'] ??
                          DateTime.now().millisecondsSinceEpoch,
                      'title': titleCtrl.text.trim(),
                      'desc': descCtrl.text.trim(),
                      'date': selectedDate,
                      'time': selectedTime,
                      'type': selectedType,
                    };
                    if (index == null) {
                      globalCalendarEvents.add(eventData);
                    } else {
                      globalCalendarEvents[index] = eventData;
                    }
                  });
                  StorageService.saveCalendarEvents(globalCalendarEvents);
                  Navigator.pop(context);
                },
                child: Text(
                  existingEvent == null ? T.s('add') : T.s('save'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(bool isDark) {
    final now = DateTime.now();
    final headerColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF0284C7);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    // حساب أيام الأسبوع الحالي (من الاثنين إلى الأحد)
    final todayWeekday = _selectedDay.weekday; // 1=Mon..7=Sun
    final weekStart = _selectedDay.subtract(Duration(days: todayWeekday - 1));

    // حساب أيام الشهر الكامل
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    int startWeekday = firstDay.weekday;
    final totalCells = startWeekday - 1 + lastDay.day;
    final rows = (totalCells / 7).ceil();

    // بناء صف واحد (أسبوع) أو كامل الشهر
    Widget buildDayCell(int? dayNum, int col) {
      if (dayNum == null || dayNum < 1 || dayNum > lastDay.day) {
        return Expanded(child: Container(height: 38));
      }
      final thisDay = DateTime(_focusedDay.year, _focusedDay.month, dayNum);
      final isToday =
          thisDay.year == now.year &&
          thisDay.month == now.month &&
          thisDay.day == now.day;
      final isSelected =
          thisDay.year == _selectedDay.year &&
          thisDay.month == _selectedDay.month &&
          thisDay.day == _selectedDay.day;
      final hasEvents = _eventsForDay(thisDay).isNotEmpty;
      final isFriday = col == 4; // العمود الخامس = الجمعة (Mon=0..Sun=6)
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedDay = thisDay),
          child: Container(
            height: 38,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? headerColor
                  : isToday
                  ? headerColor.withOpacity(0.15)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? headerColor
                        : isFriday
                        ? Colors.redAccent.withOpacity(0.8)
                        : textColor,
                  ),
                ),
                if (hasEvents)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : headerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildWeekRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (col) {
          final day = weekStart.add(Duration(days: col));
          // تأكد أن اليوم في نفس الشهر المعروض
          final dayNum = day.month == _focusedDay.month ? day.day : null;
          return buildDayCell(dayNum, col);
        }),
      );
    }

    Widget buildMonthRows() {
      return Column(
        children: List.generate(
          rows,
          (row) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - (startWeekday - 2);
              return buildDayCell(
                (dayNum < 1 || dayNum > lastDay.day) ? null : dayNum,
                col,
              );
            }),
          ),
        ),
      );
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 150 && _isWeekView) {
            // سحب للأسفل → توسيع الشهر
            setState(() => _isWeekView = false);
          } else if (details.primaryVelocity! < -150 && !_isWeekView) {
            // سحب للأعلى → تصغير للأسبوع
            setState(() => _isWeekView = true);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            // رأس التقويم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isWeekView)
                    IconButton(
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () => setState(() => _isWeekView = !_isWeekView),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isWeekView
                              ? '${_monthName(_selectedDay.month)} ${_selectedDay.year}'
                              : '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _isWeekView ? Icons.expand_more : Icons.expand_less,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  if (!_isWeekView)
                    IconButton(
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        ),
                      ),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
            ),
            // أيام الأسبوع (العناوين)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [1, 2, 3, 4, 5, 6, 7]
                    .map(
                      (wd) => Expanded(
                        child: Center(
                          child: Text(
                            _weekdayShort(wd),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: wd == 5
                                  ? Colors.redAccent
                                  : textColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // الأيام (أسبوع أو شهر)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 350),
              crossFadeState: _isWeekView
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: buildWeekRow(),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: buildMonthRows(),
              ),
            ),
            // مؤشر السحب
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEvent(int index) async {
    final event = globalCalendarEvents[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: globalLangNotifier.value == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                T.s('deleteEventConfirmTitle'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            T.s('deleteEventConfirmMsg'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(T.s('cancel')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                T.s('deleteConfirmYes'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      setState(() {
        globalTrash.add({
          'type': T.s('typeCalendar'),
          'title': event['title'],
          'data': Map<String, dynamic>.from(event),
        });
        globalCalendarEvents.removeAt(index);
      });
      StorageService.saveCalendarEvents(globalCalendarEvents);
      StorageService.saveTrash(globalTrash);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ ${event['title']}'),
            action: SnackBarAction(
              label: T.s('restore'),
              onPressed: () {
                setState(() {
                  final restored = globalTrash.lastWhere(
                    (e) => e['title'] == event['title'],
                    orElse: () => {},
                  );
                  if (restored.isNotEmpty) {
                    globalCalendarEvents.add(restored['data']);
                    globalTrash.remove(restored);
                    StorageService.saveCalendarEvents(globalCalendarEvents);
                    StorageService.saveTrash(globalTrash);
                  }
                });
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index, bool isDark) {
    final color = _eventTypeColor(event['type'] ?? 'other');
    final icon = _eventTypeIcon(event['type'] ?? 'other');
    final timeOfDay = event['time'] as TimeOfDay;
    final timeStr =
        '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
    final bool isDone = event['isDone'] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDone
            ? (isDark ? const Color(0xFF1A2535) : const Color(0xFFF8FAF8))
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isDone ? Colors.green.shade400 : color,
            width: 4,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: GestureDetector(
          onTap: () {
            setState(() => globalCalendarEvents[index]['isDone'] = !isDone);
            StorageService.saveCalendarEvents(globalCalendarEvents);
            if (!isDone) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${event['title']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDone ? Colors.green.shade400 : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? Colors.green.shade400 : color,
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Icon(icon, color: color, size: 16),
          ),
        ),
        title: Text(
          event['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDone
                ? (isDark ? Colors.white38 : Colors.grey.shade500)
                : (isDark ? Colors.white : const Color(0xFF1E293B)),
            decoration: isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.green.shade400,
            decorationThickness: 2.5,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((event['desc'] as String).isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                event['desc'],
                style: TextStyle(
                  fontSize: 11,
                  color: isDone
                      ? (isDark ? Colors.white24 : Colors.grey.shade400)
                      : (isDark ? Colors.white54 : Colors.grey.shade600),
                  decoration: isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.grey.shade400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: isDone ? Colors.green.shade400 : color,
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDone ? Colors.green.shade400 : color,
                    fontWeight: FontWeight.bold,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green.withOpacity(0.1)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isDone
                        ? T.s('eventDone')
                        : _eventTypeLabel(event['type'] ?? 'other'),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDone ? Colors.green.shade600 : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDone)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: color, size: 18),
                onPressed: () =>
                    _openAddEventDialog(existingEvent: event, index: index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: T.s('edit'),
              ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 18,
              ),
              onPressed: () => _confirmDeleteEvent(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: T.s('delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedEvents = _eventsForDay(_selectedDay);
    final upcomingEvents = _upcomingEvents();
    final now = DateTime.now();
    final isSelectedToday =
        _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicatorColor: const Color(0xFF6366F1),
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: T.s('calendarWidget')),
                Tab(text: T.s('upcoming')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMiniCalendar(isDark),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          T.s('addEvent'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _openAddEventDialog(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSelectedToday
                                ? T.s('eventsToday')
                                : '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedEvents.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${selectedEvents.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (selectedEvents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                T.s('noEvents'),
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      else
                        ...selectedEvents.asMap().entries.map((entry) {
                          final globalIndex = globalCalendarEvents.indexWhere(
                            (e) => e['id'] == entry.value['id'],
                          );
                          return _buildEventCard(
                            entry.value,
                            globalIndex,
                            isDark,
                          );
                        }).toList(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                upcomingEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              T.s('noEventsMonth'),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                T.s('addEvent'),
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _openAddEventDialog(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: upcomingEvents.length,
                        itemBuilder: (context, index) {
                          final event = upcomingEvents[index];
                          final globalIndex = globalCalendarEvents.indexWhere(
                            (e) => e['id'] == event['id'],
                          );
                          final eventDate = event['date'] as DateTime;
                          final isEventToday =
                              eventDate.year == now.year &&
                              eventDate.month == now.month &&
                              eventDate.day == now.day;
                          final isTomorrow =
                              eventDate
                                  .difference(
                                    DateTime(now.year, now.month, now.day),
                                  )
                                  .inDays ==
                              1;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0 ||
                                  _eventsForDay(
                                    upcomingEvents[index - 1]['date']
                                        as DateTime,
                                  ).isEmpty ||
                                  !(eventDate.year ==
                                          (upcomingEvents[index - 1]['date']
                                                  as DateTime)
                                              .year &&
                                      eventDate.month ==
                                          (upcomingEvents[index - 1]['date']
                                                  as DateTime)
                                              .month &&
                                      eventDate.day ==
                                          (upcomingEvents[index - 1]['date']
                                                  as DateTime)
                                              .day))
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 8,
                                    top: index == 0 ? 0 : 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isEventToday
                                              ? const Color(0xFF6366F1)
                                              : isTomorrow
                                              ? const Color(0xFF10B981)
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          isEventToday
                                              ? T.s('today')
                                              : isTomorrow
                                              ? T.s('tomorrow')
                                              : '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isEventToday || isTomorrow
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildEventCard(event, globalIndex, isDark),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
