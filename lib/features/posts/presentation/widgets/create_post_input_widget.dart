import 'package:flutter/material.dart';

class CreatePostInput extends StatelessWidget {
  const CreatePostInput({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.hintText,
    required this.charCountLabel,
    this.onChanged,
  });

  final TextEditingController controller;
  final int maxLength;
  final String hintText;
  final String Function(String current, String max) charCountLabel;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: MediaQuery.sizeOf(context).height / 3,
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: null,
            maxLength: maxLength,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              counterText: '',
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                charCountLabel(
                  controller.text.length.toString().padLeft(3, '0'),
                  maxLength.toString(),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
