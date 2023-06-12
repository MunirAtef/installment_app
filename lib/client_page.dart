
import 'dart:io' show Directory, File;
import 'package:flutter/material.dart';
import 'add_transaction.dart' show AddTransaction;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'custom_paid.dart';
import 'shared.dart' show avatar, checkDate, clientTable, phoneCheck, sendMessage, showToast, transactionTable;



class ClientPage extends StatefulWidget {
  final Map basicInfo;

  const ClientPage(this.basicInfo, {Key? key}) : super(key: key);

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Map basicInfo;


  TextEditingController newName = TextEditingController();
  TextEditingController newPhone = TextEditingController();
  TextEditingController newComment = TextEditingController();
  TextEditingController newPaidMonths = TextEditingController();
  String newImage = "null";


  List<Map> transactions = [];
  List<Map> includedTransactions = [];


  int runningTrans = 0;
  int futureTrans = 0;
  int finishedTrans = 0;
  int totalTransactions = 0;

  double totalAmount = 0;


  Color summaryCol = Colors.purple;
  Color runningCol = Colors.green;
  Color futureCol = Colors.blue;
  Color finishedCol = Colors.red;

  Future<String> saveImage() async {
    String fullPath = "null";
    Directory tempPath = await getApplicationDocumentsDirectory();
    String _path = tempPath.path;

    String ext = newImage.split(".").last;
    String _name = "client-${DateTime.now().millisecondsSinceEpoch}.$ext";


    fullPath="$_path/$_name";
    await File(newImage).copy(fullPath);

    return fullPath;
  }

  Future<void> uploadImageCamera() async {
    final imagePicker = ImagePicker();
    var pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
    if (pickedImage != null) {
      setState(() {
        newImage = pickedImage.path;
      });
    }
  }

  Future<void> uploadImageGallery() async {
    final imagePicker = ImagePicker();
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);
    if (pickedImage != null) {
      setState(() {
        newImage = pickedImage.path;
      });
    }
  }

  Widget tableRow(String title, String value, bool isBlack) {
    return Row(
      children: [
        Expanded(
          child: Container(
            // width: columnWidth,
            padding: const EdgeInsets.all(10),
            color: isBlack? Colors.grey[400] : Colors.grey[300],
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
          child: Container(
            // width: columnWidth,
            padding: const EdgeInsets.all(10),
            color: isBlack? Colors.grey[300] : Colors.grey[200],
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget summaryBox(double totalAmount, int running, int future, int finished) {
    return Column(
      children: [
        Container(height: 2, width: double.infinity, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 30)),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 7)
              )
            ],
            color: Colors.white,
            border: Border.all(color: summaryCol, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              Text(
                "SUMMARY",
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: summaryCol
                ),
              ),

              const SizedBox(height: 20),

              tableRow("Date", "${checkDate.month}-${checkDate.year}", true),
              Divider(color: summaryCol, thickness: 2, height: 2),

              tableRow("Total amount", totalAmount.toStringAsFixed(1) + " EGP", false),
              Divider(color: summaryCol, thickness: 2, height: 2),

              tableRow("Running trans.", "$running", true),
              Divider(color: summaryCol, thickness: 2, height: 2),

              tableRow("Future trans." , "$future", false),
              Divider(color: summaryCol, thickness: 2, height: 2),

              tableRow("Finished trans.", "$finished", true),
              Divider(color: summaryCol, thickness: 2, height: 2),

              tableRow("Total trans.", "${running + finished + future}", false),
              Divider(color: summaryCol, thickness: 2, height: 2),
            ],
          ),
        ),
      ],
    );
  }


  Future<Widget> isPaid(double _width, List<int> monthsToPaid, List<int> transactionNum, List<int> transactionID) async {
    double amountToPaid = 0;
    for (int i = 0; i < monthsToPaid.length; i++) {
      if (monthsToPaid[i] != 0) {
        List<Map> trn = await transactionTable.readData("id=${transactionID[i]}");
        amountToPaid += ((trn[0]["price"] - trn[0]["deposit"]) / trn[0]["plan"]) * monthsToPaid[i];
      }
    }

    if (transactionNum.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        width: _width - 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: Colors.purple),
        ),
        child: Center(
          child: Text(
            "No running transactions",
            style: GoogleFonts.bebasNeue(
              fontSize: 25,
              color: Colors.purple
            )
          ),
        )
      );
    }

    if (amountToPaid == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        width: _width - 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: Colors.purple),
        ),
        child: Center(
          child: Text(
            "PAYMENT COMPLETED",
            style: GoogleFonts.bebasNeue(
              fontSize: 25,
              color: Colors.purple
            )
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomPaid(basicInfo, totalAmount)));
        },

        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.purple),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
          )),
        ),

        child: SizedBox(
            width: _width - 60,
            height: 50,
            child: Center(
                child: Text(
                  "SET PAYMENT",
                  style: GoogleFonts.bebasNeue(
                      fontSize: 25,
                      color: Colors.white
                  ),
                )
            )
        ),
      ),
    );
  }


  Future<Widget> summaryInfo(context, double _width) async {
    List<int> monthsToPaid = [];
    List<int> transactionNum = [];
    List<int> transactionId = [];
    List<Map> _includedTransactions = [];

    int _runningTrans = 0;
    int _futureTrans = 0;
    int _finishedTrans = 0;

    double _totalAmount = 0;

    transactions = await transactionTable.readData("client=${basicInfo["id"]}");
    totalTransactions = transactions.length;

    for (int i = 0; i < totalTransactions; i++) {
      Map trn = transactions[i];
      int stYear = trn["year"];
      int stMonth = trn["month"];
      int paidMonths = trn["paidmonths"];
      if (stYear < checkDate.year || (stYear == checkDate.year && stMonth <= checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          int checkPaid = (checkDate.year - stYear)*12 + (checkDate.month - stMonth) + 1;
          checkPaid = checkPaid > trn["plan"]? trn["plan"] : checkPaid;
          monthsToPaid.add(checkPaid - paidMonths);
          transactionNum.add(i+1);
          transactionId.add(trn["id"]);
          _totalAmount += ((trn["price"] - trn["deposit"]) / trn["plan"])*(checkPaid - paidMonths);
          _includedTransactions.add(trn);
          _runningTrans++;
        }
        else {
          _finishedTrans++;
        }
      }
      else {
        _includedTransactions.add(trn);
        _futureTrans++;
      }
    }

    runningTrans = _runningTrans;
    futureTrans = _futureTrans;
    finishedTrans = _finishedTrans;
    totalAmount = _totalAmount;
    includedTransactions = _includedTransactions;

    if (totalTransactions == 0) {
      return Column(
        children: [
          Container(height: 2, width: double.infinity, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 30)),

          Container(
            width: _width - 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 2, color: Colors.purple),
            ),
            child: Center(
                child: Text(
                  "Client has no Transactions",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 25,
                    color: Colors.purple
                  )
                ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        summaryBox(_totalAmount, _runningTrans, _futureTrans, _finishedTrans),


        FutureBuilder<Widget>(
          future: isPaid(_width, monthsToPaid, transactionNum, transactionId),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SingleChildScrollView(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            }

            return snapshot.data!;
          },
        ),

      ],
    );
  }


  Widget transactionBox(Map info, int num, int status)  {
    int plan = info["plan"];
    double price = info["price"];
    double deposit = info["deposit"];
    double pricePerMonth = (price - deposit) / plan;
    int paidLimit = 0;

    DateTime startDate = DateTime(info["year"], info["month"], 1);
    DateTime endDate = DateTime(info["year"], info["month"] + plan - 1, 1);

    if (status == 3) {
      paidLimit = plan;
    } else if (status == 1) {
      paidLimit = (checkDate.year - info["year"]).toInt() * 12 + (checkDate.month - info["month"]).toInt() + 1;
      if (paidLimit > plan) {
        paidLimit = plan;
      }
    }

    Color col = status == 1? runningCol: status == 2? futureCol: finishedCol;

    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),

      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 7)
          )
        ],
        color: Colors.white,
        border: Border.all(color: col, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Text(
            "TRANSACTION $num",
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: col
            ),
          ),

          const SizedBox(height: 20),

          tableRow("Total price", price.toStringAsFixed(1) + " EGP", true),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("Price/month", pricePerMonth.toStringAsFixed(1) + " EGP", false),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("Paid months", "${info["paidmonths"]}", true),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("Ins. plan", "$plan", false),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("Deposit", deposit.toStringAsFixed(1), true),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("Start date", "${startDate.month}-${startDate.year}", false),
          Divider(color: col, thickness: 2, height: 2),

          tableRow("End date", "${endDate.month}-${endDate.year}", true),
          Divider(color: col, thickness: 2, height: 2),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => SimpleDialog(
                      title: Center(
                        child: Text(
                          "SETTINGS",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 26
                          ),
                        )
                      ),
                      children: [
                        /// edit paid
                        (status == 1 || status == 3)?
                        ListTile(
                          leading: const Icon(Icons.paid, color: Colors.purple),
                          title: const Text(
                            "Edit paid months",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            newPaidMonths.text = "";
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Edit paid months"),
                                actions: [
                                  TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Cancel")),

                                  TextButton(
                                      onPressed: () async {
                                        if (double.tryParse(newPaidMonths.text) == null) {
                                          showToast("Invalid input");
                                          return;
                                        }
                                        int paid = double.parse(newPaidMonths.text).toInt();
                                        if (paid < 0) {
                                          showToast("Invalid input");
                                          return;
                                        }
                                        if (paid > paidLimit) {
                                          showToast("limit exceeded ($paidLimit months)");
                                          return;
                                        }
                                        await transactionTable.updateData("id = ${info["id"]}", "paidmonths = $paid");
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.pushNamed(context, "/mainPage");
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(basicInfo)));
                                        showToast("Paid months updated");
                                      },
                                      child: const Text("Confirm")),
                                ],
                                content: TextField(
                                  controller: newPaidMonths,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    labelText: "Paid months",
                                  ),
                                ),
                              ),
                            );
                          },
                        ) : Container(),

                        /// edit comment
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.purple),
                          title: const Text(
                            "Edit comment",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            newComment.text = "";
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Edit comment"),
                                actions: [
                                  TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Cancel")),

                                  TextButton(
                                      onPressed: () async {
                                        await transactionTable.updateData("id=${info["id"]}", "comment='${newComment.text}'");
                                        Navigator.of(context).pop();
                                        showToast("Comment updated");
                                      },
                                      child: const Text("Confirm")),
                                ],
                                content: TextField(
                                  controller: newComment,
                                  maxLines: 2,
                                  maxLength: 200,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    fillColor: Colors.grey[300],
                                    filled: true,
                                    labelText: "Comment",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        /// delete finished
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.purple),
                          title: const Text(
                            "Delete",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Delete Transaction $num"),
                                content: const Text("Are you sure you want to delete this transaction?"),
                                actions: [
                                  TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("Cancel")),

                                  TextButton(
                                    onPressed: () async {
                                      await transactionTable.deleteData("id=${info["id"]}");
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, "/mainPage");
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(basicInfo)));
                                      showToast("Transaction deleted successfully");
                                    },
                                    child: const Text("Confirm"),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.settings, color: col),
              ),

              IconButton(
                onPressed: () {
                  if (info["comment"].toString().isEmpty) {
                    showToast("No comment in this transaction");
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Center(
                        child: Text(
                          "Comment - Trans $num",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 26
                          ),
                        )
                      ),

                      content: Text(
                        info["comment"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple
                        )
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.comment, color: col),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<List<Widget>> runningTransaction(context) async {
    List<Widget> runningBody = [];
    List<Map> _transactions = await transactionTable.readData("client=${basicInfo["id"]}");


    for (int i = 0; i < _transactions.length; i++) {
      Map trn = _transactions[i];
      if (trn["year"] < checkDate.year || (trn["year"] == checkDate.year && trn["month"] <= checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          runningBody.add(transactionBox(trn, i + 1, 1));
        }
      }
    }

    return runningBody;
  }

  Future<List<Widget>> futureTransaction(context) async {
    List<Widget> futureBody = [];
    List<Map> _transactions = await transactionTable.readData("client=${basicInfo["id"]}");

    for (int i = 0; i < _transactions.length; i++) {
      Map trn = _transactions[i];
      if (trn["year"] > checkDate.year || (trn["year"] == checkDate.year && trn["month"] > checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          futureBody.add(transactionBox(trn, i + 1, 2));
        }
      }
    }

    return futureBody;
  }

  Future<List<Widget>> finishedTransaction(context) async {
    List<Widget> finishedBody = [];
    List<Map> _transactions = await transactionTable.readData("client=${basicInfo["id"]}");


    for (int i = 0; i < _transactions.length; i++) {
      Map trn = _transactions[i];
      if (trn["paidmonths"] >= trn["plan"]) {
        finishedBody.add(transactionBox(trn, i + 1, 3));
      }
    }

    return finishedBody;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    basicInfo = widget.basicInfo;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.arrow_back_ios, color: Colors.purple),
                  ],
                ),
              ),
              onTap: () {Navigator.of(context).pop();},
            ),

            SizedBox(
              width: _width / 3 + 30,
              child: Text(
                widget.basicInfo["name"],
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bebasNeue(
                  color: Colors.white,
                  fontSize: 30,
                  // fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),

        actions: [
          /// setting
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.purple),
            onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Center(
                      child: Text(
                        "SETTINGS",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 26
                        ),
                      ),
                    ),
                    children: [
                      /// image finished
                      ListTile(
                        leading: const Icon(Icons.add_a_photo, color: Colors.purple),
                        title: const Text(
                          "Change client picture",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                              title: Center(
                                child: Text(
                                  "PICK FROM",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 26
                                  ),
                                )
                              ),

                              children: [
                                ListTile(
                                  leading: const Icon(Icons.image, color: Colors.purple,),
                                  title: const Text(
                                    "Gallery",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple
                                    )
                                  ),
                                  onTap: () async {
                                    await uploadImageGallery();
                                    Navigator.of(context).pop();
                                    if (newImage != "null") {
                                      if (widget.basicInfo["image"] != "null") {
                                        await File(widget.basicInfo["image"]).delete();
                                      }
                                      String imagePath = await saveImage();
                                      await clientTable.updateData("id=${widget.basicInfo["id"]}", "image='$imagePath'");
                                      List<Map> newInfo = await clientTable.readData("id=${basicInfo["id"]}");
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, "/mainPage");
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(newInfo[0])));
                                    }
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                                  title: const Text(
                                    "Camera",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple
                                    )
                                  ),
                                  onTap: () async {
                                    await uploadImageCamera();
                                    Navigator.of(context).pop();
                                    if (newImage != "null") {
                                      if (widget.basicInfo["image"] != "null") {
                                        await File(widget.basicInfo["image"]).delete();
                                      }
                                      String imagePath = await saveImage();
                                      await clientTable.updateData("id=${widget.basicInfo["id"]}", "image='$imagePath'");
                                      List<Map> newInfo = await clientTable.readData("id=${basicInfo["id"]}");

                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, "/mainPage");
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(newInfo[0])));
                                    }
                                  },
                                ),

                                Visibility(child: const Divider(thickness: 2), visible: basicInfo["image"] != "null"),

                                Visibility(
                                  child: ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.purple),
                                    title: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple
                                      )
                                    ),
                                    onTap: () async {
                                      File(basicInfo["image"]).delete();

                                      await clientTable.updateData("id=${widget.basicInfo["id"]}", "image = 'null'");
                                      List<Map> newInfo = await clientTable.readData("id=${basicInfo["id"]}");

                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, "/mainPage");
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(newInfo[0])));

                                    },
                                  ),
                                  visible: basicInfo["image"] != "null",
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      /// name finished
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.purple),
                        title: const Text(
                          "Edit client name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),

                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text(
                                  "Edit client name",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 26
                                  ),
                                )
                              ),
                              actions: [
                                TextButton(
                                  onPressed: (){Navigator.of(context).pop();},
                                    child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple
                                        )
                                    )
                                ),

                                TextButton(
                                  onPressed: () async {
                                    if (newName.text.length > 15) {
                                      showToast("Name exceed 15 chars");
                                      return;
                                    }

                                    if (newName.text.isNotEmpty) {
                                      await clientTable.updateData("id = ${widget.basicInfo["id"]}", "name = '${newName.text}'");
                                    }

                                    List<Map> basicInfo2 = await clientTable.readData("id = ${widget.basicInfo["id"]}");
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(basicInfo2[0])));
                                  },
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.purple
                                      )
                                    )
                                ),
                              ],
                              content: TextField(
                                controller: newName,
                                maxLength: 15,
                                cursorColor: Colors.purple,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(width: 2, color: Colors.purple)
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  labelText: "Name",
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      /// phone finished
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.purple),
                        title: const Text(
                          "Edit phone number",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Center(
                                child: Text(
                                  "Edit client number",
                                  style: GoogleFonts.bebasNeue(
                                      fontSize: 26
                                  ),
                                )
                              ),
                              actions: [
                                TextButton(
                                  onPressed: (){Navigator.of(context).pop();},
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.purple
                                      )
                                    )
                                ),

                                TextButton(
                                  onPressed: () async {
                                    if (phoneCheck(newPhone.text) == false) {
                                      return;
                                    }
                                    await clientTable.updateData("id = ${widget.basicInfo["id"]}", "phone = '${newPhone.text}'");
                                    List<Map> basicInfo2 = await clientTable.readData("id=${widget.basicInfo["id"]}");
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(basicInfo2[0])));
                                  },
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.purple
                                    )
                                  )
                                ),
                              ],
                              content: TextField(
                                controller: newPhone,
                                maxLength: 15,
                                cursorColor: Colors.purple,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(width: 2, color: Colors.purple)
                                  ),
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  labelText: "Phone number",
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      /// delete finished
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.purple),
                        title: const Text(
                          "Delete client",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete client"),
                              actions: [
                                TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Cancel")),

                                TextButton(
                                    onPressed: () async {
                                      if (widget.basicInfo["image"] != "null") {
                                        await File(widget.basicInfo["image"]).delete();
                                      }
                                      await clientTable.deleteData("id=${widget.basicInfo["id"]}");
                                      await transactionTable.deleteData("client=${widget.basicInfo["id"]}");
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, "/mainPage");
                                    },
                                    child: const Text("Delete")),
                              ],
                              content: const Text("Are you sure you want to delete this client?"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
          ),

          /// send sms
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: () {
              if (runningTrans == 0) {
                showToast("No running transaction");
                return;
              }
              if (totalAmount.toInt() == 0) {
                showToast("No amount required");
                return;
              }


              showDialog<String>(
                context: context,
                builder: (BuildContext context) => SimpleDialog(
                  title: Center(
                    child: Text(
                      "Select message type",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 26
                      ),
                    ),
                  ),
                  children: [
                    ListTile(
                      title: const Text(
                        "   Long",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple
                        ),
                      ),
                      onTap: () async {
                        await sendMessage(transactions, basicInfo["name"], basicInfo["phone"], 1);
                        Navigator.of(context).pop();
                        showToast("Message sent successfully");
                      }
                    ),

                    ListTile(
                        title: const Text(
                          "   Medium",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () async {
                          await sendMessage(transactions, basicInfo["name"], basicInfo["phone"], 2);
                          Navigator.of(context).pop();
                          showToast("Message sent successfully");
                        }
                    ),

                    ListTile(
                        title: const Text(
                          "   Short",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () async {
                          await sendMessage(transactions, basicInfo["name"], basicInfo["phone"], 3);

                          Navigator.of(context).pop();
                          showToast("Message sent successfully");
                        }
                    ),

                    ListTile(
                        title: const Text(
                          "   Auto",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),
                        ),
                        onTap: () async {
                          await sendMessage(transactions, basicInfo["name"], basicInfo["phone"], 4);
                          Navigator.of(context).pop();
                          showToast("Message sent successfully");
                        }
                    ),
                  ],
                ),
              );
            },
          ),

          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.purple),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Text("Report"),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 10));
                    if (runningTrans == 0 && futureTrans == 0) {
                      showToast("No running or future transactions");
                      return;
                    }
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientReport(basicInfo, includedTransactions, totalAmount, runningTrans, futureTrans, finishedTrans)));
                  },
                ),
              ];
            }
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const SizedBox(width: double.infinity, height: 510),

                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: _width,
                      child: Container(
                        height: 250,
                        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 7,
                                  offset: const Offset(0, 7)
                              )
                            ]
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          margin: const EdgeInsets.only(top: 123),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.basicInfo["name"],
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                widget.basicInfo["phone"],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(300),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(300),
                          ),

                          child: Hero(
                            tag: "client-avatar${basicInfo["id"]}",
                            child: avatar(_width/2 - 85, basicInfo["image"])
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTransaction(widget.basicInfo, totalTransactions + 1)));
                },

                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.purple),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                ),

                child: SizedBox(
                  width: _width - 60,
                  height: 50,
                  child: Center(
                    child: Text(
                      "ADD TRANSACTION",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 25,
                        color: Colors.white
                      ),
                    )
                  ),
                ),
              ),

              /// Summary Box
              FutureBuilder<Widget>(
                future: summaryInfo(context, _width),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SingleChildScrollView(
                      child: CircularProgressIndicator(color: Colors.purple),
                    );
                  }

                  return snapshot.data!;
                },
              ),


              const SizedBox(
                width: 300,
                child: Divider(thickness: 2, height: 50, color: Colors.grey),
              ),

              /// Running transactions
              FutureBuilder<List<Widget>>(
                future: runningTransaction(context),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: runningCol)
                      ),
                    );
                  }

                  List<Widget> runningTrans = snapshot.data!.toList();

                  if (runningTrans.isEmpty) return Container();

                  return Column(
                    children: [
                      Text(
                        "Running transaction",
                        style: GoogleFonts.bebasNeue(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: runningCol
                        ),
                      ),

                      const SizedBox(height: 20),


                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: runningTrans),
                      ),

                      const SizedBox(
                        width: 300,
                        child: Divider(thickness: 2, height: 50, color: Colors.grey),
                      ),
                    ]
                  );
                },
              ),

              /// Future transactions
              FutureBuilder<List<Widget>>(
                future: futureTransaction(context),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(color: futureCol)
                      ),
                    );
                  }

                  List<Widget> futureTrans = snapshot.data!.toList();
                  if (futureTrans.isEmpty) return Container();

                  return Column(
                    children: [
                      Text(
                        "Future transaction",
                        style: GoogleFonts.bebasNeue(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: futureCol
                        ),
                      ),

                      const SizedBox(height: 20),


                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: futureTrans),
                      ),

                      const SizedBox(
                        width: 300,
                        child: Divider(thickness: 2, height: 50, color: Colors.grey),
                      ),
                    ]
                  );
                },
              ),

              /// Finished transactions
              FutureBuilder<List<Widget>>(
                future: finishedTransaction(context),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(color: finishedCol)
                      ),
                    );
                  }

                  List<Widget> finishedTrans = snapshot.data!.toList();
                  if (finishedTrans.isEmpty) return Container();

                  return Column(
                      children: [
                        Text(
                          "Finished transaction",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: finishedCol
                          ),
                        ),

                        const SizedBox(height: 20),


                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: finishedTrans),
                        ),
                      ]
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ClientReport extends StatelessWidget {
  final Map basicInfo;
  final List<Map> includedTransactions;
  final double totalAmount;
  final int runningTrans;
  final int futureTrans;
  final int finishedTrans;

  const ClientReport(
      this.basicInfo,
      this.includedTransactions,
      this.totalAmount,
      this.runningTrans,
      this.futureTrans,
      this.finishedTrans,
      {Key? key}) : super(key: key
  );

  Future<Widget> body(_width) async {

    DateTime lastDate = DateTime(includedTransactions[0]["year"], includedTransactions[0]["month"] + includedTransactions[0]["plan"] - 1, 1);

    for (int i = 0; i < includedTransactions.length; i++) {
      if (DateTime(includedTransactions[i]["year"], includedTransactions[i]["month"] + includedTransactions[i]["plan"] - 1, 1).isAfter(lastDate)) {
        lastDate = DateTime(includedTransactions[i]["year"], includedTransactions[i]["month"] + includedTransactions[i]["plan"] - 1, 1);
      }
    }

    int monthsNum = (lastDate.year - checkDate.year)*12 + (lastDate.month - checkDate.month);
    int stYear = DateTime(checkDate.year, checkDate.month + 1, 1).year;
    int stMonth = DateTime(checkDate.year, checkDate.month + 1, 1).month;

    List<double> amount = [for (int i = 0; i < monthsNum; i++) 0];
    double totalFuturePayment = 0;
    double maxAmount = 0;

    for (int i = 0; i < monthsNum; i++) {
      DateTime currentCheckDate = DateTime(stYear, stMonth + i, 1);

      for (int j = 0; j < includedTransactions.length; j++) {
        DateTime stTransDate = DateTime(includedTransactions[j]["year"], includedTransactions[j]["month"] - 1, 1);
        DateTime endTransDate = DateTime(includedTransactions[j]["year"], includedTransactions[j]["month"] + includedTransactions[j]["plan"], 1);
        if (currentCheckDate.isAfter(stTransDate) && currentCheckDate.isBefore(endTransDate)) {
          amount[i] += (includedTransactions[j]["price"] - includedTransactions[j]["deposit"]) / includedTransactions[j]["plan"];
          maxAmount = maxAmount < amount[i]? amount[i] : maxAmount;
        }
      }
      totalFuturePayment += amount[i];
    }


    double columnWidth = _width / 2 - 10;
    List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.purple, Colors.amber, Colors.cyan];
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: _width - 20,
            decoration: BoxDecoration(
                color: Colors.green[500],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                )
            ),
            child: const Text(
              "General overview",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[500],
                child: const Text(
                  "Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[400],
                child: Center(
                  child: Text(
                    "${checkDate.month}-${checkDate.year}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // total amount finished
          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[400],
                child: const Text(
                  "Total amount",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    totalAmount.toStringAsFixed(1) + " EGP",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          //running trans.
          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[500],
                child: const Text(
                  "Running trans.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[400],
                child: Center(
                  child: Text(
                    "$runningTrans",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          //future trans.
          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[400],
                child: const Text(
                  "Future trans.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    "$futureTrans",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          //finished trans.
          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[500],
                child: const Text(
                  "Finished trans.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[400],
                child: Center(
                  child: Text(
                    "$finishedTrans",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          //total_transaction finished
          Row(
            children: [
              Container(
                width: columnWidth,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(10),
                // height: 70,
                color: Colors.grey[400],
                child: const Text(
                  "Total trans.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: columnWidth,
                padding: const EdgeInsets.all(10),
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    "${runningTrans + futureTrans + finishedTrans}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          if (monthsNum == 0) Container() else Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: _width - 20,
                decoration: BoxDecoration(
                    color: Colors.yellow[500],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    )
                ),
                child: const Text(
                  "Future payments",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),


              for (int i = 0; i < monthsNum; i++)
                Row(
                  children: [
                    Container(
                      width: columnWidth,
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.all(10),
                      color: i%2 == 0? Colors.grey[500] : Colors.grey[400],
                      child: Text(
                        "${DateTime(stYear, stMonth + i, 1).month}-${DateTime(stYear, stMonth + i, 1).year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      width: columnWidth,
                      padding: const EdgeInsets.all(10),
                      color: i%2 == 0? Colors.grey[400] : Colors.grey[300],
                      child: Center(
                        child: Text(
                          amount[i].toStringAsFixed(1) + " EGP",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              Row(
                children: [
                  Container(
                    width: columnWidth,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(10),
                    color: monthsNum%2 == 0? Colors.purple[300] : Colors.purple[200],
                    child: const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    width: columnWidth,
                    padding: const EdgeInsets.all(10),
                    color: monthsNum%2 == 0? Colors.purple[200] : Colors.purple[100],
                    child: Center(
                      child: Text(
                        totalFuturePayment.toStringAsFixed(1) + " EGP",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Visibility(
                visible: monthsNum > 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      width: _width - 20,
                      decoration: BoxDecoration(
                          color: Colors.blue[500],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          )
                      ),
                      child: const Text(
                        "Chart",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),

                              Column(
                                children: [
                                  for (int i = 21; i >= 0; i--)
                                    Container(
                                      width: 60,
                                      height: 20,
                                      color: i%2 == 0? Colors.purple[200] : Colors.purple[100],
                                      child: Center(
                                        child: Text(
                                          maxAmount < 40? (maxAmount * i / 20).toStringAsFixed(2) : (maxAmount * i / 20).toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              Container(
                                color: Colors.grey[300],
                                height: 440,
                                width: monthsNum * 50,
                                child: Stack(
                                  children: [
                                    for (int i = 0; i < monthsNum; i++)
                                      Positioned(
                                          bottom: 0,
                                          left: i * 50,
                                          child: Container(
                                            width: 50,
                                            height: amount[i] / maxAmount * 400 + 10,
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Container(
                                              color: colors[i % 6],
                                            ),
                                          )
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10)
                            ],
                          ),

                          Row(
                            children: [
                              const SizedBox(width: 10),

                              Container(
                                width: 60,
                                height: 50,
                                color: Colors.grey[400],
                              ),

                              for (int i = 0; i < monthsNum; i++)
                                Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.brown,
                                  child: Center(
                                    child: Text(
                                      "${DateTime(checkDate.year, checkDate.month + i + 1, 1).month}"
                                          "\n${DateTime(checkDate.year, checkDate.month + i + 1, 1).year}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(width: 10),
                            ],
                          ),


                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(27),
              child: SizedBox(
                width: 80,
                height: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_ios, color: Colors.purple),
                    avatar(22, basicInfo["image"]),
                  ],
                ),
              ),
              onTap: () {Navigator.of(context).pop();},
            ),

            const SizedBox(width: 10),


            Text(
              "Report",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.white
                // fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<Widget> (
        future: body(_width),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                  children: [
                    SizedBox(height: _height/2 - 50),
                    const CircularProgressIndicator(color: Colors.blue),
                  ]
              ),
            );
          }
          else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}


