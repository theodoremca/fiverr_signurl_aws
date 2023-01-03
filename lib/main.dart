import 'dart:math';

import 'package:fiverr_signurl_aws/home.dart';
import 'package:fiverr_signurl_aws/locator.dart';
import 'package:fiverr_signurl_aws/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUp();
  runApp(ProviderScope(
    child: MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
