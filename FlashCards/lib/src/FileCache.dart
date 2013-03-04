part of dbcache_api;


typedef void FileCacheReadyCallback(FileCache cache);
typedef void ReadBlobCallback(FileEntry e);
typedef void ReadBlobErrorCallback();

class FileCache {
  
  FileSystem _filesystem;
  
  FileCacheReadyCallback _readyCallback;
  
  Map<String, DirectoryEntry> dirs = new Map<String, DirectoryEntry>();
  
  FileCache(FileCacheReadyCallback readyCallback) {
    this._readyCallback = readyCallback;
    int quota = 1024* 1024 * 1024;
   // window.requestFileSystemSync(type, size)
    window.storageInfo.requestQuota(Window.PERSISTENT, quota, (size) => print("Granted quota $size"), (e) => print(e));
    window.requestFileSystem(Window.PERSISTENT, quota,
        _requestFileSystemCallback, _handleError);
  }
  
  void _requestFileSystemCallback(FileSystem filesystem) {
    _filesystem = filesystem;
    ["en", "ko", "fi", "fr"].forEach((lang) {    
      _filesystem.root.getDirectory(lang, options: {"create": true}, 
          successCallback: (entry) => _createDirectoryCallback(entry, lang), 
          errorCallback: _handleError);
    }); 
  }
  
  void _createDirectoryCallback(DirectoryEntry dir, String name) {
    print('Created directory ${dir.fullPath} ');
    dirs[name] = dir;
    if (dirs.length == 4) {
      _readyCallback(this);
    }
  }
  
  void saveBlob(String dir, String name, Blob blob, EntryCallback successCallback1) {    
    dirs[dir].getFile(name, 
      options: {"create": true},
      successCallback: (entry) => _writeBlobCallback(entry, blob, successCallback1),
      errorCallback: _handleError);
  }
  
  void readBlob(String dir, String name, ReadBlobCallback readBlobCallback) {    
    dirs[dir].getFile(name, options: {"create": false },successCallback: readBlobCallback, errorCallback: _handleError);
  }
  
  void readBlobIfExists(String dir, String name, ReadBlobCallback readBlobCallback, ErrorCallback errorCallback) {    
    dirs[dir].getFile(name, options: {"create": false },successCallback: readBlobCallback, errorCallback: errorCallback);
  }

  
  void _writeBlobCallback(FileEntry e, Blob b, EntryCallback successCallback) {
    print("Writing blob ${e.fullPath}");
    e.createWriter((writer) {
      writer.write(b);
      print("blob written");
      successCallback(e);
    }, _handleError);
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
