import 'package:flutter/material.dart';
import 'package:quickpourmerchant/features/brands/presentation/widgets/brands_tab.dart';
import 'package:quickpourmerchant/features/categories/presentation/widgets/categories_tab.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Categories & Brands',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Categories"),
              Tab(text: "Brands"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoriesTab(),
            BrandsTab(),
          ],
        ),
      ),
    );
  }
}
