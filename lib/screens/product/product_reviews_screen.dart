import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reviews = [
      {'user': 'سارة', 'rating': 5, 'comment': 'منتج ممتاز وطازج!'},
      {'user': 'خالد', 'rating': 4, 'comment': 'جيد جداً لكن التغليف يحتاج تحسين.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('التقييمات والمراجعات')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) { 
          final review = reviews[index];
          return ListTile(
            leading: CircleAvatar(child: Text(review['user'][0])),
            title: Text('${review['user']} - ${"★" * review['rating']}'),
            subtitle: Text(review['comment']),
          );
        },
      ),
    );
  }
}
