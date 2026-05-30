// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SellTokenPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const SellTokenPage({super.key, required this.startup});

  @override
  State<SellTokenPage> createState() => _SellTokenPageState();
}

class _SellTokenPageState extends State<SellTokenPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );
  final _controller = TextEditingController();

  int _quantidade = 0;
  bool _enviando = false;

  double get _precoUnitario =>
      (widget.startup['valorToken'] as num?)?.toDouble() ?? 0;
  double get _total => _quantidade * _precoUnitario;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> confirmarVenda() async {
    if (_quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }
    if (_enviando) return;
    setState(() => _enviando = true);

    try {
      final callable = _functions.httpsCallable('venderTokenPrimario');
      await callable.call({
        'startupId': widget.startup['id'],
        'quantidade': _quantidade,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda realizada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro ao realizar venda.')),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Vender Tokens'),
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
                          color: Color.fromRGBO(245, 73, 0, 1),
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

            // INPUT
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
                    color: Color.fromRGBO(245, 73, 0, 1),
                    width: 1.5,
                  ),
                ),
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
                        'Você receberá',
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
                          color: Color.fromRGBO(245, 73, 0, 1),
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
                onPressed: _enviando ? null : confirmarVenda,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color.fromRGBO(245, 73, 0, 1),
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
                        'Confirmar venda',
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
}
