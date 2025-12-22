import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension CupertinoTransition on Widget {
  CustomTransitionPage<T> buildCupertinoTransitionPage<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // справа
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final fadeOut = Tween<double>(begin: 0.0, end: 0.3).animate(animation);

        return Stack(
          children: [
            FadeTransition(
              opacity: fadeOut,
              child: Container(color: Colors.black),
            ),

            SlideTransition(position: slideIn, child: child),
          ],
        );
      },
    );
  }

  CustomTransitionPage cupertinoTransition(GoRouterState state) =>
      buildCupertinoTransitionPage(state: state, child: this);
}
