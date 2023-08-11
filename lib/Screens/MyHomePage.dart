import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  // ignore: override_on_non_overriding_member
  final TextEditingController _controller1 = TextEditingController();
  final key = GlobalKey<FormState>();
  List<String> theFinalList = [];

  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    _fechpref();
  }

  _savepref(String newString) async {
    final pref = await SharedPreferences.getInstance();
    theFinalList.add(newString);
    pref.setStringList("theFinalList", theFinalList);
  }

  _fechpref() async {
    final pref = await SharedPreferences.getInstance();
    setState(
      () {
        theFinalList = pref.getStringList("theFinalList") ?? [];
      },
    );
  }

  _removepref(int index) async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      theFinalList.removeAt(index);
      pref.setStringList("theFinalList", theFinalList);
      _fechpref();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.withOpacity(.9), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            Icons.playlist_add_check,
            size: 50,
          ),
          title: Text(
            "ToDo",
            style: TextStyle(fontSize: 30),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: TheBody(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ThrFloating(context),
      ),
    );
  }

  Container TheBody(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 40,
        ),
        child: AllScreen(),
      ),
    );
  }

  Container AllScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.withOpacity(.9), Colors.white],
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: TheUI(),
    );
  }

  ListView TheUI() {
    return ListView.builder(
      itemCount: theFinalList.length,
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Dismissible(
            onDismissed: (direction) {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Delete ${theFinalList[index]}???",
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.white),
                          ),
                          onPressed: () async {
                            _fechpref();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.white),
                          ),
                          onPressed: () async {
                            if (theFinalList.isEmpty) {
                              Navigator.pop(context);
                            } else {
                              await _removepref(index);
                              _fechpref();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            key: UniqueKey(),
            child: ListTile(
              title: Text(
                theFinalList[index],
                style: TextStyle(fontSize: 20),
              ),
            ),
            background: Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Icon(
                Icons.delete,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  FloatingActionButton ThrFloating(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.teal,
      elevation: 0,
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Form(
                    key: key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _controller1,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return "empty is not right";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Add Your Note",
                              label: Text("Add Your Note "),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (key.currentState!.validate()) {
                              _trigNoti(_controller1.text);

                              await _savepref(_controller1.text);
                              _fechpref();
                              _controller1.clear();
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(
                            Icons.playlist_add_check_circle,
                          ),
                          iconSize: 46,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Icon(
        Icons.add,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}

void _trigNoti(String _controller) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: "channelKey",
      title: "$_controller",
      // bigPicture: "assets/ic_launcher.png",
    ),
  );
}
