import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  void _showAddEditDialog(BuildContext context,
      AppLocalizations appLocalizations, FolksonomyProvider provider,
      {String? oldKey, String? oldValue}) {
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
              title: oldKey == null
                  ? appLocalizations.add_tag
                  : appLocalizations.edit_tag,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: keyController,
                    decoration: InputDecoration(
                      labelText: appLocalizations.tag_key,
                      errorText: isValidKey
                          ? null
                          : appLocalizations.invalid_key_format,
                    ),
                    enabled: oldKey == null,
                  ),
                  TextField(
                    controller: valueController,
                    decoration:
                        InputDecoration(labelText: appLocalizations.tag_value),
                  ),
                ],
              ),
              negativeAction: SmoothActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: appLocalizations.cancel,
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
                        Navigator.of(context).pop();
                      }
                    : null,
                text: appLocalizations.save,
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, AppLocalizations appLocalizations,
      FolksonomyProvider provider,
      {required String key, required String value, String? comment}) {
    showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text(appLocalizations.edit_tag),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(context, appLocalizations, provider,
                    oldKey: key, oldValue: value);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text(appLocalizations.remove_tag),
              onTap: () async {
                Navigator.pop(context);
                await provider.deleteTag(key);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final provider = context.watch<FolksonomyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.product_tags_title),
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
                            _showBottomSheet(
                                context, appLocalizations, provider,
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
                _showAddEditDialog(context, appLocalizations, provider);
              },
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }
}
