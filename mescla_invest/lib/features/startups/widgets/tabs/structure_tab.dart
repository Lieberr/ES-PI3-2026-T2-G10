// Feito por Gustavo Lieb RA: 24023376


import 'package:flutter/material.dart';

class StructureTab extends StatelessWidget {
  final Map<String, dynamic> startup;
  const StructureTab({super.key, required this.startup});

  @override
Widget build(BuildContext context) {
  final socios = (startup['socios'] ?? <dynamic>[]) as List;

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Estrutura Societária',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      // Lista de sócios dinamicamente
      ...socios.map((socio) {
        final nome = socio['nome'] ?? 'Sócio';
        final percentual = socio['percentual'] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: structureMemberCard(
            name: nome,
            role: 'Sócio',
            percentage: '$percentual%',
          ),
        );
      }).toList(),

      if (socios.isEmpty)
        const Text(
          'Nenhum sócio cadastrado.',
          style: TextStyle(color: Colors.grey),
        ),
    ],
  );
}

  Widget structureMemberCard({
  required String name,
  required String role,
  required String percentage,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
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
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    ),
  );
  }
}
