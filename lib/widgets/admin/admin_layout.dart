/// Widget Layout wrapper untuk Admin Area
/// Menyediakan struktur Header + Sidebar + Content yang konsisten
/// Responsive: drawer untuk mobile, sidebar tetap untuk desktop
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/admin_constants.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatefulWidget {
  final String currentRoute;
  final Widget child;

  // Breakpoint untuk responsive
  static const double mobileBreakpoint = 900;

  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AdminLayout.mobileBreakpoint;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundGreen,
          // Drawer untuk mobile
          drawer: isMobile
              ? Drawer(
                  child: AdminSidebar(
                    currentRoute: widget.currentRoute,
                    isMobile: true,
                  ),
                )
              : null,
          body: Column(
            children: [
              // Top Header dengan burger menu untuk mobile
              AdminHeader(
                showMenuButton: isMobile,
                onMenuPressed: isMobile
                    ? () => _scaffoldKey.currentState?.openDrawer()
                    : null,
              ),
              // Body dengan Sidebar (desktop) atau tanpa (mobile)
              Expanded(
                child: Row(
                  children: [
                    // Sidebar hanya untuk desktop
                    if (!isMobile)
                      AdminSidebar(
                        currentRoute: widget.currentRoute,
                        isMobile: false,
                      ),
                    // Main Content Area
                    Expanded(
                      child: Container(
                        color: AppColors.backgroundGreen,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AdminConstants.maxContentWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 16 : 32),
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
