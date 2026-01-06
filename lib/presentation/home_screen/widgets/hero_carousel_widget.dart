import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HeroCarouselBanner {
  const HeroCarouselBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.tag,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? tag;
}

class HeroCarouselWidget extends StatefulWidget {
  const HeroCarouselWidget({
    super.key,
    required this.banners,
    required this.onBannerTap,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  final List<HeroCarouselBanner> banners;
  final ValueChanged<HeroCarouselBanner> onBannerTap;
  final bool autoPlay;
  final Duration autoPlayInterval;

  @override
  State<HeroCarouselWidget> createState() => _HeroCarouselWidgetState();
}

class _HeroCarouselWidgetState extends State<HeroCarouselWidget> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _maybeStartAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HeroCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _maybeStartAutoPlay();
    }
  }

  void _maybeStartAutoPlay() {
    if (!widget.autoPlay || widget.banners.length <= 1) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted) return;
      if (!_controller.hasClients) return;
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, i) {
                final banner = widget.banners[i];
                return _BannerCard(
                  banner: banner,
                  onTap: () => widget.onBannerTap(banner),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 1.2.h),
        _DotsIndicator(
          count: widget.banners.length,
          activeIndex: _index,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.onTap,
  });

  final HeroCarouselBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (banner.tag != null && banner.tag!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              banner.tag!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          banner.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) {
          final active = i == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}
