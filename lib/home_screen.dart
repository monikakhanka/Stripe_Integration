import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //to capture the details of payment intent
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe payment'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            payment();
          },
          child: Text('Buy now'),
        ),
      ),
    );
  }

  //Payment intent
  Future<void> payment() async {


    try {
      Map<String, dynamic> body = {
        'amount': '10000', //100
        'currency': "INR",
        'description': "test stripe",
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ',
          'Content-type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      paymentIntent = json.decode(response.body);
    } catch (e) {
      throw Exception(e);
    }
    //
    var billingDetails = BillingDetails(
      email: 'email@stripe.com',
      phone: '+918767676787',
      name: 'Test',
      address: Address(
        city: 'Roorkee',
        country: 'India',
        line1: '1459  Circle Drive',
        line2: 'abc',
        state: 'Uttarakhand',
        postalCode: '247667',
      ),
    );

    //initialise payment sheet
    await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntent!['client_secret'],
      style: ThemeMode.light,
      merchantDisplayName: 'Monika',
      billingDetails: billingDetails
    )).then((value)=> {}) ;

    //Display payment sheet
    try{
      await Stripe.instance.presentPaymentSheet().then((value) {
        paymentIntent = null;
      });

    }catch(e){
      print(e.toString());
    }
  }
}
