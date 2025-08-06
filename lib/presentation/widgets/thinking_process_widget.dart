import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';

class ThinkingProcessWidget extends StatelessWidget {
  final ThinkingProcessModel thinkingProcess;

  const ThinkingProcessWidget({
    super.key,
    required this.thinkingProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thinking Process',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        ..._buildSteps(context),
      ],
    );
  }

  List<Widget> _buildSteps(BuildContext context) {
    return thinkingProcess.steps.map((step) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${step.stepNumber}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                step.content,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

