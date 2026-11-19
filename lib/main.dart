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
import 'package:flutter_svg/flutter_svg.dart';

const _backgroundColor = Color(0xFF003510);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intercambios Gutierrada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(title: 'Intercambios Gutierrada'),
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
  late Future<Map<String, dynamic>> _participantsFuture;

  @override
  void initState() {
    super.initState();
    _participantsFuture = descargarParticipantes();
  }

  Future<void> _navigateToRegistration(BuildContext context) async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );

    if (registered == true && mounted) {
      setState(() {
        _participantsFuture = descargarParticipantes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: ParticipationBar(
        onPressed: () => _navigateToRegistration(context),
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: _ChristmasBackgroundPainter(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    CandyCaneHeader(
                      height: 96,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Fortalesa',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ParticipantsSection(future: _participantsFuture),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const ChristmasCornerDecorations(),
        ],
      ),
    );
  }
}

class ParticipantsSection extends StatelessWidget {
  const ParticipantsSection({super.key, required this.future});

  final Future<Map<String, dynamic>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        final participants = snapshot.data;
        final count = !waiting && !snapshot.hasError
            ? participants?.length
            : null;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Text(
                count == null
                    ? 'Personas especiales'
                    : '$count ${count == 1 ? 'persona especial' : 'personas especiales'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: waiting
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : snapshot.hasError
                  ? Center(
                      child: Text(
                        'Error al cargar participantes: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFFB4AB)),
                      ),
                    )
                  : participants == null || participants.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 72,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Aún no hay participantes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '¡Sé el primero en participar!',
                            style: TextStyle(color: Color(0xFFC8E6C9)),
                          ),
                        ],
                      ),
                    )
                  : _StaggeredPhotoGrid(entries: participants.entries.toList()),
            ),
          ],
        );
      },
    );
  }
}

class ChristmasCornerDecorations extends StatelessWidget {
  const ChristmasCornerDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -1,
            left: -1,
            child: _CornerDecoration(
              assetPath: 'recursos/bordes_superior_izquierdo.png',
              width: 90,
              height: 91,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  final String assetPath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      key: ValueKey(assetPath),
      width: width,
      height: height,
    );
  }
}

class ParticipationBar extends StatelessWidget {
  const ParticipationBar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ColoredBox(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _CandyCaneStripe(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 18,
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                    onPressed: onPressed,
                    child: const Text(
                      '🎁 Participar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamilyFallback: ['Noto Color Emoji'],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CandyCaneHeader extends StatelessWidget {
  const CandyCaneHeader({super.key, required this.child, this.height = 56});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: const Color(0xFFC62828),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: child,
                ),
              ),
            ),
            const _CandyCaneStripe(),
          ],
        ),
      ),
    );
  }
}

class _CandyCaneStripe extends StatelessWidget {
  const _CandyCaneStripe();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        key: const ValueKey('candy-cane-stripe'),
        height: 8,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const tileWidth = 16.0;
            final tileCount = (constraints.maxWidth / tileWidth).ceil() + 1;
            return Stack(
              children: [
                for (var index = 0; index < tileCount; index++)
                  Positioned(
                    left: index * tileWidth,
                    top: 0,
                    child: SvgPicture.asset(
                      'recursos/candy_cane_border.svg',
                      width: tileWidth,
                      height: 8,
                      fit: BoxFit.fill,
                      semanticsLabel: index == 0
                          ? 'Borde decorativo navideño'
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StaggeredPhotoGrid extends StatelessWidget {
  const _StaggeredPhotoGrid({required this.entries});

  final List<MapEntry<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var column = 0; column < 2; column++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: column == 0 ? 2 : 7,
                  right: column == 0 ? 7 : 2,
                  top: column == 0 ? 0 : 20,
                ),
                child: Column(
                  children: [
                    for (var index = column; index < entries.length; index += 2)
                      Padding(
                        padding: EdgeInsets.only(
                          top: index == column ? 0 : 14 + (index % 2) * 7,
                        ),
                        child: _ParticipantPhotoCard(
                          name:
                              entries[index].value['nombre']?.toString() ??
                              'Sin nombre',
                          photoUrl: entries[index].value['photoUrl'],
                          height: 224 + (index % 3) * 16,
                          tilt: index.isEven
                              ? -0.024 + -(Random().nextDouble() * 0.012)
                              : 0.012 + (Random().nextDouble() * 0.012),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticipantPhotoCard extends StatelessWidget {
  const _ParticipantPhotoCard({
    required this.name,
    required this.photoUrl,
    required this.height,
    required this.tilt,
  });

  final String name;
  final dynamic photoUrl;
  final double height;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = photoUrl is String && photoUrl.isNotEmpty
        ? photoUrl
        : null;
    return Transform.rotate(
      angle: tilt,
      child: Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 7,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'recursos/burro.png',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset('recursos/burro.png', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4E342E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _ChristmasBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _backgroundColor);

    final foliagePaint = Paint()..color = const Color(0xFF104B26);
    final trunkPaint = Paint()..color = const Color(0xFF50805A);
    final berryPaint = Paint()..color = const Color(0xFFAA605F);

    var row = 0;
    for (double y = 28; y < size.height + 28; y += 96) {
      for (double x = row.isEven ? 28 : 76; x < size.width + 28; x += 96) {
        final tree = Path()
          ..moveTo(x, y)
          ..lineTo(x - 11, y + 15)
          ..lineTo(x - 5, y + 15)
          ..lineTo(x - 14, y + 27)
          ..lineTo(x - 7, y + 27)
          ..lineTo(x - 16, y + 39)
          ..lineTo(x + 16, y + 39)
          ..lineTo(x + 7, y + 27)
          ..lineTo(x + 14, y + 27)
          ..lineTo(x + 5, y + 15)
          ..lineTo(x + 11, y + 15)
          ..close();
        canvas.drawPath(tree, foliagePaint);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y + 42), width: 5, height: 7),
          trunkPaint,
        );
        canvas.drawCircle(Offset(x - 5, y + 23), 2, berryPaint);
        canvas.drawCircle(Offset(x + 6, y + 32), 2, berryPaint);
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          content: const Text(
            'Se te olvido el nombre',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E7D32),
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
          backgroundColor: const Color(0xFFF1F8E9),
          title: Text(
            '¡Ecole! 🎉',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFamilyFallback: ['Noto Color Emoji'],
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Guarda este numero',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
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
              Text(
                '¡Si se te pierde, dile al Fer!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(
                  context,
                ).pop(true); // Refresh home after registration
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: _CandyCaneStripe(),
        ),
        leading: IconButton(
          tooltip: 'Salir del registro',
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Carta de Navidad',
          style: TextStyle(
            fontFamily: 'Fortalesa',
            fontSize: 26,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: _ChristmasBackgroundPainter(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  border: Border.all(color: const Color(0xFFC62828), width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Querido participante,',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontFamily: 'Fortalesa',
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escribe tu nombre y deja una foto para formar parte de este intercambio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
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
                    SizedBox(height: 20),
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
                          border: Border.all(
                            width: 8,
                            color: const Color.fromARGB(255, 255, 91, 91),
                          ),
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
                                  Text(
                                    '📷',
                                    style: TextStyle(
                                      color: const Color(0xFFC62828),
                                      fontSize: 50,
                                      fontFamilyFallback: ['Noto Color Emoji'],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Toca para agregar',
                                    style: TextStyle(
                                      color: const Color(0xFF795548),
                                      fontFamilyFallback: ['Noto Color Emoji'],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '(La foto es opcional)',
                      style: TextStyle(
                        color: const Color(0xFF795548),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nombre:',
                      style: TextStyle(
                        color: const Color(0xFF5D4037),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF3E2723),
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText:
                            nombresPista[Random().nextInt(nombresPista.length)],
                        hintStyle: TextStyle(
                          color: const Color(0xFF9E8A7A),
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFFC62828),
                            width: 4,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF2E7D32),
                            width: 5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFC62828),
                            width: 2,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        onPressed: isLoading ? null : _submitRegistration,
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                '🎁 Participar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamilyFallback: ['Noto Color Emoji'],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const ChristmasCornerDecorations(),
        ],
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
  "Cochuy...",
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
