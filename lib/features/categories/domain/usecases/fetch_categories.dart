import 'package:quickpourmerchant/features/product/data/repositories/product_repository.dart';

import '../entities/category.dart';
import '../../data/repositories/category_repository.dart';
class FetchCategories {
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;

  FetchCategories(this.categoryRepository, this.productRepository);

  Future<(List<Category>, List<Category>)> call() async {
    final allCategories = (await categoryRepository.getCategories())
        .map((categoryModel) => Category(
              id: categoryModel.id,
              name: categoryModel.name,
              imageUrl: categoryModel.imageUrl,
            ))
        .toList();

    final products = await productRepository.fetchProducts();

    final categoriesWithProducts = allCategories.where((category) {
      return products.any((product) =>
          product.categoryName.toLowerCase() == category.name.toLowerCase());
    }).toList();

    return (allCategories, categoriesWithProducts);
  }
}

