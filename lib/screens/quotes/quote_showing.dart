import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../models/quote.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/quote_card.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  String selectedCategory = "Motivation";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);
      quotesProvider.loadQuotesByCategory(selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer<QuotesProvider>(
            builder: (_, provider, __) => IconButton(
              icon: Badge(
                isLabelVisible: provider.favorites.isNotEmpty,
                label: Text(provider.favorites.length.toString()),
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoriteQuotesScreen(
                      quotes: provider.favorites,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Text(
                  "Quote Categories",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Consumer<QuotesProvider>(
                builder: (context, quotesProvider, child) {
                  return ListView.builder(
                    itemCount: quotesProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = quotesProvider.categories[index];
                      return ListTile(
                        key: ValueKey(category),
                        leading: const Icon(Icons.category),
                        title: Text(category),
                        selected: selectedCategory == category,
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                          quotesProvider.loadQuotesByCategory(category);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Consumer<QuotesProvider>(
        builder: (context, quotesProvider, child) {
          if (quotesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final quotes = quotesProvider.categoryQuotes;

          if (quotes.isEmpty) {
            return const Center(
              child: Text("No quotes available for this category"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              // Find the current favorite status from the provider
              final isCurrentlyFavorite = quotesProvider.favorites
                  .any((favQuote) => favQuote.id == quote.id);

              return Padding(
                key: ValueKey(quote.id),
                padding: const EdgeInsets.only(bottom: 16),
                child: QuoteCard(
                  quote: quote,
                  isFavorite: isCurrentlyFavorite,
                  onFavoriteToggle: () {
                    quotesProvider.toggleFavorite(quote);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteQuotesScreen extends StatelessWidget {
  final List<QuoteMode> quotes;

  const FavoriteQuotesScreen({Key? key, required this.quotes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Quotes"),
        centerTitle: true,
      ),
      body: quotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No favorite quotes yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the heart icon to save quotes",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return Padding(
            key: ValueKey(quote.id),
            padding: const EdgeInsets.only(bottom: 16),
            child: QuoteCard(
              quote: quote,
              isFavorite: true,
              onFavoriteToggle: () {
                // This will allow removing favorites from the favorites screen
                final provider = Provider.of<QuotesProvider>(context, listen: false);
                provider.toggleFavorite(quote);
              },
            ),
          );
        },
      ),
    );
  }
}