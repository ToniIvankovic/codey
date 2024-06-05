import 'package:flutter/material.dart';

class RichTextMarkdown extends StatelessWidget {
  final List<TextSpan> _spans = [];

  RichTextMarkdown({
    Key? key,
    required String text,
    required TextStyle style,
  }) : super(key: key) {
    var isBold = false;
    var isCode = false;
    var isItalic = false;
    var buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (text.startsWith('**', i)) {
        if (buffer.isNotEmpty) {
          _spans.add(
              _createSpan(buffer.toString(), style, isBold, isCode, isItalic));
          buffer.clear();
        }
        isBold = !isBold;
        i++; // Skip the next character
      } else if (text.startsWith('##', i)) {
        if (buffer.isNotEmpty) {
          _spans.add(
              _createSpan(buffer.toString(), style, isBold, isCode, isItalic));
          buffer.clear();
        }
        isCode = !isCode;
        i++; // Skip the next character
      } else if (text.startsWith('__', i)) {
        if (buffer.isNotEmpty) {
          _spans.add(
              _createSpan(buffer.toString(), style, isBold, isCode, isItalic));
          buffer.clear();
        }
        isItalic = !isItalic;
        i++; // Skip the next character
      } else {
        buffer.write(text[i]);
      }
    }

    if (buffer.isNotEmpty) {
      _spans
          .add(_createSpan(buffer.toString(), style, isBold, isCode, isItalic));
    }
  }

  TextSpan _createSpan(
      String text, TextStyle style, bool isBold, bool isCode, bool isItalic) {
    return TextSpan(
      text: text,
      style: style.copyWith(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: isCode ? 'courier new' : null,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: _spans[0].text,
        style: _spans[0].style,
        children: _spans.sublist(1),
      ),
    );
  }
}
