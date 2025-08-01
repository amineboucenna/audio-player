import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'styles.dart'; // Import the styles class for colors

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FolderScreen(),
      },
    );
  }
}

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Map<String, dynamic>> folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  Future<void> loadFolders() async {
    if (await _requestStoragePermission()) {
      List<Map<String, dynamic>> folderList = [];
      Directory rootDir = Directory('/storage/emulated/0');

      if (await rootDir.exists()) {
        _scanDirectory(rootDir, folderList);
      }

      // Sort folders by creation date in descending order
      folderList.sort((a, b) {
        DateTime aDate = FileStat.statSync(a["path"]).modified;
        DateTime bDate = FileStat.statSync(b["path"]).modified;
        return bDate.compareTo(aDate);
      });

      setState(() {
        folders = folderList;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _scanDirectory(
      Directory directory, List<Map<String, dynamic>> folderList) {
    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is Directory && !_isExcludedFolder(entity.path)) {
        List<FileSystemEntity> files = entity.listSync();
        List<File> audioFiles = files
            .where((file) =>
                file.path.endsWith(".mp3") ||
                file.path.endsWith(".wav") ||
                file.path.endsWith(".flac") ||
                file.path.endsWith(".aac"))
            .map((file) => File(file.path))
            .toList();

        if (audioFiles.isNotEmpty) {
          folderList.add({
            "name": entity.path.split('/').last,
            "audioFiles": audioFiles,
            "path": entity.path, // Add the path for sorting
          });
        }

        // Recursively scan subdirectories
        _scanDirectory(entity, folderList);
      }
    }
  }

  bool _isExcludedFolder(String path) {
    List<String> excludedFolders = ['DCIM', 'Pictures', 'Android'];
    return excludedFolders.any((folder) => path.contains('/$folder/'));
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.isPermanentlyDenied) {
        openAppSettings();
        return false;
      } else {
        var status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick Up a Playlist"),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.gold))
          : folders.isEmpty
              ? Center(
                  child: Text(
                    "No folders found",
                    style: TextStyle(color: AppColors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height *
                            0.01, // Dynamic vertical padding
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width *
                              0.05, // Dynamic horizontal padding
                        ),
                        title: Text(
                          folder["name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        trailing: Text(
                          '${folder["audioFiles"].length} Items', // Display items on the right
                          style: TextStyle(color: AppColors.white),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/playlistTracks',
                            arguments: {
                              'audioFiles': folder["audioFiles"],
                              'playlistName': folder["name"],
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
      backgroundColor: AppColors.background,
    );
  }
}
