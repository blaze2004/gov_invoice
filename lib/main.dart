import 'package:flutter/material.dart';
import 'package:gov_invoice/invoice_generator.dart';
import 'package:gov_invoice/login_page.dart';
import 'package:gov_invoice/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'supabase_url',
    anonKey: 'supabase_anon_key',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const GovInvoice());
}

final supabase = Supabase.instance.client;

class GovInvoice extends StatelessWidget {
  const GovInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gov Invoice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/invoice': (_) => const GovInvoicePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
