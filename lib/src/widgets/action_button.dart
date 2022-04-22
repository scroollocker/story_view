import 'package:flutter/material.dart';

class StoryActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final String? text;
  final TextStyle? textStyle;
  const StoryActionButton({
    Key? key,
    this.onTap,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.textStyle,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom ?? 20,
      left: left,
      right: right,
      child: Center(
        child: GestureDetector(
          onTap: () => onTap?.call(),
          child: Container(
            width: width ?? 120,
            height: height ?? 40,
            child: Center(
                child: Text(
              text ?? 'Подробнее',
              style: textStyle,
            )),
            decoration: BoxDecoration(
              color: color ?? Colors.white,
              borderRadius: borderRadius ??
                  const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
