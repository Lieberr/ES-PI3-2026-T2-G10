import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class QuestionsTab extends StatefulWidget {
  final Map<String, dynamic> startup;
  final bool canSendPrivateQuestion;

  const QuestionsTab({
    super.key,
    required this.startup,
    this.canSendPrivateQuestion = false,
  });

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  final _perguntaController = TextEditingController();
  bool _perguntaPrivada = false;
  bool _carregando = true;
  bool _enviando = false;
  List<Map<String, dynamic>> _perguntas = [];

  @override
  void initState() {
    super.initState();
    carregarPerguntas();
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }

  Future<void> carregarPerguntas() async {
    try {
      final callable = _functions.httpsCallable('listarPerguntas');
      final result = await callable.call({'startupId': widget.startup['id']});

      if (mounted) {
        setState(() {
          _perguntas = List<Map<String, dynamic>>.from(
            (result.data['perguntas'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
          _carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO listarPerguntas: ${e.code} | ${e.message}');
      if (mounted) setState(() => _carregando = false);
    } catch (e) {
      debugPrint('ERRO GENERICO: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> enviarPergunta() async {
    final texto = _perguntaController.text.trim();
    if (texto.isEmpty) return;
    if (_enviando) return;

    setState(() => _enviando = true);

    try {
      final callable = _functions.httpsCallable('criarPergunta');
      await callable.call({
        'startupId': widget.startup['id'],
        'texto': texto,
        'visibilidade': _perguntaPrivada ? 'privada' : 'publica',
      });

      _perguntaController.clear();
      setState(() => _perguntaPrivada = false);

      // Recarrega as perguntas após enviar
      await carregarPerguntas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pergunta enviada com sucesso!')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('ERRO criarPergunta: ${e.code} | ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro ao enviar pergunta.')),
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
    return Column(
      children: [
        // Campo para enviar nova pergunta
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _perguntaController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Envie uma pergunta para a startup...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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

              const SizedBox(height: 8),

              Row(
                children: [
                  // Opção de pergunta privada — só para investidores
                  if (widget.canSendPrivateQuestion) ...[
                    Checkbox(
                      value: _perguntaPrivada,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (v) =>
                          setState(() => _perguntaPrivada = v ?? false),
                    ),
                    const Text(
                      'Pergunta privada',
                      style: TextStyle(fontSize: 13),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),

                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _enviando ? null : enviarPergunta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _enviando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Enviar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Lista de perguntas
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _perguntas.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma pergunta ainda.\nSeja o primeiro a perguntar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _perguntas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _perguntas[index];
                    return questionCard(
                      p['texto'] ?? '',
                      p['resposta'],
                      p['visibilidade'] == 'privada',
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget questionCard(String pergunta, String? resposta, bool privada) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                privada ? Icons.lock_outline : Icons.help_outline,
                color: const Color(0xFF2563EB),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pergunta,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (privada)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Privada',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                  ),
                ),
            ],
          ),

          if (resposta != null && resposta.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              resposta,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            const Text(
              'Aguardando resposta...',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
