import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/token_store.dart';

class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  AuthResult({required this.token, required this.user});
}

class AuthService {
  final GraphQLClient client;
  AuthService(this.client);

  static Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  static const _loginMutation = r'''
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
        user { id name email role }
      }
    }
  ''';

  static const _registerMutation = r'''
    mutation AddUser($name: String!, $email: String!, $phone: String!, $role: String!, $password: String!) {
      addUser(name: $name, email: $email, phone: $phone, role: $role, password: $password) {
        token
        user { id name email role }
      }
    }
  ''';

  static const _registerAdminWithBusinessDataMutation = r'''
    mutation AddUser(
      $name: String!,
      $email: String!,
      $phone: String!,
      $role: String!,
      $password: String!,
      $businessName: String,
      $address: String,
      $workHours: String
    ) {
      addUser(
        name: $name,
        email: $email,
        phone: $phone,
        role: $role,
        password: $password,
        businessName: $businessName,
        address: $address,
        workHours: $workHours
      ) {
        token
        user { id name email role businessName address workHours }
      }
    }
  ''';

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(_loginMutation),
      variables: {
        'email': email,
        'password': password,
      },
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['login'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Prazan odgovor sa servera.');
    }

    final token = data['token'] as String?;
    final user = (data['user'] as Map?)?.cast<String, dynamic>();

    if (token == null || user == null) {
      throw Exception('Nedostaju token ili user iz odgovora.');
    }

    _currentUser = user;
    await TokenStore.set(token);
    return AuthResult(token: token, user: user);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(_registerMutation),
      variables: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'password': password,
      },
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['addUser'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Prazan odgovor sa servera.');
    }

    final token = data['token'] as String?;
    final user = (data['user'] as Map?)?.cast<String, dynamic>();

    if (token == null || user == null) {
      throw Exception('Nedostaju token ili user iz odgovora.');
    }

    _currentUser = user;
    await TokenStore.set(token);
    return AuthResult(token: token, user: user);
  }

  Future<AuthResult> registerAdminWithBusinessData({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
    required String businessName,
    required String address,
    required String workHours,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(_registerAdminWithBusinessDataMutation),
      variables: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'password': password,
        'businessName': businessName,
        'address': address,
        'workHours': workHours,
      },
    ));

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['addUser'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Prazan odgovor sa servera.');
    }

    final token = data['token'] as String?;
    final user = (data['user'] as Map?)?.cast<String, dynamic>();

    if (token == null || user == null) {
      throw Exception('Nedostaju token ili user iz odgovora.');
    }

    _currentUser = user;
    await TokenStore.set(token);
    return AuthResult(token: token, user: user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await TokenStore.clear();
  }
}