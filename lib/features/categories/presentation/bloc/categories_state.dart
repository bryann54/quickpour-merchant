import '../../domain/entities/category.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> allCategories;
  final List<Category> categoriesWithProducts;

  CategoriesLoaded({
    required this.allCategories,
    required this.categoriesWithProducts,
  });
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}
