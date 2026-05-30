//Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mescla_invest/features/perfil/tabs/editarDadosPessoais_page.dart';
import 'package:mescla_invest/features/perfil/tabs/2FA_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:convert';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool is2FAEnabled = false;
  File? _profileImage;
  String? displayName;
  String? email;
  String? _photoUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 50, // comprime bastante para caber no Firestore
  );

  if (image == null) return;

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  try {
    final bytes = await image.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'fotoUrl': base64Image});

    setState(() => _photoUrl = base64Image);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada com sucesso.')),
      );
    }
  } catch (e) {
    print('Erro: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar foto.')),
      );
    }
  }
}

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    displayName = user?.displayName ?? "Usuario Demo";
    email = user?.email ?? "usuario@gmail.com";
    _photoUrl = user?.photoURL;

  // busca a foto salva no Firestore
  final uid = user?.uid;
  if (uid != null) {
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        final fotoUrl = doc.data()?['fotoUrl'];
        if (fotoUrl != null && mounted) {
          setState(() => _photoUrl = fotoUrl);
        }
      }
    });
  }

  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Meu Perfil",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //Foto de perfil
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                       radius: 55,
                        backgroundColor: const Color(0xff2453ff).withOpacity(0.15),
                        backgroundImage: _photoUrl != null
                          ? (_photoUrl!.startsWith('data:')
                              ? MemoryImage(base64Decode(_photoUrl!.split(',')[1]))
                              : NetworkImage(_photoUrl!) as ImageProvider)
                          : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.person, size: 60, color: Color(0xff2453ff))
                            : null,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xff2453ff),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    displayName ?? 'Usuario Demo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email ?? 'usuario@gmail.com',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
          
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

           

            // Opcoes
            buildTile(
              icon: Icons.person_outline,
              title: "Dados Pessoais",
              subtitle: "Editar informações da conta",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalDataPage(),
                  )
                );
              },
            ),


            //2FA
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Email2FAPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xff2453ff).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xff2453ff),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Autenticação 2FA",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                is2FAEnabled
                                    ? "Proteção Ativada"
                                    : "Clique para configurar",
                                style: TextStyle(
                                  color: is2FAEnabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            buildTile(
              icon: Icons.help_outline,
              title: "Ajuda e Suporte",
              subtitle: "Fale com nossa equipe",
              onTap: () {},
            ),

            const SizedBox(height: 30),

            
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: 
                          const Color(0xff2453ff).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xff2453ff),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
