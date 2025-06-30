import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:quickpourmerchant/features/orders/presentation/pages/order_tracking_screen.dart';

class RiderSelectionScreen extends StatefulWidget {
  final String orderId;
  final int selectedItemCount;
  final VoidCallback onDispatchCompleted;

  const RiderSelectionScreen({
    Key? key,
    required this.orderId,
    required this.selectedItemCount,
    required this.onDispatchCompleted,
  }) : super(key: key);

  @override
  State<RiderSelectionScreen> createState() => _RiderSelectionScreenState();
}

class _RiderSelectionScreenState extends State<RiderSelectionScreen> {
  String? selectedRiderId;
  bool isLoading = false;
  final List<Map<String, dynamic>> availableRiders = [
    {'id': '1', 'name': 'John Doe', 'rating': 4.8, 'distance': '0.5 km'},
    {'id': '2', 'name': 'Jane Smith', 'rating': 4.9, 'distance': '1.2 km'},
    {'id': '3', 'name': 'Mike Johnson', 'rating': 4.7, 'distance': '0.8 km'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderStatusUpdated &&
            state.orderId == widget.orderId &&
            state.newStatus == 'dispatched') {
          // Status updated successfully, continue with navigation
          if (isLoading && selectedRiderId != null) {
            _navigateToTrackingScreen();
          }
        } else if (state is OrdersError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Rider'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableRiders.length,
                itemBuilder: (context, index) {
                  final rider = availableRiders[index];
                  final isSelected = rider['id'] == selectedRiderId;

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedRiderId = rider['id'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                rider['name'].substring(0, 1),
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rider['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      Text(' ${rider['rating']}'),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.location_on,
                                          color: Colors.grey, size: 16),
                                      Text(' ${rider['distance']}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: selectedRiderId == null || isLoading
                    ? null
                    : () {
                        setState(() {
                          isLoading = true;
                        });

                        // Update order status to dispatched
                        context.read<OrdersBloc>().add(
                              UpdateOrderStatus(widget.orderId, 'dispatched'),
                            );

                        // Note: The BlocListener above will handle navigation once status is updated
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Assign Rider & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTrackingScreen() {
    // Navigate to tracking screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            orderId: widget.orderId,
            riderId: selectedRiderId!,
            onCompleted: widget.onDispatchCompleted,
          ),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
}
