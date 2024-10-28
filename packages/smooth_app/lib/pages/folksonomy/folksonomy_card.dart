import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_list.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// Card that displays buttons related to prices.
class FolksonomyCard extends StatefulWidget {
  const FolksonomyCard(this.product);
  final Product product;

  @override
  _FolksonomyCardState createState() => _FolksonomyCardState();
}

class _FolksonomyCardState extends State<FolksonomyCard> {
  late Future<Map<String, ProductTag>> _productTagsFuture;

  @override
  void initState() {
    super.initState();
    _productTagsFuture = fetchProductTags(widget.product.barcode!);
  }

  Future<Map<String, ProductTag>> fetchProductTags(String barcode) async {
    // Replace with your actual API call
    final response = await FolksonomyAPIClient.getProductTags(barcode: barcode);

    print('the response is $response');
    print(response);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension? themeExtension =
        Theme.of(context).extension<SmoothColorsThemeExtension>();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FolksonomyList(),
          ),
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
                    'Product Tags',
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center(
                                            child: Text('No tags available'));
                                      } else {
                                        final Map<String, ProductTag> tags =
                                            snapshot.data!;
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
