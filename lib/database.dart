import 'package:sqflite/sqflite.dart' show Database, getDatabasesPath, openDatabase;
import 'package:path/path.dart' show join;

class Client {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await buildDatabase();

    return _db;
  }

  buildDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "ClientDB.db");   //add path to name  =>    join(str1, str2, str3, ...) == str1/str2/str3/...
    Database myDatabase = await openDatabase(path, onCreate: _onCreate, version: 1);  //, onUpgrade: _onUpgrade
    return myDatabase;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE client (
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT,
        image TEXT
      )
    ''');
  }


  readData(String condition) async {
    String sql = "SELECT * FROM 'client' WHERE $condition";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response;
  }


  insertData(String name, String phone, String image) async {
    String sql = "INSERT INTO 'client' ('name', 'phone', 'image') VALUES (?, ?, ?)";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawInsert(sql, [name, phone, image]);  //response = 0 if it failed
    return response;
  }

  updateData(String condition, String data) async {
    String sql = "UPDATE 'client' SET $data WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawUpdate(sql);
    return response;
  }

  deleteData(String condition) async {
    String sql = "DELETE FROM 'client' WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawDelete(sql);
    return response;
  }
}


class Transactions {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await buildDatabase();

    return _db;
  }

  buildDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "TransactionDB.db");   //add path to name  =>    join(str1, str2, str3, ...) == str1/str2/str3/...
    Database myDatabase = await openDatabase(path, onCreate: _onCreate, version: 1);
    return myDatabase;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE 'Transaction' (
        id INTEGER PRIMARY KEY,
        client INTEGER,
        year INTEGER,
        month INTEGER,
        price REAL,
        deposit REAL,
        plan INTEGER,
        paidmonths INTEGER,
        comment TEXT
      )
    ''');
  }



  readData(String condition) async {
    String sql = "SELECT * FROM 'Transaction' WHERE $condition";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response;
  }


  insertData(int idClient, int startYear, int startMonth,double price, double deposit, int plan, int paidMonths, String comment) async {
    String sql = '''INSERT INTO 'Transaction' ('client', 'year', 'month','price','deposit', 'plan', 'paidmonths','comment') VALUES 
    ($idClient, $startYear, $startMonth, $price, $deposit, $plan, $paidMonths, ?)''';
    Database? myDatabase = await db;
    int response = await myDatabase!.rawInsert(sql, [comment]);  //response = 0 if it failed
    return response;
  }

  updateData(String condition, String data) async {
    String sql = "UPDATE 'Transaction' SET $data WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawUpdate(sql);
    return response;
  }

  deleteData(String condition) async {
    String sql = "DELETE FROM 'Transaction' WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawDelete(sql);
    return response;
  }
}




class Data {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await buildDatabase();

    return _db;
  }

  buildDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "Data.db");   //add path to name  =>    join(str1, str2, str3, ...) == str1/str2/str3/...
    Database myDatabase = await openDatabase(path, onCreate: _onCreate, version: 1);  //, onUpgrade: _onUpgrade
    return myDatabase;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE client (
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT,
        image TEXT
      );
      
      CREATE TABLE 'Transaction' (
        id INTEGER PRIMARY KEY,
        client INTEGER,
        year INTEGER,
        month INTEGER,
        price REAL,
        deposit REAL,
        plan INTEGER,
        paidmonths INTEGER,
        comment TEXT
      )
    ''');
  }
}

