import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('vi')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get languageCode => locale.languageCode == 'vi' ? 'vi' : 'en';

  String t(String key) {
    return _strings[languageCode]?[key] ?? _strings['en']?[key] ?? key;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _strings = {
  'en': {
    'app.title': 'Ningyou',
    'common.loading': 'Loading...',
    'common.cancel': 'Cancel',
    'common.skip': 'Skip',
    'common.tryAgain': 'Try again',
    'common.back': 'Back',
    'common.save': 'Save',
    'common.saving': 'Saving...',
    'common.retry': 'Retry',
    'common.deleteChat': 'Delete chat',
    'common.voice': 'Voice',
    'common.send': 'Send',
    'common.public': 'Public',
    'common.private': 'Private',
    'common.ai': 'AI',
    'nav.chats': 'Chats',
    'nav.discover': 'Discover',
    'nav.profile': 'Profile',
    'auth.signInWithGoogle': 'Sign in with Google',
    'auth.signingIn': 'Signing in...',
    'auth.anonymous': 'Continue anonymously',
    'auth.noAccountPrompt': 'No account yet?',
    'auth.signUpEmail': 'Sign up with email',
    'auth.hasEmailAccountPrompt': 'Already have an email account?',
    'auth.signInEmail': 'Sign in with email',
    'auth.signUpTitle': 'Create account',
    'auth.signInTitle': 'Sign in with email',
    'auth.displayNameLabel': 'DISPLAY NAME',
    'auth.displayNameHint': 'Your name',
    'auth.emailLabel': 'EMAIL',
    'auth.emailHint': 'email@example.com',
    'auth.passwordLabel': 'PASSWORD',
    'auth.passwordMinHint': 'At least 8 characters',
    'auth.passwordHint': '••••••••',
    'auth.signUp': 'Sign up',
    'auth.signIn': 'Sign in',
    'auth.signingUp': 'Signing up...',
    'auth.noAccountShort': 'No account yet?',
    'auth.hasAccountShort': 'Already have an account?',
    'auth.terms':
        'By continuing, you agree to Ningyou\'s terms of use\nand privacy policy.',
    'auth.errorEmailRegistered':
        'This email is already registered. Please sign in.',
    'auth.errorInvalidCredentials': 'Email or password is incorrect.',
    'auth.errorPasswordLength': 'Password must be at least 8 characters.',
    'auth.errorCancelled': 'Sign-in was cancelled.',
    'auth.errorNetwork': 'No network connection. Please try again.',
    'auth.errorGeneric': 'Something went wrong. Please try again.',
    'settings.guest': 'Guest',
    'settings.interface': 'Interface',
    'settings.themeSystem': 'System',
    'settings.themeLight': 'Light',
    'settings.themeDark': 'Dark',
    'settings.notifications': 'Notifications',
    'settings.pushNotifications': 'Push notifications',
    'settings.aboutApp': 'About app',
    'settings.version': 'Version',
    'settings.terms': 'Terms of use',
    'settings.privacy': 'Privacy policy',
    'settings.signOut': 'Sign out',
    'settings.tapEditProfile': 'Tap to edit profile',
    'settings.guestMode': 'GUEST MODE',
    'profileEdit.title': 'Edit profile',
    'profileEdit.tapChangePhoto': 'Tap to change photo',
    'profileEdit.displayNameLabel': 'DISPLAY NAME',
    'profileEdit.nameRequired': 'Name cannot be empty.',
    'profileEdit.saveError': 'Save failed. Please try again.',
    'profileEdit.saving': 'Saving...',
    'profileEdit.saveChanges': 'Save changes',
    'characters.title': 'Characters',
    'characters.subtitle': 'Find your next conversation partner',
    'characters.discoverTab': 'Discover',
    'characters.myTab': 'My characters',
    'characters.searchHint': 'Search characters...',
    'characters.loginToCreate': 'Please sign in to create a character',
    'characters.loadError': 'Could not load characters',
    'characters.noResults': 'No results found',
    'characters.empty': 'No characters yet',
    'characters.emptyHint': 'Check back soon for new AI personas',
    'characters.createTitle': 'Create character',
    'characters.createTitleTop': 'Create',
    'characters.createTitleBottom': 'Character',
    'characters.createSubtitle':
        'Design an AI persona with a voice, memory seed, and opening line.',
    'characters.avatarHint': 'Tap to add avatar',
    'characters.avatarOptional': 'Avatar (optional)',
    'characters.nameLabel': 'CHARACTER NAME',
    'characters.nameHint': 'Example: Hana, Levi, Zero Two...',
    'characters.nameValidation': 'Name must be at least 2 characters',
    'characters.descriptionLabel': 'SHORT DESCRIPTION',
    'characters.descriptionHint':
        'A quick introduction shown on character cards.',
    'characters.descriptionHintShort':
        'A one-line summary that appears in the list...',
    'characters.descriptionValidation':
        'Description must be at least 10 characters',
    'characters.systemPromptLabel': 'PERSONALITY & BACKSTORY (SYSTEM PROMPT)',
    'characters.systemPromptHint':
        'Describe how the character speaks, behaves, and what they know.',
    'characters.systemPromptHintLong':
        'Detailed guidance for the AI: who they are, their personality, how they speak...',
    'characters.systemPromptHelper':
        'This guides the AI. Be specific about tone, boundaries, and language.',
    'characters.systemPromptHelperShort':
        'More detail makes the character feel more authentic',
    'characters.systemPromptValidation':
        'System prompt must be at least 20 characters',
    'characters.greetingLabel': 'OPENING GREETING (optional)',
    'characters.greetingHint':
        'What should this character say when a chat starts?',
    'characters.tagsTitle': 'Tags',
    'characters.traitsTitle': 'TRAITS / TAGS (max 5)',
    'characters.tagHint': 'Add tag (e.g. tsundere, fantasy), press Enter...',
    'characters.visibilityTitle': 'Visibility',
    'characters.visibilityPublic': 'Public',
    'characters.visibilityPrivate': 'Private',
    'characters.creating': 'Creating...',
    'characters.createAction': 'Create character',
    'characters.createError': 'Could not create character. Please try again.',
    'characters.about': 'About',
    'characters.greeting': 'Greeting',
    'characters.starting': 'Starting...',
    'characters.startChat': 'Start chat',
    'characters.startChatError': 'Could not start chat. Try again.',
    'chat.composerHint': 'Write a message...',
    'chat.defaultTitle': 'Chat',
    'chat.errorTitle': 'Something went wrong',
    'chat.emptyTitle': 'Start the conversation',
    'chat.emptyHint': 'Send a message and your character will reply here.',
    'chat.emptyGreeting': 'Say hello to start the conversation',
    'chat.messageFailed': 'Message failed. Try again.',
    'chat.typing': 'Typing...',
    'conversations.title': 'Chats',
    'conversations.subtitle': 'Pick up where you left off',
    'conversations.loadError': 'Could not load chats',
    'conversations.emptyTitle': 'No chats yet',
    'conversations.emptyHint': 'Discover a character and start chatting',
    'conversations.justNow': 'Just now',
    'conversations.minutesAgoSuffix': 'm ago',
    'conversations.hoursAgoSuffix': 'h ago',
    'conversations.daysAgoSuffix': 'd ago',
    'design.previewTitle': 'Design system preview',
    'design.previewDescription':
        'Soft literary surfaces, one teal accent, custom brand widgets on a Material 3 base.',
    'design.headerDescription':
        'A quiet kit for long conversations with personas you create.',
    'design.savePersona': 'Save persona',
    'design.personaNameLabel': 'PERSONA NAME',
    'design.personaNameHint': 'e.g. Hayashi the librarian',
    'design.personaBackstoryLabel': 'PERSONA BACKSTORY',
    'design.personaBackstoryHint': 'Describe how this character speaks...',
    'design.favorite': 'Favorite',
    'design.new': 'New',
    'design.online': 'Online',
    'design.beta': 'Beta',
    'design.all': 'All',
    'design.companion': 'Companion',
    'design.tutor': 'Tutor',
    'design.writer': 'Writer',
    'design.samplePersonaName': 'Linh, the patient tutor',
    'design.samplePersonaBio':
        'A patient literature tutor who waits for your draft and reads it twice.',
    'design.samplePersonaTag': 'Tutor',
    'design.sampleChatCount': '2.4k chats',
    'design.chatTitle': 'Bubbles & personas',
    'design.chatDescription':
        'Asymmetric bubbles keep the direction of speech visible without loud chrome.',
    'design.aiMeta': 'Linh - 14:02',
    'design.aiMessage':
        'Hello. Which literature topic would you like to review first?',
    'design.userMeta': '14:02 - You',
    'design.userMessage': 'Literature first, please.',
    'design.toastTitle': 'Persona saved',
    'design.toastMessage': 'Linh is ready for the next conversation.',
  },
  'vi': {
    'app.title': 'Ningyou',
    'common.loading': 'Đang tải...',
    'common.cancel': 'Hủy',
    'common.skip': 'Bỏ qua',
    'common.tryAgain': 'Thử lại',
    'common.back': 'Quay lại',
    'common.save': 'Lưu',
    'common.saving': 'Đang lưu...',
    'common.retry': 'Thử lại',
    'common.deleteChat': 'Xóa trò chuyện',
    'common.voice': 'Ghi âm',
    'common.send': 'Gửi',
    'common.public': 'Công khai',
    'common.private': 'Riêng tư',
    'common.ai': 'AI',
    'nav.chats': 'Trò chuyện',
    'nav.discover': 'Khám phá',
    'nav.profile': 'Hồ sơ',
    'auth.signInWithGoogle': 'Đăng nhập với Google',
    'auth.signingIn': 'Đang đăng nhập...',
    'auth.anonymous': 'Tiếp tục ẩn danh',
    'auth.noAccountPrompt': 'Chưa có tài khoản?',
    'auth.signUpEmail': 'Đăng ký bằng email',
    'auth.hasEmailAccountPrompt': 'Đã có tài khoản email?',
    'auth.signInEmail': 'Đăng nhập bằng email',
    'auth.signUpTitle': 'Đăng ký tài khoản',
    'auth.signInTitle': 'Đăng nhập bằng email',
    'auth.displayNameLabel': 'TÊN HIỂN THỊ',
    'auth.displayNameHint': 'Tên của bạn',
    'auth.emailLabel': 'EMAIL',
    'auth.emailHint': 'email@example.com',
    'auth.passwordLabel': 'MẬT KHẨU',
    'auth.passwordMinHint': 'Tối thiểu 8 ký tự',
    'auth.passwordHint': '••••••••',
    'auth.signUp': 'Đăng ký',
    'auth.signIn': 'Đăng nhập',
    'auth.signingUp': 'Đang đăng ký...',
    'auth.noAccountShort': 'Chưa có tài khoản?',
    'auth.hasAccountShort': 'Đã có tài khoản?',
    'auth.terms':
        'Bằng cách tiếp tục, bạn đồng ý với điều khoản sử dụng\nvà chính sách quyền riêng tư của Ningyou.',
    'auth.errorEmailRegistered':
        'Email này đã được đăng ký. Vui lòng đăng nhập.',
    'auth.errorInvalidCredentials': 'Email hoặc mật khẩu không đúng.',
    'auth.errorPasswordLength': 'Mật khẩu phải có ít nhất 8 ký tự.',
    'auth.errorCancelled': 'Đăng nhập đã bị hủy.',
    'auth.errorNetwork': 'Không có kết nối mạng. Vui lòng thử lại.',
    'auth.errorGeneric': 'Đã xảy ra lỗi. Vui lòng thử lại.',
    'settings.guest': 'Khách',
    'settings.interface': 'Giao diện',
    'settings.themeSystem': 'Hệ thống',
    'settings.themeLight': 'Sáng',
    'settings.themeDark': 'Tối',
    'settings.notifications': 'Thông báo',
    'settings.pushNotifications': 'Thông báo đẩy',
    'settings.aboutApp': 'Về ứng dụng',
    'settings.version': 'Phiên bản',
    'settings.terms': 'Điều khoản sử dụng',
    'settings.privacy': 'Chính sách bảo mật',
    'settings.signOut': 'Đăng xuất',
    'settings.tapEditProfile': 'Chạm để chỉnh sửa hồ sơ',
    'settings.guestMode': 'CHẾ ĐỘ KHÁCH',
    'profileEdit.title': 'Chỉnh sửa hồ sơ',
    'profileEdit.tapChangePhoto': 'Chạm để thay đổi ảnh',
    'profileEdit.displayNameLabel': 'TÊN HIỂN THỊ',
    'profileEdit.nameRequired': 'Tên không được để trống.',
    'profileEdit.saveError': 'Lưu thất bại. Vui lòng thử lại.',
    'profileEdit.saving': 'Đang lưu...',
    'profileEdit.saveChanges': 'Lưu thay đổi',
    'characters.title': 'Nhân vật',
    'characters.subtitle': 'Tìm người bạn trò chuyện tiếp theo',
    'characters.discoverTab': 'Khám phá',
    'characters.myTab': 'Nhân vật của tôi',
    'characters.searchHint': 'Tìm kiếm nhân vật...',
    'characters.loginToCreate': 'Vui lòng đăng nhập để tạo nhân vật',
    'characters.loadError': 'Không thể tải nhân vật',
    'characters.noResults': 'Không tìm thấy kết quả',
    'characters.empty': 'Chưa có nhân vật',
    'characters.emptyHint': 'Hãy quay lại sau để xem persona AI mới',
    'characters.createTitle': 'Tạo nhân vật',
    'characters.createTitleTop': 'Tạo',
    'characters.createTitleBottom': 'Nhân vật',
    'characters.createSubtitle':
        'Thiết kế một persona AI với giọng nói, ký ức nền và lời chào mở đầu.',
    'characters.avatarHint': 'Chạm để thêm avatar',
    'characters.avatarOptional': 'Ảnh đại diện (tuỳ chọn)',
    'characters.nameLabel': 'TÊN NHÂN VẬT',
    'characters.nameHint': 'Ví dụ: Hana, Levi, Zero Two...',
    'characters.nameValidation': 'Tên phải có ít nhất 2 ký tự',
    'characters.descriptionLabel': 'MÔ TẢ NGẮN',
    'characters.descriptionHint':
        'Phần giới thiệu ngắn hiển thị trên thẻ nhân vật.',
    'characters.descriptionHintShort':
        'Một dòng tóm tắt xuất hiện trên danh sách...',
    'characters.descriptionValidation': 'Mô tả phải có ít nhất 10 ký tự',
    'characters.systemPromptLabel': 'TÍNH CÁCH & BỐI CẢNH (SYSTEM PROMPT)',
    'characters.systemPromptHint':
        'Mô tả cách nhân vật nói, hành xử và những gì họ biết.',
    'characters.systemPromptHintLong':
        'Hướng dẫn chi tiết cho AI: Là ai, tính cách ra sao, cách xưng hô...',
    'characters.systemPromptHelper':
        'Phần này định hướng AI. Hãy mô tả rõ giọng điệu, giới hạn và ngôn ngữ.',
    'characters.systemPromptHelperShort':
        'Càng chi tiết, nhân vật càng chân thật',
    'characters.systemPromptValidation':
        'System prompt phải có ít nhất 20 ký tự',
    'characters.greetingLabel': 'LỜI CHÀO MỞ ĐẦU (tuỳ chọn)',
    'characters.greetingHint':
        'Nhân vật sẽ nói gì khi bắt đầu cuộc trò chuyện?',
    'characters.tagsTitle': 'Tags',
    'characters.traitsTitle': 'ĐẶC ĐIỂM / TAGS (tối đa 5)',
    'characters.tagHint': 'Thêm tag (VD: tsundere, fantasy), nhấn Enter...',
    'characters.visibilityTitle': 'Hiển thị',
    'characters.visibilityPublic': 'Công khai',
    'characters.visibilityPrivate': 'Riêng tư',
    'characters.creating': 'Đang tạo...',
    'characters.createAction': 'Tạo nhân vật',
    'characters.createError': 'Tạo nhân vật thất bại. Thử lại nhé.',
    'characters.about': 'Giới thiệu',
    'characters.greeting': 'Lời chào',
    'characters.starting': 'Đang bắt đầu...',
    'characters.startChat': 'Bắt đầu trò chuyện',
    'characters.startChatError': 'Không thể bắt đầu chat. Thử lại nhé.',
    'chat.composerHint': 'Viết tin nhắn...',
    'chat.defaultTitle': 'Trò chuyện',
    'chat.errorTitle': 'Có lỗi xảy ra',
    'chat.emptyTitle': 'Bắt đầu cuộc trò chuyện',
    'chat.emptyHint': 'Gửi một tin nhắn và nhân vật sẽ trả lời ở đây.',
    'chat.emptyGreeting': 'Chào một câu để bắt đầu cuộc trò chuyện',
    'chat.messageFailed': 'Gửi tin nhắn thất bại. Thử lại nhé.',
    'chat.typing': 'Đang nhập...',
    'conversations.title': 'Trò chuyện',
    'conversations.subtitle': 'Tiếp tục những cuộc trò chuyện dang dở',
    'conversations.loadError': 'Không thể tải trò chuyện',
    'conversations.emptyTitle': 'Chưa có cuộc trò chuyện',
    'conversations.emptyHint': 'Khám phá một nhân vật và bắt đầu chat',
    'conversations.justNow': 'Vừa xong',
    'conversations.minutesAgoSuffix': ' phút trước',
    'conversations.hoursAgoSuffix': ' giờ trước',
    'conversations.daysAgoSuffix': ' ngày trước',
    'design.previewTitle': 'Xem trước design system',
    'design.previewDescription':
        'Bề mặt mềm, một màu teal nhấn, bộ widget thương hiệu trên nền Material 3.',
    'design.headerDescription':
        'Một bộ giao diện yên tĩnh cho những cuộc trò chuyện dài với persona bạn tạo.',
    'design.savePersona': 'Lưu persona',
    'design.personaNameLabel': 'TÊN PERSONA',
    'design.personaNameHint': 'VD: Hayashi, thủ thư',
    'design.personaBackstoryLabel': 'BỐI CẢNH PERSONA',
    'design.personaBackstoryHint': 'Mô tả cách nhân vật này trò chuyện...',
    'design.favorite': 'Yêu thích',
    'design.new': 'Mới',
    'design.online': 'Đang online',
    'design.beta': 'Beta',
    'design.all': 'Tất cả',
    'design.companion': 'Bạn đồng hành',
    'design.tutor': 'Gia sư',
    'design.writer': 'Nhà văn',
    'design.samplePersonaName': 'Linh, gia sư kiên nhẫn',
    'design.samplePersonaBio':
        'Một gia sư văn học kiên nhẫn, luôn chờ bản nháp và đọc lại thật kỹ.',
    'design.samplePersonaTag': 'Gia sư',
    'design.sampleChatCount': '2.4k cuộc trò chuyện',
    'design.chatTitle': 'Bong bóng chat & persona',
    'design.chatDescription':
        'Bong bóng bất đối xứng giữ hướng trò chuyện rõ ràng mà không gây ồn.',
    'design.aiMeta': 'Linh - 14:02',
    'design.aiMessage': 'Chào bạn. Hôm nay bạn muốn ôn phần nào trước?',
    'design.userMeta': '14:02 - Bạn',
    'design.userMessage': 'Văn trước nhé.',
    'design.toastTitle': 'Đã lưu persona',
    'design.toastMessage': 'Linh đã sẵn sàng cho cuộc trò chuyện tiếp theo.',
  },
};
