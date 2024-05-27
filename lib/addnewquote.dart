import 'package:flutter/material.dart';

import 'dbhelper.dart';

class AddNewQuote extends StatefulWidget {
  const AddNewQuote({Key? key}) : super(key: key);

  @override
  State<AddNewQuote> createState() => _AddNewQuoteState();
}

class _AddNewQuoteState extends State<AddNewQuote> {
  late TextEditingController textEditingController;
  String quote = "";

  void addQuote(String quote) async {
    var dbhelper = Dbhelper();
    print(quote);
    dbhelper.addQuote(quote);
  }

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Add New Quote"),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
          child: Column(
            children: [
              TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Add New Quote",
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  child: const Text("Add Quote"),
                  onPressed: () {
                    setState(() {
                      quote = textEditingController.text;
                      addQuote(quote);
                      Navigator.pop(context);
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
