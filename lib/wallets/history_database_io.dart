import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<(DatabaseFactory, String)> historyDatabase() async => (
  databaseFactoryIo,
  p.join((await getApplicationSupportDirectory()).path, 'history.db'),
);
