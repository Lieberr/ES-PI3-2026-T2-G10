import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mescla_invest/features/perfil/tabs/editarDadosPessoais_page.dart';
import 'package:mescla_invest/features/perfil/tabs/2FA_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

  Stream<double> _saldoStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0.0);
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(user.uid)
        .snapshots()
        .map((doc) => (doc.data()?['saldo'] as num?)?.toDouble() ?? 0.0);
  }

  Stream<QuerySnapshot> _movimentacoesStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(uid)
        .collection('operacoes')
        .orderBy('realizadoEm', descending: true)
        .snapshots();
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
              horizontal: 16, vertical: 40),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                // ── Cabeçalho ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: Color(0xff2453ff)),
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

                // ── Lista ──
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _movimentacoesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
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
                              Icon(Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                "Nenhuma movimentação ainda.",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15),
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
                                  // ── Ícone ──
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDeposito
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(12),
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

                                  // ── Descrição e data ──
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDeposito
                                              ? "Depósito"
                                              : "Saque",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 3),

                                        Text(
                                          _formatarData(timestamp),
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── Valor ──
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro inesperado: $e"),
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro inesperado: $e"),
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

  // ─── IMAGEM DE PERFIL ─────────────────────────────────────────────────────

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
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
                            backgroundColor:
                                const Color(0xff2453ff).withOpacity(0.15),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Color(0xff2453ff))
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
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user.displayName ?? 'Usuário',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 15),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Saldo ──
                        const Text(
                          "Saldo Disponível",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<double>(
                          stream: _saldoStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                  color: Colors.white);
                            }
                            if (snapshot.hasError) {
                              return const Text("Erro ao carregar",
                                  style:
                                      TextStyle(color: Colors.white70));
                            }
                            return Text(
                              _formatarMoeda(snapshot.data ?? 0.0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Botões Depositar / Sacar ──
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
                                    foregroundColor:
                                        const Color(0xff2453ff),
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

                        // ── Botão Histórico ──
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _abrirHistorico,
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text("Ver Histórico"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withOpacity(0.15),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(
                                  color: Colors.white54, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ── Dados Pessoais ──
                buildTile(
                  icon: Icons.person_outline,
                  title: "Dados Pessoais",
                  subtitle: "Editar informações da conta",
                  onTap: () {
                    // Navigator aqui
                  },
                ),

                // ── 2FA ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        // Navigator aqui
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xff2453ff)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield_outlined,
                                  color: Color(0xff2453ff)),
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
                                        fontSize: 16),
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
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
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

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── WIDGET DO HISTÓRICO ──────────────────────────────────────────────────

  Widget _buildHistorico() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Movimentações",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _movimentacoesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("Erro ao carregar histórico."),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          "Nenhuma movimentação ainda.",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final tipo = data['tipo'] as String? ?? '';
                  final valor =
                      (data['valor'] as num?)?.toDouble() ?? 0.0;
                  final timestamp = data['data'] as Timestamp?;
                  final descricao = data['descricao'] as String? ?? '';
                  final isDeposito = tipo == 'deposito';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // ── Ícone ──
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
                              color:
                                  isDeposito ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ── Tipo e data ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDeposito ? "Depósito" : "Saque",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 3),
                                if (descricao.isNotEmpty)
                                  Text(
                                    descricao,
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12),
                                  ),
                                Text(
                                  _formatarData(timestamp),
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // ── Valor ──
                          Text(
                            "${isDeposito ? '+' : '-'} ${_formatarMoeda(valor)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  isDeposito ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── TILE GENÉRICO ────────────────────────────────────────────────────────

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
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}