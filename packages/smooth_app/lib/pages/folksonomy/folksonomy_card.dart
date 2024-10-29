import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_list.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class FolksonomyCard extends StatefulWidget {
  const FolksonomyCard(this.product);
  final Product product;

  @override
  _FolksonomyCardState createState() => _FolksonomyCardState();
}

class _FolksonomyCardState extends State<FolksonomyCard> {
  late Future<Map<String, ProductTag>> _productTagsFuture;
  late Map<String, ProductTag> _productTags;

  @override
  void initState() {
    super.initState();
    _productTagsFuture = fetchProductTags(widget.product.barcode!);
  }

  Future<Map<String, ProductTag>> fetchProductTags(String barcode) async {
    return FolksonomyAPIClient.getProductTags(barcode: barcode);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  FolksonomyList(_productTags, widget.product)),
        );
      },
      child: buildProductSmoothCard(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Product Tags', // TODO: localize
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(width: SMALL_SPACE),
                ],
              ),
              const SizedBox(height: SMALL_SPACE),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: VERY_SMALL_SPACE,
                  bottom: VERY_SMALL_SPACE,
                ),
                child: Semantics(
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: IconWidgetSizer.getRemainingWidgetFlex(),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Wrap(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(SMALL_SPACE),
                                  child: FutureBuilder<Map<String, ProductTag>>(
                                    future: _productTagsFuture,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<Map<String, ProductTag>>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No tags available'));
                                      } else {
                                        final Map<String, ProductTag> tags =
                                            snapshot.data!;
                                        _productTags = tags;
                                        final List<MapEntry<String, ProductTag>>
                                            tagEntries = tags.entries.toList();
                                        final List<MapEntry<String, ProductTag>>
                                            displayTags =
                                            tagEntries.take(5).toList();

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...displayTags.map((entry) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: SMALL_SPACE),
                                                child: Text(
                                                    '${entry.key}: ${entry.value.value}'),
                                              );
                                            }),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Icon(ConstantIcons.instance.getForwardIcon()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
