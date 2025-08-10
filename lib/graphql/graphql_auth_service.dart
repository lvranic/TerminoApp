import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_config.dart';

Future<int> signUpWithGraphQL({
  required String name,
  required String email,
  required String role,
  required String phone,
  required String password,
}) async {
  final client = getGraphQLClient();

  const mutation = r'''
    mutation AddUser($input: UserInput!) {
      addUser(input: $input) {
        id
      }
    }
  ''';

  final result = await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'name': name,
          'email': email,
          'role': role,
          'phone': phone,
          'password': password,
        },
      },
    ),
  );

  if (result.hasException) {
    throw Exception('Greška pri registraciji: ${result.exception.toString()}');
  }

  final data = result.data;

  if (data == null || data['addUser'] == null || data['addUser']['id'] == null) {
    throw Exception('Neuspješno dohvaćanje ID-a korisnika.');
  }

  return int.parse(data['addUser']['id'].toString());
}