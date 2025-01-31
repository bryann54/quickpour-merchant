import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickpourmerchant/features/brands/data/models/brands_model.dart';
import 'package:quickpourmerchant/features/brands/data/repositories/brand_repository.dart';

part 'brands_event.dart';
part 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final BrandRepository brandRepository;

  BrandsBloc({required this.brandRepository}) : super(BrandsInitialState()) {
    on<FetchBrandsEvent>(_onFetchBrands);
    on<AddBrandEvent>(_onAddBrand);
    on<UpdateBrandEvent>(_onUpdateBrand);
    on<DeleteBrandEvent>(_onDeleteBrand);
  }

  void _onFetchBrands(FetchBrandsEvent event, Emitter<BrandsState> emit) async {
    emit(BrandsLoadingState());
    try {
      final brands = await brandRepository.getBrands();
      emit(BrandsLoadedState(brands));
    } catch (e) {
      emit(BrandsErrorState('Failed to load brands: ${e.toString()}'));
    }
  }

  void _onAddBrand(AddBrandEvent event, Emitter<BrandsState> emit) async {
    try {
      emit(BrandsLoadingState());

      // Add to repository
      await brandRepository.addBrand(event.brand);

      // Fetch updated brands list
      final updatedBrands = await brandRepository.getBrands();

      emit(BrandsLoadedState(updatedBrands));
    } catch (e) {
      emit(const BrandsErrorState('Failed to add brand'));
    }
  }

  void _onUpdateBrand(UpdateBrandEvent event, Emitter<BrandsState> emit) async {
    try {
      emit(BrandsLoadingState());

      await brandRepository.updateBrand(event.brand);

      final updatedBrands = await brandRepository.getBrands();
      emit(BrandsLoadedState(updatedBrands));
    } catch (e) {
      emit(const BrandsErrorState('Failed to update brand'));
    }
  }

  void _onDeleteBrand(DeleteBrandEvent event, Emitter<BrandsState> emit) async {
    try {
      emit(BrandsLoadingState());

      await brandRepository.deleteBrand(event.brandId);

      final updatedBrands = await brandRepository.getBrands();
      emit(BrandsLoadedState(updatedBrands));
    } catch (e) {
      emit(const BrandsErrorState('Failed to delete brand'));
    }
  }
}
