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
    window.storageInfo.requestQuota(Window.PERSISTENT, quota)
      .then((size) => print("Granted quota $size"), onError: (e) => print(e));
    window.requestFileSystem(quota, persistent: true)
        .then(_requestFileSystemCallback, onError: (e) => _handleError(e.error));
  }
  
  void _requestFileSystemCallback(FileSystem filesystem) {
    _filesystem = filesystem;
    ["en", "ko", "fi", "fr", "enResp", "koResp", "fiResp", "frResp"].forEach((lang) {    
      _filesystem.root.createDirectory(lang) 
          .then((entry) => _createDirectoryCallback(entry, lang), 
          onError: (e) => _handleError(e.error));
    }); 
  }
  
  void _createDirectoryCallback(DirectoryEntry dir, String name) {
    print('Created directory ${dir.fullPath} ');
    dirs[name] = dir;
    if (dirs.length == 4) {
      _readyCallback(this);
    }
  }
  
  void saveBlob(String dir, String name, Blob blob, successCallback1(Entry value)) {    
    dirs[dir].createFile(name)
      .then((entry) => _writeBlobCallback(entry, blob, successCallback1),
      onError: (e) => _handleError(e.error));      
  }
    
  Future<Entry> readBlobIfExists(String dir, String name) {    
    return dirs[dir].getFile(name);  
  }

  
  void _writeBlobCallback(FileEntry e, Blob b, successCallback(FileEntry entry)) {
    print("Writing blob ${e.fullPath}");
    e.createWriter().then((writer) {
      writer.write(b);
      print("blob written");
      successCallback(e);
    }, onError: (e) => _handleError(e));
  }  
  
  void _handleError(FileError e) {
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
