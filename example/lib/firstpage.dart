import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payment_2/secondpage.dart';
import 'package:http/http.dart' as http;

class allcards extends StatefulWidget {
  const allcards({Key? key}) : super(key: key);

  @override
  _allcardsState createState() => _allcardsState();
}

class _allcardsState extends State<allcards> {
  var loading = true;
  var data = [];
  Future<void> get_data() async {
    loading = true;
    setState(() {});
    String shopperReference = "YOUR_UNIQUE_SHOPPER_ID_IOfW3k9G2PvXFu2j56395Hei";
    String merchantAccount = "";
    String apiKey = '';
    var headers = {'X-API-key': apiKey, 'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('https://checkout-test.adyen.com/v68/paymentMethods'));
    request.body = json.encode({
      "merchantAccount": merchantAccount,
      "shopperReference": shopperReference
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var a = await response.stream.bytesToString();
      var data_t = json.decode(a);
      if (data_t.containsKey('storedPaymentMethods'))
        data = data_t['storedPaymentMethods'];
    } else {
      print(response.reasonPhrase);
    }

    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_data();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Container(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            // backgroundColor: Colors.white.withOpacity(0.5),
            onPressed: () {
              Get.to(ProvideCard());
              //Get.to(WebViewExample2());
            },
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: get_data,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : data.length == 0
                    ? Column(
                        children: [
                          Center(child: Text("No Card Found pull to refresh")),
                          SizedBox(
                            height: size.height,
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "My Cards",
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          ListView.separated(
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 15,
                              );
                            },
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(left: 20),
                                height: size.height * 0.2,
                                margin: EdgeInsets.only(right: 15, left: 15),
                                decoration:
                                    BoxDecoration(border: Border.all(width: 1)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Your Card",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "xxxx xxxx xxxx ${data[index]['lastFour']}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "${data[index]['expiryMonth']}/${data[index]['expiryYear']}",
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
