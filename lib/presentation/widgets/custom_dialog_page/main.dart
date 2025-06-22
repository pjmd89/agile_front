import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage CustomDialogPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  int transitionDuration = 400,
  double width = 600,
}){
  return CustomTransitionPage(
    key: state.pageKey,
    opaque: false,
    transitionDuration: Duration(milliseconds: transitionDuration),
    child: Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: width,
          child: child,
        ),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    barrierColor: Colors.black54, // O Colors.transparent
    barrierDismissible: true, // Opcional: permite cerrar tocando fuera
  );
}