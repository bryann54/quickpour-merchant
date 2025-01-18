import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/widgets/offer_dialog.dart';

class OffersScreen extends StatelessWidget {
  final DrinkRequest request;

  const OffersScreen({
    super.key,
    required this.request,
  });

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('Delete Request?'),
              content: Text(
                'Are you sure you want to delete the request for ${request.quantity}x ${request.drinkName}? Any pending offers will be cancelled.',
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ) ??
          false;
    }

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete Request?'),
            content: Text(
              'Are you sure you want to delete the request for ${request.quantity}x ${request.drinkName}? Any pending offers will be cancelled.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleDelete(BuildContext context) async {
      
    final shouldDelete = await _showDeleteConfirmation(context);

    if (shouldDelete && context.mounted) {
    

      // Show success snackbar with undo option
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.drinkName} request deleted'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Account for FAB
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                context.read<DrinkRequestBloc>().add(AddDrinkRequest(request));
              },
            ),
          ),
        );
      }

      // Pop back with fade transition
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = DateTime.parse(request.timestamp).toLocal();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
              iconTheme: const IconThemeData(color: Colors.white), 
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
          // In your SliverAppBar's FlexibleSpaceBar, replace the current background Stack with:
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/11.jpg', 
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Hero(
                tag: 'drink_name_${request.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    request.drinkName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Hero(
                                tag: 'drink_icon_${request.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/111 copy.png',
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Hero(
                                tag: 'quantity_${request.id}',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'x${request.quantity}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Hero(
                            tag: 'timestamp_${request.id}',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                               Expanded(
                              child: Text(
                                DateFormat('MMM d, h:mm a').format(
                                    timestamp), // Use the DateTime object here
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              ),
                              ],
                            ),
                          ),
                          const Text('additional Instructions'),
                          Text(request.additionalInstructions)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Offers',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                      alignment: Alignment.center, child: Text('No offers yet'))
                ],
              ),
            ),
          ),
        ],
      ),


// Replace the current FloatingActionButton with:
     floatingActionButton:  FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => OfferDialog(request: request),
          );

          if (result != null && context.mounted) {
            // TODO: Handle the offer submission
            // result contains: price, deliveryTime, and notes
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Offer sent successfully!'),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        isExtended: true,
        icon: const Icon(Icons.local_offer_outlined),
        label: const Text(
          'Make Offer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
