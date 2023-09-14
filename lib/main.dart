import 'package:flutter/material.dart';
import 'package:gov_invoice/invoice_page.dart';
import 'package:gov_invoice/login_page.dart';
import 'package:gov_invoice/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
        '/invoice': (_) => const GovInvoicePage(),
        '/login': (_) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
