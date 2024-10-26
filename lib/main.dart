import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://qpavyyivawjpafiewxcn.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXZ5eWl2YXdqcGFmaWV3eGNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk5NTgyODAsImV4cCI6MjA0NTUzNDI4MH0.hoJVzbagCbNjaAWwHKrdqtd3fjg8gO3O8RTUr3zMUik",
  );

  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: const Center(
            child: Text('Hello World!'),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return SimpleDialog(
                          title: const Text('Add a Note'),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          children: [
                            TextFormField(
                              onFieldSubmitted: (value) async {
                                await Supabase.instance.client
                                    .from('Test')
                                    .insert({'testtest': value});
                              },
                            )
                          ]);
                    }));
              },
              child: const Icon(Icons.add))),
    );
  }
}
