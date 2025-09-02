import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/quote_card.dart';
import '../../models/quote.dart';

class FavoriteQuotesScreen extends StatelessWidget {
  const FavoriteQuotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quotesProvider = Provider.of<QuotesProvider>(context);
    final favorites = quotesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Favorite Quotes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          if (favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                backgroundColor: Colors.white,
                label: Text(
                  favorites.length.toString(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: favorites.isEmpty
            ? _buildEmptyState()
            : AnimationLimiter(
                child: RefreshIndicator(
                  color: Colors.deepPurple[800],
                  onRefresh: () async {
                    await quotesProvider.loadFavorites();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final quote = favorites[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: QuoteCard(
                                  quote: quote,
                                  isFavorite: true,
                                  onFavoriteToggle: () {
                                    quotesProvider.toggleFavorite(quote);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      _buildRemovedSnackBar(quote.text),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  /// Empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.deepPurple[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Tap the heart icon on any quote to save it here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SnackBar when removing a favorite
  SnackBar _buildRemovedSnackBar(String quoteText) {
    return SnackBar(
      content: Text(
        'Removed from favorites: "${_truncateQuote(quoteText)}"',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.indigoAccent,
        onPressed: () {
          // TODO: implement undo functionality in your provider
        },
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color.fromARGB(255, 168, 45, 119),
    );
  }

  /// Helper for truncating long quotes in snackbar
  String _truncateQuote(String quoteText) {
    const maxLength = 40;
    return quoteText.length > maxLength
        ? '${quoteText.substring(0, maxLength)}...'
        : quoteText;
  }
}
