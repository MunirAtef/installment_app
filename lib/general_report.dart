
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared.dart';

class GeneralReport extends StatelessWidget {
  final int clientsNum;
  GeneralReport(this.clientsNum, {Key? key}) : super(key: key);

  List<Map> transactions = [];
  List<Map> includedTransactions = [];


  Future<Widget> body(double _width) async {
    transactions = await transactionTable.readData("id > 0");
    int transactionsNum = transactions.length;
    int future = 0;
    int running = 0;
    double totalAmount = 0;

    DateTime lastDate = DateTime(transactions[0]["year"], transactions[0]["month"] + transactions[0]["plan"] - 1, 1);


    for (int i = 0; i < transactionsNum; i++) {
      if (DateTime(transactions[i]["year"], transactions[i]["month"] + transactions[i]["plan"] - 1, 1).isAfter(lastDate)) {
        lastDate = DateTime(transactions[i]["year"], transactions[i]["month"] + transactions[i]["plan"] - 1, 1);
      }
    }

    for (int i = 0; i < transactionsNum; i++) {
      Map trn = transactions[i];
      int stYear = trn["year"];
      int stMonth = trn["month"];
      int paidMonths = trn["paidmonths"];

      if (stYear < checkDate.year || (stYear == checkDate.year && stMonth <= checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          int checkPaid = (checkDate.year - stYear)*12 + (checkDate.month - stMonth) + 1;
          checkPaid = checkPaid > trn["plan"]? trn["plan"] : checkPaid;
          totalAmount += ((trn["price"] - trn["deposit"]) / trn["plan"])*(checkPaid - paidMonths);
          includedTransactions.add(trn);
          running++;
        }
      }
      else {
        includedTransactions.add(trn);
        future++;
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
        }
      }
      totalFuturePayment += amount[i];
      maxAmount = maxAmount < amount[i]? amount[i] : maxAmount;
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
                    "$running",
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
                    "$future",
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
                    "${transactionsNum - (running + future)}",
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
                    "$transactionsNum",
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
                color: Colors.grey[500],
                child: const Text(
                  "Number of clients",
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
                    "$clientsNum",
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


          monthsNum < 1? Container() :
          Column(
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
                      // height: 70,
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
                                              // color: Colors.blue,
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
                  )
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
                  children: const [
                    Icon(Icons.arrow_back_ios, color: Colors.purple),
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage("Assets/MyCIB.png"),
                    ),
                  ],
                ),
              ),
              onTap: () {Navigator.of(context).pop();},
            ),

            const SizedBox(width: 10),


            Text(
              "General Report",
              style: GoogleFonts.bebasNeue(
                  fontSize: 30,
                  color: Colors.white
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Widget> (
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
            )
          ],
        ),
      ),
    );
  }
}
