import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../validators/auth_validator.dart';

class AuthSubmitResult {
  const AuthSubmitResult._({required this.success, this.errorMessage});

  const AuthSubmitResult.ok() : this._(success: true);

  const AuthSubmitResult.error(String message)
      : this._(success: false, errorMessage: message);

  final bool success;
  final String? errorMessage;
}

class AuthService {
  AuthService({AppDatabase? database})
      : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  Future<AuthSubmitResult> submit({
    required String email,
    required String password,
    required bool isRegister,
    String? confirmPassword,
  }) async {
    if (!AuthValidator.validEmail(email)) {
      return const AuthSubmitResult.error('Informe um email válido.');
    }
    if (isRegister) {
      if (!AuthValidator.strongPassword(password)) {
        return const AuthSubmitResult.error(
          'Senha forte: mínimo 8, com letra e número.',
        );
      }
      if (confirmPassword != password) {
        return const AuthSubmitResult.error('As senhas não coincidem.');
      }
    }

    try {
      final existing = await _db.findUserByEmail(email);

      if (isRegister) {
        if (existing != null) {
          return const AuthSubmitResult.error(
            'Este email já está cadastrado. Use Entrar ou outro email.',
          );
        }
        try {
          final newId = await _db.insertUser(email: email, password: password);
          _db.signIn(newId);
        } on DatabaseException catch (e) {
          if (e.toString().contains('UNIQUE')) {
            return const AuthSubmitResult.error(
              'Email já cadastrado. Use Entrar.',
            );
          }
          rethrow;
        }
      } else {
        if (existing == null) {
          return const AuthSubmitResult.error(
            'Conta não encontrada. Crie conta primeiro.',
          );
        }
        if ((existing['password'] ?? '') as String != password) {
          return const AuthSubmitResult.error('Senha incorreta.');
        }
        _db.signIn(existing['id'] as int);
      }

      return const AuthSubmitResult.ok();
    } catch (e) {
      return AuthSubmitResult.error('Erro: $e');
    }
  }
}
