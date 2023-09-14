import 'package:flutter/material.dart';
import 'package:gov_invoice/models/invoice.dart';
import 'package:intl/intl.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key, required this.invoice, required this.formKey});

  final Invoice invoice;
  final GlobalKey<FormState> formKey;

  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final TextEditingController _invoiceDateController = TextEditingController();
  final DateFormat format = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    super.initState();
    _invoiceDateController.text = widget.invoice.invoiceDate;
  }

  @override
  void dispose() {
    _invoiceDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Invoice invoice = widget.invoice;
    final GlobalKey<FormState> formKey = widget.formKey;

    void addItem() {
      if (formKey.currentState!.validate()) {
        setState(() {
          invoice.items.add(
            InvoiceItem(
              description: "",
              amount: 0.0,
            ),
          );
        });
      }
    }

    void setTotalAmount() {
      double totalAmount = 0;
      for (var item in invoice.items) {
        totalAmount += item.amount;
      }
      setState(() {
        invoice.totalAmount = totalAmount;
      });
    }

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != format.parse(invoice.invoiceDate)) {
        final formattedDate = "${picked.day}-${picked.month}-${picked.year}";
        setState(() {
          invoice.invoiceDate = formattedDate;
          _invoiceDateController.text = formattedDate;
        });
      }
    }

    return Form(
      key: formKey,
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
                  invoice.invoiceNumber.toString(),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Invoice name:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    initialValue: invoice.filename,
                    onChanged: (value) {
                      invoice.filename = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an invoice name';
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(hintText: 'Invoice Name'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Invoice Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                selectDate(context);
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
                        onChanged: (value) => {
                          invoice.billTo.name = value,
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        onChanged: (value) => {
                          invoice.billTo.city = value,
                        },
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      TextFormField(
                        onChanged: (value) => {
                          invoice.billTo.zipCode = int.parse(value),
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a zip code';
                          } else if (value.length != 6) {
                            return 'Zip code must be 6 digits';
                          } else if (int.tryParse(value) == null) {
                            return 'Zip code must be a number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Zip Code'),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                        onChanged: (value) => {
                          invoice.billTo.phoneNumber = value,
                        },
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
                        onChanged: (value) => {
                          invoice.from.name = value,
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        onChanged: (value) => {
                          invoice.from.city = value,
                        },
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      TextFormField(
                        onChanged: (value) => {
                          invoice.from.zipCode = int.parse(value),
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a zip code';
                          } else if (value.length != 6) {
                            return 'Zip code must be 6 digits';
                          } else if (int.tryParse(value) == null) {
                            return 'Zip code must be a number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Zip Code'),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                        onChanged: (value) => {
                          invoice.from.phoneNumber = value,
                        },
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
              itemCount: invoice.items.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          invoice.items[index].description = value;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          invoice.items[index].amount = double.parse(value);
                          setTotalAmount();
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
              onPressed: addItem,
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Total Amount: ${invoice.totalAmount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
