import 'package:different/db/drive_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'sum.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE drives(id INTEGER PRIMARY KEY, distance INTEGER, how_many INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertDrive(Drive drive) async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'drives',
      drive.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Drive>> Drives() async {
    // Get a reference to the database.
    final Database db = await initializeDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('drives');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Drive(
        id: maps[i]['id'],
        distance: maps[i]['distance'],
        how_many: maps[i]['how_many'],
      );
    });
  }


}