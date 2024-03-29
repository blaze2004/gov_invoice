import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gov_invoice/invoice_form.dart';
import 'package:gov_invoice/main.dart';
import 'package:gov_invoice/models/invoice.dart';
import 'package:gov_invoice/popup.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GovInvoicePage extends StatefulWidget {
  const GovInvoicePage({super.key});

  @override
  State<GovInvoicePage> createState() => _GovInvoicePageState();
}

Invoice createNewInvoice(int invoiceNumber) {
  return Invoice(
    updatedDate: DateTime.now(),
    createdDate: DateTime.now(),
    invoiceNumber: invoiceNumber,
    invoiceDate: DateFormat("dd-MM-yyyy").format(DateTime.now()),
    billTo: Person(name: "", city: "", zipCode: 000000, phoneNumber: ""),
    from: Person(name: "", city: "", zipCode: 000000, phoneNumber: ""),
    items: [],
    totalAmount: 0.0,
  );
}

class _GovInvoicePageState extends State<GovInvoicePage> {
  Session? session = supabase.auth.currentSession;

  Invoice _invoice = createNewInvoice(1);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _formRepaintKey = GlobalKey();

  Map<String, Invoice> localInvoiceDataSet = {};

  Future<void> _loadFromDB() async {
    final data = await supabase.from("invoice").select();
    Map<String, dynamic> invoiceData = {};
    for (var entry in data as List<dynamic>) {
      invoiceData[entry["id"].toString()] = entry;
    }
    setState(() {
      localInvoiceDataSet = jsonToMapObject(invoiceData, isDB: true);
      _invoice.invoiceNumber = localInvoiceDataSet.length + 1;
    });
  }

  Future<void> _saveToDB() async {
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic> data =
        mapObjectToJson(localInvoiceDataSet, isDB: true);
    data.forEach((key, value) async {
      value["email"] = session!.user.email;
      try {
        await supabase.from("invoice").upsert(value);
      } on PostgrestException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error saving invoices to cloud."),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something unexpected happended."),
          ),
        );
      }
    });
  }

  Map<String, Invoice> jsonToMapObject(Map<String, dynamic> dataset,
      {bool isDB = false}) {
    final Map<String, Invoice> data = <String, Invoice>{};

    for (var entry in dataset.entries) {
      data[entry.key] = Invoice(
        invoiceNumber: entry.value[isDB ? "id" : "invoiceNumber"],
        invoiceDate: entry.value["invoiceDate"],
        billTo: Person(
          name: entry.value["billTo"]["name"],
          city: entry.value["billTo"]["city"],
          zipCode: entry.value["billTo"]["zipCode"],
          phoneNumber: entry.value["billTo"]["phoneNumber"],
        ),
        from: Person(
          name: entry.value["from"]["name"],
          city: entry.value["from"]["city"],
          zipCode: entry.value["from"]["zipCode"],
          phoneNumber: entry.value["from"]["phoneNumber"],
        ),
        items: [
          for (var item in entry.value["items"])
            InvoiceItem(
              description: item["description"],
              amount: item["amount"],
            )
        ],
        totalAmount: double.parse(entry.value["totalAmount"].toString()),
        filename: entry.value["filename"],
        createdDate:
            DateTime.parse(entry.value[isDB ? "created_at" : "createdDate"]),
        updatedDate: DateTime.parse(entry.value["updatedDate"]),
      );
    }

    return data;
  }

  Future<void> _loadLocalInvoiceData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? localInvoiceData = prefs.getString("localInvoiceData");
    if (localInvoiceData != null) {
      setState(() {
        localInvoiceDataSet = jsonToMapObject(jsonDecode(localInvoiceData));
        _invoice.invoiceNumber = localInvoiceDataSet.length + 1;
      });
    }
  }

  void _showOptionsPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: OptionsPopup(
              invoice: _invoice,
              formKey: _formKey,
              formRepaintKey: _formRepaintKey,
              localInvoiceDataSet: localInvoiceDataSet,
            ),
          );
        });
  }

  void _openInvoiceManager(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: InvoiceManagerPopup(
              localInvoiceDataSet: localInvoiceDataSet,
              editInvoice: _editInvoice,
            ),
          );
        });
  }

  void _editInvoice(String invoiceNumber) {
    _formKey.currentState!.reset();
    setState(() {
      _invoice = localInvoiceDataSet[invoiceNumber]!;
    });
  }

  Future<void> _logOut() async {
    await supabase.auth.signOut();
    setState(() {
      session = supabase.auth.currentSession;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocalInvoiceData().then((value) {
      if (session != null) {
        _saveToDB().then((value) => _loadFromDB());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 8),
            const Text('Gov Invoice'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _openInvoiceManager(context);
            },
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: () {
              Invoice newInvoice =
                  createNewInvoice(localInvoiceDataSet.length + 1);
              setState(() {
                _invoice = newInvoice;
                _formKey.currentState!.reset();
              });
            },
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
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: InvoiceForm(
              invoice: _invoice,
              formKey: _formKey,
              formRepaintKey: _formRepaintKey,
            ),
          );
        },
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
