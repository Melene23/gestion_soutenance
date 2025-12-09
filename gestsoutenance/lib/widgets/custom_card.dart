import 'package:flutter/material.dart';
import '../core/constants/styles.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.border,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration.copyWith(
          color: backgroundColor,
          border: border,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class CustomCardWithTitle extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  const CustomCardWithTitle({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.headline2,
              ),
              if (actions != null) ...[
                Row(
                  children: actions!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
      padding: padding,
    );
  }
}