/// Raw recipe data — replace with PocketBase API when backend is ready.
class DummyRecipeSource {
  DummyRecipeSource._();

  static const List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'Semua'},
    {'id': '2', 'name': 'Nasi'},
    {'id': '3', 'name': 'Mie'},
    {'id': '4', 'name': 'Ayam'},
    {'id': '5', 'name': 'Sayur'},
    {'id': '6', 'name': 'Dessert'},
    {'id': '7', 'name': 'Minuman'},
  ];

  static const List<Map<String, dynamic>> recipes = [
    {
      'id': '1',
      'recipe_name': 'Nasi Goreng Spesial',
      'description':
          'Nasi goreng dengan bumbu rahasia, telur, dan ayam suwir. Cocok untuk sarapan dan makan malam.',
      'image_url': '',
      'ingredients': [
        {'name': 'Nasi putih', 'quantity': 2, 'unit': 'piring'},
        {'name': 'Telur', 'quantity': 2, 'unit': 'butir'},
        {'name': 'Bawang putih', 'quantity': 3, 'unit': 'siung'},
        {'name': 'Bawang merah', 'quantity': 5, 'unit': 'siung'},
        {'name': 'Kecap manis', 'quantity': 2, 'unit': 'sdm'},
        {'name': 'Minyak goreng', 'quantity': 1, 'unit': 'sdm'},
        {'name': 'Garam', 'quantity': 1, 'unit': 'sdt'},
      ],
      'steps': [
        'Haluskan bawang putih dan bawang merah',
        'Panaskan minyak, tumis bumbu halus hingga harum',
        'Masukkan telur, orak-arik',
        'Masukkan nasi putih, aduk rata',
        'Tambahkan kecap manis dan garam',
        'Aduk hingga merata dan sajikan',
      ],
      'cooking_time': 15,
      'difficulty': 'Mudah',
      'category': 'Nasi',
    },
    {
      'id': '2',
      'recipe_name': 'Ayam Geprek Sambal Bawang',
      'description':
          'Ayam goreng tepung crispy dengan sambal bawang pedas. Favorit mahasiswa!',
      'image_url': '',
      'ingredients': [
        {'name': 'Dada ayam', 'quantity': 2, 'unit': 'potong'},
        {'name': 'Tepung terigu', 'quantity': 100, 'unit': 'gram'},
        {'name': 'Tepung maizena', 'quantity': 50, 'unit': 'gram'},
        {'name': 'Cabai rawit', 'quantity': 10, 'unit': 'buah'},
        {'name': 'Bawang putih', 'quantity': 5, 'unit': 'siung'},
        {'name': 'Garam', 'quantity': 1, 'unit': 'sdt'},
        {'name': 'Merica', 'quantity': 1, 'unit': 'sdt'},
        {'name': 'Minyak goreng', 'quantity': 500, 'unit': 'ml'},
      ],
      'steps': [
        'Marinasi ayam dengan garam dan merica',
        'Campurkan tepung terigu dan maizena',
        'Baluri ayam dengan tepung',
        'Goreng hingga golden brown',
        'Buat sambal: ulek cabai dan bawang putih',
        'Geprek ayam dan siram sambal',
      ],
      'cooking_time': 25,
      'difficulty': 'Sedang',
      'category': 'Ayam',
    },
    {
      'id': '3',
      'recipe_name': 'Mie Goreng Jawa',
      'description':
          'Mie goreng tradisional dengan bumbu kecap manis dan sayuran segar.',
      'image_url': '',
      'ingredients': [
        {'name': 'Mie telur', 'quantity': 2, 'unit': 'bungkus'},
        {'name': 'Telur', 'quantity': 1, 'unit': 'butir'},
        {'name': 'Daun bawang', 'quantity': 1, 'unit': 'batang'},
        {'name': 'Sawi', 'quantity': 2, 'unit': 'lembar'},
        {'name': 'Kecap manis', 'quantity': 3, 'unit': 'sdm'},
        {'name': 'Bawang putih', 'quantity': 2, 'unit': 'siung'},
        {'name': 'Garam', 'quantity': 1, 'unit': 'sdt'},
      ],
      'steps': [
        'Rebus mie hingga matang, tiriskan',
        'Tumis bawang putih hingga harum',
        'Masukkan telur, orak-arik',
        'Masukkan sayuran, aduk sebentar',
        'Masukkan mie dan kecap manis',
        'Aduk rata, sajikan',
      ],
      'cooking_time': 20,
      'difficulty': 'Mudah',
      'category': 'Mie',
    },
    {
      'id': '4',
      'recipe_name': 'Sop Sayur Bening',
      'description':
          'Sop sayur segar dengan wortel, kentang, dan buncis. Sehat dan lezat.',
      'image_url': '',
      'ingredients': [
        {'name': 'Wortel', 'quantity': 2, 'unit': 'buah'},
        {'name': 'Kentang', 'quantity': 2, 'unit': 'buah'},
        {'name': 'Buncis', 'quantity': 100, 'unit': 'gram'},
        {'name': 'Daun bawang', 'quantity': 2, 'unit': 'batang'},
        {'name': 'Bawang putih', 'quantity': 3, 'unit': 'siung'},
        {'name': 'Garam', 'quantity': 1, 'unit': 'sdt'},
        {'name': 'Air', 'quantity': 500, 'unit': 'ml'},
      ],
      'steps': [
        'Potong sayuran sesuai selera',
        'Rebus air hingga mendidih',
        'Masukkan kentang dan wortel',
        'Setelah setengah matang, masukkan buncis',
        'Tambahkan bawang putih halus, garam, merica',
        'Masak hingga sayuran empuk, sajikan',
      ],
      'cooking_time': 30,
      'difficulty': 'Mudah',
      'category': 'Sayur',
    },
    {
      'id': '5',
      'recipe_name': 'Es Teh Manis Lemon',
      'description':
          'Minuman segar teh manis dengan perasan lemon. Perfect untuk cuaca panas.',
      'image_url': '',
      'ingredients': [
        {'name': 'Teh celup', 'quantity': 2, 'unit': 'kantong'},
        {'name': 'Gula pasir', 'quantity': 3, 'unit': 'sdm'},
        {'name': 'Lemon', 'quantity': 1, 'unit': 'buah'},
        {'name': 'Es batu', 'quantity': 5, 'unit': 'buah'},
        {'name': 'Air panas', 'quantity': 300, 'unit': 'ml'},
      ],
      'steps': [
        'Seduh teh dengan air panas',
        'Tambahkan gula, aduk rata',
        'Biarkan dingin',
        'Masukkan es batu ke gelas',
        'Tuang teh, peras lemon',
        'Aduk dan sajikan',
      ],
      'cooking_time': 5,
      'difficulty': 'Mudah',
      'category': 'Minuman',
    },
  ];
}
