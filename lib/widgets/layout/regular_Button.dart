import 'package:flutter/material.dart';

class RegularButton extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final dynamic onPressed;
  final double width;
  final double height;

  const RegularButton({
    super.key,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    required this.text,
    this.width = 150,
    this.height = 48,
    this.onPressed,
  });

  @override
  State<RegularButton> createState() => _RegularButtonState();
}

class _RegularButtonState extends State<RegularButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isPressed ? theme.primaryColor : widget.backgroundColor,
            border: Border.all(
              color: isPressed ? theme.highlightColor : widget.textColor,
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: isPressed ? theme.highlightColor : widget.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
