import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyPage extends StatelessWidget {
  const FolksonomyPage(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FolksonomyProvider(product.barcode!),
      child: FolksonomyContent(product),
    );
  }
}

class FolksonomyContent extends StatefulWidget {
  const FolksonomyContent(this.product);
  final Product product;

  @override
  _FolksonomyContentState createState() => _FolksonomyContentState();
}

class _FolksonomyContentState extends State<FolksonomyContent> {
  @override
  void initState() {
    super.initState();
  }

  void _showAddEditDialog(BuildContext context, FolksonomyProvider provider,
      {String? oldKey, String? oldValue, String? oldComment}) {
    final TextEditingController keyController =
        TextEditingController(text: oldKey);
    final TextEditingController valueController =
        TextEditingController(text: oldValue);
    const String regexString = r'^[a-z0-9_-]+(:[a-z0-9_-]+)*$';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isValidKey = RegExp(regexString).hasMatch(keyController.text);

            keyController.addListener(() {
              setState(() {
                isValidKey = RegExp(regexString).hasMatch(keyController.text);
              });
            });

            return SmoothAlertDialog(
              // TODO: Localize
              title: oldKey == null ? 'Add Tag' : 'Edit Tag',
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: keyController,
                    decoration: InputDecoration(
                      labelText: 'Key',
                      errorText: isValidKey ? null : 'Invalid key format.',
                    ),
                    enabled: oldKey == null,
                  ),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(labelText: 'Value'),
                  ),
                ],
              ),
              negativeAction: SmoothActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: 'Cancel',
              ),
              positiveAction: SmoothActionButton(
                onPressed: isValidKey
                    ? () async {
                        if (oldKey == null) {
                          await provider.addTag(
                              keyController.text, valueController.text);
                        } else {
                          await provider.editTag(oldKey, valueController.text);
                        }
                        if (provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${provider.error}')),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    : null,
                text: 'Save',
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, FolksonomyProvider provider,
      {required String key, required String value, String? comment}) {
    showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(context, provider,
                    oldKey: key, oldValue: value, oldComment: comment);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () async {
                Navigator.pop(context);
                await provider.deleteTag(key);
                if (provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${provider.error}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FolksonomyProvider>();

    return Scaffold(
      appBar: AppBar(
        // TODO: Localize
        title: Text('Product Tags'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: provider.productTags!.entries
                  .map((MapEntry<String, ProductTag> entry) {
                return ListTile(
                  title: Text(
                    '${entry.key} : ${entry.value.value}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: provider.isAuthorized
                      ? IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            _showBottomSheet(context, provider,
                                key: entry.key,
                                value: entry.value.value,
                                comment: entry.value.comment);
                          },
                        )
                      : null,
                );
              }).toList(),
            ),
      floatingActionButton: provider.isAuthorized
          ? FloatingActionButton(
              onPressed: () {
                _showAddEditDialog(context, provider);
              },
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }
}
