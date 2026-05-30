// Feito por gustavo lieb RA: 24023376

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DepositarPage extends StatefulWidget {
  const DepositarPage({super.key});
  
  @override
  State<DepositarPage> createState() => _DepositarPageState();
}

class _DepositarPageState extends State<DepositarPage> {
  final _valorController = TextEditingController();
  bool _carregando = false;

  Future<void> _depositar() async {
    final valorText = _valorController.text.trim();
    if(valorText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Informe o valor."),
        )
      );
      return;
    }

    final valor = double.tryParse(valorText.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Valor inválido."),
        )
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final callable = FirebaseFunctions
            .instanceFor(region: "southamerica-east1")
            .httpsCallable('depositar');
      
      await callable.call({'valor': valor});

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Depósito realizado com sucesso!"),
          )
        );
        Navigator.pop(context);
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Erro ao depositar."),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro inesperado."),
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Depositar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.arrow_downward,
                    size: 60,
                    color: Color(0xff2453ff),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Quanto deseja depositar?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      hintText: '0,00',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _carregando ? null : _depositar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2453ff),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar Depósito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}