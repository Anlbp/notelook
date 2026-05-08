import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final result = await _auth.submit(
        email: _email.text.trim(),
        password: _password.text,
        isRegister: _register,
        confirmPassword: _register ? _confirmPassword.text : null,
      );

      if (!mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Erro desconhecido.')),
        );
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('NoteLook')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Entrar')),
                  ButtonSegment(value: true, label: Text('Criar conta')),
                ],
                selected: {_register},
                onSelectionChanged: (s) {
                  setState(() {
                    _register = s.first;
                    _confirmPassword.clear();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (_register) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassword,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_register ? 'Cadastrar' : 'Entrar'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _register
                    ? 'Cadastro: email ainda não usado '
                        'Notas só estão nesta conta'
                    : 'Entrar: só aceita contas já registradas',
                style: hintStyle?.copyWith(fontSize: 13) ??
                    const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
