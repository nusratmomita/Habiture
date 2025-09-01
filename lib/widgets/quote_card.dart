import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final QuoteMode quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const QuoteCard({
    Key? key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote text
              Text(
                '"${quote.text}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              // Author
              if (quote.writer != null && quote.writer!.isNotEmpty)
                Text(
                  '- ${quote.writer}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.purple),
                    tooltip: 'Share quote',
                    onPressed: () {
                      Share.share(
                        '"${quote.text}" ${quote.writer != null ? '- ${quote.writer}' : ''}',
                        subject: 'Inspirational Quote',
                      );
                    },
                  ),
                  // Copy button
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blueAccent),
                    tooltip: 'Copy quote',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: quote.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quote copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color.fromARGB(255, 255, 82, 192),
                    ),
                    tooltip: isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
