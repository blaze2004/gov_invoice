import 'package:flutter/material.dart';
import 'package:gov_invoice/invoice_page.dart';
import 'package:gov_invoice/login_page.dart';
import 'package:gov_invoice/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: 'https://qsmlvycivznfuerrpkgm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzbWx2eWNpdnpuZnVlcnJwa2dtIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQ1NjYzOTMsImV4cCI6MjAxMDE0MjM5M30.aBeb1RM5rw9TxXYNcUPK3RlLBhstUzS8CzUX6oxpbns',
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
