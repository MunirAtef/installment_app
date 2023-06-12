
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';


class FilePickerAccess {
  static String extension = "zip";

  static Color? fileWidgetColor = Colors.grey[900];
  static Color folderColor = Colors.purple;

  static String pickedFileSystem = "null";


  static Future<String> pickFile(BuildContext context) async {
    pickedFileSystem = "null";
    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            double _width = MediaQuery.of(context).size.width;

            return AlertDialog(
              content: FilePicker(_width),
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.symmetric(vertical: 70),
              clipBehavior: Clip.antiAliasWithSaveLayer,
            );
          }
        )
    );

    return pickedFileSystem;
  }

  static void clearTempDir() async {
    Directory dir = await getTemporaryDirectory();
    dir.deleteSync(recursive: true);
    dir.createSync();
  }
}


class FilePicker extends StatefulWidget {
  final double _width;
  const FilePicker(this._width, {Key? key}) : super(key: key);

  @override
  State<FilePicker> createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePicker> {
  String currentPath = "null";
  String rootPath = "null";
  bool inHome = true;
  bool sortByName = true;  /// true by name, false by last modified


  Widget folderWidget(String folderName) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: widget._width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Icon(Icons.folder, size: 40, color: Colors.amber[600]),
                const SizedBox(width: 5),

                SizedBox(
                  width: widget._width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      folderName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          setState(() {
            currentPath += "/$folderName";
            inHome = false;
          });
        },
      ),
    );
  }

  Widget fileWidget(String fileName) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(2,2,2,0),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: widget._width - 5,
          height: 50,
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),

                // FileIcon(fileName, size: 40),
                Icon(Icons.insert_drive_file, size: 40, color: Colors.purple[400]),

                const SizedBox(width: 5),

                SizedBox(
                  width: widget._width - 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          FilePickerAccess.pickedFileSystem = currentPath + "/" + fileName;
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<Widget> listFolder() async {
    if (currentPath == "null") {
      String _rootPath = (await ExternalPath.getExternalStorageDirectories())[0];
      currentPath = _rootPath;
      rootPath = _rootPath;
    }
    Directory _dir = Directory(currentPath);

    List<FileSystemEntity> entities;

    if (sortByName) {
      /// sorting by name
      entities = _dir.listSync()
        ..sort((l, r) => l.path.toLowerCase().compareTo(r.path.toLowerCase()));
    } else {
      /// sorting by last modified
      entities = _dir.listSync()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
    }

    Iterable<Directory> folders = entities.whereType<Directory>();
    Iterable<File> files = entities.whereType<File>();

    List<Widget> body = [];

    for (Directory folder in folders) {
      body.add(folderWidget(folder.path.split("/").last));
    }

    for (File file in files) {
      if (file.path.split(".").last == FilePickerAccess.extension) {
        body.add(fileWidget(file.path.split("/").last));
      }
    }

    List<String> selectedPath = currentPath != rootPath ? currentPath
        .substring(rootPath.length + 1, currentPath.length).split("/") : [];
    selectedPath.insert(0, "Internal storage");

    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView(
        children: body,
      ),

      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,

        title: SizedBox(
          height: 50,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [

                for (int i = 0; i < selectedPath.length - 1; i++)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (i == 0) {
                              setState(() {
                                currentPath = rootPath;
                                inHome = true;
                              });
                              return;
                            }
                            String extraPath = selectedPath.sublist(1, i + 1).join("/");
                            setState(() {
                              currentPath = rootPath + "/" + extraPath;
                            });
                          },
                          child: Text(selectedPath[i], style: TextStyle(
                              fontSize: 15, color: Colors.grey[300]))),

                      Icon(Icons.arrow_right, size: 20, color: Colors.grey[300])
                    ],
                  ),

                Text(selectedPath.last, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),

                const SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),

        title: Text(
          "Pick ${FilePickerAccess.extension} file",
          style: GoogleFonts.bebasNeue(
            color: Colors.white
          )
        ),

        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.sort, size: 20, color: Colors.purple),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    enabled: !sortByName,
                    child: const Text("Sort by name"),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple
                    ),
                    onTap: () {
                      setState(() {
                        sortByName = true;
                      });
                    },
                  ),

                  PopupMenuItem(
                    enabled: sortByName,
                    child: const Text("Sort by last modified"),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple
                    ),
                    onTap: () {
                      setState(() {
                        sortByName = false;
                      });
                    },
                  ),
                ];
              }
          ),

          Visibility(
              visible: !inHome,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20, color: Colors.purple),

                onPressed: () {
                  setState(() {
                    currentPath = Directory(currentPath).parent.path;
                    inHome = currentPath == rootPath;
                  });
                },
              )
          ),
        ],
      ),

      body: SizedBox(
        width: double.infinity,
        child: FutureBuilder<Widget>(
            future: listFolder(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 100),
                        CircularProgressIndicator(color: Colors.purple),
                      ],
                    )
                );
              }

              return snapshot.data!;
            }
        ),
      ),
    );
  }
}

