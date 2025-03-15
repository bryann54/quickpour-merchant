import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/function_utils.dart';
import 'package:quickpourmerchant/features/orders/data/models/order_model.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/dispatch_button.dart';
import 'package:quickpourmerchant/features/orders/presentation/widgets/quantity_badge_widget.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final List<OrderItem> items;
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.items,
    required this.orderId,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final Map<int, bool> selectedItems = {};
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.items.length; i++) {
      selectedItems[i] = false;
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCheckbox(int index, bool? value) {
    setState(() {
      selectedItems[index] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Order Confirmation'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          index / widget.items.length,
                          (index + 1) / widget.items.length,
                          curve: Curves.easeOutCubic,
                        ),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildItemCard(item, index, isDark),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomBar(isDark),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItem item, int index, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleCheckbox(index, !selectedItems[index]!),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.images.isNotEmpty
                      ? CachedNetworkImage(imageUrl: 
                          item.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                            ),
                          
                          ),
                     
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          QuantityBadge(quantity: item.quantity),
                          const Spacer(),
                          Text(
                            'Ksh ${formatMoney(item.price)}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.accentColorDark
                                  : AppColors.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item.sku}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: selectedItems[index],
                    onChanged: (value) => _toggleCheckbox(index, value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(
        Icons.error,
        color: Colors.grey[600],
      ),
    );
  }


  Widget _buildBottomBar(bool isDark) {
    final selectedCount = selectedItems.values.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: selectedCount > 0 ? null : 0,
              child: selectedCount > 0
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '$selectedCount items selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            DispatchButton(
              orderId: widget
                  .orderId, 
              selectedCount: selectedCount,
              isLoading: _isLoading,
              onDispatchStarted: () {
                setState(() => _isLoading = true);
              },
              onDispatchCompleted: () {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
   
   
    );
  }
}
