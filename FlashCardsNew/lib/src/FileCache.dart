part of dbcache_api;


typedef void FileCacheReadyCallback(FileCache cache);
//typedef void ReadBlobCallback(FileEntry e);
typedef void ReadBlobErrorCallback();

class FileCache {
  
  FileSystem _filesystem;
  
  FileCacheReadyCallback _readyCallback;
  
  Map<String, DirectoryEntry> dirs = new Map<String, DirectoryEntry>();
  
  FileCache(FileCacheReadyCallback readyCallback) {
    this._readyCallback = readyCallback;
    int quota = 1024* 1024 * 1024;
   // window.requestFileSystemSync(type, size)    
    //window.localStorage
    /*window.storageInfo.requestQuota(Window.PERSISTENT, quota)
      .then((size) => print("Granted quota $size"), onError: (e) => print(e));*/
    window.requestFileSystem(quota, persistent: true)
        .then(_requestFileSystemCallback, onError: (e) => _logFileError(e));
  }
  
  void _requestFileSystemCallback(FileSystem filesystem) {
    _filesystem = filesystem;
    ["en", "ko", "fi", "fr", "enResp", "koResp", "fiResp", "frResp"].forEach((lang) {    
      _filesystem.root.createDirectory(lang) 
          .then((entry) => _createDirectoryCallback(entry, lang), 
          onError: (e) => _logFileError(e.error));
    }); 
  }
  
  void _createDirectoryCallback(DirectoryEntry dir, String name) {
    print('Created directory ${dir.fullPath} ');
    dirs[name] = dir;
    if (dirs.length == 4) {
      _readyCallback(this);
    }
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
