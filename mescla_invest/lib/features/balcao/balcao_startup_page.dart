// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'criar_oferta_page.dart';

class BalcaoStartupPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const BalcaoStartupPage({super.key, required this.startup});

  @override
  State<BalcaoStartupPage> createState() => _BalcaoStartupPageState();
}

class _BalcaoStartupPageState extends State<BalcaoStartupPage>
    with SingleTickerProviderStateMixin {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  late TabController _tabController;

  List<Map<String, dynamic>> _ofertasCompra = [];
  List<Map<String, dynamic>> _ofertasVenda = [];
  List<Map<String, dynamic>> _historico = [];
  bool _carregandoOfertas = true;
  bool _carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Carrega o histórico só quando o usuário abre a aba pela primeira vez
      if (_tabController.index == 1 && _carregandoHistorico) {
        carregarHistorico();
      }
    });
    carregarOfertas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> carregarOfertas() async {
    try {
      final callable = _functions.httpsCallable('getOfertasAbertas');
      final result = await callable.call({'startupId': widget.startup['id']});

      final List ofertas = result.data['ofertas'] ?? [];
      final lista = ofertas.map((e) => Map<String, dynamic>.from(e)).toList();

      if (mounted) {
        setState(() {
          _ofertasCompra = lista.where((o) => o['tipo'] == 'compra').toList();
          _ofertasVenda = lista.where((o) => o['tipo'] == 'venda').toList();
          _carregandoOfertas = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getOfertasAbertas: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregandoOfertas = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregandoOfertas = false);
    }
  }

  Future<void> carregarHistorico() async {
    try {
      final callable = _functions.httpsCallable('getMinhasOfertas');
      final result = await callable.call();

      final List ofertas = result.data['ofertas'] ?? [];

      // Filtra só as ofertas desta startup
      final lista = ofertas
          .map((e) => Map<String, dynamic>.from(e))
          .where((o) => o['startupId'] == widget.startup['id'])
          .toList();

      if (mounted) {
        setState(() {
          _historico = lista;
          _carregandoHistorico = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getMinhasOfertas: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregandoHistorico = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregandoHistorico = false);
    }
  }

  Future<void> aceitarOferta(String ofertaId) async {
    try {
      final callable = _functions.httpsCallable('aceitarOferta');
      await callable.call({'ofertaId': ofertaId});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta aceita com sucesso!')),
        );
        carregarOfertas();
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'ERRO aceitarOferta: code=${e.code} | message=${e.message} | details=${e.details}',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${e.code}: ${e.message}')));
      }
    } catch (e) {
      debugPrint('ERRO GENERICO aceitarOferta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.startup['nome'] ?? 'Balcão'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: 'Ofertas Abertas'),
            Tab(text: 'Meu Histórico'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CriarOfertaPage(startup: widget.startup),
            ),
          );
          carregarOfertas();
        },
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Criar oferta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1 — OFERTAS ABERTAS
          _carregandoOfertas
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: carregarOfertas,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _secaoTitulo(
                        'Ofertas de Compra',
                        Icons.shopping_cart_outlined,
                        const Color(0xFF2563EB),
                      ),
                      const SizedBox(height: 12),
                      if (_ofertasCompra.isEmpty)
                        _mensagemVazia('Nenhuma oferta de compra aberta.')
                      else
                        ..._ofertasCompra.map(
                          (o) => _OfertaCard(
                            oferta: o,
                            tipo: 'compra',
                            uidAtual: uid,
                            onAceitar: () => aceitarOferta(o['id']),
                          ),
                        ),

                      const SizedBox(height: 24),

                      _secaoTitulo(
                        'Ofertas de Venda',
                        Icons.attach_money,
                        const Color.fromRGBO(245, 73, 0, 1),
                      ),
                      const SizedBox(height: 12),
                      if (_ofertasVenda.isEmpty)
                        _mensagemVazia('Nenhuma oferta de venda aberta.')
                      else
                        ..._ofertasVenda.map(
                          (o) => _OfertaCard(
                            oferta: o,
                            tipo: 'venda',
                            uidAtual: uid,
                            onAceitar: () => aceitarOferta(o['id']),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

          // ABA 2 — HISTÓRICO
          _carregandoHistorico
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: carregarHistorico,
                  child: _historico.isEmpty
                      ? const Center(
                          child: Text(
                            'Você ainda não participou\nde nenhuma oferta nesta startup.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black45),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _historico.length,
                          itemBuilder: (context, index) {
                            return _HistoricoCard(
                              oferta: _historico[index],
                              uidAtual: uid,
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  Widget _secaoTitulo(String titulo, IconData icon, Color cor) {
    return Row(
      children: [
        Icon(icon, color: cor, size: 20),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  Widget _mensagemVazia(String mensagem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(mensagem, style: const TextStyle(color: Colors.black45)),
      ),
    );
  }
}

// CARD DE OFERTA ABERTA
class _OfertaCard extends StatelessWidget {
  final Map<String, dynamic> oferta;
  final String tipo;
  final String uidAtual;
  final VoidCallback onAceitar;

  const _OfertaCard({
    required this.oferta,
    required this.tipo,
    required this.uidAtual,
    required this.onAceitar,
  });

  @override
  Widget build(BuildContext context) {
    final isCompra = tipo == 'compra';
    final cor = isCompra
        ? const Color(0xFF2563EB)
        : const Color.fromRGBO(245, 73, 0, 1);
    final isMinhaOferta =
        oferta['uidComprador'] == uidAtual || oferta['uidVendedor'] == uidAtual;
    final nomeCriador =
        oferta['nomeCriador'] as String? ?? 'Usuário desconhecido';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${oferta['quantidade']} tokens',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${_formatarReal(oferta['valorUnitario'] ?? 0)} por token',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${_formatarReal(oferta['valorTotal'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cor,
                      ),
                    ),
                    if (isMinhaOferta)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Sua oferta',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Nome do criador
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  isMinhaOferta ? 'Você' : nomeCriador,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: isMinhaOferta
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),

            if (!isMinhaOferta) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAceitar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isCompra
                        ? 'Aceitar — Vender meus tokens'
                        : 'Aceitar — Comprar tokens',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final formatada = partes[0].replaceAll(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      '.',
    );
    return '$formatada,${partes[1]}';
  }
}

// CARD DO HISTÓRICO
class _HistoricoCard extends StatelessWidget {
  final Map<String, dynamic> oferta;
  final String uidAtual;

  const _HistoricoCard({required this.oferta, required this.uidAtual});

  @override
  Widget build(BuildContext context) {
    final status = oferta['status'] as String? ?? '';
    final tipo = oferta['tipo'] as String? ?? '';
    final nomeComprador = oferta['nomeComprador'] as String? ?? 'Aguardando';
    final nomeVendedor = oferta['nomeVendedor'] as String? ?? 'Aguardando';
    final euSouComprador = oferta['uidComprador'] == uidAtual;
    final euSouVendedor = oferta['uidVendedor'] == uidAtual;

    // Cor e ícone do status
    final isFechada = status == 'fechada';
    final isCancelada = status == 'cancelada';
    final corStatus = isFechada
        ? Colors.green
        : isCancelada
        ? Colors.grey
        : const Color(0xFF2563EB);
    final labelStatus = isFechada
        ? 'Concluída'
        : isCancelada
        ? 'Cancelada'
        : 'Aberta';

    // Cor do tipo
    final corTipo = tipo == 'compra'
        ? const Color(0xFF2563EB)
        : const Color.fromRGBO(245, 73, 0, 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOPO — tipo + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: corTipo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tipo == 'compra' ? 'Compra' : 'Venda',
                    style: TextStyle(
                      color: corTipo,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labelStatus,
                    style: TextStyle(
                      color: corStatus,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // VALORES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${oferta['quantidade']} tokens',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${_formatarReal(oferta['valorTotal'] ?? 0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: corTipo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // COMPRADOR
            _linhaParticipante(
              'Comprador',
              nomeComprador,
              euSouComprador,
              Icons.shopping_cart_outlined,
              const Color(0xFF2563EB),
            ),

            const SizedBox(height: 8),

            // VENDEDOR
            _linhaParticipante(
              'Vendedor',
              nomeVendedor,
              euSouVendedor,
              Icons.attach_money,
              const Color.fromRGBO(245, 73, 0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaParticipante(
    String papel,
    String nome,
    bool euSou,
    IconData icon,
    Color cor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cor),
        const SizedBox(width: 6),
        Text(
          '$papel: ',
          style: const TextStyle(fontSize: 13, color: Colors.black45),
        ),
        Expanded(
          child: Text(
            euSou ? 'Você' : nome,
            style: TextStyle(
              fontSize: 13,
              fontWeight: euSou ? FontWeight.bold : FontWeight.normal,
              color: euSou ? Colors.black87 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (euSou)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Você',
              style: TextStyle(
                fontSize: 10,
                color: cor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  static String _formatarReal(num valor) {
    final texto = valor.toStringAsFixed(2);
    final partes = texto.split('.');
    final formatada = partes[0].replaceAll(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      '.',
    );
    return '$formatada,${partes[1]}';
  }
}
