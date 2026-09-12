import 'package:flutter/material.dart';

class FotoZoomScreen extends StatelessWidget {
  final String url;
  const FotoZoomScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(child: Image.network(url)),
      ),
    );
  }
}
