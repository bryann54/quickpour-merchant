import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fetch_categories.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final FetchCategories fetchCategories;

  CategoriesBloc(this.fetchCategories) : super(CategoriesInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoriesLoading());
      try {
        final (allCategories, categoriesWithProducts) = await fetchCategories();
        emit(CategoriesLoaded(
          allCategories: allCategories,
          categoriesWithProducts: categoriesWithProducts,
        ));
      } catch (e) {
        emit(CategoriesError('Failed to load categories'));
      }
    });
  }
}
