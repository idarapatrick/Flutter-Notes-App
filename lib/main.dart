import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/note_repository_impl.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/notes/notes_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepositoryImpl(),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepositoryImpl>()),
        child: RepositoryProvider(
          create: (_) => NoteRepositoryImpl(),
          child: BlocProvider(
            create: (context) =>
                NotesBloc(noteRepository: context.read<NoteRepositoryImpl>()),
            child: MaterialApp(
              title: 'Notes App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/signup': (context) => const SignupScreen(),
                '/home': (context) => const HomeScreen(),
                '/profile': (context) => const ProfileScreen(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a loader while Firebase initializes, then routes to the real home screen.
class FirebaseInitLoader extends StatelessWidget {
  const FirebaseInitLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const Scaffold(
            body: Center(child: Text('Firebase Initialized!')), // Placeholder
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Firebase init error: \\${snapshot.error}'),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
