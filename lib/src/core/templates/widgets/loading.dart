String loadingWidget = r'''import 'package:flutter/material.dart';
import '/src/presentation/providers/loading_notifier.dart';
import 'package:provider/provider.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin{
  late AnimationController controller;
  var onLoading = true;
  
  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double opacity = 1;
    bool loading = context.watch<LoadingNotifier>().loading;
  
    if ( !loading ){
      controller.stop();
      controller.value = 0;
      opacity = 0;
    }
    else{
      controller
        ..forward(from: controller.value)
        ..repeat();
    }
    
    return Opacity(
      opacity: opacity,
      child: const LinearProgressIndicator(/*value: controller.value*/)
    );

  }
}''';