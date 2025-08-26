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
      return (token == null || token.isEmpty) ? null : 'Bearer $token';
    },
  );

  // Lagan logging grešaka da odmah vidiš što backend vraća
  final errorLink = ErrorLink(
    onGraphQLError: (req, forward, response) {
      // ignore: avoid_print
      print('🟥 GraphQL errors: ${response.errors}');
      return forward(req);
    },
    onException: (req, forward, exception) {
      // ignore: avoid_print
      print('🟥 Link exception: $exception');
      return forward(req);
    },
  );

  final Link link = errorLink.concat(authLink.concat(httpLink));

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

/// (Opcionalno) ako ti ikad treba direktan client bez provider-a.
Future<GraphQLClient> buildGraphQLClient() async {
  final notifier = await buildGraphQLNotifier();
  return notifier.value;
}