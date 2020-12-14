import 'package:flutter/material.dart';

class PrefixIcon extends StatelessWidget {
  final Widget icon;
  final bool paddingLeft;
  final bool paddingRight;

  const PrefixIcon({
    Key key,
    @required this.icon, this.paddingLeft = false, this.paddingRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      margin: new EdgeInsets.only(
        left: paddingLeft ? 22.0 : 0.0,
        right: paddingRight ? 10.0 : 0,
      ),
      child: Center(
        child: this.icon,
      ),
    );
  }
}
