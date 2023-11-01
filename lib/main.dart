import 'dart:convert';
import 'pick_export.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _email = '';
  String _password = '';
  String _token = '';

  Image? _img;
  Text? _text;

  String _installId = '';

  Future<void> _download() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference imageRef = storage.ref().child('dl').child('namib-desert-live-camera-2.jpg');
    String imageUrl = await imageRef.getDownloadURL();
    Reference textRef = storage.ref('dl/aa.txt');
    var data = await textRef.getData();

    setState(() {
      _img = Image.network(imageUrl);
      _text = Text(ascii.decode(data!));
    });

    // FIXME: does not work on web
    //Directory appDocDir = await getApplicationDocumentsDirectory();
    //File downloadToFile = File('${appDocDir.path}/download-namib.jpg');
    //try {
    //  await imageRef.writeToFile(downloadToFile);
    //} catch (e) {
    //  print(e);
    //}
  }

  // for web
  void _upload() async {
    try {
      Uint8List? uint8list = await Pick().pickFile();
      if (uint8list == null) {
        return;
      }
      //File file = File(uint8list.path);
      FirebaseStorage storage = FirebaseStorage.instance;
      var metadata = SettableMetadata(contentType: "img/jpeg");
      storage.ref('ul/upload-pic.png').putData(uint8list, metadata);
      setState(() {
        _img = null;
        _text = const Text('upload done');
      });
    } catch (e) {
      print(e);
    }
    
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('installid:$_installId'),
              Text(_token), 

              if (_img != null) _img!,
              if (_text != null) _text!,
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                    .collection('col1')
                    .doc('doc1')
                    .set({'autofield2': 'auto2'}, SetOptions(merge: true));
                  FirebaseFirestore.instance
                    .collection('col1')
                    .add({'autofield3': 'xxxxx'});
                }, 
                child: const Text('exec', style: TextStyle(fontSize: 50),)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'mail address'),
                onChanged: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'password'),
                onChanged: (String value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  try {
                    final User? user = (await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(email: _email, password: _password)).user;
                    if (user != null) {
                      print('successfull created user: ${user.email}, ${user.uid}');
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('user touroku')
              ),

              ElevatedButton(
                onPressed: () async {
                  try {
                    final User? user = (await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: _email, password: _password)).user;
                    if (user != null) {
                      print('logged in as: ${user.email}, ${user.uid}');
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('log in')),
              
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
                    print('sent an email to reset a password');
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('Password reset')),
            ],)
        ),
      ),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        FloatingActionButton(onPressed: _download, child: const Icon(Icons.download_outlined),
        ),
        FloatingActionButton(onPressed: _upload, child: const Icon(Icons.upload_outlined),
        ),
      ],),
    );
  }
}
