import '../../domain/entities/document.dart';
import '../models/document_model.dart';

abstract class DocumentRemoteDataSourceInterface {
  /// Uses the firestore api to retrive all documents.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<DocumentModel>> getList();

  /// Uses the firestore api to retrive a document specified
  /// by ID.
  /// 
  /// Throws a [ServerException] for all error codes.
  Future<DocumentModel> getById(String id);

  /// Uses the firestore api to create/update a document.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<DocumentModel> save(DocumentModel document);

  /// Uses the firestore api to delete a document.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> delete(Document document);

  /// Uses the firestore api to delete a document specified
  /// by ID.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> deleteById(String id);
}