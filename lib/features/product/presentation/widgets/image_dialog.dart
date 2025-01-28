// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:quickpourmerchant/core/utils/colors.dart';
// import 'package:quickpourmerchant/core/utils/custom_snackbar_widget.dart';
// import 'package:quickpourmerchant/features/brands/presentation/bloc/brands_bloc.dart';
// import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_bloc.dart';
// import 'package:quickpourmerchant/features/categories/presentation/bloc/categories_state.dart';
// import 'package:quickpourmerchant/features/product/data/models/product_model.dart';
// import 'package:quickpourmerchant/features/product/presentation/bloc/products_bloc.dart';

// class AddProductDialog extends StatefulWidget {
  
//   const AddProductDialog({super.key});

//   @override
//   State<AddProductDialog> createState() => _AddProductDialogState();
// }

// class _AddProductDialogState extends State<AddProductDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _auth = FirebaseAuth.instance;
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;

//   // Controllers for form fields
//   final _nameController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _discountController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _skuController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   String? _selectedCategory;
//   String? _selectedBrand;

//   // Image handling
//   List<File> _selectedImages = [];
//   List<String> _uploadedImageUrls = [];
//   bool _isUploadingImages = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _discountController.dispose();
//     _stockController.dispose();
//     _skuController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImages() async {
//     try {
//       final List<XFile>? images = await _picker.pickMultiImage();
//       if (images != null && images.isNotEmpty) {
//         setState(() {
//           _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
//         });
//       }
//     } catch (e) {
//       _showErrorMessage('Error picking images: $e');
//     }
//   }

//   Future<List<String>> _uploadImages() async {
//     List<String> imageUrls = [];
//     setState(() => _isUploadingImages = true);

//     try {
//       final storageInstance = FirebaseStorage.instance;

//       for (var i = 0; i < _selectedImages.length; i++) {
//         File imageFile = _selectedImages[i];
//         String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//         String cleanFileName =
//             path.basename(imageFile.path).replaceAll(RegExp(r'[^\w\.-]'), '_');
//         String fileName = 'product_${timestamp}_$i\_$cleanFileName';

//         Reference storageRef = storageInstance
//             .ref()
//             .child('products')
//             .child(DateTime.now().year.toString())
//             .child(DateTime.now().month.toString())
//             .child(fileName);

//         if (!await imageFile.exists()) {
//           throw Exception('Image file does not exist: ${imageFile.path}');
//         }

//         final uploadTask = await storageRef.putFile(
//           imageFile,
//           SettableMetadata(
//             contentType: 'image/jpeg',
//             customMetadata: {
//               'uploaded_at': DateTime.now().toIso8601String(),
//               'original_name': path.basename(imageFile.path),
//             },
//           ),
//         );

//         if (uploadTask.state == TaskState.success) {
//           String downloadUrl = await storageRef.getDownloadURL();
//           imageUrls.add(downloadUrl);
//         } else {
//           throw Exception('Upload task failed with state: ${uploadTask.state}');
//         }
//       }

//       return imageUrls;
//     } catch (e) {
//       throw Exception('Failed to upload images: $e');
//     } finally {
//       setState(() => _isUploadingImages = false);
//     }
//   }

//   // Validation helpers
//   String? _validatePrice(String? value) {
//     if (value == null || value.isEmpty) return 'Price is required';
//     if (double.tryParse(value) == null) return 'Enter a valid price';
//     if (double.parse(value) <= 0) return 'Price must be greater than 0';
//     return null;
//   }

//   String? _validateStock(String? value) {
//     if (value == null || value.isEmpty) return 'Stock quantity is required';
//     if (int.tryParse(value) == null) return 'Enter a valid number';
//     if (int.parse(value) < 0) return 'Stock cannot be negative';
//     return null;
//   }

//   String? _validateDiscount(String? value) {
//     if (value == null || value.isEmpty) return null;
//     if (double.tryParse(value) == null) return 'Enter a valid price';
//     if (double.parse(value) < 0) return 'Discount cannot be negative';
//     if (double.parse(value) >= double.parse(_priceController.text)) {
//       return 'Discount must be less than price';
//     }
//     return null;
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedImages.isEmpty) {
//       _showErrorMessage('Please select at least one product image');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final user = _auth.currentUser;
//       if (user == null) {
//         _showErrorMessage('Please log in to add products');
//         return;
//       }

//       // Upload images first
//       _uploadedImageUrls = await _uploadImages();

//       final productId =
//           FirebaseFirestore.instance.collection('products').doc().id;
//       final newProduct = MerchantProductModel(
//         id: productId,
//         merchantId: user.uid,
//         productName: _nameController.text.trim(),
//         imageUrls: _uploadedImageUrls,
//         price: double.parse(_priceController.text),
//         brandName: _selectedBrand!,
//         description: _descriptionController.text.trim(),
//         categoryName: _selectedCategory!,
//         stockQuantity: int.parse(_stockController.text),
//         discountPrice: _discountController.text.isEmpty
//             ? 0.0
//             : double.parse(_discountController.text),
//         sku: _skuController.text.trim(),
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       context.read<ProductsBloc>().add(AddProduct(newProduct));
//       Navigator.pop(context);
//       _showSuccessMessage('Product added successfully');
//     } catch (e) {
//       _showErrorMessage('Error adding product: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showSuccessMessage(String message) {
//    CustomAnimatedSnackbar();
//   }

//   @override
//   Widget build(BuildContext context) {
//       final theme = Theme.of(context);
//         final isDarkMode = theme.brightness == Brightness.dark;
//     return Dialog.fullscreen(
//       child: SingleChildScrollView(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 500),
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ShaderMask(
//                       shaderCallback: (bounds) => const LinearGradient(
//                         colors: [
//                           AppColors.brandAccent,
//                            AppColors.brandPrimary,
//                         ],
//                       ).createShader(bounds),
//                       child: Text(
//                          'Add New Product',
//                         style: GoogleFonts.acme(
//                           fontSize: 25,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                            'cancel',
//                           style: GoogleFonts.acme(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w800,
//                             color:isDarkMode? Colors.white:Colors.black,
//                           ),
//                         ),
//                     ),
//                 ],
//               ),
//                 const SizedBox(height: 24),

//                 // Image Selection Section
//                 Container(
//                   height: 180,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: _selectedImages.isEmpty
//                             ? Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.image_outlined,
//                                         size: 40, color: Colors.grey.shade400),
//                                     const SizedBox(height: 8),
//                                     Text('No images selected',
//                                         style: TextStyle(
//                                             color: Colors.grey.shade600)),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: _selectedImages.length,
//                                 padding: const EdgeInsets.all(8),
//                                 itemBuilder: (context, index) {
//                                   return Stack(
//                                     children: [
//                                       Container(
//                                         margin: const EdgeInsets.only(right: 8),
//                                         width: 120,
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.grey.shade300),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           image: DecorationImage(
//                                             image: FileImage(
//                                                 _selectedImages[index]),
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         right: 0,
//                                         top: 0,
//                                         child: IconButton(
//                                           icon: const Icon(Icons.cancel,
//                                               color: Colors.red),
//                                           onPressed: () {
//                                             setState(() {
//                                               _selectedImages.removeAt(index);
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ElevatedButton.icon(
//                           onPressed: _isUploadingImages ? null : _pickImages,
//                           icon:  Icon(Icons.add_photo_alternate,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.white.withOpacity(0.8),),
//                           label: const Text('Add Images'),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size(double.infinity, 44),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),


//                 // Category Dropdown
//                 BlocBuilder<CategoriesBloc, CategoriesState>(
//                   builder: (context, state) {
//                     if (state is CategoriesLoading) {
//                       return const LinearProgressIndicator();
//                     } else if (state is CategoriesLoaded) {
//                       return DropdownButtonFormField<String>(
//                         value: _selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon:  Icon(FontAwesomeIcons.folder,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         items: state.allCategories.map((category) {
//                           return DropdownMenuItem<String>(
//                             value: category.name,
//                             child: Text(category.name),
//                           );
//                         }).toList(),
//                         onChanged: (value) =>
//                             setState(() => _selectedCategory = value),
//                         validator: (value) =>
//                             value == null ? 'Select a category' : null,
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Brand Dropdown
//                 BlocBuilder<BrandsBloc, BrandsState>(
//                   builder: (context, state) {
//                     if (state is BrandsLoadingState) {
//                       return const LinearProgressIndicator();
//                     } else if (state is BrandsLoadedState) {
//                       return DropdownButtonFormField<String>(
//                         value: _selectedBrand,
//                         decoration: InputDecoration(
//                           labelText: 'Brand',
//                            labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon:  Icon(Icons.branding_watermark,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         items: state.brands.map((brand) {
//                           return DropdownMenuItem<String>(
//                             value: brand.name,
//                             child: Text(brand.name),
//                           );
//                         }).toList(),
//                         onChanged: (value) =>
//                             setState(() => _selectedBrand = value),
//                         validator: (value) =>
//                             value == null ? 'Select a brand' : null,
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Product Details
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Product Name',
//                      labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     prefixIcon:  Icon(Icons.inventory, size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),)
//                   ),
//                   validator: (value) => value?.trim().isEmpty == true
//                       ? 'Enter product name'
//                       : null,
//                 ),
//                 const SizedBox(height: 16),

//                 // Price and Discount Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _priceController,
//                         decoration: InputDecoration(
//                           labelText: 'Price',
//                            labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),
//                           prefixText: 'Ksh ',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
                            
//                           ),
//                           prefixIcon:  Icon(Icons.attach_money,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: _validatePrice,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _discountController,
//                         decoration: InputDecoration(
//                           labelText: 'Discount Price',
//                            labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5,),fontSize: 15),
//                           prefixText: 'Ksh ',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon:  Icon(Icons.discount,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: _validateDiscount,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Stock and SKU Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _stockController,
//                         decoration: InputDecoration(
//                           labelText: 'Stock Quantity',
//                            labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5),
//                               fontSize: 15),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon:  Icon(Icons.warehouse,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: _validateStock,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _skuController,
//                         decoration: InputDecoration(
//                           labelText: 'SKU',
//                            labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon:  Icon(Icons.qr_code,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                         ),
//                         validator: (value) =>
//                             value?.trim().isEmpty == true ? 'Enter SKU' : null,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                      labelStyle: TextStyle(color: isDarkMode?AppColors.background.withOpacity(.5):Colors.black.withOpacity(0.5)),

//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     prefixIcon:  Icon(Icons.description,size: 24,color: isDarkMode?AppColors.background.withOpacity(.5):Colors.grey.withOpacity(0.5),),
//                   ),
//                   maxLines: 3,
//                   validator: (value) => value?.trim().isEmpty == true
//                       ? 'Enter description'
//                       : null,
//                 ),
//                 const SizedBox(height: 24),

//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 48),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text('Add Product'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
