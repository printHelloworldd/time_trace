import 'package:get_it/get_it.dart';
import 'package:time_trace/service/activity_service.dart';
import 'package:time_trace/service/category_service.dart';
import 'package:time_trace/service/csv_service.dart';
import 'package:time_trace/view_model/activity_view_model.dart';
import 'package:time_trace/service/hive_storage.dart';
import 'package:time_trace/service/local_storage.dart';
import 'package:time_trace/service/relational_database.dart';
import 'package:time_trace/view_model/category_view_model.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await _initLocalStorage();

  _registerServices();
  _registerViewModels();
}

Future<void> _initLocalStorage() async {
  final localStorage = HiveStorage();
  // final localStorage = SharedPrefsStorage();

  await localStorage.init();

  getIt.registerSingleton<LocalStorage>(localStorage);

  final database = RelationalDatabase();
  getIt.registerSingleton<RelationalDatabase>(database);
}

void _registerServices() {
  getIt.registerLazySingleton<ActivityService>(
    () => ActivityService(database: getIt<RelationalDatabase>()),
  );

  getIt.registerLazySingleton<CategoryService>(
    () => CategoryService(database: getIt<RelationalDatabase>()),
  );

  getIt.registerLazySingleton<CsvService>(
    () => CsvService(
      activityService: getIt<ActivityService>(),
      categoryService: getIt<CategoryService>(),
    ),
  );
}

void _registerViewModels() {
  getIt.registerFactory<ActivityViewModel>(
    () => ActivityViewModel(activityService: getIt<ActivityService>()),
  );

  getIt.registerFactory<CategoryViewModel>(
    () => CategoryViewModel(categoryService: getIt<CategoryService>()),
  );
}
