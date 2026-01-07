/*
  文件：screens/profile_screen.dart
  说明：
  - 个人/宠物资料页：支持动态高度 Header，防止溢出。
  - 采用 SliverToBoxAdapter 承载资料内容，使其高度随内容自动撑开。
  - 包含 Timeline（动态）与 Moments（相册）两个 Tab。

  架构变更（v2.0）：
  - 从 AppState 迁移到专用 Providers
  - UserProvider: 用户登录状态和登出
  - PetProvider: 宠物资料管理
  - CurrencyProvider: Treats 余额显示

  优化（v2.5）：
  - 组件化重构，提取为可复用组件：
    - ProfileHeader: 头像、名字、徽章
    - ProfileInfoCard: 品种、性别、个性签名
    - TimelineItem: 时间线条目
    - BornMilestone: 出生里程碑
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import '../providers/user_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/mock_data.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/profile/timeline_item.dart';
import '../widgets/profile/born_milestone.dart';
import '../core/extensions/date_extensions.dart';

class ProfileScreen extends StatefulWidget {
  final Pet? pet;
  const ProfileScreen({super.key, this.pet});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Pet? _displayPet;
  late bool _isOwner;
  late bool _isGuestSelf;

  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.pet != null) {
        _isFollowing = widget.pet!.isFollowing;
    }
  }

  // --- Utility Methods ---

  /// 计算年龄 - 使用 DateExtension
  String _calculateAge(String birthDate) {
    try {
      return DateTime.parse(birthDate).calculateAge();
    } catch (e) {
      return "N/A";
    }
  }

  /// 计算特定日期的年龄 - 使用 DateExtension
  String _calculateAgeAtDate(String birthDate, String targetDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final target = DateTime.parse(targetDate);
      return birth.calculateAgeAt(target);
    } catch (e) {
      return "";
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Small delay to ensure any modal animations complete
    await Future.delayed(const Duration(milliseconds: 300));

    if (!context.mounted) return;

    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();

    // Perform logout - await both to ensure clean state
    await userProvider.logout();
    await authProvider.signOut();

    // Navigate to login screen
    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Remove all previous routes
    );
  }

  void _showSettings(BuildContext context) {
    final petProvider = context.read<PetProvider>();
    final nameCtrl = TextEditingController(text: petProvider.currentPet.name);
    final bioCtrl = TextEditingController(text: petProvider.currentPet.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Pet Name",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () { petProvider.updatePetProfile(nameCtrl.text, bioCtrl.text); Navigator.pop(ctx); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Close modal first
                Navigator.pop(ctx);
                // Then call logout with the parent context
                _handleLogout(context);
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      // Dispose controllers when modal closes
      nameCtrl.dispose();
      bioCtrl.dispose();
    });
  }


  @override
  Widget build(BuildContext context) {
    // Performance optimization: Use select() instead of watch()
    // Only rebuild when specific fields change, not entire provider
    final currentUser = context.select<UserProvider, UserProfile?>((p) => p.currentUser);
    final currentPet = context.select<PetProvider, Pet>((p) => p.currentPet);

    // Determine context (My Profile vs Other Profile)
    if (widget.pet != null) {
      _displayPet = widget.pet!;
      _isOwner = false;
      _isGuestSelf = false;
    } else {
      if (currentUser?.type == UserType.GUEST) {
         _isGuestSelf = true;
         _displayPet = null;
         _isOwner = true;
      } else {
         _displayPet = currentPet;
         _isOwner = true;
         _isGuestSelf = false;
      }
    }

    if (_isGuestSelf) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("👻", style: TextStyle(fontSize: 80)),
              Text("Hi, ${currentUser!.name}!", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              TextButton(onPressed: () => _handleLogout(context), child: const Text("Sign Out", style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      );
    }

    final isLocked = !_isOwner && !_isFollowing;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      body: CustomScrollView(
        slivers: [
          // 1. PINNED APP BAR (Action icons only)
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (widget.pet == null) ...[
                Consumer<CurrencyProvider>(
                  builder: (ctx, currencyProvider, _) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4E6), borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(LucideIcons.bone, size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text("${currencyProvider.treats}", style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706), fontSize: 12)),
                    ]),
                  ),
                ),
                IconButton(onPressed: () => _showSettings(context), icon: const Icon(LucideIcons.settings, color: Colors.black87, size: 22)),
              ],
            ],
          ),

          // 2. DYNAMIC HEADER (Auto-sizes based on content)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // 头部组件（头像、名字、徽章）
                  ProfileHeader(
                    pet: _displayPet!,
                    ageText: _calculateAge(_displayPet!.birthDate),
                  ),
                  const SizedBox(height: 16),

                  // 信息卡片组件（品种、性别、个性签名）
                  ProfileInfoCard(pet: _displayPet!),
                  
                  if (!_isOwner)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                        onPressed: () => setState(() => _isFollowing = !_isFollowing),
                        style: ElevatedButton.styleFrom(backgroundColor: _isFollowing ? Colors.grey.shade200 : Colors.orange.shade600, foregroundColor: _isFollowing ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                        child: Text(_isFollowing ? "Following" : "Follow", style: const TextStyle(fontWeight: FontWeight.bold)),
                      )),
                    ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(height: 40, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.clock, size: 14), SizedBox(width: 6), Text("Timeline")])),
                          Tab(height: 40, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.image, size: 14), SizedBox(width: 6), Text("Moments")])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. TAB CONTENT
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 时间线 Tab
                Container(
                  color: const Color(0xFFFEF3C7),
                  child: Builder(
                    builder: (context) {
                      final posts = MockData.posts.where((p) => p.authorId == _displayPet!.id).toList();
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          // 使用组件化的 TimelineItem
                          ...posts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final post = entry.value;
                            final isLast = index == posts.length - 1;
                            return TimelineItem(
                              post: post,
                              ageAtPost: _calculateAgeAtDate(_displayPet!.birthDate, post.date),
                              isLast: isLast,
                            );
                          }),
                          // 出生里程碑组件
                          BornMilestone(petName: _displayPet!.name),
                        ],
                      );
                    },
                  ),
                ),
                // 相册 Tab
                isLocked
                  ? const Center(child: Text("Follow to unlock moments!"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: MockData.moments.length,
                      itemBuilder: (ctx, i) => ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(MockData.moments[i].mediaUrl, fit: BoxFit.cover)),
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }
}