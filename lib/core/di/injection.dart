import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thought_box/data/repositories/auth_repository.dart';
import 'package:thought_box/data/repositories/currency_repository.dart';
import '../../data/datasources/local/cache_manager.dart';
import '../../data/datasources/remote/currency_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/currency_repository_impl.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/conversion/conversion_bloc.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => FirebaseAuth.instance);

  // Core
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton(() => CacheManager(getIt()));

  // Data sources
  getIt.registerLazySingleton(() => CurrencyApi(getIt()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt(),
      cacheManager: getIt(), // ← Pass CacheManager
    ),
  );
  
  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      currencyApi: getIt(),
      cacheManager: getIt(),
    ),
  );

  // Blocs
  getIt.registerFactory(() => AuthBloc(getIt()));
  getIt.registerFactory(() => ConversionBloc(getIt()));
}