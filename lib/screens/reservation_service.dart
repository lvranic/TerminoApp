import 'package:graphql_flutter/graphql_flutter.dart';

class ReservationService {
  ReservationService(this.client);
  final GraphQLClient client;

  static const String _createReservationMutation = r'''
    mutation CreateReservation(
      $providerId: String!,
      $serviceId: String!,
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

  String _asId(dynamic v) => v?.toString() ?? '';

  Future<String> createReservation({
    required String providerId,
    required String serviceId,
    required DateTime startsAtLocal,
    int? durationMinutes = 30,
  }) async {
    final startsAtUtc = startsAtLocal.toUtc().toIso8601String();

    final res = await client.mutate(
      MutationOptions(
        document: gql(_createReservationMutation),
        variables: {
          'providerId': _asId(providerId),
          'serviceId': _asId(serviceId),
          'startsAtUtc': startsAtUtc,
          'duration': durationMinutes,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (res.hasException) {
      throw Exception(res.exception.toString());
    }

    final data = res.data?['createReservation'] as Map<String, dynamic>?;
    if (data == null || data['id'] == null) {
      throw Exception('Prazan odgovor: createReservation.id nije vraćen.');
    }
    return data['id'] as String;
  }
}