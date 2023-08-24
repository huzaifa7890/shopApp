import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProduct extends StatelessWidget {
  static const routeName = '/user-product';
  Future<void> _refreshprodcut(BuildContext Context) async {
    await Provider.of<Products>(Context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productdata = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshprodcut(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshprodcut(context),
                    child: Consumer<Products>(
                      builder: (ctx, productdata, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItems(
                                  productdata.items[i].id,
                                  productdata.items[i].imageUrl,
                                  productdata.items[i].title),
                              Divider(),
                            ],
                          ),
                          itemCount: productdata.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
