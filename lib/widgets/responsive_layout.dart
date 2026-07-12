import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget tabletLayout;

  static const double breakpoint = 600;

  const ResponsiveLayout({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return tabletLayout;
        }
        return phoneLayout;
      },
    );
  }
}
