import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simple_ledger/presentation/screens/main_scaffold.dart';

class SimpleLedgerApp extends StatelessWidget {
  const SimpleLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcountBook',  // アプリ名
      debugShowCheckedModeBanner: false,  // 右上の"DEBUG"帯を消す
      theme: ThemeData(        // ← アプリ全体の見た目
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(    //   基準色（ここの色が全画面に効く）
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,     // タイトルを左寄せ（trueだと中央）
          elevation: 0,       // AppBar下の影を消してフラットに
        ),
        cardTheme: CardThemeData(
          elevation: 1,       // 薄い影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),    // 角を12px丸める
          ),
        ),
      ),
      localizationsDelegates: const [   //   日付ピッカー等を日本語化
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),     // 日本語（日本）
        Locale('en', 'US'),     // 英語（アメリカ）
      ],
      locale: const Locale('ja', 'JP'),     // ← 言語（日本語）
      home: const MainScaffold(),     // ← 最初に表示する画面
    );
  }
}
