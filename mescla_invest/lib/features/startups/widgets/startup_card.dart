// Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';

class StartupCard extends StatelessWidget {
  final String image;
  final String title;
  final String status;
  final String description;
  final String tokenValue;
  final String capital;
  final String tokens;
  final double progress;
  final String variation;
  final bool positive;

  const StartupCard({
    super.key,
    required this.image,
    required this.title,
    required this.status,
    required this.description,
    required this.tokenValue,
    required this.capital,
    required this.tokens,
    required this.progress,
    required this.variation,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5E5E5)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOPO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: positive
                                ? const Color(0xFFDDF5E5)
                                : const Color(0xFFFADDDD),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Text(
                            variation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: positive
                                  ? const Color(0xFF19A34A)
                                  : const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'Nova'
                            ? const Color(0xFFDBEAFE)
                            : status == 'Em expansão'
                            ? const Color(0xFFDDF5E5)
                            : const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status == 'Nova'
                              ? const Color(0xFF2563EB)
                              : status == 'Em expansão'
                              ? const Color(0xFF19A34A)
                              : const Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // DESCRIÇÃO
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4B5563),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // INFO
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor do Token',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      tokenValue,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Capital Aportado',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      capital,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // BARRA
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              tokens,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}
