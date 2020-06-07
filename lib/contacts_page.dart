import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smshomesafe/add_contact_dialog.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({Key key}) : super(key: key);

  @override
  _ContactsPageState createState() {
    return _ContactsPageState();
  }
}

class _ContactsPageState extends State<ContactsPage> {
  SharedPreferences prefs;
  List<String> contacts = [];
  Map<String, String> contactMap = {};

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      contacts = prefs.getStringList("smsHomeSafeContactsList") ?? [];
      for (String contact in contacts) {
        String number = prefs.getString(contact) ?? "";
        contactMap[contact] = number;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contactWidgets = [];
    for (String key in contactMap.keys) {
      contactWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(key),
                  ),
                ),
              ),
              Material(
                child: FlatButton(
                  child: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      contacts.remove(key);
                      contactMap.remove(key);
                      prefs.remove(key);
                      prefs.setStringList("smsHomeSafeContactsList", contacts);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Home Safe"),
      ),
      body: ListView(
        children: [
          contacts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text("No Contacts Added!")),
                )
              : Column(
                  children: contactWidgets,
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.greenAccent,
              child: MaterialButton(
                child: Text(
                  "Import Contact",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                ),
                onPressed: () async {
                  final PhoneContact deviceContact = await FlutterContactPicker.pickPhoneContact();
                  setState(() {
                    contacts.add(deviceContact.fullName);
                    contactMap[deviceContact.fullName] = deviceContact.phoneNumber.number;
                    prefs.setString(deviceContact.fullName, deviceContact.phoneNumber.number);
                    prefs.setStringList("smsHomeSafeContactsList", contacts);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.greenAccent,
              child: MaterialButton(
                child: Text(
                  "Add New Contact",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AddContactDialog();
                      }).then((value) {
                    if (value != null) {
                      setState(() {
                        // print("NAME: " + value[0] + " NUMBER: " + value[1]);
                        contacts.add(value[0]);
                        contactMap[value[0]] = value[1];
                        prefs.setString(value[0], value[1]);
                        prefs.setStringList("smsHomeSafeContactsList", contacts);
                      });
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
