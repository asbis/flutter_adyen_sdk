import 'dart:async';
import 'dart:convert';
import 'package:adyen_flutter/adyen_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;

//import 'creditcard/credit_card_form.dart';
//import 'creditcard/credit_card_model.dart';
//import 'creditcard/credit_card_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProvideCard extends StatefulWidget {
  const ProvideCard({Key? key}) : super(key: key);

  @override
  _ProvideCardState createState() => _ProvideCardState();
}

class _ProvideCardState extends State<ProvideCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String merchantAccount = '';
  String shopperReference = "YOUR_UNIQUE_SHOPPER_ID_IOfW3k9G2PvXFu2j56395Hei";
  String apiKey = '';
  String token = '';
  String securityCode = '';
  String month = '';
  String year = '';
  String encryptedResult = '';
  var f_key = GlobalKey<FormState>();

  String _returnURL = "";

  void _showModelSheet(String redirectUrl) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: WebView(
              initialUrl: redirectUrl,
              javascriptMode: JavascriptMode.unrestricted,
              debuggingEnabled: true,
              onWebViewCreated: (WebViewController webViewController) {},
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith(
                    "https://checkoutshopper-test.adyen.com/checkoutshopper/threeDS/return/payment_2:")) {
                  _returnURL = request.url;
                  Navigator.of(context).pop();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      print('Hey there, I\'m calling after hide bottomSheet');
    });
    ;
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (CreditCardBrand) {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      onCreditCardModelChange:
                          (CreditCardModel creditCardModel) {
                        setState(() {
                          cardNumber = creditCardModel.cardNumber;
                          expiryDate = creditCardModel.expiryDate;
                          cardHolderName = creditCardModel.cardHolderName;
                          cvvCode = creditCardModel.cvvCode;
                          var exp = creditCardModel.expiryDate.split("/");
                          if (exp.length == 2) {
                            month = exp[0];
                            year = exp[1];
                          }
                          isCvvFocused = creditCardModel.isCvvFocused;
                        });
                      },
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      formKey: f_key,
                      themeColor: Colors.white,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      children: const [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                    ),
                                  );
                                },
                              );
                              var encryptedCard =
                                  await AdyenFlutter.encryptedCard(
                                      publicKeyToken: token,
                                      environment: Environment.TEST,
                                      card: CreditCard(
                                        number: cardNumber,
                                        securityCode: cvvCode,
                                        expiryMonth: month,
                                        expiryYear: "20" + year,
                                      ),
                                      generationDate: DateTime.now());
                              setState(() {
                                encryptedResult = '''
                            encryptedNumber:${encryptedCard.number}\r\n
                            encryptedCode:${encryptedCard.securityCode}\r\n
                            encryptedMonth:${encryptedCard.expiryMonth}\r\n
                            encryptedYear:${encryptedCard.expiryYear}\r\n
                            ''';
                              });
                              var headers = {
                                'X-API-key': "${apiKey}",
                                'Content-Type': 'application/json'
                              };
                              var request = http.Request(
                                  'POST',
                                  Uri.parse(
                                      'https://checkout-test.adyen.com/v68/payments'));
                              request.body = json.encode({
                                "amount": {"currency": "USD", "value": 0},
                                "reference": "YOUR_ORDER_NUMBER1",
                                "paymentMethod": {
                                  "type": "scheme",
                                  "encryptedCardNumber":
                                      "${encryptedCard.number}",
                                  "encryptedExpiryMonth":
                                      "${encryptedCard.expiryMonth}",
                                  "encryptedExpiryYear":
                                      "${encryptedCard.expiryYear}",
                                  "encryptedSecurityCode":
                                      "${encryptedCard.securityCode}"
                                },
                                "billingAddress": {
                                  "street": "Infinite Loop",
                                  "houseNumberOrName": "1",
                                  "postalCode": "1011DJ",
                                  "city": "Amsterdam",
                                  "country": "NL"
                                },
                                "browserInfo": {
                                  "userAgent":
                                      "Safari/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A5370a Safari/604.1",
                                  "acceptHeader":
                                      "text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8"
                                },
                                "additionalData": {"allow3DS2": false},
                                "returnUrl": "payment_2:",
                                "merchantAccount": merchantAccount,
                                "storePaymentMethod": true,
                                "shopperInteraction": "Ecommerce",
                                "recurringProcessingModel": "CardOnFile",
                                "shopperReference": shopperReference
                              });
                              request.headers.addAll(headers);

                              http.StreamedResponse response =
                                  await request.send();
                              Navigator.of(context).pop();
                              if (response.statusCode == 200) {
                                var a = await response.stream.bytesToString();
                                var data = json.decode(a);
                                var keys = data.keys.toList();
                                print("keys ${keys}");
                                for (int i = 0; i < keys.length; i++) {
                                  print("data ${i} ${data[keys[i]]}");
                                }
                                if (data['resultCode'] == "Authorised") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Card Added")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("${data['resultCode']}")));
                                }
                              } else {
                                print(
                                    "reason error ${response.reasonPhrase} ${await response.stream.bytesToString()}");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Something went wrong")));
                              }
                            },
                            child: const Text("Add My Card")),
                        ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      children: const [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                    ),
                                  );
                                },
                              );
                              // print("card ${cardNumber} ${cardHolderName} ${cvvCode} -${year} ${month}");
                              var encryptedCard =
                                  await AdyenFlutter.encryptedCard(
                                      publicKeyToken: token,
                                      environment: Environment.TEST,
                                      card: CreditCard(
                                        number: cardNumber,
                                        securityCode: securityCode,
                                        expiryMonth: month,
                                        expiryYear: year,
                                      ),
                                      generationDate: DateTime.now());
                              setState(() {
                                encryptedResult = '''
                            encryptedNumber:${encryptedCard.number}\r\n
                            encryptedCode:${encryptedCard.securityCode}\r\n
                            encryptedMonth:${encryptedCard.expiryMonth}\r\n
                            encryptedYear:${encryptedCard.expiryYear}\r\n
                            ''';
                                print(
                                    "card ${encryptedCard.number} \n - ${encryptedCard.securityCode} \n - ${encryptedCard.expiryMonth} ${encryptedCard.expiryYear} - ");
                              });
                              var headers = {
                                'X-API-key': "${apiKey}",
                                'Content-Type': 'application/json'
                              };
                              var request = http.Request(
                                  'POST',
                                  Uri.parse(
                                      'https://checkout-test.adyen.com/v68/payments'));
                              request.body = json.encode({
                                "amount": {"currency": "USD", "value": 100},
                                "reference": "YOUR_ORDER_NUMBER" +
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                "paymentMethod": {
                                  "type": "scheme",
                                  "encryptedCardNumber":
                                      "${encryptedCard.number}",
                                  "encryptedExpiryMonth":
                                      "${encryptedCard.expiryMonth}",
                                  "encryptedExpiryYear":
                                      "${encryptedCard.expiryYear}",
                                  "encryptedSecurityCode":
                                      "${encryptedCard.securityCode}",
                                  "holderName": "S. Hopper"
                                },
                                "billingAddress": {
                                  "street": "Infinite Loop",
                                  "houseNumberOrName": "1",
                                  "postalCode": "1011DJ",
                                  "city": "Amsterdam",
                                  "country": "NL"
                                },
                                "browserInfo": {
                                  "userAgent":
                                      "Safari/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A5370a Safari/604.1",
                                  "acceptHeader":
                                      "text\/html,application\/xhtml+xml,application\/xml;q=0.9,image\/webp,image\/apng,*\/*;q=0.8"
                                },
                                "additionalData": {"allow3DS2": true},
                                "returnUrl": "payment_2:",
                                "merchantAccount": merchantAccount,
                                "shopperReference": shopperReference
                              });
                              request.headers.addAll(headers);

                              http.StreamedResponse response =
                                  await request.send();

                              if (response.statusCode == 200) {
                                // print(await response.stream.bytesToString());
                                var a = await response.stream.bytesToString();
                                var data = json.decode(a);
                                if (data['resultCode'] == "Authorised") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Paid")));
                                } else if (data['resultCode'] ==
                                    "RedirectShopper") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Redirect")));
                                  _showModelSheet(data['action']['url']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("${data['resultCode']}")));
                                }
                              } else {
                                print(
                                    "reason error ${response.reasonPhrase} ${await response.stream.bytesToString()}");
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Something went wrong")));
                              }

                              // print("eync res ${encryptedResult}");
                            },
                            child: Text("Pay 1 Doller")),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
