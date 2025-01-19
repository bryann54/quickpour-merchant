import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_state.dart';
import 'package:quickpourmerchant/features/requests/presentation/widgets/drink_request_list_tile.dart';
import 'package:quickpourmerchant/features/requests/presentation/widgets/drink_request_shimmer.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Drink Requests'),
      // ),
      body: BlocBuilder<DrinkRequestBloc, DrinkRequestState>(
        builder: (context, state) {
          if (state is DrinkRequestLoading) {
            return const Center(
              child: DrinkRequestListTileShimmer(),
            );
          }

          if (state is DrinkRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DrinkRequestBloc>().add(LoadDrinkRequests());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DrinkRequestLoaded) {
            if (state.requests.isEmpty) {
              return const Center(
                child: Text('No drink requests available'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = state.requests[index];
            return DrinkRequestListTile(request: request);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
