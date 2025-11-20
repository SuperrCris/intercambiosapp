import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
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
      
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(title: 'Intercambio Gutierrada'),
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

  void _navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 218),
      body: Stack(
         children: [        
          Positioned(
          left: 0,
          right: 0,
          top: 10,
          child: Text("Intercambios Gutierrada",textAlign: TextAlign.center,style: TextStyle(fontSize: 40,color: Colors.red,fontWeight: FontWeight.bold,fontFamily: 'Fortalesa'),)),
           Positioned(
                      left: 0,
          right: 0,
            top: 70,
            bottom: 80, // Reserve space for the bottom button
             child: Column(
             children: [
                      
                Text("Personas especiales:",style: TextStyle(fontSize: 16,color: const Color.fromARGB(255, 5, 182, 20),fontWeight: FontWeight.w600,)),
                Expanded(
                  child: Container(

                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                   decoration: BoxDecoration(
                                            color: Colors.white,
                                        border: Border.symmetric(
                      vertical: BorderSide(
                        color: const Color.fromARGB(66, 0, 0, 0),
                        width: 1.0,

                      ),
                       horizontal: BorderSide(
                        color: const Color.fromARGB(66, 0, 0, 0),
                        width: 1.0,

                      ),
                      
                    ),
                   ),
                    
                 child: FutureBuilder<Map<String, dynamic>>(
                  future: descargarParticipantes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 5,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cargando participantes...',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aún no hay participantes',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '¡Sé el primero en participar!',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final entry = data.entries.elementAt(index);
                        final photoUrl = entry.value['photoUrl'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          child: Card(
                           shadowColor: Colors.black,
                           elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: colores[index % colores.length],
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: photoUrl != null && photoUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colores[index % colores.length],
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return ClipOval(
                                            child: Image.asset(
                                              'recursos/burro.png',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                        'recursos/burro.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                              title: Text('${entry.value['nombre']}',style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),
                          ),),
                        );
                      },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No hay datos disponibles',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                 
                 ),
                ),),
                FutureBuilder<Map<String, dynamic>>(
                  future: descargarParticipantes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Total: ${snapshot.data!.length} participante${snapshot.data!.length != 1 ? 's' : ''}",
                          style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
             ]),
           ),

           Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 40, 11),
                  ),
                  onPressed: () => _navigateToRegistration(context),
                  child: Text(
                    "🎁Participar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamilyFallback: ['Noto Color Emoji'],
                    ),
                  ),
                ),
              ),
            ),
            )
    ]  ),

        

      
    );
  }
}
List<Color> colores = [
  Colors.red,
  Colors.blue,
  Colors.green,
];

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  XFile? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  String _generateUniqueId() {
    final random = Random();
    String id = '';
    for (int i = 0; i < 8; i++) {
      id += random.nextInt(10).toString();
    }
    return id;
  }

  Future<String> _getUniqueId() async {
    final firestore = FirebaseFirestore.instance;
    String id;
    bool exists = true;
    
    while (exists) {
      id = _generateUniqueId();
      final doc = await firestore.collection('participantes').doc(id).get();
      exists = doc.exists;
      if (!exists) return id;
    }
    return _generateUniqueId(); // fallback
  }

  Future<void> _submitRegistration() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se te olvido el nombre'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Generate unique ID
      final id = await _getUniqueId();
      
      String? photoUrl;
      
      // Upload photo if selected (optional)
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('$id.png');
        
        if (kIsWeb) {
          final bytes = await selectedImage!.readAsBytes();
          await storageRef.putData(bytes);
        } else {
          final file = File(selectedImage!.path);
          await storageRef.putFile(file);
        }
        
        photoUrl = await storageRef.getDownloadURL();
      }
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('participantes').doc(id).set({
        'nombre': nameController.text.trim(),
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        isLoading = false;
      });

      // Show success dialog with ID
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 248, 218),
          title: Text('¡Ecole! 🎉', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamilyFallback: ['Noto Color Emoji']),textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Guarda este numero', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  id,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('¡Si se te pierde, dile al Fer!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 218),
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(top:10),
            child: Text('✖️', style: TextStyle(color: Colors.white, fontSize: 24), textAlign: TextAlign.center,),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        title: Text('Registro del Intercambio', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '🎁',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamilyFallback: ['Noto Color Emoji'],
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    selectedImage = image;
                  });
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(width: 8, color: const Color.fromARGB(255, 255, 91, 91)),
                ),
                clipBehavior: Clip.antiAlias,
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(37),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: selectedImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return CircularProgressIndicator();
                                },
                              )
                            : Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📷', style: TextStyle(color: Colors.grey, fontSize: 50, fontFamilyFallback: ['Noto Color Emoji'])),
                          SizedBox(height: 8),
                          Text('Toca para agregar', style: TextStyle(color: Colors.grey, fontFamilyFallback: ['Noto Color Emoji'])),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 10),
            Text('(La foto es opcional)', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            Text('Nombre:', style: TextStyle(color: const Color.fromARGB(255, 182, 24, 3), fontWeight: FontWeight.w600, fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color.fromARGB(255, 255, 0, 0), fontWeight: FontWeight.w900, fontSize: 24),
              controller: nameController,
              decoration: InputDecoration(
                hintText: nombresPista[Random().nextInt(nombresPista.length)],
                hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 208, 0), fontWeight: FontWeight.w400, fontSize: 20),
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color.fromARGB(255, 255, 88, 88), width: 4),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color.fromARGB(255, 244, 54, 54), width: 5),
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: isLoading ? null : _submitRegistration,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '🎁 Participar',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamilyFallback: ['Noto Color Emoji']),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> nombresPista = [
  "Vampi...",
  "Querubin...",
  "Chalotruzas...",
  "Federico...",
  "Lupelotas...",
  "Cochuy..."
];

Future<Map<String, dynamic>> descargarParticipantes() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('participantes')
        .orderBy('createdAt', descending: false)
        .get();
    
    Map<String, dynamic> participantes = {};
    
    for (var doc in snapshot.docs) {
      // doc.id is the 8-digit ID, but we don't show it
      participantes[doc.id] = {
        'nombre': doc.data()['nombre'] ?? 'Sin nombre',
        'photoUrl': doc.data()['photoUrl'],
      };
    }
    
    return participantes;
  } catch (e) {
    print('Error al descargar participantes: $e');
    return {};
  }
}