// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_trace/config/app_router.dart';

import 'package:time_trace/injection.dart';
import 'package:time_trace/config/theme/app_theme.dart';
import 'package:time_trace/view_model/activity_view_model.dart';
import 'package:time_trace/view_model/category_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection
  await setupDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<ActivityViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<CategoryViewModel>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.buildTheme(AppTheme.lightTheme),
        darkTheme: AppThemeData.buildTheme(AppTheme.darkTheme),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter().router,
      ),
    );
  }
}
