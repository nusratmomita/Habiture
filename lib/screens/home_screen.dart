import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/habit_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/habit_card.dart';
import 'profile/user_profile.dart';
import 'progress/habit_progress.dart';
import 'quotes/quote_showing.dart';
import '../providers/auth_provider.dart' as my_auth; // prefixed alias

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final Color appBarColor = Colors.purple;

  Future<void> _logout() async {
    final authProvider =
        Provider.of<my_auth.AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider =
        Provider.of<my_auth.AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid ?? '';

    _screens = [
      ChangeNotifierProvider(
        create: (_) => HabitProvider(userId: userId),
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildBestFeaturesSection(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: habitProvider.habits.isEmpty
                          ? Center(
                              child: Text(
                                'No habits yet. Add one!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: habitProvider.habits.length,
                              itemBuilder: (context, index) {
                                return AnimatedHabitCard(
                                  habit: habitProvider.habits[index],
                                  index: index,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                    _buildUserReviews(),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_edit_habit');
                },
                backgroundColor: appBarColor,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          },
        ),
      ),
      const ProgressScreen(),
      ChangeNotifierProvider(
        create: (_) => QuotesProvider(userId: userId),
        child: const QuotesScreen(),
      ),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBestFeaturesSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.star, color: Colors.purple, size: 28),
                SizedBox(width: 8),
                Text(
                  'Why Choose Habiture?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Track your habits efficiently')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Get daily motivational quotes')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Monitor your progress visually')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Enjoy a personalized experience')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserReviews() {
    final reviews = [
      {'name': 'Alice', 'review': 'Best habit tracker I ever used!'},
      {'name': 'Bob', 'review': 'Helps me stay consistent every day.'},
      {'name': 'Clara', 'review': 'Loving the motivational quotes feature!'},
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 90,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: reviews.map((r) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('"${r['review']}"', textAlign: TextAlign.center),
                const SizedBox(height: 5),
                Text(
                  '- ${r['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Consumer<my_auth.AuthProvider>(
          builder: (context, authProvider, _) {
            final userName = authProvider.currentUser?.displayName ?? "User";
            return Text(
              'Habiture - Hi, $userName!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: appBarColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: 'Quotes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class AnimatedHabitCard extends StatelessWidget {
  final dynamic habit;
  final int index;

  const AnimatedHabitCard({Key? key, required this.habit, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
      duration: Duration(milliseconds: 300 + index * 100),
      curve: Curves.easeOut,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 100, 0),
          child: Opacity(
            opacity: 1 - offset.dx.abs(),
            child: HabitCard(habit: habit),
          ),
        );
      },
    );
  }
}
