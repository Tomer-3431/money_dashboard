import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/entries/entries_table_screen.dart';
import 'package:money_dashboard/goals/goals_container.dart';
import 'package:money_dashboard/home/home_container.dart';
import 'package:money_dashboard/investments/investments_container.dart';
// import 'theme_constants.dart';

class SidebarItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget? destination;

  const SidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.destination,
  });
}

const _sidebarItems = [
  SidebarItem(id: 'home', label: 'Main Dashboard', icon: Icons.home_outlined, destination: HomeContainer()),
  SidebarItem(id: 'goals', label: 'Goals', icon: Icons.flag_outlined, destination: GoalsContainer()),
  SidebarItem(id: 'income', label: 'Incomes', icon: Icons.trending_up_outlined, destination: EntriesTableScreen(isIncome: true)),
  SidebarItem(id: 'spend', label: 'Spends', icon: Icons.trending_down_outlined, destination: EntriesTableScreen(isIncome: false)),
  SidebarItem(id: 'investments', label: 'Investments', icon: Icons.show_chart_outlined, destination: InvestmentsContainer())
];

const String title = 'Hello Tomer';
const String version = '0.1.0'; // TODO: map to real pubspec

class Sidebar extends StatefulWidget {
  final String activeTabId;

  const Sidebar({
    super.key,
    required this.activeTabId,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  void onTabSelect(SidebarItem item) {
    if (item.destination == null) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => item.destination!));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 320,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.lg),
        ), // Fully curved rounded rectangular box
        border: Border(right: BorderSide(color: colors.border, width: 1)),
        boxShadow: AppShadows.card(
          context,
        ), // Uses your smooth design system shadow
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BRAND HEADER
                _buildHeader(colors),

                // 2. NAVIGATION DESTINATIONS (7-8 items optimized for vertical space)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    children: _sidebarItems.map((item) {
                      final isActive = widget.activeTabId == item.id;
                      return _buildNavItem(context, item, isActive);
                    }).toList(),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 6,
              top: 2,
              child: Text(version, style: context.label,)
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Text(title, style: context.h1),
    );
  }

  Widget _buildNavItem(BuildContext context, SidebarItem item, bool isActive) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: '',
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            onTap: () => onTabSelect(item),
            borderRadius: AppRadius.mdAll,
            hoverColor: colors.hover,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10, // Compact height spacing to fit 7-8 items neatly
              ),
              decoration: BoxDecoration(
                color: isActive ? colors.primaryLight : Colors.transparent,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: isActive ? colors.primary : colors.textSecondary,
                  ),

                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: context.standard.copyWith(
                        color: isActive ? colors.primary : colors.text,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: .end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: isActive
                              ? colors.primary
                              : colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
