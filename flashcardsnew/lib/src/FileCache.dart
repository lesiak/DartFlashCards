part of dbcache_api;


typedef void FileCacheReadyCallback(FileCache cache);
//typedef void ReadBlobCallback(FileEntry e);
typedef void ReadBlobErrorCallback();

class FileCache {
  
  FileSystem _filesystem;  
  
  Map<String, DirectoryEntry> dirs = new Map<String, DirectoryEntry>();
  
  FileCache(List<String> langs, FileCacheReadyCallback readyCallback) {    
    int quota = 1024* 1024 * 1024;
    DeprecatedStorageQuota sq = window.navigator.persistentStorage;
    sq.queryUsageAndQuota((usage,q) => print("AAA Persistent storage: $usage, $q")); 
   // window.requestFileSystemSync(type, size)    
    //window.localStorage
    /*window.storageInfo.requestQuota(Window.PERSISTENT, quota)
      .then((size) => print("Granted quota $size"), onError: (e) => print(e));*/
    window.requestFileSystem(quota, persistent: true)
        .then((fs) => _requestFileSystemCallback(langs,fs), onError: (e) => _logFileError(e))
        .then((nothing) => readyCallback(this));
  }
  
  Future _requestFileSystemCallback(List<String> langs, FileSystem filesystem) {
    _filesystem = filesystem;
    //var langs = ["en", "ko", "fi", "fr", "hu", "zh"];
    var respLangs = langs.map((lang) => lang+ "Resp");    
    var dirsToCreate = new List.from(langs)..addAll(respLangs);    
    return Future.forEach(dirsToCreate, (lang) {
      _filesystem.root.createDirectory(lang)
        .then((entry) => _createDirectoryCallback(entry, lang), onError: (e) => _logFileError(e));
    });
  }
  
  void _createDirectoryCallback(DirectoryEntry dir, String name) {
    print('Created directory ${dir.fullPath} ');
    dirs[name] = dir;
  }
  
  Future<FileEntry> saveBlob(String dir, String name, Blob blob) {    
    Future<FileEntry> ret = dirs[dir].createFile(name)
      .then((entry) => _writeBlob(entry, blob), 
        onError: (e)  {
          _logFileError(e.error);
          throw e;
      });
      return ret;
  }
    
  Future<Entry> readEntry(String dir, String name) {    
    return dirs[dir].getFile(name);  
  }

  
  Future<FileEntry> _writeBlob(FileEntry entry, Blob b) {
    print("Writing blob ${entry.fullPath}");
    Future<FileEntry> writtenFut = entry.createWriter().then((writer) {
      writer.write(b);
      print("blob written");
      return entry;
    });
    return writtenFut;
  }  
  
  void _logFileError(FileError e) {
    var msg = '';
    switch (e.code) {
      case FileError.QUOTA_EXCEEDED_ERR:
        msg = 'QUOTA_EXCEEDED_ERR';
        break;
      case FileError.NOT_FOUND_ERR:
        msg = 'NOT_FOUND_ERR';
        break;
      case FileError.SECURITY_ERR:
        msg = 'SECURITY_ERR';
        break;
      case FileError.INVALID_MODIFICATION_ERR:
        msg = 'INVALID_MODIFICATION_ERR';
        break;
      case FileError.INVALID_STATE_ERR:
        msg = 'INVALID_STATE_ERR';
        break;
      default:
        msg = 'Unknown Error';
        break;
    }
    print("Error: $msg");
  }
  
}
