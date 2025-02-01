import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onFilterTap;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode
                    ? AppColors.accentColor.withOpacity(.3)
                    : Colors.grey.shade300,
              ),
              color: isDarkMode ? Colors.grey.shade600 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.white : Colors.grey.shade300,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.grey.shade400,
                        fontSize: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onSearch('');
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // const SizedBox(width: 5),
        // GestureDetector(
        //   onTap: widget.onFilterTap,
        //   child: Container(
        //     height: 45,
        //     width: 50,
        //     decoration: BoxDecoration(
        //       color: AppColors.accentColorDark.withOpacity(.9),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: const Center(
        //       child: Icon(
        //         Icons.tune,
        //         color: Colors.white,
        //         size: 24,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
