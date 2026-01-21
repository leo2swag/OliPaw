/*
  文件：core/constants/app_strings.dart
  说明：
  - 应用文本字符串集中管理
  - 支持未来国际化 (i18n)
  - 所有硬编码文本应使用此文件中的常量

  v3.3 - 创建集中化字符串管理系统

  使用方式：
  ```dart
  // 之前：硬编码文本
  Text("Community Barks")

  // 现在：使用常量
  Text(AppStrings.communityBarks)
  ```
*/

/// 应用文本字符串常量
///
/// 按功能模块组织，方便未来国际化
class AppStrings {
  AppStrings._(); // 私有构造函数，禁止实例化

  // ========================================
  // 通用 (Common)
  // ========================================
  static const String appName = 'OlliePaw';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String submit = 'Submit';
  static const String continue_ = 'Continue';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String search = 'Search';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';

  // ========================================
  // 导航 (Navigation)
  // ========================================
  static const String home = 'Home';
  static const String explore = 'Explore';
  static const String community = '社区';
  static const String care = 'Care';
  static const String profile = 'Profile';
  static const String settings = 'Settings';

  // ========================================
  // 认证 (Authentication)
  // ========================================
  static const String login = 'Log In';
  static const String logout = 'Log Out';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // ========================================
  // 个人资料 (Profile)
  // ========================================
  static const String petName = 'Pet Name';
  static const String breed = 'Breed';
  static const String bio = 'Bio';
  static const String birthDate = 'Birth Date';
  static const String gender = 'Gender';
  static const String weight = 'Weight';
  static const String age = 'Age';
  static const String saveChanges = 'Save Changes';
  static const String editProfile = 'Edit Profile';
  static const String timeline = 'Timeline';
  static const String moments = 'Moments';
  static const String follow = 'Follow';
  static const String following = 'Following';
  static const String followers = 'Followers';

  // ========================================
  // 发帖 (Posts)
  // ========================================
  static const String createPost = 'Create Post';
  static const String whatsOnYourMind = "What's on your mind?";
  static const String addPhoto = 'Add Photo';
  static const String selectCategory = 'Select Category';
  static const String selectMood = 'Select Mood';
  static const String writeCaption = 'Write a caption...';
  static const String post = 'Post';
  static const String communityBarks = 'Community Barks';
  static const String likes = 'Likes';
  static const String comments = 'Comments';
  static const String share = 'Share';

  // ========================================
  // 类别 (Categories)
  // ========================================
  static const String categoryPics = 'Pics';
  static const String categorySleep = 'Sleep';
  static const String categoryWalk = 'Walk';
  static const String categoryPlay = 'Play';
  static const String clearFilters = 'Clear Filters';

  // ========================================
  // 心情 (Moods)
  // ========================================
  static const String moodHappy = 'Happy';
  static const String moodExcited = 'Excited';
  static const String moodCalm = 'Calm';
  static const String moodPlayful = 'Playful';
  static const String moodSleepy = 'Sleepy';
  static const String moodEnergetic = 'Energetic';
  static const String moodLove = 'Love';

  // ========================================
  // 每日挑战 (Daily Challenge)
  // ========================================
  static const String dailyChallenge = 'Daily Challenge';
  static const String reward = 'Reward';
  static const String treats = 'Treats';
  static const String completeChallenge = 'Complete Challenge';

  // ========================================
  // SOS & 广播 (SOS & Broadcast)
  // ========================================
  static const String sos = 'SOS';
  static const String postSOS = 'Post SOS Alert';
  static const String sosAlert = '🆘 Post SOS Alert';
  static const String lostPet = 'Lost Pet';
  static const String petFound = 'Pet Found';
  static const String submitClue = 'Submit Clue';
  static const String clues = 'Clues';
  static const String cluesReported = 'Clues Reported';
  static const String lastSeen = 'Last Seen';
  static const String location = 'Location';
  static const String distance = 'Distance';
  static const String expandSearch = 'Expand Search';
  static const String searchRadius = 'Search Radius';

  // 广播类型
  static const String broadcast = 'Broadcast';
  static const String communityBroadcasts = '📢 Community Broadcasts';
  static const String broadcastTypes = 'Broadcast Types';
  static const String sosType = 'SOS';
  static const String dangerType = 'Danger';
  static const String socialType = 'Social';
  static const String marketplaceType = 'Marketplace';

  // 广播描述
  static const String sosDesc = 'Emergency alerts (Free)';
  static const String dangerDesc = 'Safety warnings (Free)';
  static const String socialDesc = 'Events & meetups (50 Treats)';
  static const String marketplaceDesc = 'Free items & deals (50 Treats)';

  // ========================================
  // 创建内容 (Create Content)
  // ========================================
  static const String whatToShare = 'What do you want to share?';
  static const String moment = 'Moment';
  static const String momentDesc = 'Share a photo or update';
  static const String broadcastDesc = 'Announce to community';
  static const String chooseBroadcastType = 'Choose broadcast type:';

  // ========================================
  // 健康照护 (Health & Care)
  // ========================================
  static const String health = 'Health';
  static const String healthRecords = 'Health Records';
  static const String vaccinations = 'Vaccinations';
  static const String vaccineRecords = 'Vaccine Records';
  static const String addVaccine = 'Add Vaccine';
  static const String vaccineName = 'Vaccine Name';
  static const String vaccineDate = 'Vaccine Date';
  static const String nextDue = 'Next Due';
  static const String weightTracking = 'Weight Tracking';
  static const String addWeight = 'Add Weight';
  static const String currentWeight = 'Current Weight';
  static const String weightHistory = 'Weight History';
  static const String vetVisits = 'Vet Visits';
  static const String medications = 'Medications';
  static const String careCenter = 'Care Center';
  static const String healthTrack = 'Health Track';
  static const String overdue = 'Overdue';
  static const String upToDate = 'Up to date';
  static const String vet = 'Vet';

  // ========================================
  // 社区功能 (Community Features)
  // ========================================
  static const String nearbySOS = 'Nearby SOS';
  static const String funLabs = 'Fun Labs';
  static const String growthPredictor = 'Growth Predictor';
  static const String barkTranslator = 'Bark Translator';
  static const String suggestedPals = 'Suggested Pals';
  static const String seeAll = 'See All';
  static const String nearby = 'Nearby';
  static const String searchFriends = 'Search Friends';
  static const String enterPetName = 'Enter pet name...';
  static const String noLostPetsNearby = 'No lost pets nearby - all safe! 🎉';

  // ========================================
  // 签到 & 奖励 (Check-in & Rewards)
  // ========================================
  static const String checkIn = 'Check In';
  static const String dailyCheckIn = 'Daily Check-In';
  static const String streak = 'Streak';
  static const String days = 'days';
  static const String earnedTreats = 'Earned Treats';
  static const String treatsBalance = 'Treats Balance';

  // ========================================
  // 空状态 (Empty States)
  // ========================================
  static const String noPosts = 'No posts yet';
  static const String noPostsDesc = 'Share your first moment!';
  static const String noMoments = 'No moments yet';
  static const String noMomentsDesc = 'Create your first memory';
  static const String noComments = 'No comments yet';
  static const String noCommentsDesc = 'Be the first to comment';
  static const String noClues = 'No clues reported';
  static const String noCluesDesc = 'Submit a clue if you\'ve seen this pet';
  static const String noBroadcasts = 'No broadcasts yet...';
  static const String noSOS = 'No SOS alerts nearby';
  static const String noSOSDesc = 'All pets are safe!';
  static const String noResults = 'No results found';
  static const String noResultsDesc = 'Try a different search';
  static const String momentsLocked = 'Moments Locked';
  static const String momentsLockedDesc = 'Follow to unlock their moments';

  // ========================================
  // 错误 & 验证 (Errors & Validation)
  // ========================================
  static const String error = 'Error';
  static const String errorOccurred = 'An error occurred';
  static const String tryAgain = 'Please try again';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String fieldRequired = 'This field is required';
  static const String loginFailed = 'Login failed';
  static const String signUpFailed = 'Sign up failed';
  static const String networkError = 'Network error. Check your connection.';
  static const String notEnoughTreats = 'Not enough Treats!';

  // ========================================
  // 成功消息 (Success Messages)
  // ========================================
  static const String success = 'Success';
  static const String postCreated = 'Post created successfully!';
  static const String profileUpdated = 'Profile updated!';
  static const String commentAdded = 'Comment added!';
  static const String clueSubmitted = 'Clue submitted successfully!';
  static const String sosCreated = 'SOS alert created!';
  static const String broadcastCreated = 'Broadcast sent!';
  static const String feedRefreshed = 'Feed refreshed! 🎉';
  static const String checkInSuccess = 'Check-in successful!';

  // ========================================
  // 确认对话框 (Confirmation Dialogs)
  // ========================================
  static const String confirmDelete = 'Confirm Delete';
  static const String deletePostConfirm = 'Are you sure you want to delete this post?';
  static const String deleteCommentConfirm = 'Are you sure you want to delete this comment?';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String cancelPostConfirm = 'Discard this post?';
  static const String unsavedChanges = 'You have unsaved changes';

  // ========================================
  // 时间 (Time)
  // ========================================
  static const String justNow = 'Just now';
  static const String minutesAgo = 'minutes ago';
  static const String hoursAgo = 'hours ago';
  static const String daysAgo = 'days ago';
  static const String weeksAgo = 'weeks ago';
  static const String monthsAgo = 'months ago';
  static const String yearsAgo = 'years ago';

  // 星期
  static const List<String> weekdays = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
    'FRIDAY', 'SATURDAY', 'SUNDAY'
  ];

  // 月份
  static const List<String> months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  // ========================================
  // AI 功能 (AI Features)
  // ========================================
  static const String aiAssistant = 'AI Assistant';
  static const String askQuestion = 'Ask a question...';
  static const String generatingCaption = 'Generating caption...';
  static const String analyzing = 'Analyzing...';
  static const String analyzingBreedData = 'Analyzing breed data...';
  static const String thinking = 'Thinking...';
  static const String predictingFuture = 'Predicting future...';
  static const String consultingCrystalBall = 'Consulting the crystal ball 🔮';
  static const String translatingBark = 'Translating bark...';
  static const String listeningToDog = 'Listening to your dog 🎧';
  static const String futureRevealed = 'Future Revealed';
  static const String cute = 'Cute!';
  static const String drAiDailyTip = "Dr. AI's Daily Tip";
  static const String pawpalAi = 'PawPal AI';
  static const String aiVetAssistant = 'Your AI Vet Assistant';
  static const String uploadMedia = 'Upload Media';
  static const String uploadPhoto = 'Upload Photo';
  static const String uploadVideo = 'Upload Video';
  static const String sharePhotoWithPawpal = 'Share a photo with PawPal';
  static const String shareVideoWithPawpal = 'Share a video with PawPal';
  static const String pawpalThinking = 'PawPal is thinking...';
  static const String readyToSend = 'Ready to send';
  static const String askDrPawpal = 'Ask Dr. PawPal...';

  // ========================================
  // 欢迎语 (Greetings)
  // ========================================
  static const String welcomeBack = 'Welcome back';
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String hello = 'Hello';

  // ========================================
  // 单位 (Units)
  // ========================================
  static const String kg = 'kg';
  static const String lbs = 'lbs';
  static const String km = 'km';
  static const String miles = 'miles';
  static const String years = 'years';
  static const String monthsUnit = 'months';
  static const String weeks = 'weeks';

  // ========================================
  // 按钮标签 (Button Labels)
  // ========================================
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String removePhoto = 'Remove Photo';
  static const String viewProfile = 'View Profile';
  static const String sendMessage = 'Send Message';
  static const String reportIssue = 'Report Issue';
  static const String blockUser = 'Block User';
  static const String sharePost = 'Share Post';
  static const String copyLink = 'Copy Link';

  // ========================================
  // Placeholder 文本 (Placeholder Text)
  // ========================================
  static const String searchPlaceholder = 'Search for pets, users...';
  static const String commentPlaceholder = 'Write a comment...';
  static const String bioPlaceholder = 'Tell us about your pet...';
  static const String captionPlaceholder = 'Write a caption...';
  static const String descriptionPlaceholder = 'Add a description...';
  static const String locationPlaceholder = 'Add location...';

  // ========================================
  // 辅助功能 (Accessibility)
  // ========================================
  static const String settingsAccessibility = 'Settings';
  static const String profilePictureAccessibility = 'Profile picture';
  static const String postImageAccessibility = 'Post image';
  static const String likeButtonAccessibility = 'Like';
  static const String commentButtonAccessibility = 'Comment';
  static const String shareButtonAccessibility = 'Share';
  static const String backButtonAccessibility = 'Back';
  static const String menuButtonAccessibility = 'Menu';

  // ========================================
  // 帮助方法 (Helper Methods)
  // ========================================

  /// 获取时间前缀文本 (例如: "5 minutes ago")
  static String timeAgo(int value, String unit) {
    return '$value $unit';
  }

  /// 获取 Treats 数量文本
  static String treatsCount(int count) {
    return '$count Treats';
  }

  /// 获取距离文本
  static String distanceText(double distance, {String unit = 'km'}) {
    return '${distance.toStringAsFixed(1)} $unit';
  }

  /// 获取体重文本
  static String weightText(double weight, {String unit = 'kg'}) {
    return '$weight $unit';
  }

  /// 获取跟随者数量文本
  static String followersCount(int count) {
    if (count == 1) return '1 follower';
    return '$count followers';
  }

  /// 获取点赞数量文本
  static String likesCount(int count) {
    if (count == 1) return '1 like';
    return '$count likes';
  }

  /// 获取评论数量文本
  static String commentsCount(int count) {
    if (count == 1) return '1 comment';
    return '$count comments';
  }
}
