import 'package:flutter/material.dart';
import 'package:gov_invoice/drawer.dart';
import 'package:gov_invoice/invoice.dart';

class GovInvoicePage extends StatefulWidget {
  const GovInvoicePage({super.key});

  @override
  State<GovInvoicePage> createState() => _GovInvoicePageState();
}

class _GovInvoicePageState extends State<GovInvoicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gov Invoice'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: const Center(
        child: InvoiceForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Menu',
        child: const Icon(Icons.menu),
      ),
      drawer: const Drawer(
        child: SideDrawer(),
      ),
    );
  }
}
