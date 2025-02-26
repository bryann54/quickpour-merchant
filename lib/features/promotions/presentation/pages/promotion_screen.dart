import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_bloc.dart';
import 'package:quickpourmerchant/features/promotions/presentation/bloc/promotions_state.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/create_promotion_dialog.dart';
import 'package:quickpourmerchant/features/promotions/presentation/widgets/promo_card.dart';

class MerchantPromotionsScreen extends StatelessWidget {
  const MerchantPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Promotions'),
      ),
      body: BlocBuilder<PromotionsBloc, PromotionsState>(
        builder: (context, state) {
          if (state is PromotionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromotionsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PromotionsLoaded) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // This will create a grid with 2 columns
                crossAxisSpacing: 10.0, // Space between columns
                mainAxisSpacing: 10.0, // Space between rows
                childAspectRatio: 0.75, // Adjusts the aspect ratio of each card
              ),
              itemCount: state.promotions.length,
              itemBuilder: (context, index) {
                final promotion = state.promotions[index];
                return PromotionCard(promotion: promotion);
              },
            );
          }
          return const Center(child: Text('No promotions available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePromotionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePromotionDialog(),
    );
  }
}
