import 'package:flutter/widgets.dart';

class AvatarImage extends StatelessWidget {
  const AvatarImage({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}
