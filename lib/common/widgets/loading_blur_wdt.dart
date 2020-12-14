import 'package:flutter/material.dart';
import 'dart:ui';

class LoadingBlurWdt extends StatelessWidget {
  const LoadingBlurWdt({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 5.0,sigmaY: 5.0),
              child: new Container(
                decoration: new BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.5)),
              ),
            )
        ),
        new Center(
          child: new SizedBox(
            width: 100.0,
            height: 100.0,
            child: new CircularProgressIndicator(
              key: Key('circular_loading'),
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor.withOpacity(0.6))
            ),
          ),
        ),
      ],
    );
  }
}