class User {
  final String id;
  final String email;
  final String name;
  final String location;
  final List<String> products;
  final int experience;
  final String imageUrl;
  final double rating;
  final bool isVerified;
  final bool isOpen;
  final String storeName;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.location,
    required this.products,
    required this.experience,
    required this.imageUrl,
    required this.rating,
    required this.isVerified,
    required this.isOpen,
    required this.storeName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      products: List<String>.from(json['products'] ?? []),
      experience: json['experience'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] ?? false,
      isOpen: json['isOpen'] ?? false,
      storeName: json['storeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'location': location,
      'products': products,
      'experience': experience,
      'imageUrl': imageUrl,
      'rating': rating,
      'isVerified': isVerified,
      'isOpen': isOpen,
      'storeName': storeName,
    };
  }
}
