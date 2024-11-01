import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/themes/constant_icons.dart';

class FolksonomyCard extends StatelessWidget {
  const FolksonomyCard(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FolksonomyProvider(product.barcode!),
      child: Container(child: Card(product)),
    );
  }
}

class Card extends StatelessWidget {
  const Card(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (BuildContext context) => FolksonomyPage(product),
              ),
            )
            .then((completion) => {
                  Provider.of<FolksonomyProvider>(context, listen: false)
                      .fetchProductTags(),
                });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: SMALL_SPACE),
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
                CardList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FolksonomyProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else if (!provider.tagsExist) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'No tags found. Tags can be used to better group similar products. Tap to add.', // TODO: localize
                textAlign: TextAlign.center,
              ),
            ),
            Icon(ConstantIcons.instance.getForwardIcon()),
          ],
        ),
      );
    } else {
      final Map<String, ProductTag> tags = provider.productTags!;
      final Iterable<MapEntry<String, ProductTag>> displayTags =
          tags.entries.toList().take(5);

      return Padding(
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
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayTags.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: VERY_SMALL_SPACE),
                        child: Text(
                          '${entry.key}: ${entry.value.value}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Icon(ConstantIcons.instance.getForwardIcon()),
            ],
          ),
        ),
      );
    }
  }
}
