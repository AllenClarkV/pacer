import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const TimeInputField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  Color activeColor = const Color(0xffFF9500);

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text.isEmpty ? widget.hint : text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 20; // Add some padding
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final width = getTextWidth(widget.controller.text, textStyle);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width.clamp(60.0, 200.0), // Min/Max width
      child: TextField(
        controller: widget.controller,
        onTap: widget.controller.clear,
        style: textStyle,
        textAlign: TextAlign.center,
        cursorColor: Colors.transparent,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(2),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (_) => setState(() {}), // Recalculate width
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
