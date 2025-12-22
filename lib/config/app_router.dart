import 'package:go_router/go_router.dart';
import 'package:time_trace/config/animation/extension/slide_in_transition.dart';
import 'package:time_trace/view/bottom_nav_bar.dart';
import 'package:time_trace/view/pages/category_page.dart';
import 'package:time_trace/view/pages/home_page.dart';
import 'package:time_trace/view/pages/report_page.dart';
import 'package:time_trace/view/pages/settings_page.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      ShellRoute(
        routes: [
          GoRoute(
            path: "/",
            pageBuilder:
                (context, state) => HomePage().slideInTransition(state),
          ),
          GoRoute(
            path: "/category",
            pageBuilder:
                (context, state) => CategoryPage().slideInTransition(state),
          ),
          GoRoute(
            path: "/report",
            pageBuilder:
                (context, state) => ReportPage().slideInTransition(state),
          ),
          GoRoute(
            path: "/settings",
            pageBuilder:
                (context, state) => SettingsPage().slideInTransition(state),
          ),
        ],
        builder: (context, state, child) => BottomNavBar(child: child),
      ),
    ],
  );
}
