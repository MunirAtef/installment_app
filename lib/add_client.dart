

import 'package:flutter/material.dart' ;
import 'dart:io' show Directory, File;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'shared.dart' show avatar, clientTable, phoneCheck, showToast;



class NewClient extends StatefulWidget {
  const NewClient({Key? key}) : super(key: key);

  @override
  State<NewClient> createState() => _NewClientState();
}

class _NewClientState extends State<NewClient> {
  File clientImage = File("null");
  final imagePicker = ImagePicker();


  uploadImageCamera() async {
    var pickedImage = await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
    if (pickedImage != null) {
      setState(() {
        clientImage = File(pickedImage.path);
      });
    }
  }

  uploadImageGallery() async {
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);

    if (pickedImage != null) {
      setState(() {
        clientImage = File(pickedImage.path);
      });
    }
  }


  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();

  @override
  void initState() {
    nameFocus.addListener(() {
      setState(() {});
    });
    phoneFocus.addListener(() {
      setState(() {});
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    Color? textFiledColor = Colors.grey[50];

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
              "New Client",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                    /// client picture
                    Stack(
                        clipBehavior: Clip.none,

                        children: [
                          avatar(100, clientImage.path),

                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              radius: 24,
                              child: IconButton(
                                icon: const Icon(Icons.add_a_photo, color: Colors.purple),
                                color: Colors.grey[800],
                                iconSize: 30,
                                onPressed: () {
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
                                          leading: const Icon(Icons.image, color: Colors.purple),
                                          title: const Text(
                                              "Gallery",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.purple
                                              )
                                          ),
                                          onTap: () async {
                                            uploadImageGallery();
                                            Navigator.of(context).pop();
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
                                            uploadImageCamera();
                                            Navigator.of(context).pop();
                                          },
                                        ),

                                        Visibility(
                                            visible: clientImage.path != "null",
                                            child: const Divider(thickness: 2)
                                        ),

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
                                              setState(() {
                                                clientImage = File("null");
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          visible: clientImage.path != "null",
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]
                    ),

                    const SizedBox(height: 40),

                    /// name text field
                    TextField(
                      controller: name,
                      focusNode: nameFocus,
                      maxLength: 15,
                      style: Theme.of(context).textTheme.headline6,
                      cursorColor: Colors.purple,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: nameFocus.hasFocus? Colors.purple : Colors.grey,
                          ),
                          labelText: "Name",
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

                    const SizedBox(height: 10),

                    /// phone text field
                    TextField(
                      controller: phoneNumber,
                      focusNode: phoneFocus,
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.headline6,
                      cursorColor: Colors.purple,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
                            color: phoneFocus.hasFocus? Colors.purple : Colors.grey,
                          ),
                          labelText: "Phone Number",
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
                  ],
                ),
              ),


              ElevatedButton(
                onPressed: () async {
                  String _name = name.text;
                  int lenFirst = _name.length;
                  int lenPhone = phoneNumber.text.length;

                  //check if there is empty fields or not
                  if (lenFirst == 0 || lenPhone == 0) {
                    showToast("Some fields empty");
                    return;
                  }

                  /// name validation
                  if (lenFirst > 15) {
                    showToast("Name exceed 15 chars");
                    return;
                  }

                  if (!phoneCheck(phoneNumber.text)) {
                    showToast("Invalid Number entered");
                    return;
                  }

                  String fullPath = "null";
                  if (clientImage.path != "null") {
                    Directory appPath = await getApplicationDocumentsDirectory();
                    String ext = clientImage.path.split(".").last;
                    String _name = "client-${DateTime.now().millisecondsSinceEpoch}.$ext";

                    fullPath = "${appPath.path}/$_name";
                    await clientImage.copy(fullPath);
                  }

                  int response = await clientTable.insertData(_name, phoneNumber.text, fullPath);
                  if (response != 0) {
                    showToast("Client $_name added successfully");
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/mainPage");
                  }
                  else {
                    showToast("Failed to add client");
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
                        "ADD CLIENT",
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

