import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gov_invoice/main.dart';
import 'package:gov_invoice/models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsPopup extends StatelessWidget {
  const OptionsPopup(
      {super.key,
      required this.invoice,
      required this.formKey,
      required this.localInvoiceDataSet});

  final Invoice invoice;
  final GlobalKey<FormState> formKey;
  final Map<String, Invoice> localInvoiceDataSet;

  Map<String, dynamic> toJson(Map<String, Invoice> dataSet) {
    final Map<String, dynamic> data = <String, dynamic>{};

    for (var entry in dataSet.entries) {
      data[entry.key] = {
        "invoiceNumber": entry.value.invoiceNumber,
        "invoiceDate": entry.value.invoiceDate,
        "billTo": {
          "name": entry.value.billTo.name,
          "city": entry.value.billTo.city,
          "zipCode": entry.value.billTo.zipCode,
          "phoneNumber": entry.value.billTo.phoneNumber,
        },
        "from": {
          "name": entry.value.from.name,
          "city": entry.value.from.city,
          "zipCode": entry.value.from.zipCode,
          "phoneNumber": entry.value.from.phoneNumber,
        },
        "items": [
          for (var item in entry.value.items)
            {
              "description": item.description,
              "amount": item.amount,
            }
        ],
        "totalAmount": entry.value.totalAmount,
        "filename": entry.value.filename,
        "createdDate": entry.value.createdDate.toString(),
        "updatedDate": entry.value.updatedDate.toString(),
      };
    }
    return data;
  }

  Future<void> _saveInvoice() async {
    if (formKey.currentState!.validate()) {
      final String invoiceDataKey =
          invoice.filename + invoice.invoiceNumber.toString();
      localInvoiceDataSet.addEntries({
        invoiceDataKey: invoice,
      }.entries);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String localInvoiceData = jsonEncode(toJson(localInvoiceDataSet));
      await prefs.setString("localInvoiceData", localInvoiceData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: ListView(
        children: [
          const ListTile(
            title: Text("Update"),
            leading: Icon(Icons.save),
          ),
          ListTile(
            title: const Text("Save"),
            leading: const Icon(Icons.save_as),
            onTap: () {
              _saveInvoice();
            },
          ),
          const ListTile(
            title: Text("Email"),
            leading: Icon(Icons.email),
          ),
          const ListTile(
            title: Text("Print"),
            leading: Icon(Icons.print),
          ),
        ],
      ),
    );
  }
}

class InvoiceManagerPopup extends StatelessWidget {
  const InvoiceManagerPopup({super.key, required this.localInvoiceDataSet});

  final Map<String, Invoice> localInvoiceDataSet;

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

    List<Widget> gridTiles = [];

    final DateFormat format = DateFormat("dd-MM-yyyy HH:mm");

    for (var invoice in _getInvoices().values) {
      gridTiles.addAll([
        GridTile(child: Text(invoice.filename)),
        GridTile(child: Text(format.format(invoice.updatedDate))),
        GridTile(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
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
        ),
      ]);
    }

    return Container(
      height: 800,
      width: 500,
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 3.0),
        children: gridTiles,
      ),
    );
  }
}
