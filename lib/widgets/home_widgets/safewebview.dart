import 'package:flutter/material.dart'; // General Flutter Widgets
import 'package:webview_flutter/webview_flutter.dart'; // WebView Flutter package

class SafeWebView extends StatefulWidget {
  final String? url;
  SafeWebView({this.url});

  @override
  _SafeWebViewState createState() => _SafeWebViewState();
}

class _SafeWebViewState extends State<SafeWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Ensure that the WebView is initialized properly
    WidgetsFlutterBinding.ensureInitialized();
    // Create a WebViewController instance
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => print('Page started loading: $url'),
          onPageFinished: (url) => print('Page finished loading: $url'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _controller
        ..loadRequest(Uri.parse(widget.url ?? 'https://flutter.dev')), // Load the URL
    );
  }
}
