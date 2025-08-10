import 'package:flutter/foundation.dart';            // ✅ zbog ValueNotifier
import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/token_store.dart';

// ⚠️ Ako testiraš na Android emulatoru, koristi 10.0.2.2 umjesto localhost
const String kGraphQLEndpoint = 'http://10.0.2.2:5030/graphql';
// Ako testiraš na iOS simulatoru ili webu, može ostati 'http://localhost:5030/graphql'

Future<ValueNotifier<GraphQLClient>> buildGraphQLNotifier() async {
  await initHiveForFlutter();

  final httpLink = HttpLink(kGraphQLEndpoint);

  final authLink = AuthLink(
    getToken: () async {
      final token = await TokenStore.get();
      return token == null ? null : 'Bearer $token';
    },
  );

  final link = authLink.concat(httpLink);

  final client = GraphQLClient(
    link: link,                           // nema potrebe za Link.from([...])
    cache: GraphQLCache(store: HiveStore()),
  );

  return ValueNotifier<GraphQLClient>(client);        // ✅ eksplicitni generički tip
}