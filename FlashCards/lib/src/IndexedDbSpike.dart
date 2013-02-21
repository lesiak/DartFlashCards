part of dbcache_api;


Future<String> aaa() {
  
}

Future<Database> openDatabase(String dbName, String storeName, {int version:1}) {
  return HTML.window.indexedDB.open(dbName, version: version,
    onUpgradeNeeded: (e) {
      Database db = e.target.result;
      if (!db.objectStoreNames.contains(storeName)) {  
        db.createObjectStore(storeName);
      }
    });
}

main() {
  openDatabase('test-db', 'test-store').then((Database db) {
    // do database stuff
  });
}

