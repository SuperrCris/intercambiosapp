import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

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

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _showParticipationDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              
              backgroundColor: const Color.fromARGB(255, 255, 248, 218),
              title: Text(
              
                '🎁',textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Registro del Intercambio",style: TextStyle(fontSize: 16,color: const Color.fromARGB(255, 182, 24, 3),fontWeight: FontWeight.w600,)),
                    SizedBox(height: 20),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(width: 3,color: const Color.fromARGB(255, 255, 91, 91)),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
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
                                Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Pon una foto', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      child: Text('📸Buscar',style: TextStyle(color: Colors.white),),
                    ),
                    SizedBox(height: 40),
                    Text('Nombre:', style: TextStyle(color: const Color.fromARGB(255, 182, 24, 3), fontWeight: FontWeight.w600, fontSize: 12)),
                    TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: const Color.fromARGB(255, 255, 0, 0), fontWeight: FontWeight.w900, fontSize: 18),
                      controller: nameController,
                      decoration: InputDecoration(
                      hintText: nombresPista[Random().nextInt(nombresPista.length)],
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 208, 0), fontWeight: FontWeight.w400, fontSize: 16),
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 255, 88, 88), width: 4),
                        
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 244, 54, 54), width: 5),
                      ),

                      ),

                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor ingresa tu nombre'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor selecciona una foto'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    // Here you can save the data to Firebase or handle it as needed
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Participación registrada! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(
                    'Participar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
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
          child: Text("🎄Intercambios Gutierrada🎅",textAlign: TextAlign.center,style: TextStyle(fontSize: 40,color: Colors.red,fontWeight: FontWeight.bold,fontFamily: 'Fortalesa'),)),
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
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final entry = data.entries.elementAt(index);
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
                          
                            leading: CircleAvatar(
                            ),
                              title: Text('${entry.value['nombre']}',style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),
                          ),),
                        );
                      },
                      );
                    } else {
                      return Text('No data available');
                    }
                  },
                 
                 ),
                ),),
             ]),
           ),

           Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 40, 11),
                  ),
                  onPressed: () => _showParticipationDialog(context),
                  child: Text(
                    "🎁 Participar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

List<String> nombresPista = [
  "Vampi...",
  "Querubin...",
  "Chalotruzas...",
  "Federico...",
  "Lupelotas...",
  "Cochuy..."
];
Future<Map<String, dynamic>> descargarParticipantes() async {
  // Simula una operación asíncrona, como una llamada a una API o una consulta a una base de datos
  await Future.delayed(Duration(seconds: 2));

  return {'232134':{"nombre":"Fernando"},'2321442':{"nombre":"Fernando"},'23214242':{"nombre":"Fernando"},'232142342':{"nombre":"Fernando"}
  ,'2232134':{"nombre":"Fernando"},'23214442':{"nombre":"Fernando"},'232142242':{"nombre":"Fernando"},'23214412':{"nombre":"Fernando"}
  };
}