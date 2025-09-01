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
  String? _tappedCategory; // Tracks which category is currently tapped

  // Called when a category card is tapped
  void _onCategoryTap(String category) async {
    final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);

    // Update UI to show tapped state
    setState(() {
      _tappedCategory = category;
    });

    // Load quotes for the selected category
    await quotesProvider.loadQuotesByCategory(category);

    if (!mounted) return; // Ensure widget is still in the tree

    // Navigate to QuotesCategoryScreen after loading
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotesCategoryScreen(category: category),
      ),
    ).then((_) {
      // Reset tapped category after returning from quotes screen
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
          // Show loader if categories are still loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          crossAxisSpacing: 16, // spacing between columns
          mainAxisSpacing: 16, // spacing between rows
          childAspectRatio: 1.2, // card height/width ratio
        ),
        itemCount: quotesProvider.categories.length,
        itemBuilder: (context, index) {
          final category = quotesProvider.categories[index];

          return CategoryCard(
            category: category,
            isSelected: _tappedCategory == category, // highlight tapped card
            onTap: () => _onCategoryTap(category), // handle tap
          );
        },
      ),
    );
  }
}
