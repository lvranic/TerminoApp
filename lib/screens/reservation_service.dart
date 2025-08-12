import 'package:graphql_flutter/graphql_flutter.dart';

class ReservationService {
  ReservationService(this.client);
  final GraphQLClient client;

  // ✅ ista mutacija kao na ekranu – ID! tipovi i root argumenti
  static const String _createReservationMutation = r'''
    mutation CreateReservation(
      $providerId: ID!,
      $serviceId: ID!,
      $startsAtUtc: DateTime!,
      $duration: Int
    ) {
      createReservation(
        providerId: $providerId,
        serviceId: $serviceId,
        startsAtUtc: $startsAtUtc,
        durationMinutes: $duration
      ) { id }
    }
  ''';

  Future<String> createReservation({
    required String providerId,
    required String serviceId,
    required DateTime startsAtLocal, // lokalno vrijeme
    int? durationMinutes = 30,
  }) async {
    final startsAtUtc = startsAtLocal.toUtc().toIso8601String();

    final res = await client.mutate(MutationOptions(
      document: gql(_createReservationMutation),
      variables: {
        'providerId': providerId,
        'serviceId': serviceId,
        'startsAtUtc': startsAtUtc,
        'duration': durationMinutes,
      },
      fetchPolicy: FetchPolicy.noCache,
    ));

    if (res.hasException) {
      throw Exception(res.exception.toString());
    }
    return (res.data?['createReservation'] as Map<String, dynamic>)['id'] as String;
  }
}