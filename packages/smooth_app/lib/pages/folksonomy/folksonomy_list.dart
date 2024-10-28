import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FolksonomyList extends StatefulWidget {
  // final Map<String, ProductTag> tags;

  const FolksonomyList({Key? key}) : super(key: key);

  @override
  _FolksonomyListState createState() => _FolksonomyListState();
}

class _FolksonomyListState extends State<FolksonomyList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folksonomy List'),
      ),
      // body: ListView(
      //   padding: const EdgeInsets.all(16.0),
      //   children: widget.tags.entries.map((entry) {
      //     return ListTile(
      //       title: Text(entry.key),
      //       subtitle: Text(entry.value.value),
      //     );
      //   }).toList(),
      // ),
    );
  }
}
