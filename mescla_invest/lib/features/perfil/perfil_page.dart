// Feito por Gustavo Lieb RA: 24023376
//carteira digital e historico de transacoes feito por Yuri Soares da Silva RA: 25008703
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
  // Controla se o 2FA está ativado ou não
  bool is2FAEnabled = false;

  // Armazena a imagem de perfil selecionada localmente
  File? _profileImage;

  // Instância do seletor de imagem da galeria
  final ImagePicker _picker = ImagePicker();

  // Instância do Firebase Functions apontando para a região do Brasil
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  // ─── Streams ─────────────────────────────────────────────────────────────

  // Retorna um stream com o saldo em tempo real do usuário logado
  Stream<double> _saldoStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0.0); // Sem usuário, retorna 0
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(user.uid)
        .snapshots()
        .map((doc) => (doc.data()?['saldo'] as num?)?.toDouble() ?? 0.0);
  }

  // Retorna um stream com as operações (depósitos/saques) do usuário, ordenadas por data
  Stream<QuerySnapshot> _movimentacoesStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('carteiras')
        .doc(uid)
        .collection('operacoes')
        .orderBy('realizadoEm', descending: true)
        .snapshots();
  }

  // Retorna um stream com as transações de tokens do usuário no mercado primário
  Stream<QuerySnapshot> _tokensStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('mercadoPrimario')
        .where('uid', isEqualTo: uid)
        .orderBy('data', descending: true)
        .snapshots();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  // Formata um double para o padrão monetário brasileiro (ex: R$ 1.500,00)
  String _formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  // Formata um Timestamp do Firestore para string legível (DD/MM/AAAA HH:MM)
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

  // Abre um Dialog com abas de histórico de Saldo e Tokens
  void _abrirHistorico() {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 2, // Duas abas: Saldo e Tokens
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 40),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65, // 65% da altura da tela
              child: Column(
                children: [
                  // ── Cabeçalho do dialog com ícone e botão de fechar ──
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

                  // ── Barra de abas ──
                  const TabBar(
                    indicatorColor: Color(0xff2453ff),
                    labelColor: Color(0xff2453ff),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Saldo"),
                      Tab(text: "Tokens"),
                    ],
                  ),

                  // ── Conteúdo de cada aba ──
                  Expanded(
                    child: TabBarView(
                      children: [
                        _listaMovimentacoes(), // Aba de movimentações de saldo
                        _listaTokens(),        // Aba de transações de tokens
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Lista de movimentações de saldo (aba "Saldo") ──
  Widget _listaMovimentacoes() {
    return StreamBuilder<QuerySnapshot>(
      stream: _movimentacoesStream(),
      builder: (context, snapshot) {
        // Enquanto carrega, exibe indicador de progresso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar."));
        }

        final docs = snapshot.data?.docs ?? [];

        // Se não há documentos, exibe estado vazio
        if (docs.isEmpty) {
          return _listaVazia("Nenhuma movimentação ainda.");
        }

        // Monta a lista de cards de movimentação
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final tipo = data['tipo'] as String? ?? '';
            final valor = (data['valor'] as num?)?.toDouble() ?? 0.0;
            final timestamp = data['realizadoEm'] as Timestamp?;
            final isDeposito = tipo == 'deposito';

            // Renderiza card diferenciado por tipo (depósito = verde / saque = vermelho)
            return _itemCard(
              icone: isDeposito
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              corIcone: isDeposito ? Colors.green : Colors.red,
              titulo: isDeposito ? "Depósito" : "Saque",
              subtitulo: _formatarData(timestamp),
              valor: "${isDeposito ? '+' : '-'} ${_formatarMoeda(valor)}",
              corValor: isDeposito ? Colors.green : Colors.red,
            );
          },
        );
      },
    );
  }

  // ── Lista de transações de tokens (aba "Tokens") ──
  Widget _listaTokens() {
    return StreamBuilder<QuerySnapshot>(
      stream: _tokensStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar."));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _listaVazia("Nenhuma transação de tokens ainda.");
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final tipo = data['tipo'] as String? ?? '';
            final startupId = data['startupId'] as String? ?? '';
            final quantidade = (data['quantidade'] as num?)?.toInt() ?? 0;
            final valorTotal = (data['valorTotal'] as num?)?.toDouble() ?? 0.0;
            final valorUnitario =
                (data['valorUnitario'] as num?)?.toDouble() ?? 0.0;
            final timestamp = data['data'] as Timestamp?;
            final isCompra = tipo == 'compra';

            // Exibe compra (verde) ou venda (vermelho) com detalhes da startup
            return _itemCard(
              icone: isCompra
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              corIcone: isCompra ? Colors.green : Colors.red,
              titulo: "${isCompra ? 'Compra' : 'Venda'} · $startupId",
              subtitulo:
                  "$quantidade token${quantidade > 1 ? 's' : ''} · R\$ ${valorUnitario.toStringAsFixed(2).replaceAll('.', ',')} cada\n${_formatarData(timestamp)}",
              valor: "${isCompra ? '-' : '+'} ${_formatarMoeda(valorTotal)}",
              corValor: isCompra ? Colors.red : Colors.green,
            );
          },
        );
      },
    );
  }

  // ── Card reutilizável para exibir qualquer item de lista ──
  Widget _itemCard({
    required IconData icone,
    required Color corIcone,
    required String titulo,
    required String subtitulo,
    required String valor,
    required Color corValor,
  }) {
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
            // Ícone colorido com fundo suave
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: corIcone.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: corIcone, size: 20),
            ),
            const SizedBox(width: 12),
            // Título e subtítulo à esquerda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Valor colorido à direita
            Text(
              valor,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: corValor),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget exibido quando uma lista está vazia ──
  Widget _listaVazia(String mensagem) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            mensagem,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ─── SAQUE ────────────────────────────────────────────────────────────────

  // Abre dialog para o usuário digitar o valor do saque e chama a Cloud Function
  Future<void> _iniciarSaque() async {
    final valorController = TextEditingController();

    // Exibe dialog para entrada do valor
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

    // Cancela se o valor for nulo ou inválido
    if (valor == null || valor <= 0) return;

    try {
      // Chama a Cloud Function 'sacar' passando o valor
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
      // Erro vindo da Cloud Function (ex: saldo insuficiente)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao sacar: ${e.message ?? e.code}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Erro inesperado genérico
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

  // Primeiro passo: coleta o valor que o usuário deseja depositar
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

    // Se valor válido, avança para confirmação de pagamento
    if (valorInformado != null && valorInformado > 0) {
      _perguntarSePagou(valorInformado);
    }
  }

  // Segundo passo: pergunta se o pagamento externo já foi efetuado
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
        // Chama a Cloud Function 'depositar' para registrar o saldo
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
      // Se não pagou, pergunta se quer cancelar ou tentar novamente
      _perguntarSeCancela(valor);
    }
  }

  // Terceiro passo (opcional): confirma se o usuário quer cancelar o depósito
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

    // Se escolheu "Voltar", retorna ao passo de confirmação de pagamento
    if (cancelou == false) {
      _perguntarSePagou(valor);
    }
    // Se confirmou cancelamento, o fluxo termina sem fazer nada
  }

  // ─── IMAGEM DE PERFIL ─────────────────────────────────────────────────────

  // Abre a galeria do dispositivo e atualiza a foto de perfil localmente
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
      // Escuta mudanças de autenticação em tempo real
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          // Enquanto não há dados de autenticação, mostra loading
          if (!authSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Foto de perfil com botão de edição ──
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Avatar: mostra imagem local ou ícone padrão
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
                          // Botão de câmera posicionado no canto inferior direito
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
                      // Nome e e-mail do usuário logado
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

                // ── Card de carteira com saldo e ações ──
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
                        // ── Saldo em tempo real via stream ──
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

                        // ── Botões de ação: Depositar e Sacar lado a lado ──
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

                        // ── Botão para abrir o histórico de movimentações ──
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

                // ── Tile de navegação para editar dados pessoais ──
                buildTile(
                  icon: Icons.person_outline,
                  title: "Dados Pessoais",
                  subtitle: "Editar informações da conta",
                  onTap: () {
                    // TODO: navegar para EditarDadosPessoaisPage
                  },
                ),

                // ── Tile de configuração do 2FA com status dinâmico ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        // TODO: navegar para a página de configuração do 2FA
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
                                  // Texto muda conforme o estado do 2FA
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

                // ── Tile de suporte ──
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

  // ─── WIDGET DO HISTÓRICO (versão inline, atualmente não utilizada na UI) ──

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

              // Mapeia cada documento em um card de movimentação
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
                          // Ícone colorido por tipo
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

                          // Tipo, descrição e data
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
                                // Exibe descrição apenas se existir
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

                          // Valor com sinal e cor
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

  // Widget reutilizável para itens de menu com ícone, título, subtítulo e seta
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
                // Ícone com fundo azul suave
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
                // Seta indicando que é navegável
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