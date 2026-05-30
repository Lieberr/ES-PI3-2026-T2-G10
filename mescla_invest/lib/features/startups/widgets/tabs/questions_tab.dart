// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class QuestionsTab extends StatefulWidget {
  final String startupId;

  const QuestionsTab({super.key, required this.startupId});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab>
    with SingleTickerProviderStateMixin {
  final _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  // Controladores de texto separados para cada aba
  final _ctrlPublica = TextEditingController();
  final _ctrlPrivada = TextEditingController();

  late final TabController _tabController;

  List<Map<String, dynamic>> _perguntasPublicas = [];
  List<Map<String, dynamic>> _perguntasPrivadas = [];

  bool _carregandoPublicas = true;
  bool _carregandoPrivadas = false;
  bool _ehInvestidor = false;

  bool _enviandoPublica = false;
  bool _enviandoPrivada = false;

  String? _erroPublicas;
  String? _erroPrivadas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _carregarPublicas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrlPublica.dispose();
    _ctrlPrivada.dispose();
    super.dispose();
  }

  // Carrega as perguntas privadas só quando o usuário abre a aba pela 1ª vez
  void _onTabChanged() {
    if (_tabController.index == 1 &&
        _perguntasPrivadas.isEmpty &&
        !_carregandoPrivadas) {
      _carregarPrivadas();
    }
  }

  // ── Carregamentos ──────────────────────────────────────────────

  Future<void> _carregarPublicas() async {
    setState(() {
      _carregandoPublicas = true;
      _erroPublicas = null;
    });
    try {
      final result = await _functions
          .httpsCallable('getPerguntasDaStartup')
          .call({'startupId': widget.startupId});

      setState(() {
        _perguntasPublicas = List<Map<String, dynamic>>.from(
          (result.data['perguntas'] as List).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
        _carregandoPublicas = false;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _erroPublicas = e.message ?? 'Erro ao carregar perguntas.';
        _carregandoPublicas = false;
      });
    } catch (_) {
      setState(() {
        _erroPublicas = 'Erro inesperado. Tente novamente.';
        _carregandoPublicas = false;
      });
    }
  }

  Future<void> _carregarPrivadas() async {
    setState(() {
      _carregandoPrivadas = true;
      _erroPrivadas = null;
    });
    try {
      final result = await _functions
          .httpsCallable('getPerguntasPrivadasDaStartup')
          .call({'startupId': widget.startupId});

      setState(() {
        _perguntasPrivadas = List<Map<String, dynamic>>.from(
          (result.data['perguntas'] as List).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
        _ehInvestidor = true; // se não lançou erro, é investidor
        _carregandoPrivadas = false;
      });
    } on FirebaseFunctionsException catch (e) {
      // permission-denied significa que não é investidor — exibe tela bloqueada
      if (e.code == 'permission-denied') {
        setState(() {
          _ehInvestidor = false;
          _carregandoPrivadas = false;
        });
      } else {
        setState(() {
          _erroPrivadas = e.message ?? 'Erro ao carregar perguntas privadas.';
          _carregandoPrivadas = false;
        });
      }
    } catch (_) {
      setState(() {
        _erroPrivadas = 'Erro inesperado. Tente novamente.';
        _carregandoPrivadas = false;
      });
    }
  }

  // ── Envios ─────────────────────────────────────────────────────

  Future<void> _enviarPublica() async {
    final texto = _ctrlPublica.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviandoPublica = true);
    try {
      await _functions.httpsCallable('enviarPergunta').call({
        'startupId': widget.startupId,
        'texto': texto,
      });
      _ctrlPublica.clear();
      await _carregarPublicas();
      _showSnack('Pergunta enviada com sucesso!', sucesso: true);
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao enviar pergunta.');
    } catch (_) {
      _showSnack('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _enviandoPublica = false);
    }
  }

  Future<void> _enviarPrivada() async {
    final texto = _ctrlPrivada.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviandoPrivada = true);
    try {
      await _functions.httpsCallable('enviarPerguntaPrivada').call({
        'startupId': widget.startupId,
        'texto': texto,
      });
      _ctrlPrivada.clear();
      await _carregarPrivadas();
      _showSnack('Pergunta privada enviada com sucesso!', sucesso: true);
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao enviar pergunta privada.');
    } catch (_) {
      _showSnack('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _enviandoPrivada = false);
    }
  }

  void _showSnack(String msg, {bool sucesso = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: sucesso ? const Color(0xFF2563EB) : Colors.red,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seletor de abas
        Container(
          color: const Color(0xFFF3F3F3),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Públicas'),
              Tab(text: 'Privadas 🔒'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAbaPublica(), _buildAbaPrivada()],
          ),
        ),
      ],
    );
  }

  // ── Aba Pública ────────────────────────────────────────────────

  Widget _buildAbaPublica() {
    return Column(
      children: [
        _buildFormulario(
          controller: _ctrlPublica,
          hint: 'Escreva sua pergunta para os empreendedores...',
          onEnviar: _enviarPublica,
          enviando: _enviandoPublica,
        ),
        Expanded(
          child: _buildLista(
            carregando: _carregandoPublicas,
            erro: _erroPublicas,
            perguntas: _perguntasPublicas,
            onRetry: _carregarPublicas,
          ),
        ),
      ],
    );
  }

  // ── Aba Privada ────────────────────────────────────────────────

  Widget _buildAbaPrivada() {
    if (_carregandoPrivadas) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    // Usuário ainda não tentou abrir a aba
    if (!_ehInvestidor && _perguntasPrivadas.isEmpty && _erroPrivadas == null) {
      return _buildBloqueadoInvestidor();
    }

    // Não é investidor (permission-denied do backend)
    if (!_ehInvestidor) {
      return _buildBloqueadoInvestidor();
    }

    return Column(
      children: [
        _buildFormulario(
          controller: _ctrlPrivada,
          hint: 'Envie uma pergunta privada exclusiva para investidores...',
          onEnviar: _enviarPrivada,
          enviando: _enviandoPrivada,
          isPrivada: true,
        ),
        Expanded(
          child: _buildLista(
            carregando: false,
            erro: _erroPrivadas,
            perguntas: _perguntasPrivadas,
            onRetry: _carregarPrivadas,
            isPrivada: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBloqueadoInvestidor() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFDE68A), width: 2),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF854D0E),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Área exclusiva para investidores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Para acessar as perguntas privadas e enviar dúvidas exclusivas, você precisa possuir tokens desta startup.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets reutilizáveis ──────────────────────────────────────

  Widget _buildFormulario({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onEnviar,
    required bool enviando,
    bool isPrivada = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: const Color(0xFFF3F3F3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrivada
                ? const Color(0xFFFDE68A)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPrivada) ...[
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFF854D0E),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  isPrivada ? 'Enviar pergunta privada' : 'Enviar uma pergunta',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isPrivada
                        ? const Color(0xFFD97706)
                        : const Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando ? null : onEnviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrivada
                      ? const Color(0xFFD97706)
                      : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: enviando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isPrivada
                            ? 'Enviar Pergunta Privada'
                            : 'Enviar Pergunta',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista({
    required bool carregando,
    required String? erro,
    required List<Map<String, dynamic>> perguntas,
    required VoidCallback onRetry,
    bool isPrivada = false,
  }) {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }
    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                erro,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (perguntas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPrivada ? Icons.lock_open_outlined : Icons.help_outline,
                color: const Color(0xFF9CA3AF),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                isPrivada
                    ? 'Nenhuma pergunta privada ainda.\nSeja o primeiro investidor a perguntar!'
                    : 'Nenhuma pergunta ainda.\nSeja o primeiro a perguntar!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: perguntas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _PerguntaCard(pergunta: perguntas[index], isPrivada: isPrivada),
    );
  }
}

// ── Card de pergunta ───────────────────────────────────────────────

class _PerguntaCard extends StatelessWidget {
  final Map<String, dynamic> pergunta;
  final bool isPrivada;

  const _PerguntaCard({required this.pergunta, this.isPrivada = false});

  @override
  Widget build(BuildContext context) {
    final bool temResposta =
        pergunta['resposta'] != null &&
        (pergunta['resposta'] as String).isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPrivada ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPrivada
                      ? const Color(0xFFFEF9C3)
                      : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPrivada ? Icons.lock_outline : Icons.person_outline,
                  color: isPrivada
                      ? const Color(0xFF854D0E)
                      : const Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pergunta['autorNome'] ?? 'Usuário',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: temResposta
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  temResposta ? 'Respondida' : 'Aguardando',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: temResposta
                        ? const Color(0xFF15803D)
                        : const Color(0xFF854D0E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            pergunta['texto'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              height: 1.5,
            ),
          ),
          if (temResposta) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.business_center_outlined,
                        size: 15,
                        color: Color(0xFF0284C7),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Resposta dos empreendedores',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pergunta['resposta'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
