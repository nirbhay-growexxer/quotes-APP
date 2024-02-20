import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:basic_app_2/quotes.dart';

void main() {
  runApp(const MainAppScreen());
}

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.oswald(fontSize: 30, color: Colors.white),
        ),
      ),
      home: const Wisdom(),
    );
  }
}

class Wisdom extends StatefulWidget {
  const Wisdom({super.key});
  @override
  WisdomState createState() => WisdomState();
}

class WisdomState extends State<Wisdom> {
  int status = 0;
  String? error;
  List quotes = [
    '“Small is not just a stepping-stone. Small is a great destination itself.” ―Jason Fried',
    '“He that can have patience can have what he will.” ―Benjamin Franklin',
    '“The only one who can tell you “you can\'t win” is you and you don\'t have to listen.” —Jessica Ennis',
    '“Set your goals high, and don\'t stop till you get there.” —Bo Jackson',
    '“Life is like riding a bicycle. To keep your balance you must keep moving.” —Albert Einstein',
    '“What you do speaks so loudly that I cannot hear what you say.” —Ralph Waldo Emerson',
    '“I have never let my schooling interfere with my education.” —Mark Twain',
    '“If you can\'t yet do great things, do small things in a great way.” ―Napoleon Hill'
  ];
  late List<Quotes>? quotesFromAPI = [];

  @override
  void initState() {
    super.initState();
    getQuotes('https://api.quotable.io/quotes/random');
  }

  void getQuotes(String url) {
    setState(() {
      status = 0;
      quotesFromAPI = [];
    });
    Network network = Network(url);
    var data = network.fetchData();
    if (data == null) {
      setState(() {
        status = 2;
        error = 'API limit reached, try after 2-3 minutes';
      });
    } else {
      data.then((value) => {
            setState(
              () {
                quotesFromAPI = quotesFromJson(value);
                status = 1;
              },
            )
          });
    }
    debugPrint('new quote');
    // quotesFromAPI = quotesFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'Quotes App',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: 350,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.all(5.0),
                  child: switch (status) {
                    0 => Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                    1 => Column(children: [
                        Text(quotesFromAPI![0].content),
                        Text("- ${quotesFromAPI![0].author}")
                      ]),
                    2 => Center(
                        child: Text("$error"),
                      ),
                    _ => null,
                  }),
              ElevatedButton(
                  onPressed: _showQuote, child: const Text('click me')),
              Container(
                child: const Text(
                    "These quotes are from - https://github.com/lukePeavey/quotable?#readme"),
              ),
            ],
          ),
        ));
  }

  void _showQuote() {
    getQuotes('https://api.quotable.io/quotes/random');
  }
}

class Network {
  final String url;

  Network(this.url);

  Future? fetchData() async {
    Uri uri = Uri.parse(Uri.encodeFull(url));
    Response response = await get(uri);

    if (response.statusCode == 200) {
      return response.body;
    }
    if (response.statusCode == 429) {
      return null;
    }
  }
}
