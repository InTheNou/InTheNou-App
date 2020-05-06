import 'package:flutter/material.dart';

class ErrorScaffoldView extends StatelessWidget {

  final dynamic error;
  ErrorScaffoldView(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(error,
                    style: Theme.of(context).textTheme.headline5
                ),
              ),
            ],
          )
      )
    );
  }

}