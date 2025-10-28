import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // init app state if needed
  AppState.instance.initSampleData(); // optional sample data
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Pelanggaran (Flutter)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.indigo),
      home: const LoginPage(),
    );
  }
}
