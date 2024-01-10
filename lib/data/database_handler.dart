import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/tools.dart';
import '../data/array.dart';
import '../model/news_info.dart';
import '../model/category.dart';
import '../model/images.dart';
import '../model/place.dart';

class DatabaseHandler {

  // Database Version
  static const int DATABASE_VERSION = 2;

  // Database Name
  static const String DATABASE_NAME = "the_city.db";

  // Main Table Name
  static const String TABLE_PLACE         = "place";
  static const String TABLE_IMAGES        = "images";
  static const String TABLE_CATEGORY      = "category";
  static const String TABLE_NEWS_INFO     = "news_info";

  // Relational table Place to Category ( N to N )
  static const String TABLE_PLACE_CATEGORY = "place_category";

  // table only for android client
  static const String TABLE_FAVORITES     = "favorites_table";

  // Table Columns names TABLE_PLACE
  static const String KEY_PLACE_ID    = "place_id";
  static const String KEY_NAME        = "name";
  static const String KEY_IMAGE       = "image";
  static const String KEY_ADDRESS     = "address";
  static const String KEY_PHONE       = "phone";
  static const String KEY_WEBSITE     = "website";
  static const String KEY_DESCRIPTION = "description";
  static const String KEY_LNG         = "lng";
  static const String KEY_LAT         = "lat";
  static const String KEY_DISTANCE    = "distance";
  static const String KEY_LAST_UPDATE = "last_update";

  // Table Columns names TABLE_IMAGES
  static const String KEY_IMG_PLACE_ID    = "place_id";
  static const String KEY_IMG_NAME        = "name";

  // Table Columns names TABLE_CATEGORY
  static const String KEY_CAT_ID      = "cat_id";
  static const String KEY_CAT_NAME    = "name";
  static const String KEY_CAT_ICON    = "icon";

  // Table Columns names TABLE_NEWS_INFO
  static const String KEY_NEWS_ID             = "id";
  static const String KEY_NEWS_TITLE          = "title";
  static const String KEY_NEWS_BRIEF_CONTENT  = "brief_content";
  static const String KEY_NEWS_FULL_CONTENT   = "full_content";
  static const String KEY_NEWS_IMAGE          = "image";
  static const String KEY_NEWS_LAST_UPDATE    = "last_update";

  // Table Relational Columns names TABLE_PLACE_CATEGORY
  static const String KEY_RELATION_PLACE_ID = KEY_PLACE_ID;
  static const String KEY_RELATION_CAT_ID = KEY_CAT_ID;

  DatabaseHandler._privateConstructor();


  String sqlCreatePlace = '''
      CREATE TABLE $TABLE_PLACE (
        $KEY_PLACE_ID INTEGER PRIMARY KEY, 
        $KEY_NAME TEXT, 
        $KEY_IMAGE TEXT, 
        $KEY_ADDRESS TEXT, 
        $KEY_PHONE TEXT, 
        $KEY_WEBSITE TEXT, 
        $KEY_DESCRIPTION  TEXT, 
        $KEY_LNG REAL, 
        $KEY_LAT REAL, 
        $KEY_DISTANCE REAL, 
        $KEY_LAST_UPDATE INTEGER 
      )''';

  String sqlCreateImages = '''
      CREATE TABLE $TABLE_IMAGES (
        $KEY_IMG_PLACE_ID INTEGER, 
        $KEY_IMG_NAME TEXT, 
        FOREIGN KEY($KEY_IMG_PLACE_ID) REFERENCES $TABLE_PLACE ($KEY_PLACE_ID)
      )''';

  String sqlCreateCategory = '''
      CREATE TABLE $TABLE_CATEGORY (
        $KEY_CAT_ID INTEGER PRIMARY KEY, 
        $KEY_CAT_NAME TEXT, 
        $KEY_CAT_ICON INTEGER
      )''';

  String sqlCreateFavorites = '''
      CREATE TABLE $TABLE_FAVORITES (
        $KEY_PLACE_ID INTEGER PRIMARY KEY
      )''';

  // Table Relational place_category
  String sqlCreateRelation = '''
      CREATE TABLE $TABLE_PLACE_CATEGORY (
        $KEY_RELATION_PLACE_ID INTEGER,
        $KEY_RELATION_CAT_ID INTEGER 
      )''';

  String sqlCreateNewsInfo = '''
      CREATE TABLE $TABLE_NEWS_INFO (
        $KEY_NEWS_ID INTEGER PRIMARY KEY, 
        $KEY_NEWS_TITLE TEXT, 
        $KEY_NEWS_BRIEF_CONTENT TEXT, 
        $KEY_NEWS_FULL_CONTENT TEXT, 
        $KEY_NEWS_IMAGE TEXT, 
        $KEY_NEWS_LAST_UPDATE INTEGER 
      )''';

  static final DatabaseHandler instance = DatabaseHandler._privateConstructor();

  static Database? _db;
  Future<Database?> get database async {
    if (_db != null) return _db;
    _db = await _initDatabase();
    getCategorySize().then((value) {
      if(value != Array.categories.length){
        defineCategory();
      }
    });
    return _db;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), DATABASE_NAME);
    return await openDatabase(path, version: DATABASE_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    print("_onCreate");
    onCreateTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if(oldVersion < newVersion) onCreateTable(db);
    defineCategory();
  }

  Future onCreateTable(Database db) async {
    var batch = db.batch();
    db.execute("DROP TABLE IF EXISTS $TABLE_PLACE");
    batch.execute(sqlCreatePlace);
    db.execute("DROP TABLE IF EXISTS $TABLE_IMAGES");
    batch.execute(sqlCreateImages);
    db.execute("DROP TABLE IF EXISTS $TABLE_CATEGORY");
    batch.execute(sqlCreateCategory);
    db.execute("DROP TABLE IF EXISTS $TABLE_PLACE_CATEGORY");
    batch.execute(sqlCreateRelation);
    db.execute("DROP TABLE IF EXISTS $TABLE_NEWS_INFO");
    batch.execute(sqlCreateNewsInfo);
    db.execute("DROP TABLE IF EXISTS $TABLE_FAVORITES");
    batch.execute(sqlCreateFavorites);
    await batch.commit();
  }

  // refresh table place and place_category
  Future refreshTablePlace() async {
    Database db = (await instance.database)!;
    var batch = db.batch();
    batch.delete(TABLE_PLACE_CATEGORY);
    batch.delete(TABLE_IMAGES);
    batch.delete(TABLE_PLACE);
    await batch.commit();
  }

  // refresh table place and news_info
  Future refreshTableNewsInfo() async {
    Database db = (await instance.database)!;
    var res = await db.delete(TABLE_NEWS_INFO);
    return res;
  }

  Future defineCategory() async {
    Database db = (await instance.database)!;
    Batch batch = db.batch();
    batch.delete(TABLE_CATEGORY);
    for (Category cat in Array.categories) {
      Map<String, dynamic> map = cat.toJson();
      batch.insert(TABLE_CATEGORY, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Insert List place
  Future insertListPlace(List<Place>? items) async {
    List<Place>? _items = items;
    Database db = (await instance.database)!;
    Batch batch = db.batch();
    _items = Tools.itemsWithDistance(_items);
    for (Place p in _items!) {
      Map<String, dynamic> map = p.toJson();
      map.remove('categories');
      map.remove('images');
      
      // Inserting or Update Row
      batch.insert(TABLE_PLACE, map, conflictAlgorithm: ConflictAlgorithm.replace);
      // clear images
      batch.delete(TABLE_IMAGES, where: '$KEY_IMG_PLACE_ID = ?', whereArgs: [p.placeId]);
      batch.delete(TABLE_PLACE_CATEGORY, where: '$KEY_RELATION_PLACE_ID = ?', whereArgs: [p.placeId]);

      // Insert relational place with category
      for (Category c in p.categories) {
        Map<String, dynamic> placeCategory = {
          KEY_RELATION_PLACE_ID : p.placeId, KEY_RELATION_CAT_ID : c.catId
        };
        batch.insert(TABLE_PLACE_CATEGORY, placeCategory, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Insert Images places
      for (Images i in p.images) {
        batch.insert(TABLE_IMAGES, i.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit();
  }

  // Insert List News Info
  Future insertListNewsInfo(List<NewsInfo> items) async {
    Database db = (await instance.database)!;
    Batch batch = db.batch();
    for (NewsInfo n in items) {
      Map<String, dynamic> map = n.toJson();
      batch.insert(TABLE_NEWS_INFO, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<Place?> getPlace(int? placeId) async {
    Database db = (await instance.database)!;
    List<Map<String, dynamic>> records = await db.query(
        TABLE_PLACE, where: '$KEY_PLACE_ID = ?', whereArgs: [placeId]
    );
    if(records.length <= 0) return null;
    return Place.fromJson(records[0]);
  }

  // Update one place
  Future<Place?> updatePlace(Place place) async {
    List<Place> items = [];
    items.add(place);
    await insertListPlace(items);
    return await getPlace(place.placeId);
  }

  Future<List<Place>> getPlacesByPage(int? catId, int limit, int offset) async{
    Database db = (await instance.database)!;
    List<Place> result = [];
    String query;
    query = "SELECT p.* FROM $TABLE_PLACE p ";
    if(catId == -2) {
      query = query + ", $TABLE_FAVORITES f ";
      query = query + " WHERE p.$KEY_PLACE_ID = f.$KEY_PLACE_ID ";
    } else if(catId != -1){
      query = query + ", $TABLE_PLACE_CATEGORY pc ";
      query = query + " WHERE pc.$KEY_RELATION_PLACE_ID = p.$KEY_PLACE_ID AND pc.$KEY_RELATION_CAT_ID = $catId";
    }
    query = query + " ORDER BY p.$KEY_DISTANCE ASC, p.$KEY_LAST_UPDATE DESC ";
    query = query + " LIMIT $limit OFFSET $offset ";
    List<Map<String, dynamic>> res = await db.rawQuery(query);
    res.forEach((element) {
      Map<String, dynamic> json = Map.from(element);
      result.add(Place.fromJson(json));
    });
    return result;
  }

  // Adding new location by Category
  Future<List<Place>> searchAllPlace(String keyWord) async {
    Database db = (await instance.database)!;
    List<Place> result = [];
    String query = "SELECT p.* FROM $TABLE_PLACE p ";
    if (keyWord.isEmpty) {
      query = query + "ORDER BY $KEY_LAST_UPDATE DESC";
    } else {
      keyWord = keyWord.toLowerCase();
      query = query + "WHERE LOWER($KEY_NAME) LIKE '%$keyWord%' OR LOWER($KEY_ADDRESS) LIKE '%$keyWord%' OR LOWER($KEY_DESCRIPTION) LIKE '%$keyWord%' ";
    }
    List<Map<String, dynamic>> res = await db.rawQuery(query);
    res.forEach((element) {
      Map<String, dynamic> json = Map.from(element);
      result.add(Place.fromJson(json));
    });
    return result;
  }

  Future<List<Place?>> getAllPlaceByCategory(int? categoryId) async{
    Database db = (await instance.database)!;
    List<Place?> result = [];
    String query = " SELECT DISTINCT p.* FROM $TABLE_PLACE p ";
    if(categoryId == -2) {
      query = query + ", $TABLE_FAVORITES f ";
      query = query + " WHERE p.$KEY_PLACE_ID = f.$KEY_PLACE_ID ";
    } else if(categoryId != -1){
      query = query + ", $TABLE_PLACE_CATEGORY pc ";
      query = query + " WHERE pc.$KEY_RELATION_PLACE_ID = p.$KEY_PLACE_ID AND pc.$KEY_RELATION_CAT_ID = $categoryId ";
    }
    query = query + " ORDER BY p.$KEY_LAST_UPDATE DESC ";
    List<Map<String, dynamic>> res = await db.rawQuery(query);
    res.forEach((element) {
      Map<String, dynamic> json = Map.from(element);
      result.add(Place.fromJson(json));
    });
    return result;
  }

  // Get LIst Images By Place Id
  Future<List<Images>> getListImageByPlaceId(int? placeId) async {
    Database db = (await instance.database)!;
    List<Images> result =[];
    String query;
    query = "SELECT i.* FROM $TABLE_IMAGES i WHERE i.$KEY_IMG_PLACE_ID = $placeId";
    List<Map<String, dynamic>> res = await db.rawQuery(query);
    res.forEach((element) {
      Map<String, dynamic> json = Map.from(element);
      result.add(Images.fromJson(json));
    });
    return result;
  }

  // get list News Info
  Future<List<NewsInfo>> getNewsInfoByPage(int limit, int offset) async {
    Database db = (await instance.database)!;
    List<NewsInfo> result = [];
    String query = " SELECT DISTINCT n.* FROM $TABLE_NEWS_INFO n ";
    query = query + " ORDER BY n.$KEY_NEWS_ID DESC LIMIT $limit OFFSET $offset";
    List<Map<String, dynamic>> res = await db.rawQuery(query);
    res.forEach((element) {
      Map<String, dynamic> json = Map.from(element);
      result.add(NewsInfo.fromJson(json));
    });
    return result;
  }

  Future<int> addFavorites(int? id) async {
    Database db = (await instance.database)!;
    var res = await db.insert(TABLE_FAVORITES, {KEY_PLACE_ID: id});
    return res;
  }

  Future<int> deleteFavorites(int? id) async {
    Database db = (await instance.database)!;
    return await db.delete(TABLE_FAVORITES, where: '$KEY_PLACE_ID = ?', whereArgs: [id]);
  }

  Future<int?> getPlacesSize(int? catId) async {
    Database db = (await instance.database)!;
    String query;
    query = "SELECT COUNT(p.$KEY_PLACE_ID) FROM $TABLE_PLACE p ";
    if(catId == -2) {
      query = query + ", $TABLE_FAVORITES f ";
      query = query + " WHERE p.$KEY_PLACE_ID = f.$KEY_PLACE_ID ";
    } else if(catId != -1){
      query = query + ", $TABLE_PLACE_CATEGORY pc ";
      query = query + " WHERE pc.$KEY_RELATION_PLACE_ID = p.$KEY_PLACE_ID AND pc.$KEY_RELATION_CAT_ID = $catId";
    }
    var res = await db.rawQuery(query);
    return Sqflite.firstIntValue(res);
  }

  Future<bool> isFavoritesExist(int? id) async {
    Database db = (await instance.database)!;
    var res = await db.rawQuery('SELECT COUNT (*) from $TABLE_FAVORITES WHERE $KEY_PLACE_ID = $id');
    return Sqflite.firstIntValue(res)! > 0;
  }

  Future<int?> getAllPlacesSize() async {
    Database db = (await instance.database)!;
    var res = await db.rawQuery('SELECT COUNT (*) from $TABLE_PLACE');
    return Sqflite.firstIntValue(res);
  }

  Future<int?> getCategorySize() async {
    Database db = (await instance.database)!;
    var res = await db.rawQuery('SELECT COUNT (*) from $TABLE_CATEGORY');
    return Sqflite.firstIntValue(res);
  }

  Future<int?> getFavoritesSize() async {
    Database db = (await instance.database)!;
    var res = await db.rawQuery('SELECT COUNT (*) from $TABLE_FAVORITES');
    return Sqflite.firstIntValue(res);
  }

  Future<int?> getNewsInfoSize() async {
    Database db = (await instance.database)!;
    var res = await db.rawQuery('SELECT COUNT (*) from $TABLE_NEWS_INFO');
    return Sqflite.firstIntValue(res);
  }

}
