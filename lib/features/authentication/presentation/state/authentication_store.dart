import '../../../../core/features/firestore/domain/usecases/get_document_by_id.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/access_token.dart';
import '../../domain/usecases/get_access_token.dart';
import '../../domain/usecases/remove_access_token.dart';

class AuthenticationStore {
  final GetAccessToken getAccessToken;
  final GetDocumentById getDocumentById;
  final RemoveAccessToken removeAccessToken;
  AccessToken _accessToken;
  bool completedLogin = false;

  AuthenticationStore({
    GetAccessToken loginAction,
    GetDocumentById configAction,
    RemoveAccessToken logoutAction,
  })  : assert(loginAction != null),
        assert(configAction != null),
        assert(logoutAction != null),
        getAccessToken = loginAction,
        getDocumentById = configAction,
        removeAccessToken = logoutAction;

  AccessToken get accessToken => _accessToken;

  void login() async {
    completedLogin = false;
    final config = await getDocumentById('mailchimp_api_credentials');

    final document = config.fold(
      (failure) {
        print(failure.exception.toString());
        throw failure.exception;
      },
      (document) {
        return document;
      },
    );

    final authenticate = await getAccessToken(OauthParams(
      clientId: document.data['client_id'],
      accessTokenUri: document.data['access_token_uri'],
      redirectUri: document.data['redirect_uri'],
    ));

    completedLogin = true;

    _accessToken = authenticate.fold(
      (failure) {
        print(failure.exception.toString());
        throw failure.exception;
      },
      (accessToken) {
        return accessToken;
      },
    );
  }

  void logout() async {
    final result = await removeAccessToken(NoParams());
    _accessToken = result.fold(
      (failure) {
        print(failure.exception.toString());
        throw failure.exception;
      },
      (success) {
        return null;
      },
    );
  }

  void checkLoginStatus() async {
    final authenticate = await getAccessToken();

    _accessToken = authenticate.fold(
      (failure) {
        return null;
      },
      (accessToken) {
        return accessToken;
      },
    );
  }
}
