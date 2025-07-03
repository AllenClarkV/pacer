import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DistanceInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const DistanceInputField(
      {super.key, required this.controller, required this.hint});

  @override
  State<DistanceInputField> createState() => _DistanceInputFieldState();
}

class _DistanceInputFieldState extends State<DistanceInputField> {
  bool isDecimal = true;
  Color activeColor = const Color(0xffFF9500);

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text.isEmpty ? widget.hint : text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 20; // add some padding
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: activeColor, fontSize: 18);
    final width = getTextWidth(widget.controller.text, textStyle);

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      width: width.clamp(60.0, 200.0), // set min/max limits
      child: TextField(
        controller: widget.controller,
        onTap: widget.controller.clear,
        style: textStyle,
        textAlign: TextAlign.center,
        cursorColor: Colors.transparent,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(7),
          FilteringTextInputFormatter.allow(
              RegExp(isDecimal ? r'^\d*\.?\d*' : r'\d+')),
        ],
        onChanged: (_) => setState(() {}), // trigger width change
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: activeColor, width: 1),
          ),
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
