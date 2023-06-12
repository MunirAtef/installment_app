
import 'dart:convert';
import 'dart:io' show Directory, File;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'add_client.dart';
import 'client_page.dart' show ClientPage;
import 'file_picker.dart';
import 'general_report.dart';
import 'munir.dart';
import 'shared.dart' show avatar, checkDate, clientTable, sendMessage, transactionTable, showToast, loading;
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int clientsNum = 0;
  int transNum = 0;

  List<Map> clients = [];

  late List<bool> isInDept = [for (int i = 0; i < clientsNum; i++) false];
  late List<bool> pin = [for (int i = 0; i < clientsNum; i++) false];
  int pined = 0;

  bool isLoading = false;

  int searchCase = 0;  /// 0 no search, 1 found result, 2 not found

  FocusNode searchFocus = FocusNode();
  TextEditingController searchWord = TextEditingController();


  Future<int> sendToGroup(List<Map> clientsInDept, int msgType) async {
    setState(() {
      isLoading = true;
    });
    Navigator.of(context).pop();

    for (Map client in clientsInDept) {
      List<Map> trans = await transactionTable.readData("client = ${client["id"]}");
      sendMessage(trans, client["name"], client["phone"], msgType);
      await Future.delayed(const Duration(seconds: 5));
    }

    setState(() {
      isLoading = false;
    });
    showToast("Message sent to ${clientsInDept.length} client/s");
    return 1;
  }

  AppBar _appBar() {
    if (pined == 0) {
      return AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)
              ),
              color: Colors.grey[100],
              child: SizedBox(
                width: 160,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Colors.grey,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("Assets/Munir.png"),
                        radius: 25,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "MY",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          color: const Color.fromRGBO(214, 0, 0, 1),
                          letterSpacing: 1,
                        ),
                      ),

                      Text(
                        "CIB",
                        style: GoogleFonts.bebasNeue(
                          // fontWeight: FontWeight.bold,
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          color: const Color.fromRGBO(0, 91, 217, 1),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Munir()));
                  },
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
              onPressed: () async {
                if (clientsNum == 0) {
                  showToast("No clients to send the message");
                  return;
                }
                List<Map> clients = await clientTable.readData("id>0");
                List<Map> clientsInDept = [];

                for (int i = 0; i < clientsNum; i++) {
                  if (isInDept[i]) {
                    clientsInDept.add(clients[i]);
                  }
                }

                if (clientsInDept.isEmpty) {
                  showToast("No client in dept");
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
                          onTap: () {
                            sendToGroup(clientsInDept, 1);
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
                          onTap: () {
                            sendToGroup(clientsInDept, 2);
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
                          onTap: () {
                            sendToGroup(clientsInDept, 3);
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
                          onTap: () {
                            sendToGroup(clientsInDept, 4);
                          }
                      ),
                    ],
                  ),
                );

              },
              icon: const Icon(
                Icons.send,
                color: Colors.purple,
              )),

          IconButton(
              onPressed: () {
                if (clientsNum == 0) {
                  showToast("No Clients to show report");
                  return;
                }
                if (transNum == 0) {
                  showToast("No transactions to show report");
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GeneralReport(clientsNum)));
              },
              icon: const Icon(
                Icons.report,
                color: Colors.purple,
              )),

          PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.purple),
              itemBuilder: (BuildContext context) {
                return [
                  /// import
                  PopupMenuItem(
                    child: const Text(
                      "Import",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple
                      ),
                    ),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 10));
                      PermissionStatus status = await Permission.storage.status;
                      if (status.isDenied) {
                        await Permission.storage.request();

                        if ((await Permission.storage.status).isDenied) {
                          return;
                        }
                      }

                      String zipFilePath = await FilePickerAccess.pickFile(context);
                      if (zipFilePath != "null") {
                        loading("Importing data", context);
                        bool response = await ExportImport.import(zipFilePath);
                        Navigator.of(context).pop();

                        if (response) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainPage())
                          );
                        }
                      }
                    },
                  ),

                  /// Export
                  PopupMenuItem(
                    child: const Text(
                      "Export all data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple
                      ),
                    ),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 10));
                      loading("Creating file", context);
                      String? zipFilePath = await ExportImport.export();
                      Navigator.of(context).pop();

                      if (zipFilePath != null) {
                        await Share.shareXFiles(
                          [XFile(zipFilePath)],
                          text: 'Share exported file'
                        );
                      }
                    },
                  ),
                ];
              }
          ),
        ],
      );
    }

    else if (pined < pin.length) {
      return AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
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
              onTap: () {
                setState(() {
                  pined = 0;
                  for (int i = 0; i < pin.length; i++) {
                    pin[i] = false;
                  }
                });
              },
            ),

            Text(
              "$pined",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),

        actions: [
          //send to selected
          IconButton(
              onPressed: () async {
                if (clientsNum == 0) {
                  showToast("No clients to send the message");
                  return;
                }

                List<Map> clients = await clientTable.readData("id>0");
                List<Map> clientsInDept = [];

                for (int i = 0; i < clientsNum; i++) {
                  if (pin[i] && isInDept[i]) {
                    clientsInDept.add(clients[i]);
                  }
                }

                if (clientsInDept.isEmpty) {
                  showToast("No client in dept");
                  return;
                }


                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: const Text("Select message type"),
                    children: [
                      ListTile(
                          title: const Text("   Long"),
                          onTap: () {
                            sendToGroup(clientsInDept, 1);
                          }
                      ),

                      ListTile(
                          title: const Text("   Medium"),
                          onTap: () {
                            sendToGroup(clientsInDept, 2);
                          }
                      ),

                      ListTile(
                          title: const Text("   Short"),
                          onTap: () {
                            sendToGroup(clientsInDept, 3);
                          }
                      ),

                      ListTile(
                          title: const Text("   Auto"),
                          onTap: () {
                            sendToGroup(clientsInDept, 4);
                          }
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.send,
                color: Colors.purple,
              )
          ),

          //delete selected
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () async {

                          List<Map> list = await clientTable.readData("id>0");
                          for (int i = 0; i < list.length; i++) {
                            if (pin[i] == true) {
                              if (list[i]["image"] != "null") {
                                await File(list[i]["image"]).delete();
                              }
                              await transactionTable.deleteData("client=${list[i]["id"]}");
                              await clientTable.deleteData("id=${list[i]["id"]}");
                            }
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, "/mainPage");
                        },
                        child: const Text("Delete")),
                  ],
                  content: const Text("Are you sure you want to delete selected clients?"),
                ),
              );
            },
            icon: const Icon(Icons.delete, color: Colors.purple),
          ),

          //select all
          IconButton(
              onPressed: () {
                setState(() {
                  pined = pin.length;
                  for (int i = 0; i < pin.length; i++) {
                    pin[i] = true;
                  }
                });
              },
              icon: const Icon(Icons.select_all, color: Colors.purple)
          ),
        ],
      );
    }

    else {
      return AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
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
              onTap: () {
                setState(() {
                  pined = 0;
                  for (int i = 0; i < pin.length; i++) {
                    pin[i] = false;
                  }
                });
              },
            ),

            Text(
              "$pined",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),

        actions: [
          //send to all
          IconButton(
              onPressed: () async {
                if (clientsNum == 0) {
                  showToast("No clients to send the message");
                  return;
                }
                List<Map> clients = await clientTable.readData("id>0");
                List<Map> clientsInDept = [];

                for (int i = 0; i < clientsNum; i++) {
                  if (isInDept[i]) {
                    clientsInDept.add(clients[i]);
                  }
                }

                if (isInDept.isEmpty) {
                  showToast("No clients in dept");
                  return;
                }


                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: const Text("Select message type"),
                    children: [
                      ListTile(
                          title: const Text("   Long"),
                          onTap: () {
                            sendToGroup(clientsInDept, 1);
                          }
                      ),

                      ListTile(
                          title: const Text("   Medium"),
                          onTap: () {
                            sendToGroup(clientsInDept, 2);
                          }
                      ),

                      ListTile(
                          title: const Text("   Short"),
                          onTap: () {
                            sendToGroup(clientsInDept, 3);
                          }
                      ),

                      ListTile(
                          title: const Text("   Auto"),
                          onTap: () {
                            sendToGroup(clientsInDept, 4);
                          }
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.send,
                color: Colors.purple,
              )
          ),

          //delete all
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete all"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () async {
                          transactionTable.deleteData("id>0");
                          List<Map> list = await clientTable.readData("id>0");
                          await clientTable.deleteData("id>0");
                          for (int i = 0; i < list.length; i++) {
                            if (list[i]["image"] != "null") {
                              await File(list[i]["image"]).delete();
                            }
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, "/mainPage");
                        },
                        child: const Text("Delete")),
                  ],
                  content: const Text(
                      "Are you sure you want to delete all clients?"),
                ),
              );
            },
            icon: const Icon(Icons.delete, color: Colors.purple),
          ),
        ],
      );
    }
  }

  Future<Text> amountRequired(int id, int i) async {
    double totalAmount = 0;
    int running = 0;
    List<Map> clientTransactions = await transactionTable.readData("client = $id");
    List<Map> transactions = await transactionTable.readData("id > 0");
    transNum = transactions.length;

    if (clientTransactions.isEmpty) {
      return const Text(
        "Client has no transactions",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.purple
        ),
      );
    }

    for (Map trn in clientTransactions) {
      int stYear = trn["year"];
      int stMonth = trn["month"];
      int paidMonths = trn["paidmonths"];
      if (stYear < checkDate.year || (stYear == checkDate.year && stMonth <= checkDate.month)) {
        if (trn["paidmonths"] < trn["plan"]) {
          running++;
          int checkPaid = (checkDate.year - stYear)*12 + (checkDate.month - stMonth) + 1;
          checkPaid = checkPaid > trn["plan"]? trn["plan"] : checkPaid;
          totalAmount += ((trn["price"] - trn["deposit"]) / trn["plan"])*(checkPaid - paidMonths);
        }
      }
    }

    if (running == 0) {
      return const Text(
        "No running transactions",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.purple
        ),
      );
    }

    if (totalAmount.toInt() == 0) {
      return const Text(
        "Payment completed",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.purple
        ),
      );
    }

    isInDept[i] = true;

    return Text(
      "Amount required: ${totalAmount.toStringAsFixed(1)} EGP",
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.purple
      ),
    );
  }

  Container clientContainer(context, Map clientInfo, int i) {
    String name = clientInfo["name"];
    String imagePath = clientInfo["image"];

    Color? bgc = pin[i]? Colors.purple[100] : Colors.white;
    Color? shadow = pin[i]? Colors.purple[300] : Colors.grey;

    return Container(
      height: 90,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: shadow!
          ),

          BoxShadow(
            color: bgc!,
            blurRadius: 12,
            spreadRadius: -8,
          )
        ]
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (pined != 0) {
            if (pin[i]) {
              setState(() {
                pin[i] = false;
                pined--;
              });
            }
            else {
              setState(() {
                pin[i] = true;
                pined++;
              });
            }
          } else {
            Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ClientPage(clientInfo)
                )
            );
          }
        },
        onLongPress: () {
          if (pin[i]) {
            return;
          }
          setState(() {
            pin[i] = true;
            pined++;
          });
        },
        splashColor: Colors.grey[400],

        child: Row(
          children: [
            const SizedBox(width: 10),

            Stack(
              children: [

                GestureDetector(
                  onTap: () {
                    if (pined != 0) {
                      if (pin[i]) {
                        setState(() {
                          pin[i] = false;
                          pined--;
                        });
                        return;
                      } else {
                        setState(() {
                          pin[i] = true;
                          pined++;
                        });
                        return;
                      }
                    }
                    if (clientInfo["image"] == "null") {
                      showToast("No profile photo");
                      return;
                    }

                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
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

                                    Text(
                                      clientInfo["name"],
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              body: Center(
                                child: Hero(
                                  tag: "client-avatar${clientInfo["id"]}",
                                  child: Image.file(File(clientInfo["image"])),
                                ),
                              ),
                            )
                        )
                    );
                  },
                  child: Hero(
                      tag: "client-avatar${clientInfo["id"]}",
                      child: avatar(35, imagePath)
                  ),
                ),


                Positioned(
                    bottom: 1,
                    right: 1,
                    child: Visibility(
                      visible: pin[i],
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.check, color: Colors.white, size: 17),
                      ),
                    )
                ),
              ],
            ),

            const SizedBox(width: 10),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  // width: _width - 120,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                FutureBuilder<Widget>(
                    future: amountRequired(clientInfo["id"], i),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("", style: TextStyle(fontSize: 15));
                      } else {
                        return snapshot.data!;
                      }
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Column> pageBody(context) async {
    List<Map> clients = await clientTable.readData("id>0");
    List<Widget> body = [];
    clientsNum = clients.length;

    if (clientsNum == 0) {
      return Column(
        children: [
          const SizedBox(height: 50),

          Text(
            "Welcome to ",
            style: GoogleFonts.tangerine(
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "My ",
                style: GoogleFonts.tangerine(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromRGBO(214, 0, 0, 1),
                ),
              ),

              Text(
                "CIB ",
                style: GoogleFonts.tangerine(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromRGBO(0, 91, 217, 1),
                ),
              ),

            ],
          ),

          const SizedBox(height: 40),

          Image.asset("Assets/MyCIB.png", width: 300),
        ],
      );
    }

    for (int i = 0; i < clientsNum; i++) {
      Map client = clients[i];
      body.add(clientContainer(context, client, i));
    }

    return Column(children: body);
  }

  Future<void> getClients() async {
    clients.clear();
    setState(() {isLoading = true;});
    List<Map> _clients = await clientTable.readData("id > 0");
    clients.addAll(_clients);
    clientsNum = clients.length;
    setState(() {isLoading = false;});
  }

  @override
  void initState() {
    // TODO: implement initState
    searchFocus.addListener(() {
      setState(() {});
    });
    getClients();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pined != 0) {
          pined = 0;
          for (int i = 0; i < pin.length; i++) {
            pin[i] = false;
          }
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),

        body: Column(
          children: [
            Visibility(
              visible: pined == 0,
              child: Stack(
                children: [
                  Container(
                    color: Colors.white,
                    height: 90
                  ),

                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      )
                    ),
                  ),

                  Positioned(
                    top: 10,
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width - 70,
                      margin: const EdgeInsets.symmetric(horizontal: 35),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey
                            ),

                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 12,
                              spreadRadius: -8,
                            )
                          ]
                        ),
                        child: TextField(
                          focusNode: searchFocus,
                          controller: searchWord,
                          cursorColor: Colors.purple,
                          style:  const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),

                          decoration: InputDecoration(
                            hintText: "Search..",
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            prefixIcon: searchFocus.hasFocus? IconButton(
                              onPressed: () async {
                                List<Map> copyClients = await clientTable.readData("id > 0");

                                setState(() {
                                  isLoading = true;
                                  clients.clear();
                                });

                                for (int i = 0; i < copyClients.length; i++) {
                                  if (copyClients[i]["name"].toString().toLowerCase().contains(searchWord.text.trim().toLowerCase())) {
                                    setState(() {
                                      clients.add(copyClients[i]);
                                    });
                                  }
                                }

                                searchCase = clients.isEmpty? 2 : 1;

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.purple,
                              ),
                            ) : Icon(Icons.search, color: Colors.grey[700]),
                            suffixIcon: searchFocus.hasFocus? IconButton(
                              onPressed: () {
                                searchWord.clear();
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(Icons.cancel, color: Colors.purple),
                            ) : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(color: Colors.purple),
              ),

            Visibility(
              visible: searchCase != 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    searchCase == 1? "Search result" : "No result found",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple
                    ),
                  ),

                  IconButton(
                    onPressed: () async {
                      searchCase = 0;
                      getClients();
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.purple,
                    )
                  )
                ],
              )
            ),

            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < clients.length; i++)
                    clientContainer(context, clients[i], i),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewClient()
              )
            );
          },
          backgroundColor: Colors.purple,
          child: const Icon(Icons.add, color: Colors.white, size: 35),
          tooltip: "Add client",
        ),
      ),
    );
  }
}



class ExportImport {
  static Future<String?> export() async {
    /// JSON data
    List<Map<String, dynamic>> clients = await clientTable.readData("id > 0");
    List<Map<String, dynamic>> transactions = await transactionTable.readData("id > 0");

    if (clients.isEmpty) {
      showToast("No clients to export data");
      return null;
    }

    List<Map> editedList = clients.map((e) => {
      "id": e["id"],
      "name": e["name"],
      "phone": e["phone"],
      "image": e["image"].split("/").last
    }).toList();


    String data = json.encode({
      "clients": editedList,
      "transactions": transactions
    });

    Directory tempDir = await getTemporaryDirectory();
    String jsonFilePath = "${tempDir.path}/data.json";
    File jsonFile = File(jsonFilePath);
    jsonFile.writeAsStringSync(data);

    ZipFileEncoder encoder = ZipFileEncoder();

    String zipFilePath = "${tempDir.path}/MyCIB-${DateTime.now().millisecondsSinceEpoch}.zip";
    encoder.create(zipFilePath);

    encoder.addFile(jsonFile);

    for (Map client in clients) {
      if (client["image"] != "null") {
        encoder.addFile(File(client["image"]));
      }
    }
    encoder.close();
    return zipFilePath;
  }

  static Future<bool> import(String path) async {
    try {
      String tempPath = (await getTemporaryDirectory()).path;

      File zippedFile = File(path);
      List<int> bytes = zippedFile.readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(bytes);

      String newDir = "$tempPath/temp";

      await Directory(newDir).create();
      for (ArchiveFile file in archive) {
        String fileName = "$newDir/${file.name}";
        List<int> data = file.content;
        File(fileName)..create(recursive: true)..writeAsBytesSync(data);
      }

      await _decodeJson(newDir);
      return true;
    } catch(e) {
      showToast("File may be corrupted");
      showToast("Failed to import data");
      return false;
    }
  }

  static Future<void> _decodeJson(String rootDir) async {
    File jsonFile = File("$rootDir/data.json");
    String jsonString = jsonFile.readAsStringSync();

    var jsonObject = json.decode(jsonString);
    List<dynamic> clients = jsonObject["clients"];
    List<dynamic> transactions = jsonObject["transactions"];

    /// old_client_id: new_client_id
    Map<int, int> mapId = {};

    String filesPath = (await getApplicationDocumentsDirectory()).path;

    for (int i = 0; i < clients.length; i++) {
      int oldId = clients[i]["id"];
      String name = clients[i]["name"];
      String phone = clients[i]["phone"];
      String oldImage = clients[i]["image"];
      String newImagePath = "null";

      if (oldImage != "null") {
        String ext = oldImage.split(".").last;
        newImagePath = "$filesPath/client-$i-${DateTime.now().millisecondsSinceEpoch}.$ext";
        File("$rootDir/$oldImage").copySync(newImagePath);
      }
      int responseId = await clientTable.insertData(name, phone, newImagePath);
      mapId[oldId] = responseId;
    }

    for (int i = 0; i < transactions.length; i++) {
       int clientOldId = transactions[i]["client"];
       int year = transactions[i]["year"];
       int month = transactions[i]["month"];
       double price = transactions[i]["price"];
       double deposit = transactions[i]["deposit"];
       int plan = transactions[i]["plan"];
       int paidMonths = transactions[i]["paidmonths"];
       String comment = transactions[i]["comment"];

      int clientNewId = mapId[clientOldId]!;

      await transactionTable.insertData(clientNewId, year, month, price,
          deposit, plan, paidMonths, comment);
    }
  }
}

