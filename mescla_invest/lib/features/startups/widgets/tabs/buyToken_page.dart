// Feito por Leonardo Dionel RA: 25010092
// Feito por Gustavo Lieb RA: 24023376 (primeira versao da tela)


import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BuyTokenPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const BuyTokenPage({super.key, required this.startup});

  @override
  State<BuyTokenPage> createState() => _BuyTokenPageState();
}

class _BuyTokenPageState extends State<BuyTokenPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );
  final _controller = TextEditingController();

  int _quantidade = 0;
  bool _enviando = false;
  double _saldo = 0;
  int _meuTokens = 0;
  bool _carregandoDados = true;

  double get _precoUnitario =>
      (widget.startup['valorToken'] as num?)?.toDouble() ?? 0;
  double get _total => _quantidade * _precoUnitario;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    try {
      final callable = _functions.httpsCallable('getCarteira');
      final result = await callable.call();
      final saldo = (result.data['saldo'] as num?)?.toDouble() ?? 0;
      final tokens = List<Map<String, dynamic>>.from(
        (result.data['tokens'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      );
      final tokenDaStartup = tokens.firstWhere(
        (t) => t['startupId'] == widget.startup['id'],
        orElse: () => {},
      );
      if (mounted) {
        setState(() {
          _saldo = saldo;
          _meuTokens = (tokenDaStartup['quantidade'] as num?)?.toInt() ?? 0;
          _carregandoDados = false;
        });
      }
    } catch (e) {
      debugPrint('ERRO getCarteira: $e');
      if (mounted) setState(() => _carregandoDados = false);
    }
  }

  Future<void> confirmarCompra() async {
    if (_quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }
    if (_enviando) return;
    setState(() => _enviando = true);

    try {
      final callable = _functions.httpsCallable('comprarTokenPrimario');
      await callable.call({
        'startupId': widget.startup['id'],
        'quantidade': _quantidade,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro ao realizar compra.')),
        );
      }
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.startup['nome'] ?? '';
    final imagem = widget.startup['imagem'] ?? 'https://picsum.photos/300/200';
    final disponiveis =
        (widget.startup['tokensDisponiveis'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Comprar Tokens'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO DA STARTUP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagem,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${_formatarReal(_precoUnitario)} por token',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_carregandoDados)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: _miniCard(
                      'Seu saldo',
                      'R\$ ${_formatarReal(_saldo)}',
                      Icons.wallet,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniCard(
                      'Meus tokens',
                      '$_meuTokens tokens',
                      Icons.token,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // INPUT DE QUANTIDADE
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  setState(() => _quantidade = int.tryParse(v) ?? 0),
              decoration: InputDecoration(
                labelText: 'Quantidade de tokens',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Disponíveis: ${_formatarMilhar(disponiveis)} tokens',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // RESUMO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _linhaResumo('Quantidade', '$_quantidade tokens'),
                  const SizedBox(height: 12),
                  _linhaResumo(
                    'Valor unitário',
                    'R\$ ${_formatarReal(_precoUnitario)}',
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_formatarReal(_total)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviando ? null : confirmarCompra,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirmar compra',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaResumo(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  static String _formatarMilhar(num valor) {
    return valor
        .toStringAsFixed(0)
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
  }
}

Widget _miniCard(String label, String valor, IconData icon, Color cor) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: cor.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(icon, color: cor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
