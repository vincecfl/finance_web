import 'package:finance_web/page/wap/farm_wap_page.dart';
import 'package:finance_web/provider/index_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart'as fluro;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'common/platform.dart';
import 'generated/l10n.dart';
import 'page/pc/farm_pc_page.dart';
import 'router/application.dart';
import 'router/router.dart';

void main() {
  final router = fluro.Router();
  Routes.configure(router);
  Application.router = router;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => IndexProvider()..init()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final isNotMobile = !PlatformDetector().isMobile();
    return  MaterialApp(
      title: 'Flash Finance',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Application.router.generator,
      home: isNotMobile ? FarmPcPage() : FarmWapPage(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        print(locales);
        return;
      },
    );
  }
}
