import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gov_invoice/main.dart';
import 'package:gov_invoice/models/invoice.dart';
import 'package:gov_invoice/print_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> updateLocalInvoiceDataset(
    Map<String, Invoice> localInvoiceDataSet) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String localInvoiceData = jsonEncode(toJson(localInvoiceDataSet));
  await prefs.setString("localInvoiceData", localInvoiceData);
}

class OptionsPopup extends StatelessWidget {
  const OptionsPopup({
    super.key,
    required this.invoice,
    required this.formKey,
    required this.formRepaintKey,
    required this.localInvoiceDataSet,
  });

  final Invoice invoice;
  final GlobalKey<FormState> formKey;
  final GlobalKey formRepaintKey;
  final Map<String, Invoice> localInvoiceDataSet;

  Future<String> _saveInvoice() async {
    if (formKey.currentState!.validate()) {
      final String invoiceDataKey = invoice.invoiceNumber.toString();
      localInvoiceDataSet.addEntries({
        invoiceDataKey: invoice,
      }.entries);
      await updateLocalInvoiceDataset(localInvoiceDataSet);
      return "Invoice saved successfully.";
    }
    return "Fix form errors before saving.";
  }

  void _askRecipientEmailPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Enter Email'),
          content: Form(
            key: emailFormKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                } else if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailFormKey.currentState!.validate()) {
                  InvoicePdf(invoice: invoice)
                      .sendEmailWithPDF(emailController.text)
                      .then(
                    (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: ListView(
        children: [
          ListTile(
            title: const Text("Save"),
            leading: const Icon(Icons.save),
            onTap: () {
              _saveInvoice()
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value),
                        ),
                      ));
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text("Email"),
            leading: const Icon(Icons.email),
            onTap: () {
              _askRecipientEmailPopup(context);
            },
          ),
          ListTile(
            title: const Text("Print"),
            leading: const Icon(Icons.print),
            onTap: () {
              Navigator.of(context).pop();
              InvoicePdf(invoice: invoice)
                  .savePdf()
                  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invoice printed successfully."),
                        ),
                      ));
            },
          ),
        ],
      ),
    );
  }
}

class InvoiceManagerPopup extends StatefulWidget {
  const InvoiceManagerPopup(
      {super.key,
      required this.localInvoiceDataSet,
      required this.editInvoice});

  final Map<String, Invoice> localInvoiceDataSet;

  final void Function(String) editInvoice;

  @override
  State<InvoiceManagerPopup> createState() => _InvoiceManagerPopupState();
}

class _InvoiceManagerPopupState extends State<InvoiceManagerPopup> {
  @override
  Widget build(BuildContext context) {
    Map<String, Invoice> localInvoiceDataSet = widget.localInvoiceDataSet;

    Map<String, Invoice> getInvoices() {
      if (supabase.auth.currentSession != null) {
        final response = supabase.from("invoices").select();
        return response as Map<String, Invoice>;
      } else {
        return localInvoiceDataSet;
      }
    }

    void showDeleteInvoiceWarning(BuildContext context, String invoiceId) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Invoice"),
              content:
                  const Text("Are you sure you want to delete this invoice?"),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      localInvoiceDataSet.remove(invoiceId);
                      updateLocalInvoiceDataset(localInvoiceDataSet);
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
              ],
            );
          });
    }

    final Map<String, Invoice> invoices = getInvoices();

    if (invoices.isEmpty) {
      return const Center(
        child: Text("No invoices found"),
      );
    }

    List<Widget> gridTiles = [];

    final DateFormat format = DateFormat("dd-MM-yyyy HH:mm");

    for (var invoice in invoices.values) {
      gridTiles.addAll([
        GridTile(child: Text(invoice.filename)),
        GridTile(child: Text(format.format(invoice.updatedDate))),
        GridTile(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  widget.editInvoice(invoice.invoiceNumber.toString());
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  showDeleteInvoiceWarning(
                    context,
                    invoice.invoiceNumber.toString(),
                  );
                },
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
          crossAxisCount: 3,
          childAspectRatio: 3.0,
        ),
        children: gridTiles,
      ),
    );
  }
}
