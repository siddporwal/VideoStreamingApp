import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/video_info.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference kudos =
      Firestore.instance.collection('collectionName');

  Future updateUserData(String username, String fullname) async {
    return await kudos.document(uid).setData({
      'userName': username,
      'fullName': fullname,
    });
  }

  static updatePersonalData(String fname) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return await Firestore.instance
        .collection('collectionName')
        .document(uid)
        .updateData({
      'fullName': fname,
    });
  }

  static saveVideo(VideoInfo video) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    await Firestore.instance
        .collection('collectionName')
        .document(uid)
        .setData({
      'videoUrl': FieldValue.arrayUnion([video.videoUrl]),
      'thumbUrl': FieldValue.arrayUnion([video.thumbUrl]),
      'coverUrl': FieldValue.arrayUnion([video.coverUrl]),
      'aspectRatio': video.aspectRatio,
      'uploadedAt': FieldValue.arrayUnion([video.uploadedAt]),
      'videoName': FieldValue.arrayUnion([video.videoName]),
    }, merge: true).then((value) async {
      await Firestore.instance
          .collection('public')
          .document('videos-detail')
          .setData({
        'videoUrl': FieldValue.arrayUnion([video.videoUrl]),
        'thumbUrl': FieldValue.arrayUnion([video.thumbUrl]),
        'coverUrl': FieldValue.arrayUnion([video.coverUrl]),
      }, merge: true);
    });
  }
}
