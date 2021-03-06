import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mailchimp/core/network/local_server_builder.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';

import 'package:mailchimp/core/error/exceptions.dart';
import 'package:mailchimp/core/network/local_server_interface.dart';
import 'package:mailchimp/core/utils/url_builder.dart';
import 'package:mailchimp/core/utils/url_launcher.dart';
import 'package:mailchimp/features/authentication/data/datasources/access_token_remote_data_source.dart';
import 'package:mailchimp/features/authentication/data/models/access_token_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockLocalServerBuilder extends Mock implements LocalServerBuilder {}

class MockLocalServer extends Mock implements LocalServerInterface {}

class MockUrlBuilder extends Mock implements UrlBuilder {}

class MockUrlLauncher extends Mock implements UrlLauncher {}

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  MockStream<Map<String, String>> mockStream;
  MockClient mockClient;
  MockResponse mockResponse;
  MockLocalServer mockLocalServer;
  MockLocalServerBuilder mockLocalServerBuilder;
  MockUrlBuilder mockUrlBuilder;
  MockUrlLauncher mockUrlLauncher;
  AccessTokenRemoteDataSource dataSource;

  setUp(() {
    mockStream = MockStream<Map<String, String>>();
    mockClient = MockClient();
    mockResponse = MockResponse();
    mockLocalServer = MockLocalServer();
    mockLocalServerBuilder = MockLocalServerBuilder();
    mockUrlBuilder = MockUrlBuilder();
    mockUrlLauncher = MockUrlLauncher();
    dataSource = AccessTokenRemoteDataSource(
      client: mockClient,
      serverBuilder: mockLocalServerBuilder,
      urlBuilder: mockUrlBuilder,
      urlLauncher: mockUrlLauncher,
    );
  });

  final String authorizePath = '/oauth2/authorize';
  final String accessTokenPath = '/production/token';
  final String baseUri = 'test.dev';
  final String tClientId = '123456789012';
  final String tAccessTokenUri = 'token.test';
  final String tCode = '1edf2589e664fd317f6a7ff5f97b42f7';
  final String tRedirectUri = 'http://127.0.0.1:8080';
  final Map<String, String> tAuthorizeRequestParams = {
    'response_type': 'code',
    'client_id': tClientId,
    'redirect_uri': tRedirectUri,
  };
  final Map<String, String> tAccessTokenRequestParams = {
    'code': tCode
  };
  final Map<String, String> redirectUriRequestParams = {'code': tCode};
  final Map<String, String> failureRedirectUriRequestParams = {};
  final Uri tAuthorizeUrl =
      Uri.https(baseUri, authorizePath, tAuthorizeRequestParams);
  final Uri tAccessTokenUrl =
      Uri.https(baseUri, accessTokenPath, tAccessTokenRequestParams);
  final tResponse = json.decode(fixture('token_response.json'));
  final tAccessToken = AccessTokenModel.fromJson(tResponse);

  group('getToken', () {
    test(
      'should return AccessToken when authentication is successful',
      () async {
        // arrange
        when(mockLocalServerBuilder.build())
            .thenAnswer((_) async => mockLocalServer);
        when(mockLocalServer.start()).thenAnswer((_) async => mockStream);
        when(mockUrlBuilder.build(
                baseUri, authorizePath, true, tAuthorizeRequestParams))
            .thenReturn(tAuthorizeUrl);
        when(mockUrlLauncher.canLaunch(any)).thenAnswer((_) async => true);
        when(mockUrlLauncher.launch(any, forceSafariVC: true))
            .thenAnswer((_) async => null);
        when(mockStream.first)
            .thenAnswer((_) async => redirectUriRequestParams);
        when(mockUrlBuilder.build(tAccessTokenUri, accessTokenPath, true,
                tAccessTokenRequestParams))
            .thenReturn(tAccessTokenUrl);
        when(mockUrlLauncher.closeWebView()).thenAnswer((_) async => null);
        when(mockClient.post(any, body: anyNamed("body"))).thenAnswer((_) async => mockResponse);
        when(mockResponse.body).thenReturn(fixture('token_response.json'));
        // act
        final result =
            await dataSource.getToken(tClientId, tAccessTokenUri, tRedirectUri);
        // assert
        expect(result, equals(tAccessToken));
      },
    );

    test(
      'should throw an AuthenticationException when the device is unable to open the url',
      () async {
        // arrange
        when(mockLocalServerBuilder.build())
            .thenAnswer((_) async => mockLocalServer);
        when(mockLocalServer.start()).thenAnswer((_) async => mockStream);
        when(mockUrlBuilder.build(
                baseUri, authorizePath, true, tAuthorizeRequestParams))
            .thenReturn(tAuthorizeUrl);
        when(mockUrlLauncher.canLaunch(any)).thenAnswer((_) async => false);
        // act
        final call = dataSource.getToken;
        // assert
        expect(() => call(tClientId, tAccessTokenUri, tRedirectUri),
            throwsA(TypeMatcher<AuthenticationException>()));
      },
    );

    test(
      'should throw an AuthenticationException when there is an improper request to the local server',
      () async {
        // arrange
        when(mockLocalServerBuilder.build())
            .thenAnswer((_) async => mockLocalServer);
        when(mockLocalServer.start()).thenAnswer((_) async => mockStream);
        when(mockUrlBuilder.build(
                baseUri, authorizePath, true, tAuthorizeRequestParams))
            .thenReturn(tAuthorizeUrl);
        when(mockUrlLauncher.canLaunch(any)).thenAnswer((_) async => true);
        when(mockUrlLauncher.launch(any, forceSafariVC: true))
            .thenAnswer((_) async => null);
        when(mockStream.first)
            .thenAnswer((_) async => failureRedirectUriRequestParams);
        // act
        final call = dataSource.getToken;
        // assert
        expect(() => call(tClientId, tAccessTokenUri, tRedirectUri),
            throwsA(TypeMatcher<AuthenticationException>()));
      },
    );
  });
}
