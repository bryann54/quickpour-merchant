import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';

import '../entities/category.dart';
import '../../data/repositories/category_repository.dart';
class FetchCategories {
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;

  FetchCategories(this.categoryRepository, this.productRepository);

  Future<List<Category>> call() async {
    // Fetch all categories and convert to Category entities
    final allCategories = (await categoryRepository.getCategories())
        .map((categoryModel) => Category(
              id: categoryModel.id,
              name: categoryModel.name,
              imageUrl: categoryModel.imageUrl,
            ))
        .toList();

    // Fetch all products for the merchant
    final products = await productRepository.fetchProducts();

    // Filter categories to only those with products
    final categoriesWithProducts = allCategories.where((category) {
      return products.any((product) =>
          product.categoryName.toLowerCase() == category.name.toLowerCase());
    }).toList();

    return categoriesWithProducts;
  }
}
