import 'package:flutter/material.dart';
import '../../core/utils/responsive_helper.dart';

class SearchStatusWidget extends StatelessWidget {
  final String status;
  final bool isSearching;
  final Color? color;

  const SearchStatusWidget({
    super.key,
    required this.status,
    required this.isSearching,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Container(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSearching) ...[
                SizedBox(
                  width: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  height: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.search,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  color: color ?? Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
              ],
              Flexible(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    color: color ?? Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Simple version for basic cases
class SimpleSearchStatusWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const SimpleSearchStatusWidget({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color ?? Colors.blue,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}