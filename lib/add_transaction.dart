
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'client_page.dart';
import 'shared.dart' show avatar, showToast, transactionTable, checkDate;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;



class AddTransaction extends StatefulWidget {
  final Map basicInfo;
  final int transactionNum;
  const AddTransaction(this.basicInfo, this.transactionNum, {Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  TextEditingController totalPrice = TextEditingController();
  TextEditingController deposit = TextEditingController();
  TextEditingController comment = TextEditingController();


  int startMonth = 0;
  int startYear = 0;
  int thisYear = DateTime.now().year;
  int thisMonth = DateTime.now().month;
  int missingMonths = 0;

  String selectedPlan = "12";
  var plans = [ "1", "6", "12", "18", "24"];

  String selectedPayment = "0";
  List<String> months = [for (int i = 0; i <= 24; i++) i.toString()];

  bool _visible = false;


  void checkMissingMonths(DateTime newDateTime) {
    bool dayCheck = startYear == thisYear && startMonth == thisMonth && DateTime.now().day < 6;
    setState(() {

      if ((startYear < thisYear || (startYear == thisYear && startMonth <= thisMonth)) && !dayCheck) {
        int years = thisYear - startYear;
        missingMonths = years*12 + thisMonth - startMonth + 1;

        if (missingMonths >= double.parse(selectedPlan).toInt()) {
          missingMonths = double.parse(selectedPlan).toInt();
        }

        missingMonths = DateTime.now().day < 6? missingMonths - 1: missingMonths;

        if (DateTime(startYear, startMonth + double.parse(selectedPlan).toInt() - 1, 1).isBefore(checkDate)) {
          missingMonths = double.parse(selectedPlan).toInt();
        }

        _visible = true;
        selectedPayment = missingMonths.toString();
      }

      else {
        _visible = false;
        missingMonths = 0;
        selectedPayment = "0";
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    if (DateTime.now().day < 11) {
      startMonth = DateTime.now().month + 1;
      startYear = DateTime.now().year;
      if (startMonth > 12) {
        startMonth -= 12;
        startYear += 1;
      }
    }
    else {
      startMonth = DateTime.now().month + 2;
      startYear = DateTime.now().year;
      if (startMonth > 12) {
        startMonth -= 12;
        startYear += 1;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    Color? textFiledColor = Colors.grey[50];

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

                          Hero(
                            tag: "client-avatar${widget.basicInfo["id"]}",
                            child: avatar(22, widget.basicInfo["image"])
                          ),
                        ],
                      ),
                    ),
                    onTap: () {Navigator.of(context).pop();},
                  ),

                  // avatar_(20, basicInfo["image"]),
                  const SizedBox(width: 10),

                  Text(
                    "Add Transaction",
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
                          text: "To  ",
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
          ],
        ),
      ),

      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
                margin: const EdgeInsets.fromLTRB(20, 30, 20, 40),

                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 7)
                    )
                  ],
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    /// transaction number
                    Text(
                      "Transaction ${widget.transactionNum}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                          fontSize: 32,
                          color: Colors.purple
                      ),
                    ),

                    /// price field
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 20),

                      child: TextField(
                        controller: totalPrice,
                        keyboardType: TextInputType.number,

                        style: Theme.of(context).textTheme.headline6,
                        cursorColor: Colors.purple,
                        decoration: InputDecoration(
                          labelText: "Price",
                          labelStyle: const TextStyle(
                            color: Colors.purple
                          ),
                          fillColor: textFiledColor,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.grey, width: 2)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: Colors.purple, width: 2)
                          )
                        ),
                      ),
                    ),

                    /// deposit field
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: deposit,
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.headline6,
                        cursorColor: Colors.purple,
                        decoration: InputDecoration(
                          labelText: "Deposit",
                          labelStyle: const TextStyle(
                              color: Colors.purple
                          ),
                          fillColor: textFiledColor,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.grey, width: 2)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: Colors.purple, width: 2)
                          )
                        ),
                      ),
                    ),

                    /// installment plan
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 60,

                      decoration: BoxDecoration(
                        color: textFiledColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(width: 2, color: Colors.grey),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Installment Plan",
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
                            value: selectedPlan,

                            items: plans.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),

                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPlan = newValue!;
                                checkMissingMonths(DateTime(startYear, startMonth, 1));
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    /// start date
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25)
                        )
                      ),
                      child: const Center(
                        child: Text(
                          "Start Date",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),

                    /// date picker
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: textFiledColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: CupertinoDatePicker(
                        dateOrder: DatePickerDateOrder.dmy,
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: DateTime(thisYear, DateTime.now().day>10? thisMonth%12 + 2: thisMonth%12 + 1, 1),
                        maximumDate: DateTime(thisYear, thisMonth + 6, 1),
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            startMonth = newDateTime.month;
                            startYear = newDateTime.year;
                            checkMissingMonths(newDateTime);
                          });
                        },
                        use24hFormat: false,
                        minuteInterval: 1,
                      ),
                    ),

                    /// comment section
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: comment,
                        style: Theme.of(context).textTheme.headline6,
                        maxLines: 3,
                        minLines: 1,
                        maxLength: 200,
                        cursorColor: Colors.purple,
                        decoration: InputDecoration(
                          labelText: "Comment",
                          labelStyle: const TextStyle(
                              color: Colors.purple
                          ),
                          fillColor: textFiledColor,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.grey, width: 2)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: Colors.purple, width: 2)
                          )
                        ),
                      ),
                    ),


                    /// warning (by default it's not visible)
                    Visibility(
                      visible: _visible,
                      child: Column(
                        children: [
                          const Divider(thickness: 2, color: Colors.purple),

                          const SizedBox(height: 20),

                          /// warning text
                          Text(
                            "WARNING",
                            style: GoogleFonts.bebasNeue(
                              fontSize: 32,
                              color: Colors.purple,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "This is old transaction",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Number of months supposed to be paid is $missingMonths",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "If client paid $missingMonths months ignore this warning",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),

                          /// determining the paid months
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 60,

                            decoration: BoxDecoration(
                              color: textFiledColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Paid months",
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
                                  value: selectedPayment,

                                  items: months.sublist(0, selectedPlan == missingMonths.toString()? missingMonths + 1: missingMonths + 2).map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),

                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPayment = newValue!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// add button
              ElevatedButton(
                onPressed: () async {
                  double _price;
                  double _deposit;
                  int _plan;
                  int _paid = 0;
                  String _comment;

                  /// price validation
                  if (totalPrice.text.isEmpty) {
                    showToast("Price is required");
                    return;
                  } else {
                    if (double.tryParse(totalPrice.text) == null) {
                      showToast("Invalid price entered");
                      return;
                    } else {
                      _price = double.parse(totalPrice.text);
                    }
                  }

                  if (_price < 1) {
                    showToast("Price is too low");
                    return;
                  }
                  if (_price > 500000) {
                    showToast("Price is too high (limit: 500000 EGP)");
                    return;
                  }

                  /// deposit validation
                  if (deposit.text.isEmpty) {
                    _deposit = 0;
                  } else {
                    if (double.tryParse(deposit.text) == null) {
                      showToast("Invalid deposit entered");
                      return;
                    } else {
                      _deposit = double.parse(deposit.text);
                    }
                  }

                  if (_deposit >= _price) {
                    showToast("Deposit must be less than the price");
                    return;
                  }

                  _comment = comment.text.trim();
                  _plan = double.parse(selectedPlan).toInt();

                  if (_visible) {
                    _paid = double.parse(selectedPayment).toInt();
                  }

                  int response = await transactionTable.insertData(widget.basicInfo["id"], startYear, startMonth, _price, _deposit, _plan, _paid, _comment);
                  if(response != 0) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/mainPage");
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClientPage(widget.basicInfo)));
                    showToast("Transaction added successfully");
                  }
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
                        "ADD TRANSACTION",
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
