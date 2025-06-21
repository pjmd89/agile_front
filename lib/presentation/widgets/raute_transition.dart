import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage CustomSlideTransition({required BuildContext context, required GoRouterState state, required Widget child,}) {
  return CustomTransitionPage(
    child: child,
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: const Offset(.8, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.decelerate))),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      );
    },
  );
}