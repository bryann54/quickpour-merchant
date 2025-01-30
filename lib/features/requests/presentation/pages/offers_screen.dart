import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/features/requests/data/models/drink_request_model.dart';
import 'package:quickpourmerchant/features/requests/data/repositories/drink_request_repo.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:quickpourmerchant/features/requests/presentation/bloc/requests_event.dart';
import 'package:quickpourmerchant/features/requests/presentation/widgets/offer_dialog.dart';

class OffersScreen extends StatelessWidget {
  final DrinkRequest request;

  const OffersScreen({
    super.key,
    required this.request,
  });

  Future<List<Map<String, dynamic>>> _fetchOffers() {
    final repository = DrinkRequestRepository();
    return repository.getOffers(request.id);
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('Delete Request?'),
              content: Text(
                'Are you sure you want to delete the offer for ${request.quantity}x ${request.drinkName}? Any pending offers will be cancelled.',
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
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Hero(
                                  tag: 'drink_name_${request.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      request.drinkName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Hero(
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
                                      'Quantity: ${request.quantity}',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(.2),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Text('additional Instructions',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Divider(
                                      thickness: 1,
                                    ),
                                    Row(
                                      children: [
                                        Text(request.additionalInstructions),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Offers',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchOffers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load offers',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final offer = snapshot.data![index];
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow
                                        .withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 2),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            offer['storeName'] ??
                                                'Unknown Store',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Ksh ${offer['price']}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.secondaryContainer
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            offer['location'] ??
                                                'Location not specified',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.tertiaryContainer
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: theme.colorScheme.tertiary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Delivery by: ${DateFormat('MMM d, h:mm a').format(
                                              DateTime.parse(
                                                  offer['deliveryTime']),
                                            )}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (offer['notes']?.isNotEmpty ??
                                        false) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.surfaceContainerHighest
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Notes:',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              offer['notes'],
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              Text(
                                'No offers yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),

//FAB
      floatingActionButton: FloatingActionButton.extended(
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
