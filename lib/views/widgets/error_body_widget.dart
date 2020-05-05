import 'package:flutter/material.dart';

class ErrorWBodyWidget extends StatelessWidget {

  final dynamic error;
  ErrorWBodyWidget(this.error);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error.toString(),
                  style: Theme.of(context).textTheme.headline5
              ),
            ),
          ],
        )
    );
  }
}