import 'package:flutter/material.dart';

class RecipeRecommendationScreen extends StatelessWidget {
  final List<String> ingredients;

  const RecipeRecommendationScreen({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Resep'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resep untuk: ${ingredients.join(', ')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // TODO Genard: fetch recipes from PocketBase by ingredients
            Expanded(
              child: ListView(
                children: [
                  _buildDummyRecipeCard('Nasi Goreng Spesial', 'Tingkat kesulitan: Mudah'),
                  const SizedBox(height: 12),
                  _buildDummyRecipeCard('Tumis Sayur Campur', 'Tingkat kesulitan: Sedang'),
                  const SizedBox(height: 12),
                  _buildDummyRecipeCard('Sup Ayam Sehat', 'Tingkat kesulitan: Mudah'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyRecipeCard(String title, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: Colors.orange),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
