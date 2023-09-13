class InvoiceItem {
  String description;
  double amount;

  InvoiceItem({required this.description, required this.amount});
}

class Person {
  String name;
  String city;
  String zipCode;
  String phoneNumber;

  Person({
    required this.name,
    required this.city,
    required this.zipCode,
    required this.phoneNumber,
  });
}

class Invoice {
  String invoiceNumber;
  String invoiceDate;
  Person billTo;
  Person from;
  List<InvoiceItem> items;
  double totalAmount;

  String filename;
  DateTime createdDate = DateTime.now();
  DateTime updatedDate;

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.billTo,
    required this.from,
    required this.items,
    required this.totalAmount,
    required this.updatedDate,
    this.filename = "my-invoice",
  });
}

Map<String, Invoice> localInvoiceDataSet = {
  // "temp": Invoice(
  //     filename: "temp",
  //     updatedDate: DateTime.now(),
  //     invoiceNumber: "1",
  //     invoiceDate: "20-02-2002",
  //     billTo: Person(name: "1", city: "1", zipCode: "1", phoneNumber: "1"),
  //     from: Person(name: "1", city: "1", zipCode: "1", phoneNumber: "1"),
  //     items: [],
  //     totalAmount: 1.0)
};
