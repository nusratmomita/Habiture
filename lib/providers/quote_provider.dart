import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/firestore_service.dart';

class QuotesProvider extends ChangeNotifier {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  List<QuoteMode> favorites = [];
  List<QuoteMode> categoryQuotes = [];
  List<String> categories = [];
  bool isLoading = false;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  // Local category-based quotes (Refreshed with unique habit-related quotes)
  final Map<String, List<String>> localQuotes = {
    "Motivation": [
      "Each small habit is a brick in the house of your future.",
      "Motivation fades, but habits stay when you build them daily.",
      "The first step to change is showing up, even when it’s hard.",
      "Consistency turns ordinary days into extraordinary results.",
    ],
    "Discipline": [
      "Discipline is choosing habit over mood.",
      "Discipline is remembering what you said you’d do long after the feeling left.",
      "Each disciplined choice strengthens the habit muscle.",
      "The cost of discipline is small compared to the regret of neglect.",
    ],
    "Success": [
      "Success is built one habit at a time, never overnight.",
      "The difference between wishing and achieving is daily habits.",
      "Success is the shadow cast by disciplined habits.",
      "Your habits decide whether success feels near or far.",
    ],
    "Habits": [
      "Good habits free you, bad habits trap you.",
      "The best habit you can build is the one you keep.",
      "Your future self is built by your current habits.",
      "Habits outlive motivation, and that’s their power.",
    ],
  };

  QuotesProvider({required this.userId}) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadFavorites(),
      loadCategories(),
    ]);
  }

  Future<void> loadCategories() async {
    categories = localQuotes.keys.toList();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    isLoading = true;
    notifyListeners();

    favorites = await _firestoreService.getFavoriteQuotes(userId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadQuotesByCategory(String category) async {
    isLoading = true;
    _selectedCategory = category;
    notifyListeners();

    if (localQuotes.containsKey(category)) {
      categoryQuotes = localQuotes[category]!
          .asMap()
          .entries
          .map(
            (entry) => QuoteMode(
          id: '${category}_${entry.key}',
          text: entry.value,
          tags: [category],
          isFavorite:
          favorites.any((f) => f.id == '${category}_${entry.key}'),
        ),
      )
          .toList();
    } else {
      categoryQuotes = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(QuoteMode quote) async {
    final updatedQuote = quote.copyWith(isFavorite: !quote.isFavorite);

    if (updatedQuote.isFavorite) {
      await _firestoreService.addFavoriteQuote(userId, updatedQuote);
    } else {
      await _firestoreService.removeFavoriteQuote(userId, updatedQuote);
    }

    await loadFavorites();
  }
}
