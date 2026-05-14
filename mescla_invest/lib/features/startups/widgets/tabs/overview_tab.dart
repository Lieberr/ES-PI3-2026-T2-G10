import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [

                        const Text(
                          'Sumário Executivo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'A startup desenvolve soluções tecnológicas inovadoras para transformar o mercado.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF4B5563),
                          ),
                        ),

                        const SizedBox(height: 24),

                        sectionCard(),

                        const SizedBox(height: 20),

                        mentorCard(),
                      ],
                    );
  }

  static Widget sectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6)
          )
        ]
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Tokens',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total de Tokens'),
              Text(
                '100 000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tokens Disponíveis'),
              Text(
                '45 000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Percentual Disponível'),
              Text(
                '45.0%',
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            ],
          )
        ],
      ),
    );
  }

  static Widget mentorCard() {
  return Container(
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),


       boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 18,
      spreadRadius: 1,
      offset: const Offset(0, 6),
    ),
  ],

    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'Mentores',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [

            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: Color(0xFFE8F0FE),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Prof. Dr. João Silva',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Mentor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

  
}

