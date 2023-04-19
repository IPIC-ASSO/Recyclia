import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:RecycLIA/icons.dart';
import 'package:RecycLIA/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NouvContribution extends StatefulWidget {

  final XFile picture;
  const NouvContribution({Key? key, required this.picture}) : super(key: key);

State<NouvContribution> createState() => _NouvContributionState();
}

class _NouvContributionState extends State<NouvContribution> {

  late int _selected = -1;
  bool visible = false;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage grosseDB = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Type de déchet')),
      body: ListView(
        children: [
          SizedBox(
            height: 100,
              width: 100,
              child:ListView(
            //shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              _icon(0, text: "Plastique", icon: Icons.recycling, couleur: Colors.yellow[800]??Colors.yellow),
              _icon(1, text: "Papier", icon: MyFlutterApp.newspaper,couleur: Colors.blue),
              _icon(2, text: "Verre", icon: MyFlutterApp.glass_martini_alt, couleur: Colors.green),
              _icon(3, text: "Matière organique", icon: Icons.fastfood, couleur: Colors.brown[400]??Colors.brown),
              _icon(4, text: "Non recyclable", icon: MyFlutterApp.trash_alt, couleur: Colors.red),
            ],
          )),
          Image.file(File(widget.picture.path), fit: BoxFit.cover, ),
        ]),
        floatingActionButton:Visibility(
          visible: visible,
          child:FloatingActionButton.extended(
          onPressed: (){envoieContri(File(widget.picture.path), _selected);},
          label: const Text("Envoyer"),
          icon: const Icon(Icons.send),
      )),
    );
  }
  Widget _icon(int index, {required String text, required IconData icon, required Color couleur}) {
    return SizedBox(
      width: 80.0,
      //padding: const EdgeInsets.all(16.0),
      child: InkResponse(
        child: Center(child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selected == index ? couleur : null,
            ),
            Text(text, style: TextStyle(
                color: _selected == index ? couleur : null)),
          ],
        )),
        onTap: () =>
            setState(() {
              visible = true;
               _selected = index;
              },
            ),
      ),
    );
  }

  envoieContri(File monFichier, int type){
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return AlertDialog(
          title: const Text('Envoi'),
          content: SingleChildScrollView(
          child:FutureBuilder<bool>(
          future: televerseFichier(monFichier,type),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            List<Widget> children;
            if (snapshot.hasData &&snapshot.data==true) {
              children = <Widget>[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Contribution envoyée'),
                ),
                ElevatedButton(onPressed: ()=>versAccueil(), child: const Text("OK"))
              ];
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ), ElevatedButton(onPressed: ()=>versAccueil(), child: const Text("OK"))
              ];
            } else {
              children = const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Envoi des données...'),
                ),
              ];
            }
            return Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
            ));
          })
          )
      );});
  }

  Future<bool> televerseFichier(File? monFichier, int type) async {
    String nomFichier = p.basename(monFichier?.path??"document inconnu");
    UploadTask uploadTask = chargeFichier(monFichier!, nomFichier);
    try {
      TaskSnapshot snapshot = await uploadTask;
      String URLmonFichier = await snapshot.ref.getDownloadURL();
      await reference(URLmonFichier, type);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("contributions", (prefs.getInt("contributions")??0) +1);
      return true;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    }
  }

  UploadTask chargeFichier(File fichier, String filename) {
    Reference reference = grosseDB.ref().child(filename);
    UploadTask uploadTask = reference.putFile(fichier);
    return uploadTask;
  }

  Future<bool> reference(String URL, int typePoubelle) async {
    await db.collection("images").doc(DateTime.now().millisecondsSinceEpoch.toString()).set({
      "url":URL,
      "type":typePoubelle
    });
    return true;
  }

  versAccueil(){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => const MyHomePage(
            title: 'RecycLIA'
        )));
  }
}
