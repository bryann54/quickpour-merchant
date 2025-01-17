// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class BrandsScreen extends StatelessWidget {
//   const BrandsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Brands'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Brands',
//               style: Theme.of(context).textTheme.displayLarge,
//             ),
//           ),
//           Expanded(
//             child: BlocProvider(
//               create: (context) =>
//                   BrandsBloc(brandRepository: BrandRepository())
//                     ..add(FetchBrandsEvent()),
//               child: BlocBuilder<BrandsBloc, BrandsState>(
//                 builder: (context, state) {
//                   if (state is BrandsLoadingState) {
//                     return const CircularProgressIndicator();
//                   } else if (state is BrandsLoadedState) {
//                     return ListView.builder(
//                       itemCount: state.brands.length,
//                       itemBuilder: (context, index) {
//                         final brand = state.brands[index];
//                         return BrandCardWidget(
//                           brand: brand,
//                         );
//                       },
//                     );
//                   }
//                   return const Text('Failed to load brands');
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
