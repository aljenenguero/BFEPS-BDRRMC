import 'package:flutter/material.dart';
import '../screen/riskAssessment/bmap.dart';
import '../screen/riskAssessment/flood_risk_page.dart';
import '/screen/calamity/calamity_page.dart';
import '/screen/dashboard_page.dart';
import '/screen/profiling/household.dart';
import '/screen/profiling/individual.dart';
import '../screen/relief_operation.dart';

class SideBar extends StatelessWidget {
  final bool isProfilingExpanded;
  final bool isRaReportExpanded;
  final String selectedMenu;
  final void Function(String, Widget) onMenuSelect;
  final VoidCallback toggleProfiling;
  final VoidCallback toggleRaReport;

  const SideBar({
    super.key,
    required this.isProfilingExpanded,
    required this.isRaReportExpanded,
    required this.selectedMenu,
    required this.onMenuSelect,
    required this.toggleProfiling,
    required this.toggleRaReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(right: BorderSide(color: Color(0xFFC0C0C0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem(
            icon: 'assets/images/dashboard-icon.png',
            label: 'Dashboard',
            isSelected: selectedMenu == 'Dashboard',
            onTap: () => onMenuSelect('Dashboard', Dashboardpage()),
          ),
          const SizedBox(height: 11),
          GestureDetector(
            onTap: toggleProfiling,
            child: _buildMenuItem(
              icon: 'assets/images/profiling-icon.png',
              label: 'Profiling',
              isSelected: selectedMenu == 'Profiling' || isProfilingExpanded,
              arrowIcon: isProfilingExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (isProfilingExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onMenuSelect('Household List', HouseholdPage()),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Household List',
                        style: TextStyle(
                          color: selectedMenu == 'Household List' ? const Color(0xFF5576F5) : const Color(0xFF9E9E9E),
                          decoration: selectedMenu == 'Household List' ? TextDecoration.underline : TextDecoration.none, // Apply underline when selected
                          decorationColor: selectedMenu == 'Household List' ? const Color(0xFF5576F5) : Colors.transparent, // Set underline color
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onMenuSelect('Individual List', const IndividualPage()),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Individual List',
                        style: TextStyle(
                          color: selectedMenu == 'Individual List' ? const Color(0xFF5576F5) : const Color(0xFF9E9E9E),
                          decoration: selectedMenu == 'Individual List' ? TextDecoration.underline : TextDecoration.none, // Apply underline when selected
                          decorationColor: selectedMenu == 'Individual List' ? const Color(0xFF5576F5) : Colors.transparent, // Set underline color
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 11),
          _buildMenuItem(
            icon: 'assets/images/calamity-icon.png',
            label: 'Calamity',
            isSelected: selectedMenu == 'Calamity',
            onTap: () => onMenuSelect('Calamity', const CalamityPage()),
          ),
          _buildMenuItem(
            icon: 'assets/images/relief-icon.png',
            label: 'Relief Operation',
            isSelected: selectedMenu == 'Relief',
            onTap: () => onMenuSelect('Relief', const ReliefOperationPage()),
          ),
           const SizedBox(height: 11),
          GestureDetector(
            onTap: toggleRaReport,
            child: _buildMenuItem(
              icon: 'assets/images/risk-assessment-icon.png',
              label: 'Risk Assessment',
              isSelected: selectedMenu == 'Risk Assessment' || isRaReportExpanded,
              arrowIcon: isRaReportExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (isRaReportExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onMenuSelect('Flood Risk Reports', FloodRiskReports(onMenuSelect: onMenuSelect)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Flood Risk Reports',
                        style: TextStyle(
                          color: selectedMenu == 'Flood Risk Reports' ? const Color(0xFF5576F5) : const Color(0xFF9E9E9E),
                          decoration: selectedMenu == 'Flood Risk Reports' ? TextDecoration.underline : TextDecoration.none, // Apply underline when selected
                          decorationColor: selectedMenu == 'Flood Risk Reports' ? const Color(0xFF5576F5) : Colors.transparent, // Set underline color
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onMenuSelect('Buenavista Map', Bmap()),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Buenavista Map',
                        style: TextStyle(
                          color: selectedMenu == 'Buenavista Map' ? const Color(0xFF5576F5) : const Color(0xFF9E9E9E),
                          decoration: selectedMenu == 'Buenavista Map' ? TextDecoration.underline : TextDecoration.none, // Apply underline when selected
                          decorationColor: selectedMenu == 'Buenavista Map' ? const Color(0xFF5576F5) : Colors.transparent, // Set underline color
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    IconData? arrowIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? const Color(0xFF5576F5) : Colors.transparent,
          ),
          child: Row(
            children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
                color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
              ),
              const SizedBox(width: 15, height: 40),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                      ),
                      overflow: constraints.maxWidth < 100 ? TextOverflow.ellipsis : null,
                      maxLines: 1,
                    );
                  },
                ),
              ),
              if (arrowIcon != null)
                Icon(
                  arrowIcon,
                  color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
