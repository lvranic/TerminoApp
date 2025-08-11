import 'package:graphql_flutter/graphql_flutter.dart';

class ReservationService {
  ReservationService(this.client);
  final GraphQLClient client;

  // ⚠️ Ako backend već ima drugu mutaciju, promijeni ime i polja ispod.
  static const String _createReservationMutation = r'''
    mutation CreateReservation($input: ReservationInput!) {
      createReservation(input: $input) {
        id
        dateTime
        serviceId
        userId
        adminId
      }
    }
  ''';

  // ⚠️ Ako imaš query za slobodne slotove, zamijeni ovim pravim.
  static const String _availableSlotsQuery = r'''
    query AvailableSlots($adminId: ID!, $serviceId: ID!, $date: String!) {
      availableSlots(adminId: $adminId, serviceId: $serviceId, date: $date)
    }
  ''';

  Future<List<String>> getAvailableSlots({
    required String adminId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
      final res = await client.query(QueryOptions(
        document: gql(_availableSlotsQuery),
        variables: {
          'adminId': adminId,
          'serviceId': serviceId,
          'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (res.hasException) {
        // Fallback: lokalno generiraj slotove svakih 30 min (09–17)
        return _generateLocalSlots();
      }
      final data = res.data?['availableSlots'] as List<dynamic>?;
      if (data == null) return _generateLocalSlots();
      return data.map((e) => e.toString()).toList();
    } catch (_) {
      return _generateLocalSlots();
    }
  }

  Future<Map<String, dynamic>> createReservation({
    required String adminId,
    required String serviceId,
    required String userId,
    required DateTime dateTime,
  }) async {
    final res = await client.mutate(MutationOptions(
      document: gql(_createReservationMutation),
      variables: {
        'input': {
          'adminId': adminId,
          'serviceId': serviceId,
          'userId': userId,
          'dateTime': dateTime.toIso8601String(),
        }
      },
    ));
    if (res.hasException) {
      throw Exception(res.exception.toString());
    }
    return res.data?['createReservation'] as Map<String, dynamic>;
  }

  List<String> _generateLocalSlots() {
    final slots = <String>[];
    var t = const TimeOfDay(hour: 9, minute: 0);
    while (t.hour < 17 || (t.hour == 17 && t.minute == 0)) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      slots.add('$hh:$mm');
      final m2 = t.minute + 30;
      t = TimeOfDay(hour: t.hour + (m2 ~/ 60), minute: m2 % 60);
    }
    return slots;
  }
}