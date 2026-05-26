import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StaggeredListAnimator extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double verticalOffset;
  final double horizontalOffset;
  final Duration duration;

  const StaggeredListAnimator({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.verticalOffset = 50.0,
    this.horizontalOffset = 0.0,
    this.duration = const Duration(milliseconds: 375),
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: duration,
            child: SlideAnimation(
              verticalOffset: verticalOffset,
              horizontalOffset: horizontalOffset,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
