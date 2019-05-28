import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodrecipes/api.dart';
import 'package:shimmer/shimmer.dart';

import '../database/dbhelper.dart';
import '../endpoint.dart';
import '../model/foods.dart';

class DetailScreen extends StatefulWidget {
  final String id, img;

  DetailScreen({Key key, this.id, this.img}) : super(key: key);

  @override
  _DetailState createState() => _DetailState(id, img);
}

class _DetailState extends State<DetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFavorite = false;
  String _id, _name, _img, _category;
  List<String> _ingredients = [];
  var db = DbHelper();

  _DetailState(this._id, this._img);

  @override
  void initState() {
    super.initState();
    db.getFavoriteById(_id).then((favorite) {
      if (favorite) {
        setState(() {
          _isFavorite = true;
        });
      } else {
        setState(() {
          _isFavorite = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: _generateAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _generateBody(),
            ],
          ),
        ));
  }

  Widget _generateAppBar() {
    if (_isFavorite) {
      return AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Detail",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, false)),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.favorite),
            onPressed: () {
              db.delete(_id);
              setState(() {
                _isFavorite = false;
              });
            },
          )
        ],
      );
    }
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Detail",
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context, false)),
      actions: <Widget>[
        FlatButton(
          child: Icon(Icons.favorite_border),
          onPressed: () {
            db.insertFavorite(Foods(_id, _name, _img, _category));
            setState(() {
              _isFavorite = true;
            });
          },
        )
      ],
    );
  }

  Widget _generateBody() {
    if (_name == null || _id == null || _ingredients.length < 1) {
      loadData();
    }
    return Center(
      child: Column(
        children: <Widget>[
          _generatePic(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _generateName(),
                Padding(
                  padding: EdgeInsets.all(16),
                ),
                Text(
                  "Bahan : ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                _ingredientList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _generatePic() {
    return Hero(
      child: CachedNetworkImage(imageUrl: _img),
      tag: _img,
    );
  }

  Widget _generateName() {
    if (_name == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Shimmer.fromColors(
            child: Container(
              width: double.infinity,
              height: 32,
              color: Colors.white,
            ),
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100]),
      );
    }
    return Text(
      _name,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
    );
  }

  Widget _ingredientList() {
    if (_ingredients.length < 1) {
      return Shimmer.fromColors(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 32,
                color: Colors.white,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 32,
                color: Colors.white,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 32,
                color: Colors.white,
              )
            ],
          ),
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100]);
    }
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
            title: Text(_ingredients[index]),
            leading: Text((index + 1).toString() + ". "),
          ),
      itemCount: _ingredients.length,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  loadData() async {
    try {
      var api = Api();
      api.getData(Endpoint.link + "lookup.php?i=" + _id).then((response) {
        var responseJson = json.decode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            _name = responseJson["meals"][0]["strMeal"];
            _category = responseJson["meals"][0]["strCategory"];
            for (int x = 1; x <= 20; x++) {
              if (responseJson["meals"][0]["strIngredient" + x.toString()] ==
                  "") {
                break;
              }
              _ingredients.add(
                  responseJson["meals"][0]["strIngredient" + x.toString()]);
            }
          });
        } else {
          throw Exception("Failed to load data");
        }
      });
    } catch (e) {
      final SnackBar sn = SnackBar(
        content: Text("Failed to load data"),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => loadData(),
          textColor: Colors.white,
        ),
      );
      _scaffoldKey.currentState.showSnackBar(sn);
    }
  }
}
