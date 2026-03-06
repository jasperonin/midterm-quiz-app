// lib/widgets/coding/code_editor_field.dart
import 'package:flutter/material.dart';

class CodeEditorField extends StatefulWidget {
  final String initialCode;
  final ValueChanged<String> onCodeChanged;
  final bool enabled;
  final String hintText;
  final int minLines;
  final int maxLines;

  const CodeEditorField({
    Key? key,
    this.initialCode = '',
    required this.onCodeChanged,
    this.enabled = true,
    this.hintText = '// Write your code here...',
    this.minLines = 10,
    this.maxLines = 20,
  }) : super(key: key);

  @override
  _CodeEditorFieldState createState() => _CodeEditorFieldState();
}

class _CodeEditorFieldState extends State<CodeEditorField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(CodeEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCode != _controller.text) {
      _controller.text = widget.initialCode;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus ? Colors.blue.shade400 : Colors.grey.shade800,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editor header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(
                  'C Programming',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code input area
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onCodeChanged,
            enabled: widget.enabled,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.green,
            ),
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}