part of fsutils;

class FileSystemUtils {
  
  /*
  static void ls(DirectoryEntry dir, successCallback) {     
      // Read contents of current working directory. According to spec, need to
      // keep calling readEntries() until length of result array is 0. We're
      // guarenteed the same entry won't be returned again.
      List<Entry> entries = [];
    
      var reader = dir.createReader();

      var readEntries;
      readEntries = () {
        reader.readEntries().then((List<Entry> results) {
          if (results.isEmpty) {
           // entries.sort();
            successCallback(entries);
          } else {
            entries.addAll(results);
            readEntries();
          }
        });
      };

      readEntries();
  }
  
  static Future<FileEntry> saveBlob(DirectoryEntry dir, String name, Blob blob) {    
    Future<FileEntry> ret = dir.createFile(name).then((entry) => _writeBlob(entry, blob));
     return ret;
   }

  static Future<FileEntry> _writeBlob(FileEntry entry, Blob b) {
    print("Writing blob ${entry.fullPath}");
    
    Future<FileEntry> writtenFut = entry.createWriter().then((writer) {     
      writer.write(b);
      print("blob written");
      return entry;
    });
    return writtenFut;
  }*/
  
  static Future<String> readFileAsText(DirectoryEntry dir, String fileName) {      
    return dir.getFile(fileName).then((Entry entry) => _readEntryAsText(entry));
  }
    
  static Future<String> _readEntryAsText(FileEntry entry) {
    return entry.file().then(_readFSFileAsText);
  }
       
  static Future<String> _readFSFileAsText(File ff) {
    var reader = new FileReader();
    reader.readAsText(ff);
    return reader.onLoadEnd.first.then((ProgressEvent e) => reader.result);
  }
  
  static Future<Entry> readEntryFromDir(DirectoryEntry dir, String name) {    
    return dir.getFile(name);  
  }
  
  /*static Future<String> readAsText(DirectoryEntry dir, String path) {
    Future readerFuture = dir.getFile(path).then((FileEntry fileEntry) => _getTextFromFileEntry(fileEntry));
    return readerFuture;
  }
    
  static Future<List<int>> readAsArrayBuffer(DirectoryEntry dir, String path/*, successCallback*/) {    
    Future readerFuture = dir.getFile(path).then((FileEntry fileEntry) => _getArrayBufferFileEntry(fileEntry));
    return readerFuture;
  }
  
  static Future<String> _getTextFromFileEntry(FileEntry fileEntry) {
    return fileEntry.file().then((ff) {
      var reader = new FileReader();
      Future<String> resultFut = reader.onLoadEnd.first.then((e) => reader.result);     
      reader.readAsText(ff);
      return resultFut;
    });       
  }

  static Future<List<int>> _getArrayBufferFileEntry(FileEntry fileEntry) {
    return fileEntry.file().then((ff) {
      var reader = new FileReader();
      Future<List<int>> resultFut = reader.onLoadEnd.first.then((e) => reader.result);     
      reader.readAsArrayBuffer(ff);
      return resultFut;
    });       
  }
  */
  
  
  
  static Future<bool> fileExists(DirectoryEntry dir, String fileName) {
    Future<Entry> entryFut = dir.getFile(fileName);
    return entryFut.then((Entry entry) => true, onError: (e) => false);               
  }
}