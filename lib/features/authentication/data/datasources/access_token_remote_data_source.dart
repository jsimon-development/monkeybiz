import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/local_server_interface.dart';
import '../../../../core/utils/url_builder.dart';
import '../../../../core/utils/url_launcher.dart';
import '../models/access_token_model.dart';
import 'access_token_remote_data_source_interface.dart';

class AccessTokenRemoteDataSource
    implements AccessTokenRemoteDataSourceInterface {
  final String authorizePath = '/authorize';
  final String accessTokenPath = '/token';
  final String baseUri = 'login.mailchimp.com/oauth2';
  final http.Client client;
  final LocalServerInterface server;
  final UrlBuilder urlBuilder;
  final UrlLauncher urlLauncher;

  AccessTokenRemoteDataSource(
    this.client,
    this.server,
    this.urlBuilder,
    this.urlLauncher,
  );

  @override
  Future<AccessTokenModel> getToken(
    String clientId,
    String clientSecret,
    String redirectUri,
  ) async {
    Stream<Map<String, String>> onRequestParams = await server.start();

    final authorizeUrl = urlBuilder.build(baseUri, authorizePath, true, {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri
    });

    if (!(await urlLauncher.canLaunch(authorizeUrl.toString()))) {
      throw AuthenticationException();
    }

    await urlLauncher.launch(authorizeUrl.toString(), forceSafariVC: true);

    final Map<String, String> params = await onRequestParams.first;

    if (!params.containsKey('code')) {
      throw AuthenticationException("Failed authenticating user. Invalid request.");
    }

    final String code = params['code'];

    final accessTokenUrl = urlBuilder.build(baseUri, accessTokenPath, true, {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'code': code
    });

    await urlLauncher.closeWebView();
    final http.Response response = await client.get(accessTokenUrl.toString());
    final token = AccessTokenModel.fromJson(json.decode(response.body));
    return token;
  }
}
