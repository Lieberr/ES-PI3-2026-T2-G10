// Feito por Leonardo Dionel RA: 25010092

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CriarOfertaPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const CriarOfertaPage({super.key, required this.startup});

  @override
  State<CriarOfertaPage> createState() => _CriarOfertaPageState();
}

class _CriarOfertaPageState extends State<CriarOfertaPage> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );
  final _quantidadeController = TextEditingController();

  String _tipo = 'compra';
  int _quantidade = 0;
  bool _enviando = false;

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  double get _valorUnitario =>
      (widget.startup['valorToken'] as num?)?.toDouble() ?? 0;
  double get _valorTotal => _quantidade * _valorUnitario;

  Future<void> criarOferta() async {
    if (_quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }
    if (_enviando) return;
    setState(() => _enviando = true);

    try {
      final callable = _functions.httpsCallable('criarOfertaBalcao');
      await callable.call({
        'startupId': widget.startup['id'],
        'quantidade': _quantidade,
        'tipo': _tipo,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta criada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro ao criar oferta.')),
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
    final isCompra = _tipo == 'compra';
    final cor = isCompra
        ? const Color(0xFF2563EB)
        : const Color.fromRGBO(245, 73, 0, 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Criar Oferta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.startup['imagem'] ??
                          'https://picsum.photos/300/200',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.startup['nome'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${_formatarReal(_valorUnitario)} por token',
                        style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SELETOR DE TIPO
            const Text(
              'Tipo de oferta',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tipo = 'compra'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tipo == 'compra'
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2563EB)),
                      ),
                      child: Center(
                        child: Text(
                          'Compra',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tipo == 'compra'
                                ? Colors.white
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tipo = 'venda'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tipo == 'venda'
                            ? const Color.fromRGBO(245, 73, 0, 1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(245, 73, 0, 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Venda',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tipo == 'venda'
                                ? Colors.white
                                : const Color.fromRGBO(245, 73, 0, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // QUANTIDADE
            const Text(
              'Quantidade de tokens',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  setState(() => _quantidade = int.tryParse(v) ?? 0),
              decoration: InputDecoration(
                hintText: 'Ex: 100',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cor, width: 1.5),
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
                    'R\$ ${_formatarReal(_valorUnitario)}',
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_formatarReal(_valorTotal)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cor,
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
                onPressed: _enviando ? null : criarOferta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                    : Text(
                        isCompra
                            ? 'Confirmar oferta de compra'
                            : 'Confirmar oferta de venda',
                        style: const TextStyle(
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
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
