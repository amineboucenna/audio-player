import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'styles.dart';

class PlaylistTracks extends StatefulWidget {
  final List<File> audioFiles;
  final String playlistName;

  PlaylistTracks({required this.audioFiles, required this.playlistName});

  @override
  _PlaylistTracksState createState() => _PlaylistTracksState();
}

class _PlaylistTracksState extends State<PlaylistTracks> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose(); // Properly dispose of the AudioPlayer
    super.dispose();
  }

  Future<Metadata> _getMetadata(File file) async {
    return await MetadataRetriever.fromFile(File(file.path));
  }

  Future<String> _getDuration(File file) async {
    await _audioPlayer.setUrl(file.path);
    final duration = _audioPlayer.duration;
    return _formatDuration(duration);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) {
      return '0:00';
    }
    String hours = (duration.inHours).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if(hours == '00') {
      return '$minutes:$seconds';
    }
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background, // Matches the background color
          elevation: 0, // Removes the shadow
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      "PLAYLIST",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      widget.playlistName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.audioFiles.length,
                itemBuilder: (context, index) {
                  final file = widget.audioFiles[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/player',
                          arguments: {
                            'audioFiles': widget.audioFiles,
                            'playlistName': widget.playlistName,
                            'initialIndex': index,
                          },
                        );
                      },
                      child: Row(
                        children: [
                          FutureBuilder<Metadata>(
                            future: _getMetadata(file),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return CircularProgressIndicator(
                                    color: AppColors.gold);
                              } else if (snapshot.hasError) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: AssetImage('images/cover.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                final metadata = snapshot.data;
                                Uint8List? albumArt = metadata?.albumArt;
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: albumArt != null
                                        ? DecorationImage(
                                            image: MemoryImage(albumArt),
                                            fit: BoxFit.cover,
                                          )
                                        : DecorationImage(
                                            image:
                                                AssetImage('images/cover.png'),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.path.split('/').last,
                                  style: TextStyle(color: AppColors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                FutureBuilder<String>(
                                  future: _getDuration(file),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.none) {
                                      return CircularProgressIndicator(
                                          color: AppColors.gold);
                                    } else if (snapshot.hasError) {
                                      return Text(snapshot.data ?? '0:00',
                                          style: TextStyle(
                                              color: AppColors.white));
                                    } else {
                                      return Text(
                                        snapshot.data ?? '0:00',
                                        style:
                                            TextStyle(color: AppColors.white),
                                      );
                                    }
                                  },
                                ),
                              ],
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
        backgroundColor: AppColors.background,
      ),
    );
  }
}
