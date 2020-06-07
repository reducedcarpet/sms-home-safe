import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';

class SMSPage extends StatefulWidget {
  SMSPage({Key key}) : super(key: key);

  @override
  _SMSPageState createState() => _SMSPageState();
}

class _SMSPageState extends State<SMSPage> {
  SharedPreferences prefs;
  List<String> numbers = [];

  TextEditingController safeController = TextEditingController();
  TextEditingController notSafeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  void dispose() {
    safeController.dispose();
    notSafeController.dispose();
    super.dispose();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      safeController.text = prefs.getString("safeString") == "" ? "Home Safe!" : prefs.getString("safeString") ?? "Home Safe!";
      notSafeController.text = prefs.getString("notSafeString") == "" ? "Not Safe!" : prefs.getString("notSafeString") ?? "Not Safe!";
    });

    safeController.addListener(_saveSafeMessage);
    notSafeController.addListener(_saveNotSafeMessage);

    List<String> contacts = prefs.getStringList("smsHomeSafeContactsList") ?? [];
    for (String contact in contacts) {
      String number = prefs.getString(contact) ?? "";
      numbers.add(number);
    }
    print("NUMBERS: " + numbers.toString());
  }

  _saveSafeMessage() {
    prefs.setString("safeString", safeController.text);
  }

  _saveNotSafeMessage() {
    prefs.setString("notSafeString", notSafeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Home Safe"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.greenAccent,
                child: MaterialButton(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Text(
                      "HOME SAFE",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.5),
                    ),
                  ),
                  onPressed: () {
                    _send(numbers, safeController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 46),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.red[700],
                child: MaterialButton(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Text(
                      "NOT SAFE!",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.5),
                    ),
                  ),
                  onPressed: () {
                    _send(numbers, notSafeController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 46),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: safeController,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Home Safe Message",
                  labelStyle: TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: notSafeController,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Not Safe Message",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  "The message sent when you press the 'NOT SAFE!' button. \n\nYou might consider putting in some information ahead of time, if you know it: Where you expect to be taken, any special things you want the people on your list to do in the event of a bad situation. \n\nMessages are sent via SMS to each number on this apps contact list in order. Both messages are stored in the apps local data area. It is not particularly secure if someone has your phone."),
            ),
          ],
        ),
      ),
    );
  }

  void _send(List<String> people, String message) {
    SmsSender sender = new SmsSender();
    for (String address in people) {
      sender.sendSms(new SmsMessage(address, message));
    }
  }
}
