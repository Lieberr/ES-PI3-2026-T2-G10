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

class _BalcaoStartupPageState extends State<BalcaoStartupPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  List<Map<String, dynamic>> _ofertasCompra = [];
  List<Map<String, dynamic>> _ofertasVenda = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    carregarOfertas();
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
          _carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO getOfertasAbertas: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregando = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregando = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro ao aceitar oferta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.startup['nome'] ?? 'Balcão'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // Botão de criar oferta
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarOfertas,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // SEÇÃO COMPRA
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
                      (oferta) => _OfertaCard(
                        oferta: oferta,
                        tipo: 'compra',
                        uidAtual: uid ?? '',
                        onAceitar: () => aceitarOferta(oferta['id']),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // SEÇÃO VENDA
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
                      (oferta) => _OfertaCard(
                        oferta: oferta,
                        tipo: 'venda',
                        uidAtual: uid ?? '',
                        onAceitar: () => aceitarOferta(oferta['id']),
                      ),
                    ),

                  // Espaço para o FAB não cobrir o último item
                  const SizedBox(height: 80),
                ],
              ),
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

    // Oferta própria — não pode aceitar
    final isMinhaOferta =
        oferta['uidComprador'] == uidAtual || oferta['uidVendedor'] == uidAtual;

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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantidade e valor unitário
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

                // Valor total
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
                    const SizedBox(height: 4),
                    if (isMinhaOferta)
                      Container(
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

            // Botão aceitar — só aparece se não for a própria oferta
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
