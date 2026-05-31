//Feito por Gustavo Lieb RA: 24023376
//carteira digital feito por Yuri Soares da Silva RA: 25008703
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool is2FAEnabled = false;
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  // ─── Streams ─────────────────────────────────────────────────────────────

  Stream<Map<String, double>> _carteiraStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return Stream.value({'saldo': 0.0, 'saldoReservado': 0.0});
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(user.uid)
        .snapshots()
        .map(
          (doc) => {
            'saldo': (doc.data()?['saldo'] as num?)?.toDouble() ?? 0.0,
            'saldoReservado':
                (doc.data()?['saldoReservado'] as num?)?.toDouble() ?? 0.0,
          },
        );
  }

  // todas as operações ficam em 'operacoes'
  Stream<QuerySnapshot> _movimentacoesStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(uid)
        .collection('operacoes')
        .orderBy('realizadoEm', descending: true)
        .snapshots();
  }

  // ─── Logout ──────────────────────────────────────────────────────────────

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return "--";
    final dt = timestamp.toDate();
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  // ─── HISTÓRICO ───────────────────────────────────────────────────────────

  void _abrirHistorico() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 40,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xff2453ff),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Histórico",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _movimentacoesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Erro ao carregar histórico."),
                        );
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Nenhuma movimentação ainda.",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final tipo = data['tipo'] as String? ?? '';
                          final valor =
                              (data['valor'] as num?)?.toDouble() ?? 0.0;
                          final timestamp = data['realizadoEm'] as Timestamp?;
                          final isDeposito = tipo == 'deposito';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xfff5f6fa),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDeposito
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isDeposito
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: isDeposito
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDeposito ? "Depósito" : "Saque",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _formatarData(timestamp),
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${isDeposito ? '+' : '-'} ${_formatarMoeda(valor)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDeposito
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── SAQUE ────────────────────────────────────────────────────────────────

  Future<void> _iniciarSaque() async {
    final valorController = TextEditingController();

    final double? valor = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sacar Saldo"),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Valor do saque",
              prefixText: "R\$ ",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final valorDigitado = double.tryParse(
                  valorController.text.replaceAll(',', '.'),
                );
                Navigator.pop(context, valorDigitado);
              },
              child: const Text("Sacar"),
            ),
          ],
        );
      },
    );

    if (valor == null || valor <= 0) return;

    try {
      await _functions.httpsCallable('sacar').call({'valor': valor});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saque realizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao sacar: ${e.message ?? e.code}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── DEPÓSITO ─────────────────────────────────────────────────────────────

  Future<void> _iniciarAdicaoSaldo() async {
    final valorController = TextEditingController();

    final double? valorInformado = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar Saldo"),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Valor a depositar",
              hintText: "Ex: 150.50",
              prefixText: "R\$ ",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(
                  valorController.text.replaceAll(',', '.'),
                );
                Navigator.pop(context, valor);
              },
              child: const Text("Continuar"),
            ),
          ],
        );
      },
    );

    if (valorInformado != null && valorInformado > 0) {
      _perguntarSePagou(valorInformado);
    }
  }

  Future<void> _perguntarSePagou(double valor) async {
    final bool? pagou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmação de Depósito"),
          content: Text(
            "O pagamento no valor de ${_formatarMoeda(valor)} foi efetuado?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sim"),
            ),
          ],
        );
      },
    );

    if (pagou == true) {
      try {
        await _functions.httpsCallable('depositar').call({'valor': valor});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Saldo atualizado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseFunctionsException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao depositar: ${e.message ?? e.code}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (pagou == false) {
      _perguntarSeCancela(valor);
    }
  }

  Future<void> _perguntarSeCancela(double valor) async {
    final bool? cancelou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atenção"),
          content: const Text("Deseja cancelar a adição de saldo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Voltar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Sim, Cancelar"),
            ),
          ],
        );
      },
    );

    if (cancelou == false) {
      _perguntarSePagou(valor);
    }
  }

  // ─── IMAGEM ───────────────────────────────────────────────────────────────

  Future<void> pickImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image == null) return;

  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child('fotoPerfil/$uid.jpg');

    if (kIsWeb) {
      // Web: usa bytes em vez de File
      final bytes = await image.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      // Mobile: usa File normalmente
      final file = File(image.path);
      setState(() => _profileImage = file); // preview local só no mobile
      await ref.putFile(file);
    }

    final url = await ref.getDownloadURL();

    await FirebaseAuth.instance.currentUser!.updatePhotoURL(url);
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted) setState(() {});

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .set({'fotoUrl': url}, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    debugPrint('Erro ao salvar foto: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar foto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Meu Perfil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (!authSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Foto de perfil ──
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: const Color(0xff2453ff).withOpacity(0.15),
                            backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                                ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                                : (!kIsWeb && _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null) as ImageProvider?,
                            child: FirebaseAuth.instance.currentUser?.photoURL == null &&
                                    (kIsWeb || _profileImage == null)
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
                        user.displayName ?? 'Usuário',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ── Card Carteira ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xff2453ff), Color(0xff1d3ed8)],
                      ),
                    ),
                    child: StreamBuilder<Map<String, double>>(
                      stream: _carteiraStream(),
                      builder: (context, snapshot) {
                        final saldo = snapshot.data?['saldo'] ?? 0.0;
                        final saldoReservado =
                            snapshot.data?['saldoReservado'] ?? 0.0;
                        final carregando =
                            snapshot.connectionState == ConnectionState.waiting;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // saldo disponível
                            const Text(
                              "Saldo Disponível",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            carregando
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    _formatarMoeda(saldo),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                            // saldo reservado — só aparece se > 0
                            if (!carregando && saldoReservado > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    color: Colors.redAccent,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${_formatarMoeda(saldoReservado)} em negociação",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // botões depositar / sacar
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: _iniciarAdicaoSaldo,
                                      icon: const Icon(Icons.add),
                                      label: const Text("Depositar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xff2453ff,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: _iniciarSaque,
                                      icon: const Icon(Icons.remove),
                                      label: const Text("Sacar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // botão histórico
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _abrirHistorico,
                                icon: const Icon(Icons.receipt_long_outlined),
                                label: const Text("Ver Histórico"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Colors.white54,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ── Dados Pessoais ──
                buildTile(
                  icon: Icons.person_outline,
                  title: "Dados Pessoais",
                  subtitle: "Editar informações da conta",
                  onTap: () {},
                ),

                // ── 2FA ──
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
                      onTap: () {},
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

                // ── Ajuda ──
                buildTile(
                  icon: Icons.help_outline,
                  title: "Ajuda e Suporte",
                  subtitle: "Fale com nossa equipe",
                  onTap: () {},
                ),

                // ── Sair ──
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
                      onTap: _sair,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Text(
                                "Sair da conta",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
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

                const SizedBox(height: 30),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    color: const Color(0xff2453ff).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xff2453ff)),
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
                        style: const TextStyle(color: Colors.grey),
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
