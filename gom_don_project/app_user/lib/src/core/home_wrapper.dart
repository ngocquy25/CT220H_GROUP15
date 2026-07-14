import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/search_food/search_food_screen.dart';
import '../features/order_history/order_history_screen.dart';
import '../features/profile/profile_screen.dart';
import 'app_colors.dart';
import 'app_routes.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onSearchTapped: () => _onItemTapped(1)),
    const SearchFoodScreen(),
    const SizedBox(), // Placeholder cho nút Gom Đơn (push modal/screen riêng)
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Nhấn vào nút "Gom Đơn" giữa màn hình
      // Tạm thời push sang RoomDetail hoặc Cart (tuỳ luồng)
      Navigator.pushNamed(context, AppRoutes.roomDetail);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          border: Border(top: BorderSide(color: AppColors.primaryDark.withOpacity(0.08))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Trang chủ'),
                _buildNavItem(1, Icons.search_outlined, Icons.search, 'Tìm kiếm'),
                _buildPrimaryNavItem(2, Icons.restaurant_menu, 'Gom Đơn'),
                _buildNavItem(3, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Đơn hàng'),
                _buildNavItem(4, Icons.person_outline, Icons.person, 'Cá nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.primaryDark.withOpacity(0.35);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? filledIcon : outlineIcon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.primaryDark.withOpacity(0.4),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryNavItem(int index, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
