import 'package:flutter/material.dart';
import 'package:mescla_invest/features/startups/startups_page.dart';
import 'package:mescla_invest/features/balcao/balcao_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const BalcaoPage(),
    const Center(child: Text('Portfólio')),
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Startups',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Balcão',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Portfólio',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}