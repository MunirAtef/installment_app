
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'client_page.dart';
import 'shared.dart';

class CustomPaid extends StatefulWidget {
  final Map basicInfo;
  final double totalAmount;
  const CustomPaid(this.basicInfo, this.totalAmount, {Key? key}) : super(key: key);

  @override
  State<CustomPaid> createState() => _CustomPaidState();
}

class _CustomPaidState extends State<CustomPaid> {
  List<int> idUnpaidTrans = [];
  List<String> extraPaid = [];
  List<int> correspondingId = [];
  List<int> requiredMonths = [];



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

  Widget setPaidTrans(double _width, Map transInfo, int requiredMonths, int num, int index) {
    if (extraPaid.length == index) {
      extraPaid.add("0");
      correspondingId.add(transInfo["id"]);
    }

    double pricePerMonth = (transInfo["price"] - transInfo["deposit"]) / transInfo["plan"];

    List<String> numOfPaidMonths = [for (int i = 0; i <= 24; i++) i.toString()];

    return Container(
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
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Text(
            "Transaction $num",
            style: GoogleFonts.bebasNeue(
                fontSize: 32,
                color: Colors.purple
            ),
          ),

          const SizedBox(height: 20),

          /// price/month
          tableRow("Price/month", pricePerMonth.toStringAsFixed(1) + " EGP", true),
          const Divider(color: Colors.purple, thickness: 2, height: 2),

          /// paid
          tableRow("Paid", "${transInfo["paidmonths"]}", false),
          const Divider(color: Colors.purple, thickness: 2, height: 2),

          /// unpaid months
          tableRow("Unpaid months", "$requiredMonths", true),
          const Divider(color: Colors.purple, thickness: 2, height: 2),

          /// extra paid months
          tableRow("Unpaid amount", (pricePerMonth*requiredMonths).toStringAsFixed(1) + " EGP", true),
          const Divider(color: Colors.purple, thickness: 2, height: 2),

          /// extra paid months
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,

            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(width: 2, color: Colors.grey),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Extra months paid",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple
                  ),
                ),

                DropdownButton(
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple
                  ),

                  iconSize: 30,
                  value: extraPaid[index],

                  items: numOfPaidMonths.sublist(0, requiredMonths + 1).map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),

                  onChanged: (String? newValue) {
                    setState(() {
                      extraPaid[index] = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20)
            ),

            child: Text(
              "Paid amount ${(pricePerMonth * double.parse(extraPaid[index])).toStringAsFixed(1)} EGP",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> runningTransaction(context, double _width) async {
    List<Map> _transactions = await transactionTable.readData("client=${widget.basicInfo["id"]}");
    List<Map> runningTrans = [];
    List<int> requiredMonths = [];
    List<int> transNum = [];

    for (int i = 0; i < _transactions.length; i++) {
      Map trn = _transactions[i];
      int stYear = trn["year"];
      int stMonth = trn["month"];
      int paidMonths = trn["paidmonths"];

      if (trn["year"] < checkDate.year || (trn["year"] == checkDate.year && trn["month"] <= checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          runningTrans.add(trn);
          int checkPaid = (checkDate.year - stYear)*12 + (checkDate.month - stMonth) + 1;
          checkPaid = checkPaid > trn["plan"]? trn["plan"] : checkPaid;
          requiredMonths.add(checkPaid - paidMonths);
          transNum.add(i + 1);
        }
      }
    }

    this.requiredMonths = requiredMonths;

    List<Widget> body = [];
    int index = 0;
    idUnpaidTrans = [];
    for (int i = 0; i < requiredMonths.length; i++) {
      idUnpaidTrans.add(runningTrans[i]["id"]);
      if (requiredMonths[i] != 0) {
        body.add(setPaidTrans(_width, runningTrans[i], requiredMonths[i], transNum[i], index));
        index++;
      }
    }

    return Column(
      children: body,
    );
  }

  Future<void> setPaid() async {
    for (int i = 0; i < requiredMonths.length; i++) {
      if (requiredMonths[i] != 0) {
        await transactionTable.updateData("id = ${idUnpaidTrans[i]}", "paidmonths = paidmonths + ${requiredMonths[i]}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),

        title: Stack(
            children: [
              const SizedBox(height: 130),

              SizedBox(
                height: 90,
                child: Row(
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

                            avatar(22, widget.basicInfo["image"])
                          ],
                        ),
                      ),
                      onTap: () {Navigator.of(context).pop();},
                    ),

                    const SizedBox(width: 10),


                    Text(
                      "Setting payment",
                      style: GoogleFonts.bebasNeue(
                          fontSize: 30,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 15,
                child: SizedBox(
                  height: 45,
                  width: _width,

                  child: Center(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text: "For  ",
                                style: GoogleFonts.bebasNeue(
                                    fontSize: 26,
                                    color: Colors.white
                                ),
                              ),

                              TextSpan(
                                text: "${widget.basicInfo["name"]}",
                                style: GoogleFonts.bebasNeue(
                                    fontSize: 26,
                                    color: Colors.purple
                                ),
                              ),
                            ]
                        ),
                      )
                  ),
                ),
              )
            ]
        ),
      ),

      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// show the total amount
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  margin: const EdgeInsets.only(top: 30, bottom: 20),
                  width: _width - 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: Colors.purple),
                  ),
                  child: Center(
                    child: Text(
                      "Total amount: ${widget.totalAmount.toStringAsFixed(1)} EGP",
                      style: GoogleFonts.bebasNeue(
                          fontSize: 25,
                          color: Colors.purple
                      )
                    ),
                  )
              ),

              /// client paid all amount
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Center(
                        child: Text(
                          "Confirmation",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 26
                          ),
                        ),
                      ),
                      content: Text(
                        "Are you sure that client paid\n${widget.totalAmount.toStringAsFixed(1)} EGP?",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {Navigator.of(context).pop();},
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple
                              ),
                            )
                        ),

                        TextButton(
                            onPressed: () async {
                              await setPaid();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, "/mainPage");
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(widget.basicInfo)));

                              showToast("Payment Completed for ${widget.basicInfo["name"]}");
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple
                              ),
                            )
                        )
                      ],
                    ),
                  );
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
                          "Client paid all amount",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 25,
                              color: Colors.white
                          ),
                        )
                    )
                ),
              ),

              const SizedBox(height: 20),


              /// divider for custom paid
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: _width / 2 - 70,
                    color: Colors.black,
                  ),

                  SizedBox(
                    width: 140,
                    child: Text(
                      "Custom paid",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                          fontSize: 30,
                          color: Colors.purple
                      ),
                    ),
                  ),

                  Container(
                    height: 3,
                    width: _width / 2 - 70,
                    color: Colors.black,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              FutureBuilder<Widget> (
                  future: runningTransaction(context, _width),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator(color: Colors.purple);
                    }
                    return snapshot.data!;
                  }
              ),

              const SizedBox(height: 30),

              /// apply changes
              ElevatedButton(
                onPressed: () async {
                  int test = 0;
                  for (int i = 0; i < extraPaid.length; i++) {
                    int _extraPaid = double.parse(extraPaid[i]).toInt();
                    if (_extraPaid != 0) {
                      test++;
                      await transactionTable.updateData("id = ${correspondingId[i]}", "paidmonths = paidmonths + $_extraPaid");
                    }
                  }

                  if (test == 0) {
                    showToast("Nothing changed!!");
                    return;
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, "/mainPage");
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(widget.basicInfo)));
                  showToast("Data updated successfully");
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
                          "APPLY CHANGES",
                          style: GoogleFonts.bebasNeue(
                              fontSize: 25,
                              color: Colors.white
                          ),
                        )
                    )
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}




