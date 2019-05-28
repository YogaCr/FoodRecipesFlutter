import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodrecipes/api.dart';
import 'package:foodrecipes/database/dbhelper.dart';
import 'package:shimmer/shimmer.dart';

import '../endpoint.dart';
import '../model/foods.dart';
import 'detailscreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _isSearch = false, _isTab = false, _isSearching = false;
  List<Foods> _desert = [];
  List<Foods> _seafood = [];
  List<Foods> _search = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();
  var db = DbHelper();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        loadData();
        return;
      }
      searchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bahan Makanan',
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: _generateAppBar(),
              body: _setBody(),
              bottomNavigationBar: BottomNavigationBar(
                key: Key("BottomNav"),
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.fastfood), title: Text("Desert")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.fastfood), title: Text("Seafood")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), title: Text("Favorite"))
                ],
                onTap: _menuNavigation,
                currentIndex: _index,
              ),
            )));
  }

  _menuNavigation(int index) {
    setState(() {
      _isSearch = false;
      _index = index;
      if (index == 2) {
        _isTab = true;
      } else {
        _isTab = false;
      }
    });
  }

  _changeIsSearch(bool b) {
    if (b) {
      loadData();
    }
    setState(() {
      _isSearching = false;
      _search.clear();
      _controller.text = "";
      _isSearch = b;
    });
  }

  Widget _generateAppBar() {
    List<Widget> action;
    if (_isTab) {
      action = null;
    } else {
      action = [
        FlatButton(
            key: Key("SearchButton"),
            onPressed: () => _changeIsSearch(true),
            child: Icon(
              Icons.search,
              color: Colors.black,
            ))
      ];
    }
    if (_isSearch) {
      return AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          key: Key("SearchTextBox"),
          decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
              hintText: "Search"),
          controller: _controller,
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: () => _changeIsSearch(false),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ))
        ],
        bottom: _setTab(),
      );
    }
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Food Recipes',
        style: TextStyle(color: Colors.black),
      ),
      actions: action,
      bottom: _setTab(),
    );
  }

  Widget _setTab() {
    if (_isTab) {
      return TabBar(
        tabs: [
          Padding(
            child: Text(
              "Desert",
              style: TextStyle(color: Colors.black),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          Padding(
            child: Text(
              "Seafood",
              style: TextStyle(color: Colors.black),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          )
        ],
      );
    }
    return null;
  }

  Widget _setBody() {
    if (_isSearching) {
      return _loadingShimmer();
    }
    if (_isSearch) {
      if (!_isTab) {
        return _generateBody(_search);
      }
    }
    if (_index == 0) {
      return _generateBody(_desert);
    } else if (_index == 1) {
      return _generateBody(_seafood);
    } else {
      return _generateFavoriteBody();
    }
  }

  Widget _loadingShimmer() {
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: 8,
        itemBuilder: (BuildContext c, int index) => Card(
              child: Column(
                children: <Widget>[
                  Shimmer.fromColors(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 100,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100])
                ],
              ),
            ));
  }

  Widget _generateBody(List<Foods> data) {
    if (data.length < 1 && !_isTab) {
      loadData();
      return _loadingShimmer();
    }
    return GridView.builder(
        key: Key("Content"),
        padding: EdgeInsets.all(8),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: data.length,
        itemBuilder: (BuildContext c, int index) => GestureDetector(
            key: Key("makanan"),
            child: Card(
                child: Column(
              children: <Widget>[
                _showImage(data[index].img),
                _showName(data[index].name)
              ],
            )),
            onTap: () {
              final snackbar = SnackBar(content: Text(data[index].name));
              Scaffold.of(c).showSnackBar(snackbar);
              Navigator.push(
                  c,
                  MaterialPageRoute(
                      builder: (context) => DetailScreen(
                            id: data[index].id,
                            img: data[index].img,
                          )));
            }));
  }

  Widget _favBody(String cat) {
    return FutureBuilder<List<Foods>>(
      future: db.getFavorite(cat),
      builder: (c, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return _generateBody(snapshot.data);
          else
            return Center(
              child: Text("No Data"),
            );
        } else {
          return Center(
            child: Text("No Data"),
          );
        }
      },
    );
  }

  Widget _generateFavoriteBody() {
    return TabBarView(
        children: <Widget>[_favBody("Desert"), _favBody("Seafood")]);
  }

  Widget _showImage(String path) {
    return Expanded(
      flex: 2,
      child: Hero(
        tag: path,
        child: CachedNetworkImage(
          imageUrl: path,
          placeholder: (c, s) => Shimmer.fromColors(
              child: Container(
                  width: double.infinity, height: 100, color: Colors.white),
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100]),
        ),
      ),
    );
  }

  Widget _showName(String name) {
    return Expanded(
        flex: 1,
        child: Padding(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));
  }

  loadData() async {
    try {
      var api = Api();
      var link;
      if (_index == 0) {
        link = Endpoint.link + "filter.php?c=Desert";
      } else if (_index == 1) {
        link = Endpoint.link + "filter.php?c=Seafood";
      }
      api.getData(link).then((response) {
        if (response.statusCode == 200) {
          var responseJson = jsonDecode(response.body);
          if (_index == 0) {
            setState(() {
              _desert = (responseJson['meals'] as List)
                  .map((p) => Foods.fromJson(p))
                  .toList();
            });
          } else {
            setState(() {
              _seafood = (responseJson['meals'] as List)
                  .map((p) => Foods.fromJson(p))
                  .toList();
            });
          }
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

  searchData() async {
    try {
      var api = Api();
      api
          .getData(Endpoint.link + "search.php?s=" + _controller.text)
          .then((response) {
        var responseJson = json.decode(response.body);
        if (response.statusCode == 200) {
          if (_index == 0) {
            setState(() {
              _search = (responseJson['meals'] as List)
                  .map((p) => Foods.fromJson(p))
                  .toList();
              _search.removeWhere((food) => food.category != "Desert");
            });
          } else {
            setState(() {
              _search = (responseJson['meals'] as List)
                  .map((p) => Foods.fromJson(p))
                  .toList();
              _search.removeWhere((food) => food.category != "Seafood");
              _isSearching = false;
            });
          }
        } else {
          throw Exception("Failed to load data");
        }
      });
    } catch (e) {
      if (e is NoSuchMethodError) {
        final SnackBar sn = SnackBar(
          content: Text("Can't find that food,please check the name again"),
          backgroundColor: Colors.red,
        );
        _scaffoldKey.currentState.showSnackBar(sn);
      }
      final SnackBar sn = SnackBar(
        content: Text("Failed to load data"),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => searchData(),
          textColor: Colors.white,
        ),
      );
      _scaffoldKey.currentState.showSnackBar(sn);
    }
  }
}
