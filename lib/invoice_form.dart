import 'package:flutter/material.dart';
import 'package:gov_invoice/models/invoice.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _billToNameController = TextEditingController();
  final TextEditingController _billToCityController = TextEditingController();
  final TextEditingController _billToZipCodeController =
      TextEditingController();
  final TextEditingController _billToPhoneController = TextEditingController();
  final List<InvoiceItem> _invoiceItems = [];
  final int _invoiceNumber = 1;
  double _totalAmount = 0;
  DateTime _selectedDate = DateTime.now();

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _invoiceItems.add(
          InvoiceItem(
            description: "",
            amount: 0.0,
          ),
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      final formattedDate = "${picked.day}-${picked.month}-${picked.year}";
      setState(() {
        _selectedDate = picked;
        _invoiceDateController.text = formattedDate;
      });
    }
  }

  void _setTotalAmount() {
    double totalAmount = 0;
    for (var item in _invoiceItems) {
      totalAmount += item.amount;
    }
    setState(() {
      _totalAmount = totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Invoice number:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16.0),
                Text(
                  _invoiceNumber.toString(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Invoice Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: IgnorePointer(
                child: TextFormField(
                  controller: _invoiceDateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an invoice date';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill To:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: _billToNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: _billToCityController,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      TextFormField(
                        controller: _billToZipCodeController,
                        decoration:
                            const InputDecoration(labelText: 'Zip Code'),
                      ),
                      TextFormField(
                        controller: _billToPhoneController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: _billToNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: _billToCityController,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      TextFormField(
                        controller: _billToZipCodeController,
                        decoration:
                            const InputDecoration(labelText: 'Zip Code'),
                      ),
                      TextFormField(
                        controller: _billToPhoneController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64.0),
            const Text(
              'Invoice Items:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _invoiceItems.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          // Update the description when text changes
                          _invoiceItems[index].description = value;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          // Update the amount when text changes
                          _invoiceItems[index].amount = double.parse(value);
                          _setTotalAmount();
                        },
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Total Amount: $_totalAmount',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
