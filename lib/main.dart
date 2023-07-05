import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:RecycLIA/PageDeCam.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';


Future<void> main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.manual, overlays: []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecycLIA',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'RecycLIA'),
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

  @override
  initState() {
    SharedPreferences.getInstance().then(
            (value) => setState(() {
              _counter = value.getInt("contributions")??0;
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: ()=>montreInfos(), icon: const Icon(Icons.info_outline)),
          IconButton(
            onPressed: ()=>montreAide(),
            icon: const Icon(Icons.question_mark),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Contributions envoyées:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
                onPressed:  () async {
                  await availableCameras().then((value) => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PageDeCam(cameras: value))));
                },
                child: const Text("Nouvelle contribution")
            )
          ],
        ),
      ),

    );
  }

  montreInfos() {
    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Informations'),
              content: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Nous vous remercions de participer à notre beau projet! \nL\'application contributeur est développée et maintenue par IPIC-ASSO, dans le but d\'entrainer l\'intelligence artificielle RecycLIA.\nPour toute question, problème, réclamation ou suggestion, contactez nous à l\'adresse: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'contact@ipic-asso.fr',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await Clipboard.setData(const ClipboardData(text: "contact@ipic-asso.fr"));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('copié !'),
                            ));
                          },
                      ),
                      const TextSpan(
                        text: ' ou visitez ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'notre site',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://www.ipic-asso.fr'));
                          },
                      ),
                    ],
                  ),
                ),
              )
          );
        });
  }

  montreAide() {
    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Aide'),
              content: SingleChildScrollView(
                child:  RichText(
                  text:  TextSpan(
                    children: [
                       const TextSpan(
                        text: 'Le but de l\'application est de récolter des données sur les déchets, pour développer une intelligence artificielle qui indiquera comment les recycler. \nVotre mission, si vous l\'acceptez, est de prendre un déchet en photo, d\'indiquer où il faut le recycler pour que nous puissions entrainer avec ces données l\'IA\nSi vous avez besoin d\'une aide supplémentaire, contactez nous à l\'adresse: ',
                        style: TextStyle(color: Colors.black),
                      ),
                       TextSpan(
                        text: 'contact@ipic-asso.fr',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await Clipboard.setData(const ClipboardData(text: "contact@ipic-asso.fr"));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('copié !'),
                            ));
                          },
                      ),
                       const TextSpan(
                        text: ' ou visitez ',
                        style:  TextStyle(color: Colors.black),
                      ),
                       TextSpan(
                        text: 'notre site',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://www.ipic-asso.fr'));
                          },
                      ),
                    ],
                  ),
                ),
              )
          );
        });
  }
}
