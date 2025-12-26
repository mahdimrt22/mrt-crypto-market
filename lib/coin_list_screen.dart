import 'package:crypto_market/data/constants/color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:crypto_market/data/model/crypto.dart';

// ignore: must_be_immutable
class CoinListScreen extends StatefulWidget {
  CoinListScreen({super.key, this.cryptoList});
  List<Crypto>? cryptoList;

  @override
  State<CoinListScreen> createState() =>
      _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptoList;
  bool isSearchLoadingVisible = false;

  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MRT Crypto Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: BlueApp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                top: 8,
                right: 28,
                bottom: 8,
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  onChanged: (value) {
                    filterList(value);
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search coin',
                    hintStyle: TextStyle(
                      color: Colors.lightBlue[100],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      borderSide: BorderSide(
                        width: 0,

                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true,
                    fillColor: BlueApp,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isSearchLoadingVisible,
              child: Text(
                'Updating List ...',
                style: TextStyle(
                  color: BlueApp,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: BlueApp,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: cryptoList!.length,
                  itemBuilder: (context, index) {
                    return _getListTitleItem(
                      cryptoList![index],
                    );
                  },
                ),
                onRefresh: () async {
                  List<Crypto> freshData = await getData();
                  setState(() {
                    cryptoList = freshData;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListTitleItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(crypto.symbol),
      leading: SizedBox(
        width: 30,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                crypto.rank.toString(),
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      trailing: SizedBox(
        width: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(
                        2,
                      ) +
                      ' %',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getColorChangeText(
                      crypto.changePercent24Hr,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 50,
              child: _geticonChangePercent(
                crypto.changePercent24Hr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _geticonChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(
            Icons.trending_down_rounded,
            size: 30,
            color: Colors.pink[400],
          )
        : Icon(
            Icons.trending_up_rounded,
            size: 30,
            color: Colors.teal[600],
          );
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? PinkColor : GreenColor;
  }

  Future<List<Crypto>> getData() async {
    var response = await Dio().get(
      'https://rest.coincap.io/v3/assets?apiKey=506168f014336b45472a4e884829bd9c27f6bab2c14e45005395965257c5de9f',
    );
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>(
          (jsonMapObject) =>
              Crypto.fromMapJson(jsonMapObject),
        )
        .toList();
    return cryptoList;
  }

  Future<void> filterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchLoadingVisible = true;
      });
      var result = await getData();
      setState(() {
        cryptoList = result;
        isSearchLoadingVisible = false;
      });
      return;
    }
    cryptoResultList = cryptoList!.where((element) {
      return element.name.toLowerCase().contains(
        enteredKeyword.toLowerCase(),
      );
    }).toList();
    setState(() {
      cryptoList = cryptoResultList;
    });
  }
}
