import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    
          appBar:  AppBar(
              title: Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.displayLarge,
      )),
    );
  }
}