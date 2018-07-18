import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String token;
  StreamSubscription<Uri> _onLink;

  void initState() {
    _onLink = getUriLinksStream().listen(handleUrl);
    getInitialUri().then(handleUrl);
    super.initState();
  }

  void deactivate() {
    _onLink?.cancel();
    super.deactivate();
  }

  Widget guest(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('You are not logged in.'),
        Divider(
          color: Colors.transparent,
        ),
        RaisedButton(
          child: Text('LOG IN NOW'),
          onPressed: () async {
            var url = 'http://localhost:3000/auth/twitter';

            if (!await canLaunch(url)) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Whoops!'),
                  );
                },
              );
            } else {
              launch(url, forceSafariVC: true, forceWebView: true);
            }
          },
        ),
      ],
    );
  }

  Widget loggedIn(BuildContext context) {
    return Text('Token: $token');
  }

  void handleUrl(Uri url) {
    print('URL received: $url');
    if (url != null &&
        url.scheme == 'twif' &&
        url.queryParameters.containsKey('token')) {
      closeWebView();
      setState(() {
        token = url.queryParameters['token'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Authentication Sample'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: token == null ? guest(context) : loggedIn(context),
        ),
      ),
    );
  }
}
