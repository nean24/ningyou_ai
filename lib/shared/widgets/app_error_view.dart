import 'package:flutter/widgets.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
