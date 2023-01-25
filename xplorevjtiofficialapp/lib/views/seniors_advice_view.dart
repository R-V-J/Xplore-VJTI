import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:xplorevjtiofficialapp/constants/routes.dart';
import 'package:xplorevjtiofficialapp/database/seniorsAdviceDatabase/MongoDBSeniorAdvicesModel.dart';
import 'package:xplorevjtiofficialapp/database/seniorsAdviceDatabase/mongodb.dart';
import 'package:xplorevjtiofficialapp/database/userDatabase/MongoDBUserModel.dart';
import 'package:xplorevjtiofficialapp/utilites/show_error_dialog.dart';

class SeniorAdviceView extends StatefulWidget {
  const SeniorAdviceView({super.key});

  @override
  State<SeniorAdviceView> createState() => _SeniorAdviceViewState();
}

class _SeniorAdviceViewState extends State<SeniorAdviceView> {
  late final TextEditingController messageController;

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as dynamic;

    log(data.toString());

    return Scaffold(
      backgroundColor: Colors.deepOrange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[50],
        elevation: 0,
        //actions: <Widget>[
        leading: IconButton(
            onPressed: () {
              //pushnamed to header view
            },
            tooltip: 'header',
            icon: const Icon(
              Icons.menu_sharp,
              color: Colors.black,
            )),
        title: const Text(
          'VJTI',
          style: TextStyle(
            fontFamily: 'Vollkorn',
            fontSize: 50,
            letterSpacing: 7,
            color: Color.fromARGB(255, 124, 5, 5),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Seniors Advice',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 124, 5, 5),
                )),
            const SizedBox(height: 0),
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: FutureBuilder(
                future: MongoSeniorAdviceDatabase.getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      var totalData =
                          snapshot.data!.length; //getting total length of data

                      print('Total Data' + totalData.toString());

                      // return Text('Data Found');
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(85, 219, 112, 112),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return displayCard(
                                        MongoDbSeniorAdviceModel.fromJson(
                                            snapshot.data![index]));
                                  }),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text("No data Available"),
                      );
                    }
                  }
                },
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          child: Row(
            children: [
              TextFormField(
                controller: messageController,
                enableSuggestions: true,
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Message',
                ),
              ),
              IconButton(
                  onPressed: () async {
                    final result =
                        await insertMessage(data, messageController.text);
                    if (result == 'Success') {
                      setState(() {
                        Navigator.of(context).pushNamed(seniorAdviceRoute);
                      });
                    } else {
                      showErrorDiaglog(context, result);
                    }
                  },
                  icon: Icon(Icons.send))
            ],
          ),
        ),
      ),
    );
  }

  Widget displayCard(MongoDbSeniorAdviceModel data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Card(
        color: Color.fromARGB(222, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                    children: [
                      TextSpan(
                        text: "${data.name}",
                        style: TextStyle(letterSpacing: 1),
                      ),
                      TextSpan(
                        text: "${data.year}",
                        style: TextStyle(letterSpacing: 1),
                      ),
                      TextSpan(
                          text: '${data.time}',
                          style: TextStyle(letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
            RichText(
                text: TextSpan(
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        letterSpacing: 2),
                    children: [
                  TextSpan(
                    text: "${data.message}",
                    style: TextStyle(letterSpacing: 1),
                  )
                ]))
          ]),
        ),
      ),
    );
  }
}

Future<String> insertMessage(dynamic userdata, String message) async {
  String time = DateTime.now().toString();
  var id = M.ObjectId();

  final data = MongoDbSeniorAdviceModel(
      id: id,
      name: userdata['name'],
      email: userdata['email'],
      year: year,
      time: time,
      status: status,
      message: message);

  var result = await MongoSeniorAdviceDatabase.insert(data);
  if (result == 'Something went wrong while inserting data') {
    return 'Something went wrong. Try again';
  } else {
    return 'Success';
  }
}
