import 'package:flutter/material.dart';

class PromotionImageUpload extends StatelessWidget {
  final String? imageUrl;
  final Function(String) onImageUpload;

  const PromotionImageUpload({
    super.key,
    required this.imageUrl,
    required this.onImageUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onImageUpload(''),
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () async {
                      // Handle image upload logic here
                    },
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Click to upload image'),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
