import 'package:flutter/material.dart';
import '../providers/products.dart';
import '../widgets/product_item.dart';

import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool fav;
  ProductsGrid(this.fav);
  @override
  Widget build(BuildContext context) {
    final productsdata = Provider.of<Products>(context);
    final products = fav ? productsdata.showfav : productsdata.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // create: (context) => products[i], we can also use this syntax
        value: products[i],
        child: ProductItem(

            // id: products[i].id,
            // title: products[i].title,
            // imageUrl: products[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
