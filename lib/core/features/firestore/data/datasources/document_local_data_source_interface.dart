import '../../domain/entities/document.dart';

abstract class DocumentLocalDataSourceInterface {
  /// Uses the device storage to retrive all documents.
  ///
  /// Throws a [CacheException] if no cached data is present.
  Future<List<Document>> getList();

  /// Uses the device storage to store all documents.
  ///
  /// Throws a [CacheException] for all error codes.
  Future<void> cacheList(List<Document> documents);

  /// Uses the device storage to retrive a document specified
  /// by ID.
  /// 
  /// Throws a [CacheException] if no cached data is present.
  Future<Document> getById(String id);

  /// Uses the device storage to store a document.
  ///
  /// Throws a [CacheException] for all error codes.
  Future<void> cache(Document document);

  /// Uses the device storage to delete a document.
  ///
  /// Throws a [CacheException] if no cached data is present.
  Future<bool> delete(Document document);

  /// Uses the device storage to delete a document specified
  /// by ID.
  ///
  /// Throws a [CacheException] if no cached data is present.
  Future<bool> deleteById(String id);
}