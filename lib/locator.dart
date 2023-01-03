
import 'package:fiverr_signurl_aws/services.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;
void setUp() {

  locator.registerLazySingleton<Services>(
    () => Services(),
  );

}
