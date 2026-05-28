import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mescla_invest/features/perfil/tabs/editarDadosPessoais_page.dart';
import 'package:mescla_invest/features/perfil/tabs/2FA_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool is2FAEnabled = false;
  File? _profileImage;
  
  // 1. Variável para controlar o saldo da carteira simulada
  double _saldoAtual = 10000.00;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // Função auxiliar para formatar o valor como Moeda (R$)
  String _formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  // --- FLUXO DA CARTEIRA DIGITAL ---

  // Passo 1: Pede o valor
  Future<void> _iniciarAdicaoSaldo() async {
    TextEditingController valorController = TextEditingController();

    double? valorInformado = await showDialog<double>(
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
                // Converte o texto para double (trocando vírgula por ponto se o usuário errar)
                double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
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

  // Passo 2: Confirma se pagou
  Future<void> _perguntarSePagou(double valor) async {
    bool? pagou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmação de Depósito"),
          content: Text("O pagamento no valor de ${_formatarMoeda(valor)} foi efetuado?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Respondeu Não
              child: const Text("Não"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), // Respondeu Sim
              child: const Text("Sim"),
            ),
          ],
        );
      },
    );

    if (pagou == true) {
      // Se pagou, atualiza o saldo e mostra aviso de sucesso
      setState(() {
        _saldoAtual += valor;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saldo atualizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (pagou == false) {
      // Se não pagou, vai pro passo 3
      _perguntarSeCancela(valor);
    }
  }

  // Passo 3: Pergunta se quer cancelar
  Future<void> _perguntarSeCancela(double valor) async {
    bool? cancelou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atenção"),
          content: const Text("Deseja cancelar a adição de saldo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Não quer cancelar
              child: const Text("Voltar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Quer cancelar
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Sim, Cancelar"),
            ),
          ],
        );
      },
    );

    if (cancelou == false) {
      // Se não quer cancelar, volta pra pergunta se pagou
      _perguntarSePagou(valor);
    } else if (cancelou == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Adição de saldo cancelada."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // Foto de perfil
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xff2453ff).withOpacity(0.15),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xff2453ff),
                              )
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
                  const Text(
                    "Usuario Demo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "usuario@gmail.com",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Card Saldo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff2453ff),
                      Color(0xff1d3ed8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Saldo Disponível",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      // 2. Aqui usamos a variável de saldo dinamicamente
                      _formatarMoeda(_saldoAtual),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        // 3. Chamamos o inicio do fluxo ao apertar o botão
                        onPressed: _iniciarAdicaoSaldo,
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Saldo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff2453ff),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Opcoes (mantidas iguais)
            buildTile(
              icon: Icons.person_outline,
              title: "Dados Pessoais",
              subtitle: "Editar informações da conta",
              onTap: () {
                // Mantenha seu Navigator aqui
              },
            ),

            // 2FA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    // Mantenha seu Navigator aqui
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
                                is2FAEnabled ? "Proteção Ativada" : "Clique para configurar",
                                style: TextStyle(
                                  color: is2FAEnabled ? Colors.green : Colors.grey,
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

  // Widget buildTile mantido inalterado
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
