import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _reviewController = TextEditingController();
  int _selectedStars = 0;

  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'AMI',
      'stars': 4,
      'text': 'Electric Home is the best application ever!',
    },
    {
      'name': 'BAIYOK',
      'stars': 4,
      'text': 'This app makes it easy to manage electricity usage at home.',
    },
    {
      'name': 'NEW',
      'stars': 5,
      'text': 'Five stars for this application.',
    },
  ];

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty || _selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่รีวิวและเลือกดาวด้วยนะ')),
      );
      return;
    }
    setState(() {
      _reviews.insert(0, {
        'name': 'YOU',
        'stars': _selectedStars,
        'text': _reviewController.text.trim(),
      });
      _reviewController.clear();
      _selectedStars = 0;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A9E82),
        foregroundColor: Colors.white,
        title: const Text(
          'User Reviews',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Write a Review card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 36, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WRITE A REVIEW',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xFF1A3A2E),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Text input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'เขียนรีวิวของคุณที่นี่...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStars = i + 1),
                        child: Icon(
                          i < _selectedStars ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A9E82),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'USER REVIEWS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFF1A3A2E),
              ),
            ),
            const SizedBox(height: 14),

            // Review list
            ..._reviews.map((r) => _buildReviewCard(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF1A3A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review['stars'] ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review['text'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
