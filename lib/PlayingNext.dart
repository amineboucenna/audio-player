import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'styles.dart'; // Import the styles class for colors

class PlayingNext extends StatelessWidget {
  final List<File> audioFiles;
  final String playlistName;

  PlayingNext({required this.audioFiles, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background, // Same color as the background
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Text(
          playlistName,
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playing Section
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "PLAYING",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.01), // Padding between "PLAYING" and the currently playing item

                  // Currently playing item (audio file name and image)
                  Row(
                    children: [
                      FutureBuilder<Metadata>(
                        future: _getMetadata(audioFiles[0]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(
                                color: AppColors.gold);
                          } else if (snapshot.hasError) {
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              decoration: BoxDecoration(
                                color: AppColors.darker,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            );
                          } else {
                            final metadata = snapshot.data;
                            Uint8List? albumArt = metadata?.albumArt;
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              decoration: BoxDecoration(
                                color: AppColors.darker,
                                borderRadius: BorderRadius.circular(15),
                                image: albumArt != null
                                    ? DecorationImage(
                                        image: MemoryImage(albumArt),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Expanded(
                        child: Text(
                          audioFiles[0].path.split('/').last,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.01), // Padding before "NEXT"

            // Next Section
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NEXT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.01), // Padding between "NEXT" and the next items

                  // Next items (list of audio files except the currently playing one)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: audioFiles.length > 1
                        ? audioFiles.length - 1
                        : 0, // Exclude the current item
                    itemBuilder: (context, index) {
                      final file = audioFiles[index + 1]; // Skip the first item
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.01,
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/player',
                              arguments: {
                                'audioFiles': audioFiles,
                                'playlistName': playlistName,
                                'initialIndex':
                                    index + 1, // Start from the next item
                              },
                            );
                          },
                          child: Row(
                            children: [
                              FutureBuilder<Metadata>(
                                future: _getMetadata(file),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator(
                                        color: AppColors.gold);
                                  } else if (snapshot.hasError) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'images/cover.png'), // Fallback image in case of error
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final metadata = snapshot.data;
                                    Uint8List? albumArt = metadata?.albumArt;
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: albumArt != null
                                            ? DecorationImage(
                                                image: MemoryImage(albumArt),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: AssetImage(
                                                    'images/cover.png'), // Default image if no album art
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Expanded(
                                child: Text(
                                  file.path.split('/').last,
                                  style: TextStyle(color: AppColors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }

  Future<Metadata> _getMetadata(File file) async {
    final metadata = await MetadataRetriever.fromFile(File(file.path));
    return metadata;
  }
}
