part of dbcache_api;


typedef void FileCacheReadyCallback(FileCache cache);
//typedef void ReadBlobCallback(FileEntry e);
typedef void ReadBlobErrorCallback();

class FileCache {
  
  FileSystem _filesystem;  
  
  Map<String, DirectoryEntry> dirs = new Map<String, DirectoryEntry>();
  
  FileCache(List<String> langs, FileCacheReadyCallback readyCallback) {    
    
    DeprecatedStorageQuota sq = window.navigator.persistentStorage;
    
    sq.queryUsageAndQuota((usage,q) {
      var usagePerc = (usage*100)/q;
      print("AAA Persistent storage: usage: $usage, quota: $q, used $usagePerc%");
    }); 
   //     

    /*window.storageInfo.requestQuota(Window.PERSISTENT, quota)
      .then((size) => print("Granted quota $size"), onError: (e) => print(e));*/
    int fsQuota = 3 * 1024 * 1024 * 1024;
    sq.requestQuota(fsQuota, (int grantedQuotaInBytes) => print('Granted $grantedQuotaInBytes bytes'), (DomError error) => print(error));
    window.requestFileSystem(fsQuota, persistent: true)
        .then((fs) => _requestFileSystemCallback(langs,fs), onError: (e) => _logFileError(e))
        .then((nothing) => readyCallback(this));
  }
  
  Future _requestFileSystemCallback(List<String> langs, FileSystem filesystem) {
    _filesystem = filesystem;    //
    var respLangs = langs.map((lang) => lang+ "Resp");    
    var dirsToCreate = new List.from(langs)..addAll(respLangs)..add('PronoMetadata');
    return Future.forEach(dirsToCreate, (lang) {
      _filesystem.root.createDirectory(lang)
        .then((entry) => _createDirectoryCallback(entry, lang), onError: (e) => _logFileError(e));
    });
  }
  
  void _createDirectoryCallback(DirectoryEntry dir, String name) {
    print('Created directory ${dir.fullPath}');
    dirs[name] = dir;
  }
  
  Future<String> readFileAsText(String dirName, String fileName) {
    DirectoryEntry dir = dirs[dirName];
    return FileSystemUtils.readFileAsText(dir, fileName);        
  }
    
  Future<bool> fileExistsinDir(String dir, String fileName) {
    return FileSystemUtils.fileExists(dirs[dir], fileName);               
  }
    
       
    
  void removeFile(DirectoryEntry dir, String fileName) {
    dir.getFile(fileName).then((Entry fileEntry) {
      fileEntry.remove().then((_empty) => print('Removed: $fileName'), onError: _logFileError);
    }); 
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
  
  Future<FileEntry> saveText(String dir, String name, String text) {
    Blob blob = new Blob([text], 'text/plain');    
    return saveBlob(dir, name, blob);    
  }
    
  Future<Entry> readEntry(String dir, String name) {    
    return dirs[dir].getFile(name);  
  }
  
  Future<Entry> readEntryFromDir(DirectoryEntry dir, String name) {    
      return dir.getFile(name);  
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
  
  Future<FileEntry> writeTextToEntry(FileEntry entry, String text) {
    Blob blob = new Blob([text], 'text/plain');
    return _writeBlob(entry, blob);     
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
