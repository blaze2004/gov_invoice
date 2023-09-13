import 'package:flutter/material.dart';
import 'package:gov_invoice/main.dart';
import 'package:gov_invoice/models/invoice.dart';

class OptionsPopup extends StatelessWidget {
  const OptionsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: ListView(
        children: const [
          ListTile(
            title: Text("Update"),
            leading: Icon(Icons.save),
          ),
          ListTile(
            title: Text("Save"),
            leading: Icon(Icons.save_as),
            // onTap: () { },
          ),
          ListTile(
            title: Text("Email"),
            leading: Icon(Icons.email),
          ),
          ListTile(
            title: Text("Print"),
            leading: Icon(Icons.print),
          ),
        ],
      ),
    );
  }
}

class InvoiceManagerPopup extends StatelessWidget {
  const InvoiceManagerPopup({super.key});

  Map<String, Invoice> _getInvoices() {
    if (supabase.auth.currentSession != null) {
      final response = supabase.from("invoices").select();
      return response as Map<String, Invoice>;
    } else {
      return localInvoiceDataSet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Invoice> invoices = _getInvoices();

    if (invoices.isEmpty) {
      return const Center(
        child: Text("No invoices found"),
      );
    }

    return Container(
      height: 800,
      width: 500,
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          for (var invoice in _getInvoices().values)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(invoice.filename),
                Text(invoice.updatedDate.toString()),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                  height: 20,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
        ],
      ),
    );
  }
}
