import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart' show Client, Transactions;
import 'package:flutter_sms/flutter_sms.dart';


//database
Client clientTable = Client();
Transactions transactionTable = Transactions();

int year = DateTime.now().year;
int month = DateTime.now().month;
DateTime checkDate = DateTime.now().day > 5? DateTime(year, month + 1, 1):DateTime(year, month, 1);


void showToast(String _msg) => Fluttertoast.showToast(
    msg: _msg,
    // timeInSecForIosWeb: 5,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 2
);

Future<int> sendMessage(List<Map> transactions, String name, String phone, int msgType) async {
  /// msgType == 1 => "sendLongMessage"
  /// msgType == 2 => "sendMediumMessage"
  /// msgType == 3 => "sendShortMessage"
  /// else auto message

  double total = 0;
  List<int> required = [];

  List<Map> includedTrans = [];

  for (int i = 0; i < transactions.length; i++) {
    Map trn = transactions[i];
    int stYear = trn["year"];
    int stMonth = trn["month"];
    int paidMonths = trn["paidmonths"];
    if (stYear < checkDate.year || (stYear == checkDate.year && stMonth <= checkDate.month)) {
      if (trn["paidmonths"] < trn["plan"]) {
        int checkPaid = (checkDate.year - stYear)*12 + (checkDate.month - stMonth) + 1;
        checkPaid = checkPaid > trn["plan"]? trn["plan"] : checkPaid;
        if (checkPaid - paidMonths != 0) {
          required.add(checkPaid - paidMonths);
          includedTrans.add(trn);
          total += ((trn["price"] - trn["deposit"]) / trn["plan"]) * (checkPaid - paidMonths);
        }
      }
    }
  }


  if (msgType == 1) {
    sendLongMessage(includedTrans, required, total, name, phone);
  } else if (msgType == 2) {
    sendMediumMessage(includedTrans, required, total, name, phone);
  } else if (msgType == 3) {
    sendShortMessage(total, required.length, name, phone);
  } else {  /// auto
    if (required.length < 4) {
      sendLongMessage(includedTrans, required, total, name, phone);
    } else if (required.length < 9) {
      sendMediumMessage(includedTrans, required, total, name, phone);
    } else {
      sendShortMessage(total, required.length, name, phone);
    }
  }

  return 1;
}


void sendLongMessage(List<Map> includedTrans, List<int> required, double total, String name, String phone) async {

  String _msg = "Hi $name!"
      "\nStatement Date: ${checkDate.month}-${checkDate.year}"
      "\nTotal amount: ${total.toStringAsFixed(1)} EGP"
      "\nRunning unpaid trans.: ${required.length}";

  if (includedTrans.length == 1) {
    String unpaidLine = required[0] == 1? "" : "\nUnpaid months: ${required[0]}";
    _msg += "$unpaidLine\nPaid months: ${includedTrans[0]["paidmonths"]} / ${includedTrans[0]["plan"]}";
  }

  else {
    for (int i = 0; i < includedTrans.length; i++) {
      double requiredAmount = ((includedTrans[i]["price"] - includedTrans[i]["deposit"]) / includedTrans[i]["plan"]) * required[i];
      String unpaidLine = required[i] == 1? "" : "\nUnpaid months: ${required[i]}";
      _msg += "\n\n>>>Transaction ${i + 1}"
          "\nRequired amount: ${requiredAmount.toStringAsFixed(1)} EGP"
          "$unpaidLine"
          "\nPaid months: ${includedTrans[i]["paidmonths"]} / ${includedTrans[i]["plan"]}";
    }
  }

  await sendSMS(message: _msg, recipients: [phone], sendDirect: true)
      .catchError((onError) { showToast("Error while sending SMS"); });
}

void sendMediumMessage(List<Map> includedTrans, List<int> required, double total, String name, String phone) async {

  String _msg = "Hi $name!"
      "\nStatement Date: ${checkDate.month}-${checkDate.year}"
      "\nTotal amount: ${total.toStringAsFixed(1)} EGP"
      "\nRunning unpaid trans.: ${required.length}";

  if (includedTrans.length == 1) {
    String unpaidLine = required[0] < 2? "" : "\nUnpaid months: ${required[0]}";
    _msg += "$unpaidLine\nPaid months: ${includedTrans[0]["paidmonths"]} / ${includedTrans[0]["plan"]}";
  }

  else {
    for (int i = 0; i < includedTrans.length; i++) {
      double requiredAmount = ((includedTrans[i]["price"] - includedTrans[i]["deposit"]) / includedTrans[i]["plan"]) * required[i];
      String unpaidLine = required[i] < 2? "" : "  #${required[i]}";
      _msg += "\n\n>>Trans ${i + 1}: ${requiredAmount.toStringAsFixed(1)} EGP$unpaidLine";
    }
  }


  await sendSMS(message: _msg, recipients: [phone], sendDirect: true)
      .catchError((onError) { showToast("Error while sending SMS"); });
}

void sendShortMessage(double total, int runningUnpaid, String name, String phone) async {

  String _msg = "Hi $name!"
      "\nStatement Date: ${checkDate.month}-${checkDate.year}"
      "\nTotal amount: ${total.toStringAsFixed(1)} EGP"
      "\nRunning unpaid trans.: $runningUnpaid";


  await sendSMS(message: _msg, recipients: [phone], sendDirect: true)
      .catchError((onError) { showToast("Error while sending SMS"); });
}



Widget avatar(double r, String path) {
  if (path == "null") {
    return Container(
      padding: EdgeInsets.all(r/20),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(r * 21 / 20),
      ),
      child: CircleAvatar(
        radius: r,
        child: Icon(Icons.person, size: r * 3 / 2, color: Colors.white),
        backgroundColor: Colors.grey[500],
      ),
    );
  } else {
    return Container(
      padding: EdgeInsets.all(r/20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r * 21 / 20),
      ),
      child: CircleAvatar(
        radius: r,
        backgroundImage: FileImage(File(path)),
      ),
    );
  }
}

bool phoneCheck(String _phone) {
  //phone number check
  int lenPhone = _phone.length;
  if (!(lenPhone == 11 || lenPhone == 13)) {
    showToast("Invalid Number entered");
    return false;
  }

  if (lenPhone == 13) {
    if (_phone.substring(0, 4) != "+201") {
      showToast("Invalid Number entered");
      return false;
    }

    if (!(_phone[4] == "0" || _phone[4] == "1" || _phone[4] == "2" || _phone[4] == "5")) {
      showToast("Invalid Number entered");
      return false;
    }
    if (double.tryParse(_phone.substring(5, 13)) == null) {
      showToast("Invalid Number entered");
      return false;
    }
  }

  if (lenPhone == 11) {
    if (_phone.substring(0, 2) != "01") {
      showToast("Invalid data entered");
      return false;
    }
    if (!(_phone[2] == "0" || _phone[2] == "1" || _phone[2] == "2" || _phone[2] == "5")) {
      showToast("Invalid Number entered");
      return false;
    }
    if (double.tryParse(_phone.substring(3, 11)) == null) {
      showToast("Invalid Number entered");
      return false;
    }
  }
  return true;
}

void loading(String title, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },

        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              title,
              style: GoogleFonts.bebasNeue(
                fontSize: 26
              ),
            )
          ),
          content: const LinearProgressIndicator(
            color: Colors.purple,
            backgroundColor: Colors.black,
            minHeight: 8,
          ),
        ),
      )
  );
}

