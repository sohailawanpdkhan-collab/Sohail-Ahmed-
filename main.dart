
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// NOTE: You must add your Firebase options (google-services.json / plist) for real device testing.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NexaChatApp());
}

class NexaChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MaterialApp(
        title: 'NexaChat',
        theme: _buildTheme(Brightness.dark),
        home: AuthGate(),
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness);
  final gold = Color(0xFFCFA84D);
  return base.copyWith(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: base.colorScheme.copyWith(
      secondary: gold,
      primary: Colors.black,
      background: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: gold,
      elevation: 0,
    ),
    textTheme: base.textTheme.apply(bodyColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class AuthState extends ChangeNotifier {
  User? user;
  AuthState() {
    user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthState>(context);
    if (auth.user != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool loading = false;
  String message = '';

  Future<void> register() async {
    setState(() { loading = true; message=''; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() { message = e.message ?? 'Error'; });
    } finally {
      setState(() { loading = false; });
    }
  }
  Future<void> login() async {
    setState(() { loading = true; message=''; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() { message = e.message ?? 'Error'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Color(0xFFCFA84D);
    return Scaffold(
      appBar: AppBar(title: Text('NexaChat'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Icon(Icons.chat_bubble, size: 88, color: gold),
            SizedBox(height: 20),
            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passCtl,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password (6+ chars)',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
              ),
            ),
            SizedBox(height: 12),
            if (message.isNotEmpty) ...[
              Text(message, style: TextStyle(color: Colors.redAccent)),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading ? CircularProgressIndicator() : Text('Login'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    child: loading ? CircularProgressIndicator() : Text('Register'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('For testing, create an account or use Firebase console to add users.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gold = Color(0xFFCFA84D);
    final auth = Provider.of<AuthState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('NexaChat Home'),
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: Icon(Icons.logout, color: gold),
          )
        ],
      ),
      body: Center(
        child: Text('Welcome to NexaChat', style: TextStyle(color: gold, fontSize: 20)),
      ),
    );
  }
}
