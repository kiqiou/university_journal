import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/widgets/input_decoration.dart';
class TextFieldWithText extends StatefulWidget {
  final String textFieldName;
  final String inputDecorationText;
  final TextInputFormatter? formatter;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? textController;

  const TextFieldWithText({
    super.key,
    required this.textFieldName,
    required this.inputDecorationText,
    required this.textController,
    this.formatter,
    this.inputFormatters,
  });

  @override
  State<TextFieldWithText> createState() => _TextFieldWithTextState();
}

class _TextFieldWithTextState extends State<TextFieldWithText> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          widget.textFieldName,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: widget.textController,
          decoration: textInputDecoration(widget.inputDecorationText),
          validator: (value) => value == null || value.isEmpty
              ? widget.inputDecorationText
              : null,
          inputFormatters: widget.formatter != null
              ? [widget.formatter!]
              : widget.inputFormatters ?? [],
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
