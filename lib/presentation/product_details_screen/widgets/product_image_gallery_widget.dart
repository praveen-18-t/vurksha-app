import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Product image gallery widget with swipe pagination and zoom capability
class ProductImageGalleryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> images;

  const ProductImageGalleryWidget({super.key, required this.images});

  @override
  State<ProductImageGalleryWidget> createState() =>
      _ProductImageGalleryWidgetState();
}

class _ProductImageGalleryWidgetState extends State<ProductImageGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
      width: double.infinity,
      color: theme.colorScheme.surface,
      child: Stack(
        children: [
          // Image gallery with pinch zoom
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 3.0,
                child: Center(
                  child: CustomImageWidget(
                    imageUrl: widget.images[index]['url'] as String,
                    width: 100.w,
                    height: 50.h,
                    fit: BoxFit.contain,
                    semanticLabel:
                        widget.images[index]['semanticLabel'] as String,
                  ),
                ),
              );
            },
          ),

          // Page indicators
          Positioned(
            bottom: 2.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                  width: _currentPage == index ? 3.w : 2.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
