import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import './Auth/Database.dart';
import './apis/encoding_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'models/video_info.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  PickedFile _imageFile;
  PickedFile videofile;
  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;
  final thumbWidth = 100;
  final thumbHeight = 150;
  String _processPhase = 'Uploading';
  int _videoDuration = 0;
  double _progress = 0.0;
  bool _processing = false;
  bool _canceled = false;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  @override
  void initState() {
    super.initState();
    EncodingProvider.enableStatisticsCallback((int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps) {
      if (_canceled) return;

      setState(() {
        _progress = time / _videoDuration;
      });
    });
  }

  void _onUploadProgress(event) {
    if (event.type == StorageTaskEventType.progress) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        // _progress = progress;
      });
    }
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final StorageReference ref =
        FirebaseStorage.instance.ref().child(folderName).child(basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    // uploadTask.events.listen(_onUploadProgress);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') _updatePlaylistUrls(file, videoName);

      setState(() {
        //_processPhase = 'Uploading video file $i out of ${files.length}';
        // _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<void> _processVideo(File rawVideoFile) async {
    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio = EncodingProvider.getAspectRatio(info);

    setState(() {
      // _processPhase = 'Generating video da';
      _videoDuration = EncodingProvider.getDuration(info);
      _progress = 10.0;
    });

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);

    setState(() {
      //_processPhase = 'Encoding video';
      _progress = 30.0;
    });

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      // _processPhase = 'Uploading video data to kudos server';
      _progress = 40.0;
    });
    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    setState(() {
      _progress = 60.0;
    });
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);
    setState(() {
      _progress = 70.0;
    });

    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
    );

    setState(() {
      //_processPhase = 'Saving video metadata to kudos server';
      _progress = 80.0;
    });

    await DatabaseService.saveVideo(videoInfo);

    setState(() {
      // _processPhase = '';
      _progress = 100.0;
      _processing = false;
    });
    if (_progress == 100.0) {
      showAlertDialog(context);
    }
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
              //value: _progress,
              ),
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase + ": $_progress%"),
          ),
        ],
      ),
    );
  }

  Future<void> _playVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      if (kIsWeb) {
        _controller = VideoPlayerController.network(file.path);
      } else {
        _controller = VideoPlayerController.file(File(file.path));
      }
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.play();
      setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      videofile = await _picker.getVideo(
        source: source,
      );

      await _playVideo(videofile);
    } else {
      await _displayPickImageDialog(context,
          (double maxWidth, double maxHeight, int quality) async {
        try {
          final pickedFile = await _picker.getImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFile = pickedFile;
            _processing = true;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Uploaded!"),
      content: Text("Video Uploaded Successfully"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an video.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _processing == true
                          ? _getProgressBar()
                          : _previewVideo();

                    default:
                      {
                        if (snapshot.hasError) {
                          return Text(
                            'Pick image/video error: ${snapshot.error}}',
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return const Text(
                            'Please Select a Video',
                            textAlign: TextAlign.center,
                          );
                        }
                      }
                  }
                },
              )
            : (_processing == true ? _getProgressBar() : _previewVideo()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _controller != null
                  ? FloatingActionButton.extended(
                      label: Text('Upload'),
                      isExtended: true,
                      elevation: 3,
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        if (isVideo == true) {
                          try {
                            setState(() {
                              _processing = true;
                            });
                            await _processVideo(File(videofile.path));
                          } catch (e) {
                            print('${e.toString()}');
                          } finally {
                            setState(() {
                              _processing = false;
                            });
                          }
                        } else {
                          Text('No Video Selected');
                        }
                      },
                      heroTag: 'videoupload',
                      tooltip: 'upload video',
                      icon: Icon(Icons.cloud_upload),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FloatingActionButton.extended(
                label: Text('Capture'),
                isExtended: true,
                elevation: 3,
                backgroundColor: Colors.red,
                onPressed: () {
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.camera);
                },
                heroTag: 'video1',
                tooltip: 'Take a Video',
                icon: Icon(Icons.videocam),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FloatingActionButton.extended(
                label: Text('Gallery'),
                elevation: 3,
                backgroundColor: Colors.red,
                onPressed: () {
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.gallery);
                },
                heroTag: 'video0',
                tooltip: 'Pick Video from gallery',
                icon: Icon(Icons.image),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxWidth if desired"),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(hintText: "Enter maxHeight if desired"),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Enter quality if desired"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    double width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    double height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    int quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
