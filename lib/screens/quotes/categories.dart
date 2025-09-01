import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/category_card.dart';
import 'quote_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _tappedCategory;

  void _onCategoryTap(String category) async {
    final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);

    setState(() {
      _tappedCategory = category;
    });

    // Load quotes first
    await quotesProvider.loadQuotesByCategory(category);

    if (!mounted) return;

    // Navigate after loading is complete
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotesCategoryScreen(category: category),
      ),
    ).then((_) {
      // Reset the tapped category after returning from the quotes screen
      if (mounted) {
        setState(() {
          _tappedCategory = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quotesProvider = Provider.of<QuotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Categories'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: quotesProvider.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: quotesProvider.categories.length,
        itemBuilder: (context, index) {
          final category = quotesProvider.categories[index];
          return CategoryCard(
            category: category,
            isSelected: _tappedCategory == category,
            onTap: () => _onCategoryTap(category),
          );
        },
      ),
    );
  }
}