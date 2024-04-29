import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrical Genius',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        hintColor: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.grey[300],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo),
            )),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyrical Genius'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist Name',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _songController,
                decoration: const InputDecoration(
                  labelText: 'Song Title',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lyricsController,
                decoration: const InputDecoration(
                  labelText: 'Lyrics',
                ),
                maxLines: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLyrics,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('lyricCollection').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final List<QueryDocumentSnapshot> documents =
                      snapshot.data!.docs;
                  if (documents.isEmpty) {
                    return const Text("No Lyrics Available");
                  }

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final lyricsData =
                          documents[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(
                            '${lyricsData['artist']} - ${lyricsData['song']}'),
                        subtitle: Text(lyricsData['lyrics']),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLyrics() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String artist = _artistController.text;
    String song = _songController.text;
    String lyrics = _lyricsController.text;

    if (artist.isNotEmpty && song.isNotEmpty && lyrics.isNotEmpty) {
      firestore.collection('lyricCollection').doc().set({
        'artist': artist,
        'song': song,
        'lyrics': lyrics,
      }).then((value) {
        if (kDebugMode) {
          print('Data added successfully');
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('Error adding data: $error');
        }
      });

      _artistController.clear();
      _songController.clear();
      _lyricsController.clear();
    }
  }
}
