import 'dart:async';
import 'dart:convert';

import 'package:InTheNou/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart' as flux;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebView extends StatefulWidget {

  @override
  _LoginWebViewState createState() => new _LoginWebViewState();

}

class _LoginWebViewState extends State<LoginWebView>
    with flux.StoreWatcherMixin<LoginWebView> {
  final Completer<WebViewController> _controller =
    Completer<WebViewController>();
  UserStore _userStore;
  String contentBase64 = "";
  @override
  void initState() {
    _userStore = listenToStore(UserStore.userStoreToken);
    try {
      contentBase64 =
          base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    } catch(e){

    }

    super.initState();
  }
  String kNavigationExamplePage = '''<!DOCTYPE html>
      <html>
  <head>
  <title>Forwarding ...</title>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=0">
  <script src='https://ssl.gstatic.com/accounts/o/4176129571-xsrfstatemanager.js' nonce="H1jGxGQc11vpxEybRxtD2A">
  </script>
  </head>
  <body >
  <noscript>
  <meta http-equiv="refresh" content="0;url=/o/noscript">
  </noscript>
  
<script type="text/javascript" nonce="H1jGxGQc11vpxEybRxtD2A">
xsrfstatemanager.chooseKeyAndRedirect(
'https:\/\/accounts.google.com\/signin\/oauth?client_id\x3d413106471204-utam6s38omd35q649036q4tb9gft8l0u.apps.googleusercontent.com\x26as\x3dHJyiNKAA2KOA1rzgbjvO7A\x26destination\x3dhttps:\/\/inthenou.uprm.edu\x26approval_state\x3d!ChQ5aGJuai11VlFiNjFXNkJqNHMzdRIfSTE1TnpURjVfekVZVUU3MWpGWk5XazBEeS10dUZCYw%E2%88%99AF-3PDcAAAAAXopC1-xRlpwn1IGsI-87g4-Axf10iuA1\x26oauthgdpr\x3d1\x26xsrfsig\x3dChkAeAh8T37bf7kwDemAZwtcF0o1fvvkAs21Eg5hcHByb3ZhbF9zdGF0ZRILZGVzdGluYXRpb24SBXNvYWN1Eg9vYXV0aHJpc2t5c2NvcGU', 'R0WZXjAX7ROk_jPkqzFhJSQVuLl6i8jBsA5bAJg6z6s', 'OCAK',true,true, 'https:\/\/accounts.google.com\/o\/nocookie');
</script>
</body>
</html>''';

  WebViewController webViewController;
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
//    flutterWebviewPlugin
//        .evalJavascript('setCookie("in_app=true;);');
//    flutterWebviewPlugin.onStateChanged.listen((viewState) async {
//      if (viewState.type == WebViewState.shouldStart) {
//        await flutterWebviewPlugin.evalJavascript('document.cookie');
//        final String cookies =
//        await flutterWebviewPlugin.evalJavascript('setCookie("in_app=true; path=/")');
//        print("hello");
//        print(cookies);
//      }
//    });
//    return WebviewScaffold(
//      url: 'data:text/html;base64,$contentBase64',
//      withLocalStorage: true,
//      appCacheEnabled: true,
//      withJavascript: true,
//    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Builder(
        builder: (context){
          return WebView(
            initialUrl: 'data:text/html;base64,$contentBase64',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              this.webViewController = webViewController;
              _controller.complete(webViewController);
//              _controller.future.then((value) {
//                _onShowUserAgent(value);
////                _onNavigationDelegateExample(value);
//              });
            },
            onPageStarted: (_){
              webViewController.evaluateJavascript('setCookie("in_app=true; path=/");'
                  '');
            },
          );
        },
      ),
    );
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
    await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }
  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }

  void _onNavigationDelegateExample(WebViewController controller) async {
    final String contentBase64 =
      base64Encode(const Utf8Encoder().convert(_userStore.redirectURL));
    debugPrint(contentBase64);
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }
}

