import 'package:afk_redeem/ui/appearance_manager.dart';
import 'package:flutter/material.dart';

Dialog carouselDialog(BuildContext context, List<Widget> items) {
  return Dialog(
    insetPadding: EdgeInsets.all(20.0),
    child: Container(
      height: 450.0,
      width: 450.0,
      child: CarouselViewer(items),
    ),
  );
}

class CarouselViewer extends StatefulWidget {
  final List<Widget> items;
  final double? height;

  CarouselViewer(this.items, {this.height});

  @override
  _CarouselViewerState createState() => _CarouselViewerState();
}

class _CarouselViewerState extends State<CarouselViewer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CarouselView(
            backgroundColor: AppearanceManager().color.dialogBackground,
            itemExtent: widget.height ?? 450,
            shrinkExtent: 0.0,
            children: widget.items,
          ),
        ),
      ],
    );
  }
}
