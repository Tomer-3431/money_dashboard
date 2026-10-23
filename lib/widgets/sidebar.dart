import 'package:flutter/material.dart';
import 'package:money_dashboard/entries/entries_table_screen.dart';
import 'package:money_dashboard/goals/goals_container.dart';
import 'package:money_dashboard/home/home_container.dart';
import 'package:money_dashboard/home/mock_data.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Hello Tomer',
                    style: TextTheme.of(context).headlineLarge,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            _navRow(
              icon: Icons.home_outlined,
              label: 'Main Dashboard',
              destination: HomeContainer(),
            ),
            _navRow(
              icon: Icons.flag_outlined, 
              label: 'Goals', 
              destination: GoalsContainer()
            ),
            _navRow(
              icon: Icons.trending_up_outlined, 
              label: 'Income', 
              destination: EntriesTableScreen(isIncome: true, entries: kMockEntries)
            ),
            _navRow(
              icon: Icons.trending_down_outlined, 
              label: 'Debt', 
              destination: EntriesTableScreen(isIncome: false, entries: kMockEntries)
            ),
            _navRow(
              icon: Icons.settings_outlined, 
              label: 'Settings', 
              destination: Container()
            ),
          ],
        ),
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String label,
    required Widget destination,
  }) => GestureDetector(
    onTap: () =>
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination)),
    child: Row(
      spacing: 5,
      children: [
        Icon(icon),
        Text(label),
        Expanded(
          child: Row(
            mainAxisAlignment: .end,
            children: [Icon(Icons.arrow_forward_ios)],
          ),
        ),
      ],
    ),
  );
}