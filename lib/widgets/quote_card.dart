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
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Decorative quote icon
              const Icon(Icons.format_quote,
                  color: Colors.deepPurple, size: 30),
              const SizedBox(height: 8),

              // Quote text
              Text(
                '"${quote.text}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Color(0xFF3D2C8D),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionIcon(
                    context,
                    icon: Icons.share,
                    color: Colors.pinkAccent,
                    tooltip: "Share quote",
                    onPressed: () {
                      // Add your share logic
                      Share.share(quote.text);
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildActionIcon(
                    context,
                    icon: Icons.copy,
                    color: Colors.blueAccent,
                    tooltip: "Copy the quote",
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: quote.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildActionIcon(
                    context,
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.deepPurple,
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

  /// Helper widget for action icons with circular background
  Widget _buildActionIcon(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
