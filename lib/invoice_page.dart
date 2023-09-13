import 'package:flutter/material.dart';
import 'package:gov_invoice/invoice_form.dart';
import 'package:gov_invoice/main.dart';
import 'package:gov_invoice/popup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GovInvoicePage extends StatefulWidget {
  const GovInvoicePage({super.key});

  @override
  State<GovInvoicePage> createState() => _GovInvoicePageState();
}

class _GovInvoicePageState extends State<GovInvoicePage> {
  Session? session = supabase.auth.currentSession;

  void _showOptionsPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialog(
            child: OptionsPopup(),
          );
        });
  }

  void _openInvoiceManager(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialog(
            child: InvoiceManagerPopup(),
          );
        });
  }

  Future<void> _logOut() async {
    await supabase.auth.signOut();
    setState(() {
      session = supabase.auth.currentSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gov Invoice'),
        actions: [
          IconButton(
            onPressed: () {
              _openInvoiceManager(context);
            },
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              if (session == null) {
                Navigator.of(context).pushReplacementNamed("/login");
              } else {
                _logOut();
              }
            },
            icon: session == null
                ? const Icon(Icons.login)
                : const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: InvoiceForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOptionsPopup(context);
        },
        tooltip: 'Menu',
        child: const Icon(Icons.menu),
      ),
    );
  }
}
