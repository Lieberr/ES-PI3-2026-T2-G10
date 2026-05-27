import 'package:flutter/material.dart';

class QuestionsTab extends StatelessWidget {
  final Map<String, dynamic> startup;
  const QuestionsTab({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        const Text(
          'Perguntas Frequentes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        questionCard(
          'Como funciona o investimento?',
          'Você compra tokens da startup e participa do crescimento do projeto.',
        ),

        const SizedBox(height: 16),

        questionCard(
          'Existe risco?',
          'Sim. Todo investimento possui riscos e variações de mercado.',
        ),

        const SizedBox(height: 16),

        questionCard(
          'Posso vender meus tokens?',
          'Sim. Os tokens poderão ser negociados futuramente na plataforma.',
        ),
      ],
    );
  }

  Widget questionCard(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),

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

              const Icon(
                Icons.help_outline,
                color: Color(0xFF2563EB),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}