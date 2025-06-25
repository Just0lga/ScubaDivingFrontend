import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            child: Image.network(
              "https://scuba-diving-s3-bucket.s3.eu-north-1.amazonaws.com/products/23-1.jpeg",
            ),
          ),
        ],
      ),
    );
  }
}
