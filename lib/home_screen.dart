import 'package:crypto_market/data/constants/color.dart';
import 'package:crypto_market/data/model/crypto.dart';
import 'package:crypto_market/coin_list_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhiteApp,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              Text(
                'MRT Crypto Market',
                style: TextStyle(
                  color: BlueApp,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              Container(
                width: 200,
                height: 200,
                child: Image(
                  image: AssetImage('images/1.png'),
                ),
              ),
              SpinKitPulsingGrid(
                color: BlueApp,
                size: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getData() async {
    var response = await Dio().get(
      'https://rest.coincap.io/v3/assets?apiKey=506168f014336b45472a4e884829bd9c27f6bab2c14e45005395965257c5de9f',
    );
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>(
          (jsonMapObject) =>
              Crypto.fromMapJson(jsonMapObject),
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CoinListScreen(cryptoList: cryptoList),
      ),
    );
  }
}
