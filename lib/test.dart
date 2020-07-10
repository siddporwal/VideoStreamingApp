import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import './widgets/player.dart';

class LoadDataFromFirestore extends StatefulWidget {
  @override
  _LoadDataFromFirestoreState createState() => _LoadDataFromFirestoreState();
}

class _LoadDataFromFirestoreState extends State<LoadDataFromFirestore> {
  var frameit;
  @override
  void initState() {
    super.initState();
    getDriversList().then((results) {
      setState(() {
        querySnapshot = results;
        frameit = querySnapshot.documents[0].data['videoUrl'].length;
        print(querySnapshot.documents[0].data['videoUrl'].length);
      });
    });
  }

  QuerySnapshot querySnapshot;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showDrivers(),
    );
  }

  //build widget as prefered
  //i'll be using a listview.builder
  Widget _showDrivers() {
    //check if querysnapshot is null
    if (frameit == null) {
      return Center(
          child: CircularProgressIndicator() //Text("No videos Available!"),
          );
    } else {
      if (querySnapshot != null) {
        return StaggeredGridView.countBuilder(
          primary: false,
          crossAxisCount: 4,
          itemCount: frameit,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Player(
                        video: querySnapshot.documents[0].data['videoUrl']
                            [index]);
                  },
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.network(
                querySnapshot.documents[0].data['thumbUrl'][index],
                fit: BoxFit.cover,
                height: 50,
              ),
            ),
          ),
          staggeredTileBuilder: (int index) =>
              new StaggeredTile.count(2, index.isEven ? 3 : 2),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  //get firestore instance
  getDriversList() async {
    return await Firestore.instance.collection('public').getDocuments();
  }
}
