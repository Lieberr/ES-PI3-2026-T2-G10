import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),

      child: SafeArea(
        child: Column(
          children: [

            // HEADER
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    'Startups',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),

                children: const [

                  StartupCard(
                    image:
                        'https://images.unsplash.com/photo-1497436072909-60f360e1d4b1?q=80&w=400',
                    title: 'EcoTech Solutions',
                    status: 'Em operação',
                    description:
                        'Plataforma de gestão sustentável para empresas',
                    tokenValue: 'R\$ 10.50',
                    capital: 'R\$ 250k',
                    tokens: '45 000 tokens disponíveis',
                    progress: 0.58,
                    variation: '+ 2.5%',
                    positive: true,
                  ),

                  SizedBox(height: 14),

                  StartupCard(
                    image:
                        'https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=400',
                    title: 'HealthAI',
                    status: 'Em expansão',
                    description:
                        'Inteligência artificial para diagnósticos médicos',
                    tokenValue: 'R\$ 25.00',
                    capital: 'R\$ 800k',
                    tokens: '12 000 tokens disponíveis',
                    progress: 0.82,
                    variation: '+ 5.2%',
                    positive: true,
                  ),

                  SizedBox(height: 14),

                  StartupCard(
                    image:
                        'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=400',
                    title: 'EduTech Brasil',
                    status: 'Em operação',
                    description:
                        'Plataforma de educação personalizada com IA',
                    tokenValue: 'R\$ 8.75',
                    capital: 'R\$ 180k',
                    tokens: '35 000 tokens disponíveis',
                    progress: 0.47,
                    variation: '- 1.2%',
                    positive: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),

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
                        color: status == 'Em expansão'
                            ? const Color(0xFFDDF5E5)
                            : const Color(0xFFFFE7CC),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status == 'Em expansão'
                              ? const Color(0xFF19A34A)
                              : const Color(0xFFE27C16),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
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
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF2563EB),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              tokens,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}