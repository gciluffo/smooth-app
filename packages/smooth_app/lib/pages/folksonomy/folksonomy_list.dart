import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FolksonomyList extends StatefulWidget {
  FolksonomyList(this.tags, this.product);
  final Map<String, ProductTag> tags;
  final Product product;

  @override
  _FolksonomyListState createState() => _FolksonomyListState();
}

class _FolksonomyListState extends State<FolksonomyList> {
  late Map<String, ProductTag> _tags;

  @override
  void initState() {
    super.initState();
    _tags = Map<String, ProductTag>.from(widget.tags ?? {});
  }

  void _addTag(String key, String value, String? comment) {
    // TODO: Make api call, verified authed
    setState(() {
      // _tags[key] = ProductTag(value: value, comment: comment);
    });
  }

  void _editTag(
      String oldKey, String newKey, String newValue, String? newComment) {
    // TODO: Make api call, verified authed
    setState(() {
      // _tags.remove(oldKey);
      // _tags[newKey] = ProductTag(value: newValue, comment: newComment);
    });
  }

  void _deleteTag(String key) {
    // TODO: Make api call, verified authed
    setState(() {
      _tags.remove(key);
    });
  }

  void _showAddEditDialog(
      {String? oldKey, String? oldValue, String? oldComment}) {
    final TextEditingController keyController =
        TextEditingController(text: oldKey);
    final TextEditingController valueController =
        TextEditingController(text: oldValue);
    final TextEditingController commentController =
        TextEditingController(text: oldComment);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // TODO: Localize
          title: Text(oldKey == null ? 'Add Tag' : 'Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: InputDecoration(labelText: 'Key'),
              ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Value'),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Comment (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (oldKey == null) {
                  _addTag(keyController.text, valueController.text,
                      commentController.text);
                } else {
                  _editTag(oldKey, keyController.text, valueController.text,
                      commentController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: Localize
        title: Text('Product Tags'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: _tags.entries.map((MapEntry<String, ProductTag> entry) {
          return Dismissible(
            key: Key(entry.key),
            background: Container(
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white)),
            onDismissed: (direction) {
              _deleteTag(entry.key);
            },
            child: ListTile(
              title: Text('${entry.key} : ${entry.value.value}'),
              // subtitle: Text(entry.value.comment),
              subtitle: Text('Comennt on the k v value'),
              onTap: () {
                _showAddEditDialog(
                    oldKey: entry.key,
                    oldValue: entry.value.value,
                    oldComment: entry.value.comment);
              },
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
