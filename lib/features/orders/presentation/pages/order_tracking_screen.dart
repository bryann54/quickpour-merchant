import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/orders/presentation/bloc/orders_bloc.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String riderId;
  final VoidCallback onCompleted;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.riderId,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int currentStep = 0;
  bool isUpdating = false;
  final List<Map<String, dynamic>> trackingSteps = [
    {'status': 'dispatched', 'label': 'Order Dispatched'},
    {'status': 'picked_up', 'label': 'Rider Picked Up'},
    {'status': 'in_transit', 'label': 'In Transit'},
    {'status': 'delivered', 'label': 'Delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _simulateTracking();
  }

  void _simulateTracking() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && currentStep < trackingSteps.length - 1) {
        _updateOrderStatus(currentStep + 1);
      }
    });
  }

  void _updateOrderStatus(int step) {
    if (!mounted) return;

    final newStatus = trackingSteps[step]['status'];
    setState(() {
      isUpdating = true;
    });

    // Update order status in the bloc
    context.read<OrdersBloc>().add(
          UpdateOrderStatus(widget.orderId, newStatus as String),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderStatusUpdated && state.orderId == widget.orderId) {
          // Find the index of the updated status
          final statusIndex = trackingSteps
              .indexWhere((step) => step['status'] == state.newStatus);

          if (statusIndex != -1 && statusIndex > currentStep) {
            setState(() {
              currentStep = statusIndex;
              isUpdating = false;
            });
            // Continue simulation if not at the last step
            if (currentStep < trackingSteps.length - 1) {
              _simulateTracking();
            }
          }
        } else if (state is OrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isUpdating = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Tracking',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primaryColor.withValues(alpha: 0.1),
                            radius: 24,
                            child: const Icon(
                              Icons.directions_bike,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rider ID: ${widget.riderId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order ID: ${widget.orderId}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Show dialog to contact rider
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Contact Rider'),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.phone),
                                        title: Text('Call Rider'),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.message),
                                        title: Text('Message Rider'),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Contact'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tracking Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stepper(
                        currentStep: currentStep,
                        controlsBuilder: (context, details) => Container(),
                        steps: List.generate(
                          trackingSteps.length,
                          (index) => Step(
                            title: Text(trackingSteps[index]['label']),
                            content: Container(),
                            isActive: currentStep >= index,
                            state: currentStep > index
                                ? StepState.complete
                                : currentStep == index
                                    ? StepState.editing
                                    : StepState.indexed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: (currentStep == trackingSteps.length - 1 &&
                        !isUpdating)
                    ? () {
                        // Mark as completed (final status after delivery)
                        context.read<OrdersBloc>().add(
                              UpdateOrderStatus(widget.orderId, 'completed'),
                            );

                        // Call the completion callback
                        widget.onCompleted();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order completed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Delivery',
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
}
