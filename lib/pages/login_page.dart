import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  String? _err;

  void _login() {
    setState(() => _err = null);
    if (_u.text.trim() == 'admin' && _p.text.trim() == '12345') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BottomNavBar()));
    } else {
      setState(() => _err = 'Username atau password salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sistem Poin Pelanggaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[700])),
                  const SizedBox(height: 12),
                  TextField(controller: _u, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 8),
                  TextField(controller: _p, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock))),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _login, child: const Text('Masuk')),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 8),
                    Text(_err!, style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
