// lib/graphql/graphql_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show ValueNotifier, kIsWeb;
import 'package:graphql_flutter/graphql_flutter.dart';

import '../utils/token_store.dart';

const String graphQLEndpoint = 'https://termino-backend.onrender.com/graphql';

/// Globalni GraphQL client u ValueNotifieru (potreban GraphQLProvider-u).
Future<ValueNotifier<GraphQLClient>> buildGraphQLNotifier() async {
  await initHiveForFlutter();

  final httpLink = HttpLink(graphQLEndpoint);

  final authLink = AuthLink(
    getToken: () async {
      final token = await TokenStore.get();
      if (token == null || token.isEmpty) {
        print('⚠️ Nema spremljenog tokena!');
        return null;
      }

      print('📦 TOKEN KOJI SE ŠALJE: $token');
      return 'Bearer $token';
    },
  );

  final errorLink = ErrorLink(
    onGraphQLError: (req, forward, response) {
      print('🟥 GraphQL error(s): ${response.errors}');
      return forward(req);
    },
    onException: (req, forward, exception) {
      print('🟥 GraphQL exception: $exception');
      return forward(req);
    },
  );

  final Link link = errorLink.concat(authLink).concat(httpLink);

  final client = GraphQLClient(
    link: link,
    cache: GraphQLCache(store: HiveStore()),
    defaultPolicies: DefaultPolicies(
      watchQuery: Policies(fetch: FetchPolicy.cacheAndNetwork),
      query: Policies(fetch: FetchPolicy.networkOnly),
      mutate: Policies(fetch: FetchPolicy.noCache),
    ),
  );

  return ValueNotifier<GraphQLClient>(client);
}

/// (Opcionalno) direktan pristup GraphQL clientu bez providera.
Future<GraphQLClient> buildGraphQLClient() async {
  final notifier = await buildGraphQLNotifier();
  return notifier.value;
}