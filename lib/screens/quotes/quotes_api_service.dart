import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/local_quotes.dart';
import 'dart:math';

class QuotesApiService {
  static const String _apiUrl = "https://type.fit/api/quotes";

  // Fetch a random quote (with optional category)
  Future<String> fetchQuote({String category = "Motivation"}) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final randomQuote = data[Random().nextInt(data.length)];
        return randomQuote["text"] ?? _getLocalQuote(category);
      } else {
        return _getLocalQuote(category);
      }
    } catch (e) {
      return _getLocalQuote(category);
    }
  }

  /// ✅ Get all available categories (local fallback)
  Future<List<String>> fetchAvailableCategories() async {
    try {
      // You can later enhance this to fetch categories from API
      return localQuotes.keys.toList();
    } catch (e) {
      return localQuotes.keys.toList();
    }
  }

  /// ✅ Fetch multiple quotes by category
  Future<List<String>> fetchQuotesByCategory({required String category}) async {
    try {
      if (localQuotes.containsKey(category)) {
        return localQuotes[category]!;
      } else {
        return localQuotes["Motivation"]!;
      }
    } catch (e) {
      return localQuotes["Motivation"]!;
    }
  }

  /// Helper: get one random local quote
  String _getLocalQuote(String category) {
    if (localQuotes.containsKey(category)) {
      final quotes = localQuotes[category]!;
      return quotes[Random().nextInt(quotes.length)];
    } else {
      final quotes = localQuotes["Motivation"]!;
      return quotes[Random().nextInt(quotes.length)];
    }
  }
}
